package CSG::Mapping::Config;

# TODO - make this a singleton, maybe
# TODO - build class methods with MooseX::ClassAttribute

use Moose;

use CSG::Base qw(:config);
use CSG::Constants;
use CSG::Types;

Readonly::Scalar my $DEFAULT_CONFIG => qq($FindBin::Bin/../etc/config.ini);

has '_file' => (
  is      => 'ro',
  isa     => 'FileOnDisk',
  default => sub {
    return $ENV{CSG_MAPPING_CONF} // $DEFAULT_CONFIG;
  }
);

has 'conf' => (is => 'ro', isa => 'Config::Tiny', lazy => 1, builder => '_build_conf');

sub _build_conf {
  return Config::Tiny->read(shift->_file);
}

sub get {
  my ($self, $category, $name) = @_;
  my $section = ($category eq q{global}) ? $UNDERSCORE : $category;
  return $self->conf->{$section}->{$name};
}

sub clusters {
  return join($PIPE, split(/$COMMA/, shift->conf->get('global', 'clusters')));
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
