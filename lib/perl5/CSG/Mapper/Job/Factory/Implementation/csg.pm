package CSG::Mapper::Job::Factory::Implementation::csg;

use CSG::Base qw(cmd);
use CSG::Constants qw(:mapping);
use CSG::Mapper::Config;
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
  my ($self, $file) = @_;

  CSG::Mapper::Exception::Job::BatchFileNotFound->throw() unless -e $file;
  CSG::Mapper::Exception::Job::BatchFileNotReadable->throw() unless -r $file;

  try {
    my $output = capture($JOB_SUBMIT_CMD, $file);

    if ($output =~ /$JOB_OUTPUT_REGEXP/) {
      $self->job_id($+{jobid});
    } else {
      CSG::Mapper::Exception::Job::ProcessOutput->throw(output => $output);
    }
  } catch {
    CSG::Mapper::Exception::Job::SubmissionFailure->throw(error => $_);
  };

  return;

}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

