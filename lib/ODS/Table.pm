package ODS::Table;

use strict;
use warnings;
use ODS::Attributes;
use Tie::IxHash;
use Carp qw/croak/;

has options => (
	isa => hash,
);

has columns => (
	isa => ordered_hash,
	default => 1
);

BEGIN {
	no strict 'refs';
	my @attributes = ('name');
	my $package = __PACKAGE__;
	for my $attr (@attributes) {
		*{"${package}::${attr}"} = sub {
			$_[0]->{$attr} = $_[1] if defined ($_[1]);
			$_[0]->{$attr};
		};
	}
}

sub add_column {
	my ($self, @column) = @_;

	my $column = shift @column;

	if ($self->columns->{$column}) {
		croak sprintf "Column %s is already defined in the %s table", 
			$column, $self->name;
	}


	if (scalar @column % 2) {
		croak "The column definition for %s does not contain an even number of key/values in the %s table.",
			$column, $self->name;
	}


	$self->columns->{$column} = { @column };

	if (! $self->columns->{$column}->{type} ) {
		$self->columns->{$column}->{type} = 'string';
	}

	return $self;
}

1;

__END__
