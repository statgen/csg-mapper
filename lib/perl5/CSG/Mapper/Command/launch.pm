package CSG::Mapper::Command::launch;

# TODO - need logging
# TODO - add dry-run support
# TODO - add support to output the batch script but not submit

use CSG::Mapper -command;

use CSG::Base;
use CSG::Constants qw(:basic :mapping);
use CSG::Mapper::Config;
use CSG::Mapper::DB;

sub opt_spec {
  return (
    ['limit|l=i',    'Limit number of jobs to submit'],
    ['procs|p=i',    'Number of cores to request'],
    ['memory|m=i',   'Amount of memory to request, in MB'],
    ['walltime|w=i', 'Amount of wallclock time for this job'],
    ['build|b=i',    'Reference build to use (ie; 37 or 38)'],
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
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $jobs   = 0;
  my $delay  = int(rand(120));
  my $schema = $self->{stash}->{schema};
  my $config = $self->{stash}->{config};

  my $cluster     = $self->app->global_options->{cluster};
  my $project     = $self->app->global_options->{project};
  my $project_dir = qq{$FindBin::Bin/../};

  my $procs    = $opts->{procs}    // $config->get($project, 'procs');
  my $memory   = $opts->{memory}   // $config->get($project, 'memory');
  my $walltime = $opts->{walltime} // $config->get($project, 'walltime');
  my $build    = $opts->{build}    // $config->get($project, 'ref_build');

  for my $sample ($schema->resultset('Sample')->search({state => $SAMPLE_STATE{requested}})) {
    last if $opts->{limit} and ++$jobs > $opts->{limit};

    my $bam = CSG::Mapper::Bam->new(
      cluster => $self->app->global_options->{cluster},
      center  => $sample->center,
      name    => $sample->filename,
      pi      => $sample->pi,
      rundir  => $sample->run_dir,
    );

    my $fh = File::Temp->new(UNLINK => 0);    # TODO - use the sample id to create a the batch file in the run_dir or workdir
    my $tt = Template->new(INCLUDE_PATH => qq($FindBin::Bin/../templates));
    my $job = CSG::Mapper::Job->new(cluster => $opts->{cluster});

    my $basedir = File::Spec->join($config->get($cluster, 'prefix'), $bam->host, 'mapping');
    unless (-e $basedir) {
      make_path($basedir);                    # TODO - add logging
    }

    my $log_dir = File::Spec->join($basedir, $config->get($project_dir, 'workdir'), $bam->sample_id);
    unless (-e $log_dir) {
      make_path($log_dir);                    # TODO - add logging
    }

    my $run_dir = File::Spec->join($basedir, $config->get($project_dir, 'run_dir'));
    unless (-e $run_dir) {
      make_path($run_dir);                    # TODO - add logging
    }

    my $gotcloud_conf = File::Spec->join($project_dir, $config->get($cluster, 'gotcloud_conf'));
    unless (-e $gotcloud_conf) {
      die qq{Unable to locate GOTCLOUD_CONF [$gotcloud_conf]};    # TODO - add logging
    }

    my $gotcloud_root = File::Spec->join($project_dir, $config->get($cluster, 'gotcloud_root'));
    unless (-e $gotcloud_root) {
      die qq{GOTCLOUD_ROOT [$gotcloud_root] does not exist!};     # TODO - add logging
    }

    my $gotcloud_ref = $config->get('gotcloud', qq{build${build}_ref_dir});
    unless (-e $gotcloud_ref) {
      die qq{GOTCLOUD_REF_DIR [$gotcloud_ref] does not exist!};    # TODO - add logging
    }

    my $job_meta = $sample->add_to_jobs(
      {
        cluster  => $opts->{cluster},
        procs    => $procs,
        memory   => $memory,
        walltime => $walltime,
        delay    => $delay,
      }
    );

    $tt->process(
      "batch/$opts->{cluster}.tt2", {
        job => {
          procs    => $procs,
          memory   => $memory,                                      # XXX - different formats for diff clusters
          walltime => $walltime,
          build    => $build,
          email    => $config->get($project, 'email'),
          job_name => $opts->{project} . $DASH . $bam->sample_id,
          account  => $config->get($cluster, 'account'),
          workdir  => $log_dir,
        },
        settings => {
          tmp_dir         => File::Spec->join('/tmp',            $opts->{project}),
          run_dir         => $run_dir,
          job_log         => File::Spec->join($bam->results_dir, q{job_log}),
          project_dir     => $project_dir,
          pipeline        => $config->get('pipelines',           $bam->center),
          delay           => $delay,
          threads         => $procs,
          max_failed_runs => $config->get($project,              'max_failed_runs'),
          job_id          => $job_meta->id,
        },
        gotcloud => {
          root    => $gotcloud_root,
          conf    => $gotcloud_conf,
          ref_dir => $gotcloud_ref,
        },
        bam => $bam,
      },
      $fh->filename,
    );

    # XXX - this might throw an exception? not yet but maybe if it fails to submit the job?
    $job->submit($fh->filename);

    $sample->update(
      state        => $SAMPLE_STATE{submitted},
      submitted_at => DateTime->now(),
    );

    say $fh->filename;
  }
}

1;

__END__

=head1

CSG::Mapper::Command::launch - Launch remapping jobs
