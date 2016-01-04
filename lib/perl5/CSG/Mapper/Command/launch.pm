## no critic (NamingConventions::Capitalization, Subroutines::RequireFinalReturn)
package CSG::Mapper::Command::launch;

use CSG::Mapper -command;
use CSG::Base qw(file templates);
use CSG::Constants qw(:basic :mapping);
use CSG::Mapper::Config;
use CSG::Mapper::DB;
use CSG::Mapper::Job;
use CSG::Mapper::Logger;
use CSG::Mapper::Sample;

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

  my $debug   = $self->app->global_options->{debug};
  my $verbose = $self->app->global_options->{verbose};
  my $cluster = $self->app->global_options->{cluster};
  my $project = $self->app->global_options->{project};

  my $jobs   = 0;
  my $delay  = int(rand($MAX_DELAY));
  my $schema = $self->{stash}->{schema};
  my $config = $self->{stash}->{config};

  my $project_dir = qq{$FindBin::Bin/../};
  my $prefix      = $config->get($cluster, 'prefix');
  my $workdir     = $config->get($project, 'workdir');

  my $procs    = $opts->{procs}    // $config->get($project, 'procs');
  my $memory   = $opts->{memory}   // $config->get($project, 'memory');
  my $walltime = $opts->{walltime} // $config->get($project, 'walltime');
  my $build    = $opts->{build}    // $config->get($project, 'ref_build');
  my $tmp_dir  = $opts->{tmp_dir}  // q{/tmp};

  for my $sample ($schema->resultset('Sample')->search({state => $SAMPLE_STATE{requested}})) {
    last if $opts->{limit} and ++$jobs > $opts->{limit};

    my $job_meta = $sample->add_to_jobs(
      {
        cluster  => $cluster,
        procs    => $procs,
        memory   => $memory,
        walltime => $walltime,
        delay    => $delay,
      }
    );

    my $sample_obj = CSG::Mapper::Sample->new(cluster => $cluster, record => $sample, build => $build);
    my $logger = CSG::Mapper::Logger->new(job_id => $job_meta->id);

    my $basedir = File::Spec->join($prefix, $workdir);
    $logger->debug("basedir: $basedir") if $debug;
    unless (-e $basedir) {
      make_path($basedir);
      $logger->debug('created basedir') if $debug;
    }

    my $log_dir = File::Spec->join($basedir, $config->get($project, 'log_dir'), $sample_obj->center, $sample_obj->pi, $sample_obj->sample_id);
    unless (-e $log_dir) {
      make_path($log_dir);
      $logger->debug('created log_dir') if $debug;
    }

    my $run_dir = File::Spec->join($basedir, $config->get($project, 'run_dir'));
    unless (-e $run_dir) {
      make_path($run_dir);
      $logger->debug('created run_dir') if $debug;
    }

    my $gotcloud_conf = File::Spec->join($project_dir, $config->get($cluster, 'gotcloud_conf') . qq{.hg$build});
    $logger->debug("gotcloud conf: $gotcloud_conf") if $debug;
    unless (-e $gotcloud_conf) {
      croak qq{Unable to locate GOTCLOUD_CONF [$gotcloud_conf]};
    }

    my $gotcloud_root = File::Spec->join($basedir, $config->get($cluster, 'gotcloud_root'));
    $logger->debug("gotcloud root: $gotcloud_root") if $debug;
    unless (-e $gotcloud_root) {
      croak qq{GOTCLOUD_ROOT [$gotcloud_root] does not exist!};
    }

    my $gotcloud_ref = File::Spec->join($prefix, $config->get('gotcloud', qq{build${build}_ref_dir}));
    $logger->debug("gotcloud ref_dir: $gotcloud_ref") if $debug;
    unless (-e $gotcloud_ref) {
      croak qq{GOTCLOUD_REF_DIR [$gotcloud_ref] does not exist!};
    }

    my $job_file = File::Spec->join($run_dir, $sample_obj->sample_id . qq{.$cluster.sh});
    my $tt = Template->new(INCLUDE_PATH => qq($project_dir/templates/batch/$project));

    $tt->process(
      qq{$cluster.sh.tt2}, {
        job => {
          procs    => $procs,
          memory   => $memory,
          walltime => $walltime,
          build    => $build,
          email    => $config->get($project, 'email'),
          job_name => $project . $DASH . $sample_obj->sample_id,
          account  => $config->get($cluster, 'account'),
          workdir  => $log_dir,
        },
        settings => {
          tmp_dir         => File::Spec->join($tmp_dir,                 $project),
          job_log         => File::Spec->join($sample_obj->result_path, q{job.yml}),
          pipeline        => $config->get('pipelines',                  $sample_obj->center),
          max_failed_runs => $config->get($project,                     'max_failed_runs'),
          out_dir         => $sample_obj->result_path,
          run_dir         => $run_dir,
          project_dir     => $project_dir,
          delay           => $delay,
          threads         => $procs,
          meta_id         => $job_meta->id,
          mapper_cmd      => $PROGRAM_NAME,
        },
        gotcloud => {
          root    => $gotcloud_root,
          conf    => $gotcloud_conf,
          ref_dir => $gotcloud_ref,
          cmd     => File::Spec->join($gotcloud_root, 'gotcloud'),
        },
        sample => $sample_obj,
      },
      $job_file
      )
      or croak $Template::ERROR;

    $logger->info("wrote batch file to $job_file") if $verbose or $debug;

    unless ($self->app->global_options->{dry_run}) {
      my $job = CSG::Mapper::Job->new(cluster => $cluster);

      $logger->debug("submitting batch file $job_file") if $debug;

      try {
        $job->submit($job_file);
      }
      catch {
        if (not ref $_) {
          $logger->critical('Uncaught exception');
          $logger->debug($_) if $debug;

        } elsif ($_->isa('CSG::Mapper::Execption::Job::BatchFileNotFound')) {
          $logger->error($_->description);

        } elsif ($_->isa('CSG::Mapper::Exception::Job::BatchFileNotReadable')) {
          $logger->error($_->description);

        } elsif ($_->isa('CSG::Mapper::Exception::Job::SubmissionFailure')) {
          $logger->error($_->description);

        } elsif ($_->isa('CSG::Mapper::Exception::Job::ProcessOutput')) {
          $logger->error($_->description);
          $logger->debug($_->output) if $debug;

        } else {
          if ($_->isa('Exception::Class')) {
            chomp(my $error = $_->error);
            $logger->critical($error);
          } else {
            $logger->critical('something went sideways');
            print STDERR Dumper $_ if $debug;
          }
        }
      }
      finally {
        unless (@_) {
          $logger->info('submitted job (' . $job->job_id . ') for sample ' . $sample_obj->sample_id) if $verbose;

          $sample->update({state => $SAMPLE_STATE{submitted}});
          $job_meta->update(
            {
              job_id       => $job->job_id(),
              submitted_at => $schema->now(),
            }
          );
        }
      };
    }
  }
}

1;

__END__

=head1

CSG::Mapper::Command::launch - Launch remapping jobs
