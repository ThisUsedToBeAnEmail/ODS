package ResultSet::User;

use YAOO;

extends 'ODS::Table::ResultSet';

has admins => rw, isa(object);

sub find_all_admins {
	my ($self) = @_;

	$self->admins(
		$self->table->select(
			admin => \1,
		)
	);

	return $self->admins;
}

1;

