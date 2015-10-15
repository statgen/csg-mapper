requires 'App::Cmd';
requires 'Config::Tiny';
requires 'Modern::Perl';
requires 'Import::Base';
requires 'Readonly';
requires 'Template';

requires 'System::Command';
requires 'IPC::System::Simple';

requires 'DBD::mysql';
requires 'DBD::SQLite';
requires 'DBIx::Class';
requires 'DBIx::Class::Schema::Loader';

requires 'Moose';
requires 'MooseX::AbstractFactory';

requires 'WWW::Mechanize';
requires 'Mojo::UserAgent';
requires 'JSON::MaybeXS';
requires 'IO::Socket::SSL';

requires 'File::Stat';

on 'test' => sub {
  requires 'Test::Class';
  requires 'Test::Exception';
  requires 'Test::More';
  requires 'Test::Most';
};
