package CSG::Mapper::Logger::Dispatch::DBI {
  use base qw(Log::Dispatch::DBI);

  sub create_statement {
    my $self = shift;
    my $sql  = qq{insert into $self->{table} (job_id, level, message) values (?, ?, ?)'};
    return $self->{dbh}->prepare($sql);
  }

  sub log_message {
    my $self   = shift;
    my %params = @_;
    return $self->{sth}->execute(@params{qw(job_id level message)});
  }
};

package CSG::Mapper::Logger;

use CSG::Base qw(logging);
use CSG::Constants;
use CSG::Mapper::Config;

use Moose;

has 'job_id' => (is => 'ro', isa => 'Int',                 required => 1);
has 'log'    => (is => 'ro', isa => 'Log::Dispatch',       lazy     => 1, builder => '_build_log',);
has '_conf'  => (is => 'ro', isa => 'CSG::Mapper::Config', lazy     => 1, builder => '_build_conf');

sub _build_conf {
  return CSG::Mapper::Config->new();
}

sub _build_log {
  my ($self) = @_;

  my $log = Log::Dispatch->new();

  $log->add(
    Log::Dispatch::Screen->new(
      stdout    => 1,
      stderr    => 0,
      min_level => 'debug',
      max_level => 'warning',
    )
  );

  $log->add(
    Log::Dispatch::Screen->new(
      stdout    => 0,
      stderr    => 1,
      min_level => 'error',
      max_level => 'emergency',
    )
  );

  $log->add(
    CSG::Mapper::Logger::Dispatch::DBI->new(
      datasource => $self->conf->dsn,
      table      => 'logs',
      min_level  => 'debug',
    )
  );

  return $log;
}

sub _log {
  my ($self, $level, $msg) = @_;
  return $self->log(level => $level, messages => $msg, job_id => $self->job_id);
}

sub debug     {shift->_log('debug',     @_);}
sub info      {shift->_log('info',      @_);}
sub notice    {shift->_log('notice',    @_);}
sub warning   {shift->_log('warning',   @_);}
sub error     {shift->_log('info',      @_);}
sub critical  {shift->_log('critical',  @_);}
sub alert     {shift->_log('alert',     @_);}
sub emergency {shift->_log('emergency', @_);}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
