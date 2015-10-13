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
    @TIME_FORMAT_REGEXPS
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
      )
  ],
  mapping => [
    qw(
      @TIME_FORMAT_REGEXPS
    )
  ],
);

Readonly::Scalar our $EMPTY      => q{};
Readonly::Scalar our $COMMA      => q{,};
Readonly::Scalar our $UNDERSCORE => q{_};
Readonly::Scalar our $PERIOD     => q{.};
Readonly::Scalar our $TRUE       => q{1};
Readonly::Scalar our $FALSE      => q{0};

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

1;
