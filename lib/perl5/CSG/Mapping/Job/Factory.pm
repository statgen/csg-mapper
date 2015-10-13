package CSG::Mapping::Job::Factory;

use MooseX::AbstractFactory;

implementation_does [
  qw(
    CSG::Mapping::Job::Factory::Implementation::Requires
    )
];

implementation_class_via sub {
  q{CSG::Mapping::Job::Factory::Implementation::} . shift;
};

1;
