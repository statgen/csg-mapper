package CSG::Mapper::Job::Factory::Implementation::csg;

use CSG::Base qw(cmd);
use CSG::Constants;
use CSG::Mapper::Util qw(parse_time);

use Moose;

Readonly::Scalar my $JOB_ELAPSED_TIME_FORMAT => q{sacct -j %d -X -n -o elapsed};
Readonly::Scalar my $JOB_STATE_CMD_FORMAT    => q{sacct -j %d -X -n -o state%%20};
Readonly::Scalar my $JOB_OUTPUT_REGEXP       => qr/^Submitted batch job (?<jobid>\d+)$/i;
Readonly::Scalar my $JOB_SUBMIT_CMD          => q{/usr/cluster/bin/sbatch};

Readonly::Hash my %JOB_STATES => (
  RUNNING   => 'running',
  COMPLETED => 'completed',
  FAILED    => 'failed',
  REQUEUED  => 'requeued',
  CANCELLED => 'cancelled',
);

has 'job_id'            => (is => 'rw', isa => 'Int',       predicate => 'has_job_id');
has 'job_output_regexp' => (is => 'ro', isa => 'RegexpRef', default   => sub {return $JOB_OUTPUT_REGEXP});
has 'job_submit_cmd'    => (is => 'ro', isa => 'Str',       default   => sub {return $JOB_SUBMIT_CMD});

sub elapsed {
  my ($self) = @_;
  my $cmd = sprintf $JOB_ELAPSED_TIME_FORMAT, $self->job_id;
  chomp(my $time = capture(EXIT_ANY, $cmd));
  return parse_time($time);
}

sub state {
  my ($self) = @_;
  my $cmd = sprintf $JOB_STATE_CMD_FORMAT, $self->job_id;
  chomp(my $state = capture(EXIT_ANY, $cmd));
  $state =~ s/^\s+|\s+$//g;
  return $JOB_STATES{$state};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

