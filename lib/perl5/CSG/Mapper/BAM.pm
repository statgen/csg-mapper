package CSG::Mapper::BAM;

use CSG::Base qw(file cmd);
use CSG::Constants qw(:mapping);
use CSG::Types;
use CSG::Mapper::Config;

use Moose;

has 'cluster' => (is => 'ro', isa => 'Str', required => 1);
has 'center'  => (is => 'ro', isa => 'Str', required => 1);
has 'rundir'  => (is => 'ro', isa => 'Str', required => 1);
has 'name'    => (is => 'ro', isa => 'Str', required => 1);
has 'pi'      => (is => 'ro', isa => 'Str', required => 1);
has 'project' => (is => 'ro', isa => 'Str', required => 1);

has 'host'        => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_host');
has 'sample_id'   => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_sample_id');
has 'cram'        => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_cram');
has 'crai'        => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_crai');
has 'bam'         => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_bam');
has 'results_dir' => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_results_dir');
has 'prefix'      => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_prefix');

sub _build_bam {
  my ($self) = @_;
  return File::Spec->join($self->prefix, $self->center, $self->rundir, $self->name);
}

sub _build_sample_id {
  chomp(my $sample_id = capture(q{samtools view -H } . shift->bam . q{ | grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2}));
  return $sample_id;
}

sub _build_host {
  my ($self) = @_;

  my $host = undef;
  my $center_path = File::Spec->join($self->prefix, $self->center);

  if (-l $center_path) {
    my $file  = Path::Class->file(readlink($center_path));
    my @comps = $file->components();
    $host = $comps[4];
  }

  return $host // 'topmed'; # FIXME
}

# FIXME - completely wrong atm
sub _build_results_dir {
  my ($self) = @_;
  return File::Spec->join($self->prefix, $self->host, 'working', 'mapping', 'results', $self->center, $self->pi, $self->sample_id);
}

sub _build_cram {
  my ($self) = @_;
  return File::Spec->join($self->results_path, 'bams', $self->sample_id . '.recal.cram');
}

sub _build_crai {
  return shift->cram . '.crai';
}

sub _build_prefix {
  my $conf = CSG::Mapper::Config->new();
  return $conf->get(shift->cluster, 'prefix');
}

sub is_complete {
  my ($self) = @_;

  return unless -e $self->cram;
  return if -z $self->cram;
  return unless -e $self->crai;

  my $cram_stat = File::Stat->new($self->cram);
  my $crai_stat = File::Stat->new($self->crai);

  return unless $crai_stat->mtime > $cram_stat->mtime;

  return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
