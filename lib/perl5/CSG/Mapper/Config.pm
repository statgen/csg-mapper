package CSG::Mapper::Config;

# TODO - make this a singleton, maybe
# TODO - build class methods with MooseX::ClassAttribute

use Moose;

use CSG::Base qw(config);
use CSG::Constants;
use CSG::Types;

Readonly::Scalar my $DEFAULT_CONFIG => qq($FindBin::Bin/../etc/mapper.ini);

has '_file' => (
  is      => 'ro',
  isa     => 'FileOnDisk',
  default => sub {
    return $ENV{CSG_MAPPING_CONF} // $DEFAULT_CONFIG;
  }
);

has 'conf' => (is => 'ro', isa => 'Config::Tiny', lazy => 1, builder => '_build_conf');
has 'dsn'  => (is => 'ro', isa => 'Str',          lazy => 1, builder => '_build_dsn');

sub _build_conf {
  return Config::Tiny->read(shift->_file);
}

sub _build_dsn {
  my ($self) = @_;
  return sprintf 'dbi:mysql:database=%s;host=%s;port=%d',
    $self->get('db', 'db'),
    $self->get('db', 'host'),
    $self->get('db', 'port');
}

sub get {
  my ($self, $category, $name) = @_;
  my $section = ($category eq q{global}) ? $UNDERSCORE : $category;
  return $self->conf->{$section}->{$name};
}

sub has_category {
  my ($self, $category) = @_;
  return exists $self->conf->{$category};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
