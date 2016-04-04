requires 'App::Cmd';
requires 'Config::Tiny';
requires 'Modern::Perl';
requires 'Import::Base';
requires 'Readonly';
requires 'Template';
requires 'Class::CSV';
requires 'Try::Tiny';
requires 'IO::All';
requires 'local::lib';

requires 'System::Command';
requires 'IPC::System::Simple';

requires 'DBD::mysql';
requires 'DBD::SQLite';
requires 'DBIx::Class';
requires 'DBIx::Class::Schema::Loader';

requires 'DateTime';
requires 'DateTime::Duration';
requires 'DateTime::Format::MySQL';

requires 'Moose';
requires 'MooseX::AbstractFactory';

requires 'WWW::Mechanize';
requires 'Mojo::UserAgent';
requires 'JSON::MaybeXS';
requires 'IO::Socket::SSL';

requires 'File::Stat';
requires 'File::Slurp::Tiny';

requires 'Log::Dispatch';
requires 'Log::Dispatch::DBI';

requires 'YAML';

on 'test' => sub {
  requires 'Test::Class';
  requires 'Test::Exception';
  requires 'Test::More';
  requires 'Test::Most';
};
