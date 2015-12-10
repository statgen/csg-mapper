package CSG::Mapper::Command::launch;

# TODO - need logging
#      - add dry-run support
#      - add support to output the batch script but not submit
#      - add logging
#      - try/catch on job submission
#      - handle memory format differences

use CSG::Mapper -command;

use CSG::Base qw(file templates);
use CSG::Constants qw(:basic :mapping);
use CSG::Mapper::Config;
use CSG::Mapper::DB;
use CSG::Mapper::Job;

sub opt_spec {
  return (
    ['limit|l=i',    'Limit number of jobs to submit'],
    ['procs|p=i',    'Number of cores to request'],
    ['memory|m=i',   'Amount of memory to request, in MB'],
    ['walltime|w=i', 'Amount of wallclock time for this job'],
    ['build|b=i',    'Reference build to use (ie; 37 or 38)'],
    ['tmp-dir|t=s',  'Local temporary disk locaiton (defaults to /tmp)'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $schema = CSG::Mapper::DB->new();
  my $config = CSG::Mapper::Config->new();

  $self->{stash}->{schema} = $schema;
  $self->{stash}->{config} = $config;

  if ($self->app->global_options->{cluster}) {
    unless ($self->app->global_options->{cluster} =~ /$VALID_CLUSTER_REGEXPS/) {
      $self->usage_error('Invalid cluster environment');
    }
  } else {
    $self->usage_error('Cluster environment is required');
  }

  unless ($self->app->global_options->{project}) {
    $self->usage_error('Project is required');
  } else {
    unless ($config->has_category($self->app->global_options->{project})) {
      $self->usage_error('Unknown project');
    }
  }

  if ($opts->{'tmp-dir'}) {
    unless (-e $opts->{'tmp-dir'} and -r $opts->{'tmp-dir'}) {
      $self->usage_error('Temporary disk space does not exist or is not writable');
    }
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $jobs   = 0;
  my $delay  = int(rand(120));
  my $schema = $self->{stash}->{schema};
  my $config = $self->{stash}->{config};

  my $cluster = $self->app->global_options->{cluster};
  my $project = $self->app->global_options->{project};

  my $project_dir = qq{$FindBin::Bin/../};
  my $prefix      = $config->get($cluster, 'prefix');
  my $workdir     = $config->get($project, 'workdir');

  my $procs    = $opts->{procs}    // $config->get($project, 'procs');
  my $memory   = $opts->{memory}   // $config->get($project, 'memory_per_core');
  my $walltime = $opts->{walltime} // $config->get($project, 'walltime');
  my $build    = $opts->{build}    // $config->get($project, 'ref_build');
  my $tmp_dir = $opts->{'tmp-dir'} // q{/tmp};

  for my $sample ($schema->resultset('Sample')->search({state => $SAMPLE_STATE{requested}})) {
    last if $opts->{limit} and ++$jobs > $opts->{limit};

    # XXX - this can't always be the project node
    my $basedir = File::Spec->join($prefix, $project, $workdir);
    unless (-e $basedir) {
      make_path($basedir);
    }

    my $log_dir = File::Spec->join($basedir, $config->get($project, 'log_dir'), $sample->center->name, $sample->pi->name, $sample->sample_id);
    unless (-e $log_dir) {
      make_path($log_dir);
    }

    my $run_dir = File::Spec->join($basedir, $config->get($project, 'run_dir'));
    unless (-e $run_dir) {
      make_path($run_dir);
    }

    my $gotcloud_conf = File::Spec->join($project_dir, $config->get($cluster, 'gotcloud_conf'));
    unless (-e $gotcloud_conf) {
      die qq{Unable to locate GOTCLOUD_CONF [$gotcloud_conf]};
    }

    my $gotcloud_root = File::Spec->join($basedir, $config->get($cluster, 'gotcloud_root'));
    unless (-e $gotcloud_root) {
      die qq{GOTCLOUD_ROOT [$gotcloud_root] does not exist!};
    }

    my $gotcloud_ref = File::Spec->join($prefix, $config->get('gotcloud', qq{build${build}_ref_dir}));
    unless (-e $gotcloud_ref) {
      die qq{GOTCLOUD_REF_DIR [$gotcloud_ref] does not exist!};
    }

    my $job_meta = $sample->add_to_jobs(
      {
        cluster  => $cluster,
        procs    => $procs,
        memory   => $memory,
        walltime => $walltime,
        delay    => $delay,
      }
    );

    my $results_dir = File::Spec->join($basedir, $config->get($project, 'results_dir'), $sample->center->name, $sample->pi->name, $sample->sample_id);
    my $job_file = File::Spec->join($run_dir, $sample->sample_id . qq{.$cluster.sh});
    my $tt = Template->new(INCLUDE_PATH => qq($project_dir/templates/batch/$project));
    $tt->process(
      qq{$cluster.sh.tt2}, {
        job => {
          procs    => $procs,
          memory   => $memory,
          walltime => $walltime,
          build    => $build,
          email    => $config->get($project, 'email'),
          job_name => $project . q{-} . $sample->sample_id,
          account  => $config->get($cluster, 'account'),
          workdir  => $log_dir,
        },
        settings => {
          tmp_dir         => File::Spec->join($tmp_dir,     $project),
          job_log         => File::Spec->join($results_dir, q{job.log}),
          pipeline        => $config->get('pipelines',      $sample->center->name),
          max_failed_runs => $config->get($project,         'max_failed_runs'),
          out_dir         => $results_dir,
          run_dir         => $run_dir,
          project_dir     => $project_dir,
          delay           => $delay,
          threads         => $procs,
          meta_id         => $job_meta->id,
          mapper_cmd      => $0,
        },
        gotcloud => {
          root    => $gotcloud_root,
          conf    => $gotcloud_conf,
          ref_dir => $gotcloud_ref,
          cmd     => File::Spec->join($gotcloud_root, 'bin', 'gotcloud'),
        },
        sample => $sample,
      },
      $job_file
      )
      or die $Template::ERROR;

    my $job = CSG::Mapper::Job->new(cluster => $cluster);
    $job->submit($job_file);

    $sample->update(
      {
        state => $SAMPLE_STATE{submitted},
      }
    );

    $job_meta->update(
      {
        job_id       => 42,
        submitted_at => DateTime->now(),
      }
    );
  }
}

1;

__END__

=head1

CSG::Mapper::Command::launch - Launch remapping jobs
