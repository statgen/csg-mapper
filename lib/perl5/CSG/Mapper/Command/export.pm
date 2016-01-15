package CSG::Mapper::Command::export;

use CSG::Mapper -command;
use CSG::Base qw(cmd);
use CSG::Mapper::Config;
use CSG::Mapper::DB;

sub opt_spec {
  return (
    ['build=s', 'Reference build used to mapping these samples'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $config = CSG::Mapper::Config->new();
  my $schema = CSG::Mapper::DB->new();
  my $logger = CSG::Mapper::Logger->new();

  $self->{stash}->{schema} = $schema;
  $self->{stash}->{config} = $config;
  $self->{stash}->{logger} = $logger;

  unless ($self->app->global_options->{project}) {
    $self->usage_error('Project is required');
  }

  unless ($config->has_category($self->app->global_options->{project})) {
    $self->usage_error('Unknown project');
  }

  unless ($self->can('_export_' . $self->app->global_options->{project})) {
    $self->usage_error('No export method defined for this project');
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $schema  = $self->{stash}->{schema};
  my $results = $schema->resultset('Project')->search(
    {
      'me.name'             => $self->app->global_options->{project},
      'samples.exported_at' => undef,
    }, {
      join      => 'samples',
      '+select' => [qw(samples.id)],
      '+as'     => [qw(sample_id)],

    }
  );

  while (my $result = $results->next) {
    my $export_meth = '_export_' . $result->name;
    $self->$export_meth($result->get_column('sample_id'), $opts->{build});
  }
}

sub _export_topmed {
  my ($self, $sample_id, $build) = @_;

  my $logger = $self->{stash}->{logger};
  my $schema = $self->{stash}->{schema};
  my $sample = $schema->resultset('Sample')->find($sample_id);
  my $cmd    = sprintf '/usr/cluster/monitor/bin/topmedcmd.pl %s mapped%d completed', $sample->sample_id, $build;

  $logger->debug("EXPORT CMD: '$cmd'") if $self->app->global_options->{debug};

  try {
    run($cmd);
    $logger->info('Exported sample[' . $sample->sample_id . '] to topmedcmd ') if $self->app->global_options->{verbose};
    $sample->update({exported_at => DateTime->now()});
  }
  catch {
    unless (ref $_) {
      $logger->error($_);
    }
  };
}

1;

__END__

=head1

CSG::Mapper::Command::export - export remapping jobs
