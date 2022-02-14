package ODS::Table::Row;

use YAOO;

use overload 
	'%{}' => sub {  caller() =~ m/YAOO$/ ? $_[0] : $_[0]->as_hash; },
	fallback => 1;

has table => isa(object);

has columns => isa(ordered_hash), default(1);

sub build {
	my ($self, %args) = @_;

	$self->table($args{table});
	for my $column ( keys %{ $self->table->columns } ) {
		my $col = $self->table->columns->{$column}->build_column($args{data}{$column}, $args{inflated});
		$self->columns->{$column} = $col;
		YAOO::make_keyword($self->table->row_class, $column, sub { 
			my $self = shift; 
			$self->columns->{$column}->value(@_); 
		}) unless $self->can($column);
	}
	return $self;
}

sub as_hash {
	my %hash;
	$hash{$_} = $_[0]->columns->{$_}->value
		for keys %{$_[0]->columns};	
	return \%hash;
}

sub set_row {
	my ($self, $data) = @_;

	for my $key ( %{ $data } ) {
		$self->$key($data->{$key});
	}
}

sub store_row {
	my ($self, $data) = @_;
	$self->set_row($data) if defined $data && ref($data || "") eq "HASH";
	my %hash = map +(
		$_ => $self->columns->{$_}->store_column()->value
	), keys %{ $self->columns };
	return \%hash;
}

sub validate {
	my ($self, $data) = @_;
	$self->set_row($data) if defined $data && ref($data || "") eq "HASH";
	my %hash = map +(
		$_ => $self->columns->{$_}->validate()->value
	), keys %{ $self->columns };
	return \%hash;
}

sub update {
	my ($self, %update) = @_;
	my $data = $self->data;
	for (keys %update) {
		$data->{$_}->set($update{$_});
	}
	$self->table->storage->update($data);
}

sub delete {
	my ($self) = @_;
	$self->table->storage->delete($self->data);
}

1;
