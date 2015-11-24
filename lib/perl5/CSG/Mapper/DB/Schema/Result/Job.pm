use utf8;
package CSG::Mapper::DB::Schema::Result::Job;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CSG::Mapper::DB::Schema::Result::Job

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

=head1 TABLE: C<jobs>

=cut

__PACKAGE__->table("jobs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 job_id

  data_type: 'integer'
  is_nullable: 0

=head2 cluster

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 procs

  data_type: 'integer'
  is_nullable: 0

=head2 memory

  data_type: 'integer'
  is_nullable: 0

=head2 walltime

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 exit_code

  data_type: 'integer'
  is_nullable: 1

=head2 elapsed

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 submitted_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 0

=head2 started_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 1

=head2 ended_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
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
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "job_id",
  { data_type => "integer", is_nullable => 0 },
  "cluster",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "procs",
  { data_type => "integer", is_nullable => 0 },
  "memory",
  { data_type => "integer", is_nullable => 0 },
  "walltime",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "exit_code",
  { data_type => "integer", is_nullable => 1 },
  "elapsed",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "submitted_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
  },
  "started_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 1,
  },
  "ended_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
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

=head1 UNIQUE CONSTRAINTS

=head2 C<job_id_UNIQUE>

=over 4

=item * L</job_id>

=back

=cut

__PACKAGE__->add_unique_constraint("job_id_UNIQUE", ["job_id"]);

=head1 RELATIONS

=head2 sample

Type: belongs_to

Related object: L<CSG::Mapper::DB::Schema::Result::Sample>

=cut

__PACKAGE__->belongs_to(
  "sample",
  "CSG::Mapper::DB::Schema::Result::Sample",
  { id => "sample_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-12 15:12:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+vRkjZU1imu11uUcKHybEQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;