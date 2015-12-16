package CSG::Mapper::Exception;

use Exception::Class (
  __PACKAGE__ . '::Job::BatchFileNotFound' => {
    description => 'Unable to locate batch file',
  },
  __PACKAGE__ . '::Job::BatchFileNotReadable' => {
    description => 'Unable to read batch file',
  },
  __PACKAGE__ . '::Job::SubmissionFailure' => {
    description => 'Failed to submit job',
  },
  __PACKAGE__ . '::Job::ProcessOutput' => {
    description => 'Failed to parse the job submission output',
    fields      => [qw(output)],
  }
);

1;
