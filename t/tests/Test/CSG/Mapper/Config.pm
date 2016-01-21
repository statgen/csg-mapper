package Test::CSG::Mapper::Test;

use base qw(Test::Class);
use CSG::Base qw(test);

use CSG::Mapper::Config;

sub class {
  return 'CSG::Mapper::Config';
}

sub startup : Test(startup) {
  my ($test) = @_;

  my $fixture_path = qq{$FindBin::Bin/../t/fixtures/configs};
  diag($fixture_path);
  $test->{fixtures}->{config} = qq{$fixture_path/mapper.ini};
}

sub setup : Test(setup => 2) {
  my ($test) = @_;

  my $config = $test->class->new(_file => $test->{fixtures}->{config});
  isa_ok($config, $test->class);
  can_ok($config, 'get');

  $test->{config} = $config;
}

sub test_has_category : Test(4) {
  my ($test) = @_;
  my $config = $test->{config};
  can_ok($config, 'has_category');

  for my $cat ((qw(db pipelines gotcloud))) {
    ok($config->has_category($cat), "$cat category exists");
  }
}

sub test_dsn : Test(1) {
  my ($test) = @_;

  my $config = $test->{config};
  my $dsn    = 'dbi:mysql:database=csgmapper;host=localhost;port=3306';

  is($config->dsn, $dsn, 'dsn matches');
}

1;
