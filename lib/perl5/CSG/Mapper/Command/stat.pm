package CSG::Mapper::Command::stat;

use CSG::Mapper -command;
use CSG::Base;
use CSG::Mapper::DB;

sub opt_spec {
  return (
    ['job-id=s',  'job to provide stats for'],
    ['time-left', 'calculate time remaining in hours for a given jobid'],
    ['totals',    'various counts'],
    ['build|b=s', 'reference build'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($opts->{time_left} and not $opts->{job_id} and not $self->app->global_options->{cluster}) {
    $self->usage_error('cluster and job-id are required for the time-left stat');
  }

  if ($opts->{totals} and not $opts->{build}) {
    $self->usage_error('build is required when viewing totals');
  }

  unless ($opts->{build} =~ /37|38/) {
    $self->usage_error('invalid reference build');
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  if ($opts->{time_left}) {
    $self->_time_left($opts->{job_id});
  }

  if ($opts->{totals}) {
    $self->_totals();
  }
}

sub _time_left {
  my ($self, $job_id) = @_;

  my $job = CSG::Mapper::Job->new(
    cluster => $self->app->global_options->{cluster},
    job_id  => $job_id,
  );

  say $job->time_remaining();
}

sub _totals {
  my ($self) = @_;

  my $schema = CSG::Mapper::DB->new();

  # TODO - display stats per project per build
  #   * total samples
  #   * total completed samples (per cluster)
  #   * total failed samples
  #   * total running samples
  #   * 
}

1;

__END__

=head1

CSG::Mapper::Command::stat - stat remapping jobs
