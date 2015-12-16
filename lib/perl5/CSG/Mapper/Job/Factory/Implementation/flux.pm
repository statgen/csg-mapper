package CSG::Mapper::Job::Factory::Implementation::flux;

use CSG::Base qw(cmd www);
use CSG::Constants;
use CSG::Mapper::Util qw(:parsers);

use Moose;

Readonly::Scalar my $FLUX_KIBANA_URL_FORMAT => q{https://kibana.arc-ts.umich.edu/logstash-joblogs-%d.*/pbsacctlog/_search};
Readonly::Scalar my $JOB_STATE_CMD_FORMAT   => q{qstat -f -e %d > /dev/null 2>&1 ; echo $?};
Readonly::Scalar my $JOB_OUTPUT_REGEXP      => qr/^(?<jobid>\d+)\.nyx\.arc\-ts\.umich\.edu$/i;
Readonly::Scalar my $JOB_SUBMIT_CMD         => q{/usr/local/torque/bin/qsub};

Readonly::Hash my %JOB_STATES => (
  0   => 'running',
  153 => 'not_running',
);

has '_logstash_url' => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build__logstash_url');

has 'job_id'            => (is => 'rw', isa => 'Str',       predicate => 'has_job_id');
has 'job_output_regexp' => (is => 'ro', isa => 'RegexpRef', default   => sub {return $JOB_OUTPUT_REGEXP});
has 'job_submit_cmd'    => (is => 'ro', isa => 'Str',       default   => sub {return $JOB_SUBMIT_CMD});

around 'job_id' => sub {
  my ($orig, $self) = @_;
  (my $job_id = $self->$orig()) =~ s/\.nyx(?:\.arc\-ts\.umich\.edu)//g;
  return $job_id;
};

sub _build__logstash_url {
  my ($self) = @_;

  my $now = DateTime->now();
  my $uri = URI->new(sprintf $FLUX_KIBANA_URL_FORMAT, $now->year);
  $uri->query_form(
    {
      q      => 'jobid:' . $self->job_id,
      fields => 'resources_used.walltime',
    }
  );

  return $uri->as_string;
}

sub elapsed {
  my ($self) = @_;

  my $ua    = Mojo::UserAgent->new();
  my $stash = $ua->get($self->_logstash_url)->res->json;

  for my $hit (@{$stash->{hits}->{hits}}) {
    if (exists $hit->{fields}) {
      return parse_time($hit->{fields}->{'resources_used.walltime'}->[0]);
    }
  }

  return;
}

sub state {
  my ($self) = @_;
  my $cmd = sprintf $JOB_STATE_CMD_FORMAT, $self->job_id;
  chomp(my $state = capture(EXIT_ANY, $cmd));
  return $JOB_STATES{$state};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
