package CSG::Mapper;
use App::Cmd::Setup -app;

sub global_opt_spec {
  return (
    ['debug|d',     'Debug output'],
    ['verbose|v',   'Verbose output'],
    ['cluster|c=s', 'Cluster environemtn (csg|flux)'],
    ['dry-run|n',   'Dry run; show what would be done without actaully doing anything'],
    ['help|h',      'Usage'],
  );
}

1;
