package PicBot::DB::Main::Result::Pdb;
use base qw/DBIx::Class/;
__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('pdb');
__PACKAGE__->add_columns(qw/ pid url said channel network fails /);
__PACKAGE__->add_unique_constraint(['url']);
__PACKAGE__->set_primary_key('pid');

1
