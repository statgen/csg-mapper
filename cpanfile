requires 'App::Cmd';
requires 'Config::Tiny';
requires 'Modern::Perl';
requires 'Import::Base';
requires 'Readonly';
requires 'System::Command';
requires 'Template';

requires 'DBD::mysql';
requires 'DBD::SQLite';
requires 'DBIx::Class';
requires 'DBIx::Class::Schema::Loader';

requires 'Moose';
requires 'MooseX::AbstractFactory';

on 'test' => sub {
  requires 'Test::Class';
  requires 'Test::Exception';
  requires 'Test::More';
  requires 'Test::Most';
};
