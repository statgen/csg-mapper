package CSG::Mapper::Command::show;

use CSG::Mapper -command;
use CSG::Base qw(formats);
use CSG::Constants;
use CSG::Mapper::DB;

sub opt_spec {
  return (
    ['meta-id=i', 'job meta id'],
    ['info',      'display basic job info'],
    ['format=s',  'output format (yaml|txt)'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($opts->{meta_id}) {
    $self->usage_error('meta-id is required');
  }

  if ($opts->{format}) {
    unless ($opts->{format} =~ /yaml|txt/) {
      $self->usage_error('invalid output format');
    }
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $schema = CSG::Mapper::DB->new();
  my $meta   = $schema->resultset('Job')->find($opts->{meta_id});

  if ($opts->{info}) {
    my $info = {
      sample => {
        id        => $meta->result->sample->id,
        sample_id => $meta->result->sample->sample_id,
        center    => $meta->result->sample->center->name,
        study     => $meta->result->sample->study->name,
        pi        => $meta->result->sample->pi->name,
        host      => $meta->result->sample->host->name,
        filename  => $meta->result->sample->filename,
        run_dir   => $meta->result->sample->run_dir,
        state     => $meta->result->state->name,
        build     => $meta->result->build,
        fullpath  => $meta->result->sample->fullpath,
      },
      job => {
        id        => $meta->id,
        job_id    => $meta->job_id,
        cluster   => $meta->cluster,
        procs     => $meta->procs,
        memory    => $meta->memory,
        walltime  => $meta->walltime,
        node      => $meta->node,
        delay     => $meta->delay,
        submitted => ($meta->submitted_at) ? $meta->submitted_at->ymd . $SPACE . $meta->submitted_at->hms : $EMPTY,
        created   => $meta->created_at->ymd . $SPACE . $meta->created_at->hms,
      }
    };

    my $format = $opts->{format} // 'yaml';

    if ($format eq 'txt') {
      print Dumper $info;
    } else {
      print Dump($info);
    }
  }

}

1;

__END__

=head1

CSG::Mapper::Command::show - show remapping jobs
