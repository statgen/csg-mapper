package CSG::Mapper::Job::Factory::Implementation::csg;

use CSG::Base qw(cmd);
use CSG::Constants qw(:mapping);
use CSG::Mapper::Config;
use CSG::Mapper::Util qw(parse_time);

use Moose;

Readonly::Scalar my $JOB_ELAPSED_TIME_FORMAT => q{sacct -j %d -X -n -o elapsed};
Readonly::Scalar my $JOB_STATE_CMD_FORMAT    => q{sacct -j %d -X -n -o state%%20};

Readonly::Hash my %JOB_STATES => (
  RUNNING   => 'running',
  COMPLETED => 'completed',
  FAILED    => 'failed',
  REQUEUED  => 'requeued',
  CANCELLED => 'cancelled',
);

has 'job_id' => (is => 'rw', isa => 'Int', predicate => 'has_job_id');

sub elapsed {
  my ($self) = @_;
  my $cmd = sprintf $JOB_ELAPSED_TIME_FORMAT, $self->job_id;
  chomp(my $time = capture(EXIT_ANY, $cmd));
  return parse_time($time);
}

sub elapsed_seconds {
  my $e = shift->elapsed;
  return ($e->days * 24 * 3600) + ($e->hours * 3600) + ($e->minutes * 60) + $e->seconds;
}

sub state {
  my ($self) = @_;
  my $cmd = sprintf $JOB_STATE_CMD_FORMAT, $self->job_id;
  chomp(my $state = capture(EXIT_ANY, $cmd));
  $state =~ s/^\s+|\s+$//g;
  return $JOB_STATES{$state};
}

sub submit {
  # TODO - need to parse the output for the qsub command and set the job_id
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

