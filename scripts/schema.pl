#!/usr/bin/env perl

use FindBin qw($Bin);
use lib qq($Bin/../lib/perl5);

use DBIx::Class::Schema::Loader qw(make_schema_at);

use CSG::Base;
use CSG::Mapping::Config;

my $config = CSG::Mapping::Config->new();

make_schema_at(
  'CSG::Mapping::DB::Schema', {
    debug          => 1,
    dump_directory => qq($Bin/../lib/perl5),
    components     => [qw(InflateColumn::DateTime)],
  },
  [$config->dsn, $config->get('db','user'), $config->get('db','pass')]
);
