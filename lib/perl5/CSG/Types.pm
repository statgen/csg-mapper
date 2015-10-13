package CSG::Types;

use CSG::Mapping::Base;
use CSG::Mapping::Config;

use Moose::Util::TypeConstraints;

subtype 'ValidCluster',
  as 'Str',
  where {
    my $conf     = CSG::Mapping::Config->new();
    my $clsuters = $conf->clusters;
    $_ =~ /\Q$clusters\E/;
  },
  message { 'is not a valid cluster type' };

subtype 'FileOnDisk',
  as 'Str',
  where {-s $_}
  message {'invalid file'}

no Moose::Util::TypeConstraints;

1;
