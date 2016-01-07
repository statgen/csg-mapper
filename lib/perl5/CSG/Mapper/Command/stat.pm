package CSG::Mapper::Command::stat;

use CSG::Mapper -command;
use CSG::Base;
use CSG::Mapper::Config;
use CSG::Mapper::DB;

sub opt_spec {
  return (
    ['job-id=s',  'job to provide stats for'],
    ['time-left', 'calculate time remaining in hours for a given jobid'],
    ['totals',    'various counts'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($opts->{time_left} and not $opts->{job_id} and not $self->app->global_options->{cluster}) {
    $self->usage_error('cluster and job-id are required for the time-left stat');
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  if ($opts->{time_left}) {
    $self->_time_left($opts->{job_id});
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

1;

__END__

=head1

CSG::Mapper::Command::stat - stat remapping jobs
