package CSG::Types;

use CSG::Base;
use CSG::Constants qw(:mapping);

use Moose::Util::TypeConstraints;

subtype 'ValidCluster',
  as 'Str',
  where { $_ =~ /$VALID_CLUSTER_REGEXPS/ },
  message { 'is not a valid cluster type' };

subtype 'FileOnDisk',
  as 'Str',
  where {-s $_},
  message {'invalid file'};

no Moose::Util::TypeConstraints;

1;
