package CSG::Mapping::Job;

use Moose;

use CSG::Base;
use CSG::Types;
use CSG::Mapping::Job::Factory;

has 'cluster' => (is => 'ro', isa => 'ValidCluster', required => 1);
has 'job_id'  => (is => 'ro', isa => 'Int',          required => 1);

sub BUILD {
  my ($self) = @_;
  my $class  = __PACKAGE__ . q{::Factory};

  return $class->create($self->cluster, {job_id => $self->job_id});
}

1;
