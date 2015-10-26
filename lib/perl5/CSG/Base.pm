package CSG::Base;

use base qw(Import::Base);

our @IMPORT_MODULES = (
  qw(
    FindBin
    Modern::Perl
    Data::Dumper
    DateTime
    Readonly
    ),
  'English'         => [qw(-no_match_vars)],
  'List::MoreUtils' => [qw()],
);

our %IMPORT_BUNDLES = (
  cmd => [
    'IPC::System::Simple' => [qw(run capture EXIT_ANY)],
    'System::Command',
  ],
  config => [
    qw(
      Config::Tiny
      )
  ],
  file => [
    qw(
      File::Spec
      File::Basename
      File::Stat
      Path::Class
      ),
    'File::Slurp::Tiny' => [qw(read_file read_lines)],
  ],
  test => [
    qw(
      Test::Most
      Test::More
      Test::Exception
      )
  ],
  www => [
    qw(
      URI
      URI::QueryParam
      JSON::MaybeXS
      Mojo::UserAgent
      )
  ]
);

1;
