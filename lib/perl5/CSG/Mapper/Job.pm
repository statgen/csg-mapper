package CSG::Mapper::Job;

use Moose;

use CSG::Base;
use CSG::Types;
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
      submit
      elapsed
      elapsed_seconds
      state
      submit
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

1;
