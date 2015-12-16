package CSG::Mapper::Job;

use Moose;

use CSG::Base qw(cmd);
use CSG::Types;
use CSG::Mapper::Exceptions;
use CSG::Mapper::Job::Factory;

has 'cluster' => (is => 'ro', isa => 'ValidCluster', required  => 1);
has 'job_id'  => (is => 'ro', isa => 'Int',          predicate => 'has_job_id');
has 'factory' => (
  is      => 'ro',
  isa     => 'ValidJobFactory',
  lazy    => 1,
  builder => '_build_factory',
  handles => [
    qw(
      elapsed
      state
      job_output_regexp
      job_submit_cmd
      )
  ],
);

sub _build_factory {
  my ($self) = @_;
  my $class  = __PACKAGE__ . q{::Factory};
  my $opts   = {};

  if ($self->has_job_id) {
    $opts->{job_id} = $self->job_id;
  }

  return $class->create($self->cluster, $opts);
}

sub elapsed_seconds {
  my $e = shift->elapsed;
  return ($e->days * 24 * 3600) + ($e->hours * 3600) + ($e->minutes * 60) + $e->seconds;
}

sub submit {
  my ($self, $file) = @_;

  CSG::Mapper::Exception::Job::BatchFileNotFound->throw() unless -e $file;
  CSG::Mapper::Exception::Job::BatchFileNotReadable->throw() unless -r $file;

  try {
    my $output = capture($self->job_submit_cmd, $file);

    if ($output =~ /$self->job_output_regexp/) {
      $self->job_id($+{jobid});
    } else {
      CSG::Mapper::Exception::Job::ProcessOutput->throw(output => $output);
    }
  } catch {
    CSG::Mapper::Exception::Job::SubmissionFailure->throw(error => $_);
  };

  return;
}

1;
