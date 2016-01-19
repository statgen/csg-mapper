## no critic (NamingConventions::Capitalization, Subroutines::RequireFinalReturn)
#
# TODO - add logging
#
package CSG::Mapper::Command::update;

use CSG::Mapper -command;
use CSG::Base;
use CSG::Constants qw(:mapping);
use CSG::Mapper::Config;
use CSG::Mapper::DB;

sub opt_spec {
  return (
    ['meta-id=i',   'Job meta data db record id'],
    ['start',       'Mark a sample started'],
    ['job-id=i',    'Add the clusters job id for a given sample'],
    ['node=s',      'Update what node(s) a sample is running on in the cluster'],
    ['state=s',     'Update the jobs state (valid states: failed|submitted|completed|cancelled|requested)'],
    ['exit-code=i', 'Update the exit code from a given sample'],
    ['step=s',      'Job step [bam2fastq|align|all]'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($opts->{meta_id}) {
    $self->usage_error('meta-id is required');
  }

  my $schema = CSG::Mapper::DB->new();
  my $meta   = $schema->resultset('Job')->find($opts->{meta_id});

  $self->{stash}->{schema} = $schema;
  $self->{stash}->{meta}   = $meta;

  unless ($meta) {
    $self->usage_error('unable to locate the job meta data record');
  }

  if ($opts->{state} and not exists $SAMPLE_STATE{$opts->{state}}) {
    $self->usage_error('invalid job state');
  }

  if ($opts->{start} and $meta->started_at) {
    $self->usage_error('job has already started');
  }

  if (defined $opts->{exit_code} and $meta->ended_at) {
    $self->usage_error('job has already ended');
  }

  unless ($opts->{step}) {
    $self->usage_error('step is required');
  }

  unless ($opts->{step} =~ /bam2fastq|align|all/) {
    $self->usage_error('invalid job step');
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $meta   = $self->{stash}->{meta};
  my $schema = $self->{stash}->{schema};

  if ($opts->{start}) {
    $meta->update({started_at => $schema->now()});
  }

  if ($opts->{job_id}) {
    $meta->update({job_id => $opts->{job_id}});
  }

  if ($opts->{node}) {
    $meta->update({node => $opts->{node}});
  }

  if ($opts->{state}) {
    $meta->sample->update({state => $SAMPLE_STATE{$opts->{state}}});
  }

  if (defined $opts->{exit_code}) {
    $meta->update(
      {
        exit_code => $opts->{exit_code},
        ended_at  => $schema->now(),
      }
    );
  }

  if ($opts->{step}) {
    $meta->update({type => $opts->{step}});
  }
}

1;

__END__

=head1

CSG::Mapper::Command::update - update remapping jobs
