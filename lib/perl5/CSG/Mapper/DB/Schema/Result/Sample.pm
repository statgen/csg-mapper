use utf8;
package CSG::Mapper::DB::Schema::Result::Sample;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CSG::Mapper::DB::Schema::Result::Sample

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<samples>

=cut

__PACKAGE__->table("samples");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sample_id

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 center_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 study_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 pi_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 host_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 filename

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 run_dir

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 state

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 ref_build

  data_type: 'varchar'
  default_value: 37
  is_nullable: 0
  size: 45

=head2 exported_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 created_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 0

=head2 modified_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sample_id",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "center_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "study_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "pi_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "host_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "filename",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "run_dir",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "state",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "ref_build",
  { data_type => "varchar", default_value => 37, is_nullable => 0, size => 45 },
  "exported_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "created_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
  },
  "modified_at",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 center

Type: belongs_to

Related object: L<CSG::Mapper::DB::Schema::Result::Center>

=cut

__PACKAGE__->belongs_to(
  "center",
  "CSG::Mapper::DB::Schema::Result::Center",
  { id => "center_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 host

Type: belongs_to

Related object: L<CSG::Mapper::DB::Schema::Result::Host>

=cut

__PACKAGE__->belongs_to(
  "host",
  "CSG::Mapper::DB::Schema::Result::Host",
  { id => "host_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 jobs

Type: has_many

Related object: L<CSG::Mapper::DB::Schema::Result::Job>

=cut

__PACKAGE__->has_many(
  "jobs",
  "CSG::Mapper::DB::Schema::Result::Job",
  { "foreign.sample_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pi

Type: belongs_to

Related object: L<CSG::Mapper::DB::Schema::Result::Pi>

=cut

__PACKAGE__->belongs_to(
  "pi",
  "CSG::Mapper::DB::Schema::Result::Pi",
  { id => "pi_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 study

Type: belongs_to

Related object: L<CSG::Mapper::DB::Schema::Result::Study>

=cut

__PACKAGE__->belongs_to(
  "study",
  "CSG::Mapper::DB::Schema::Result::Study",
  { id => "study_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-12 14:23:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i6musxJANa4e1zedACo4Mw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;