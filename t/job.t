#!/usr/bin/env perl

use FindBin qw($Bin);
use lib qq{$Bin/../t/tests}, qq{$Bin/../lib/perl5};

use Test::CSG::Mapping::Job;

Test::Class->runtests;
