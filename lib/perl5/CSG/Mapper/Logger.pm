## no critic (RequireArgUnpacking, ProhibitNestedSubs, RequireFilenameMatchesPackage, ProhibitMultiplePackages)
#
package CSG::Mapper::Logger::Dispatch::DBI {
  use base qw(Log::Dispatch::DBI);

  sub create_statement {
    my $self = shift;
    my $sql  = qq{insert into $self->{table} (job_id, level, message) values (?, ?, ?)};
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

has 'job_id' => (is => 'ro', isa => 'Int', required => 1);
has '_logger'    => (is => 'rw', isa => 'Log::Dispatch', lazy => 1, builder => '_build_logger');

sub _build_logger {
  my ($self) = @_;

  sub _add_timestamp {
    my (%log) = @_;
    return sprintf '%s [%s] %s', uc($log{level}), DateTime->now(time_zone => $TIMEZONE), $log{message};
  }

  my $conf = CSG::Mapper::Config->new();
  my $log  = Log::Dispatch->new();

  $log->add(
    Log::Dispatch::Screen->new(
      stdout    => 1,
      stderr    => 0,
      newline   => 1,
      min_level => 'debug',
      max_level => 'warning',
      callbacks => \&_add_timestamp,
    )
  );

  $log->add(
    Log::Dispatch::Screen->new(
      stdout    => 0,
      stderr    => 1,
      newline   => 1,
      min_level => 'error',
      max_level => 'emergency',
      callbacks => \&_add_timestamp,
    )
  );

  $log->add(
    CSG::Mapper::Logger::Dispatch::DBI->new(
      datasource => $conf->dsn,
      username   => $conf->get('db', 'user'),
      password   => $conf->get('db', 'pass'),
      table      => 'logs',
      min_level  => 'info',
    )
  );

  return $log;
}

sub _log {
  my ($self, $level, $msg) = @_;
  return $self->_logger->log(level => $level, message => $msg, job_id => $self->job_id);
}

sub debug     {return shift->_log('debug',     @_);}
sub info      {return shift->_log('info',      @_);}
sub notice    {return shift->_log('notice',    @_);}
sub warning   {return shift->_log('warning',   @_);}
sub error     {return shift->_log('info',      @_);}
sub critical  {return shift->_log('critical',  @_);}
sub alert     {return shift->_log('alert',     @_);}
sub emergency {return shift->_log('emergency', @_);}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
