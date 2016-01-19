use utf8;
package CSG::Mapper::DB::Schema::Result::State;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CSG::Mapper::DB::Schema::Result::State

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::CSG::CreatedAt>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "CSG::CreatedAt");

=head1 TABLE: C<states>

=cut

__PACKAGE__->table("states");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_UNIQUE>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_UNIQUE", ["name"]);

=head1 RELATIONS

=head2 results

Type: has_many

Related object: L<CSG::Mapper::DB::Schema::Result::Result>

=cut

__PACKAGE__->has_many(
  "results",
  "CSG::Mapper::DB::Schema::Result::Result",
  { "foreign.state_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-19 09:21:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k5E+OigFDSqf7CXIi/bj8Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
