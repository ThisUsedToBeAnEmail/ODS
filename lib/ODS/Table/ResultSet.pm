package ODS::Table::ResultSet;

use YAOO;

auto_build;

has table => isa(object);

sub all {
	my ($self, @params) = @_;
	return $self->table->storage->all(@params);
}

sub select {
	my ($self, @params) = @_;
	$self->table->storage->select(@params);
}

sub create {
	my ($self, @params) = @_;
	$self->table->storage->create(@params);
}

sub update {
	my ($self, @params) = @_;
	$self->table->storage->update(@params);
}

sub delete {
	my ($self, @params) = @_;
	$self->table->storage->delete(@params);
}

1;
