package CSG::Constants;

use base qw(Exporter);
use CSG::Base;

our @EXPORT = (
  qw(
    $EMPTY
    $COMMA
    $UNDERSCORE
    $PERIOD
    $TRUE
    $FALSE
    $PIPE
    )
);

our @EXPORT_OK = (
  qw(
    $EMPTY
    $COMMA
    $UNDERSCORE
    $PERIOD
    $TRUE
    $FALSE
    $PIPE
    @TIME_FORMAT_REGEXPS
    $VALID_CLUSTER_REGEXPS
    %JOB_ELAPSED_TIME_FORMAT
    %JOB_STATE_CMD_FORMAT
    %JOB_STATES
    )
);

our %EXPORT_TAGS = (
  all => [
    qw(
      $EMPTY
      $COMMA
      $UNDERSCORE
      $PERIOD
      $TRUE
      $FALSE
      $PIPE
      @TIME_FORMAT_REGEXPS
      $VALID_CLUSTER_REGEXPS
      %JOB_ELAPSED_TIME_FORMAT
      %JOB_STATE_CMD_FORMAT
      %JOB_STATES
      )
  ],
  mapping => [
    qw(
      @TIME_FORMAT_REGEXPS
      $VALID_CLUSTER_REGEXPS
      %JOB_ELAPSED_TIME_FORMAT
      %JOB_STATE_CMD_FORMAT
      %JOB_STATES
    )
  ],
);

Readonly::Scalar our $EMPTY      => q{};
Readonly::Scalar our $COMMA      => q{,};
Readonly::Scalar our $UNDERSCORE => q{_};
Readonly::Scalar our $PERIOD     => q{.};
Readonly::Scalar our $TRUE       => q{1};
Readonly::Scalar our $FALSE      => q{0};
Readonly::Scalar our $PIPE       => q{|};

Readonly::Scalar our $VALID_CLUSTER_REGEXPS => qr{csg|flux};

Readonly::Array our @TIME_FORMAT_REGEXPS => (
  # dd-hh:mm:ss or dd:hh:mm:ss
  qr/(?<days>\d{1,2})(?:\-|:)(?<hours>\d{2}):(?<minutes>\d{2}):(?<seconds>\d{2})/,

  # hhh:mm:ss
  qr/(?<hours>\d{1,3}):(?<minutes>\d{2}):(?<seconds>\d{2})/,

  # hh:mm
  qr/(?<hours>\d{1,2}):(?<minutes>\d{2})/,

  # sssssss
  qr/(?<seconds>\d{1,7})/,
);

Readonly::Hash our %JOB_ELAPSED_TIME_FORMAT => (
  flux => undef,
  csg  => q{sacct -j %d -X -n -o elapsed},
);

Readonly::Hash our %JOB_STATE_CMD_FORMAT => (
  flux => q{qstat -f -e %d > /dev/null 2>&1 ; echo $?},
  csg  => q{sacct -j %d -X -n -o state%%20},
);

Readonly::Hash our %JOB_STATES => (
  RUNNING   => 'running',
  COMPLETED => 'completed',
  FAILED    => 'failed',
  REQUEUED  => 'requeued',
  CANCELLED => 'cancelled',
  0         => 'running',
  153       => 'not_running',
);

1;
