package CSG::Mapper::DB;

use base qw(CSG::Mapper::DB::Schema);

use CSG::Base;
use CSG::Mapper::Config;
use CSG::Mapper::DB::Schema;

sub new {
  my $conf = CSG::Mapper::Config->new();
  return __PACKAGE__->connect($conf->dsn, $conf->get('db', 'user'), $conf->get('db', 'pass'));
}

1;