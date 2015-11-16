package CSG::Mapper::Command::launch;

# TODO - need logging
# TODO - add dry-run support
# TODO - add support to output the batch script but not submit

use CSG::Mapper -command;

use CSG::Base;
use CSG::Constants qw(:mapping);
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
  $self->{stash}->{schema} = $schema;

  if ($self->app->global_options->{cluster}) {
    unless ($self->app->global_options->{cluster} =~ /$VALID_CLUSTER_REGEXPS/) {
      $self->usage_error('Invalid cluster environment');
    }
  } else {
    $self->usage_error('Cluster environment is required');
  }

  unless ($self->app->global_options->{project}) {
    $self->usage_error('Project is required');
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $jobs   = 0;
  my $config = CSG::Mapper::Config->new();
  my $schema = $self->{stash}->{schema};

  my $procs    = $opts->{procs}    // $config->get($opts->{project}, 'procs');
  my $memory   = $opts->{memory}   // $config->get($opts->{project}, 'memory');
  my $walltime = $opts->{walltime} // $config->get($opts->{project}, 'walltime');
  my $build    = $opts->{build}    // $config->get($opts->{project}, 'ref_build');

  for my $sample ($schema->resultset('Sample')->search({state => $SAMPLE_STATE{requested}})) {
    last if $opts->{limit} and ++$jobs > $opts->{limit};

    my $bam = CSG::Mapper::Bam->new(
      cluster => $self->app->global_options->{cluster},
      id      => $sample->id,
      center  => $sample->center,
      name    => $sample->filename,
      pi      => $sample->pi,
      rundir  => $sample->run_dir,
    );

    my $fh = File::Temp->new();
    my $tt = Template->new(INCLUDE_PATH => qq($Bin/../templates));

    $tt->process(
      "batch/$opts->{cluster}.tt2", {
        settings => {
          threads  => $procs,
          memory   => $memory,                                               # XXX - different formats for diff clusters
          walltime => $walltime,
          build    => $build,
          tmp_dir  => File::Spec->join($config->get('', '')),                # XXX
          run_dir  => File::Spec->join(),                                    # XXX
          job_name => sprintf '%s-%s', $opts->{project}, $bam->sample_id,    # XXX
          email           => $config->get($opts->{project}, 'email'),
          workdir         => File::Spec->join(),            # XXX
          account         => $config->get($opts->{cluster}, 'account'),
          project_dir     => File::Spec->join(),            # XXX
          max_failed_runs => $config->get($opts->{project}, 'max_failed_runs'),
          pipeline        => $config->get($opts->{project}, 'pipeline'),          # XXX
        },
        gotcloud => {
          root    => File::Spec->join(),                                          # XXX
          conf    => File::Spec->join(),                                          # XXX
          ref_dir => File::Spec->join(),                                          # XXX
        },
        bam => $bam,
      }
    );

    my $batch = build_batch_script_template();
    my $job = CSG::Mapper::Job->new(cluster => $opts->{cluster});

    # XXX - this might throw an exception? not yet but maybe if it fails to submit the job?
    $job->submit($batch);

    $sample->update(state => $SAMPLE_STATE{submitted});

    $sample->add_to_jobs(
      {
        sample_id    => $bam->sample_id,
        job_id       => $job->job_id,
        cluster      => $opts->{cluster},
        procs        => $procs,
        memory       => $memory,
        walltime     => $walltime,
        submitted_at => DateTime->now(),
      }
    );
  }
}

1;

__END__

=head1

CSG::Mapper::Command::launch - Launch remapping jobs
