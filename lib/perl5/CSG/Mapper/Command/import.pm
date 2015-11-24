package CSG::Mapper::Command::import;

use CSG::Mapper -command;
use CSG::Base qw(parsers);
use CSG::Constants qw(:mapping);
use CSG::Mapper::BAM;
use CSG::Mapper::Config;
use CSG::Mapper::DB;

Readonly::Array my @IMPORT_FIELDS => (qw(center run_dir filename study pi sample_id fullpath));

sub opt_spec {
  return (['filename|f=s', 'Filename to import'], ['headers', 'Import file contains a header row'],);
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $config = CSG::Mapper::Config->new();

  if ($self->app->global_options->{cluster}) {
    unless ($self->app->global_options->{cluster} =~ /$VALID_CLUSTER_REGEXPS/) {
      $self->usage_error('Invalid cluster environment');
    }
  } else {
    $self->usage_error('Cluster environment is required');
  }

  if ($self->app->global_options->{project}) {
    unless ($config->has_category($self->app->global_options->{project})) {
      $self->usage_error('Invalid project specified');
    }
  } else {
    $self->usage_error('Project is required');
  }

  unless (-e $opts->{filename}) {
    $self->usage_error('Unable to locate import filename on disk');
  } else {

    my $csv;
    try {
      $csv = Class::CSV->parse(
        filename => $opts->{filename},
        fields   => \@IMPORT_FIELDS,
      );
    }
    catch {
      $self->usage_error(qq{Unable to parse file $_});
    };

    $self->{stash}->{csv} = $csv;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $schema = CSG::Mapper::DB->new();
  my @lines  = @{$self->{stash}->{csv}->lines()};

  shift @lines if $opts->{headers};

  for my $line (@lines) {
    my $bam = CSG::Mapper::BAM->new(
      cluster => $self->app->global_options->{cluster},
      project => $self->app->global_options->{project},
      center  => $line->center,
      rundir  => $line->run_dir,
      name    => $line->filename,
      pi      => $line->pi,
    );

    my $project = $schema->resultset('Project')->find_or_create({name => $bam->project});
    my $center = $schema->resultset('Center')->find_or_create({name => $bam->center});
    my $study = $schema->resultset('Study')->find_or_create({name => $line->study});
    my $host = $schema->resultset('Host')->find_or_create({name => $bam->host});
    my $pi = $schema->resultset('Pi')->find_or_create({name => $bam->pi});

    $schema->resultset('Sample')->find_or_create(
      {
        sample_id  => $line->sample_id,
        center_id  => $center->id,
        study_id   => $study->id,
        pi_id      => $pi->id,
        host_id    => $host->id,
        project_id => $project->id,
        filename   => $bam->name,
        run_dir    => $bam->rundir,
        fullpath   => $line->fullpath,
      }
    );

    # TODO - add logging
  }
}

1;

__END__

=head1

CSG::Mapper::Command::import - import remapping jobs
