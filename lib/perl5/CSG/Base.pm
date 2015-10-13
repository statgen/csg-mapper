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
  'List::MoreUtils' => [qw(all any none)],
);

our %IMPORT_BUNDLES = (
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
