package CSG::Mapper::Job::Factory::Implementation::Requires;

use Moose::Role;

requires(
  qw(
    job_id
    has_job_id
    elapsed
    elapsed_seconds
    state
    submit
    )
);

1;
