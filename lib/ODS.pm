package ODS;

use strict; use warnings;

our $VERSION = '0.01';

use ODS::Table;
use Blessed::Merge;

sub import {
	my $package = shift;
	no strict 'refs';
	my $called = caller();
	my $table = ODS::Table->new();
	my $bm = Blessed::Merge->new(
		blessed => 0,
		same => 0
	);
	*{"${called}::true"} = sub { 1; };
	*{"${called}::false"} = sub { 0; };
	*{"${called}::name"} = sub {
		my (@args) = @_;
		$table->name(@args);
	};
	*{"${called}::options"} = sub {
		my (%args) = @_;
		$table->options($bm->merge($table->options, \%args));
	};
	*{"${called}::column"} = sub {
		my (@args) = @_;
		if (!$table->name) {
			$table->name([split "\:\:", $called]->[-1]);
		}
		$table->add_column(@args);
	};
	*{"${called}::storage_class"} = sub {
		my (@args) = @_;
		$table->storage_class(pop @args);
	};
	*{"${called}::connect"} = sub {
		return $table->connect(@_);
	};
}

=head1 NAME

ODS - Object Data Store

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

	package Table::Patient

	use ODS;

	name "user";

	options (
		custom => 1
	);

	column id => (
		type => "integer",
		auto_increment => true,
		mandatory => true,
		filterable => true,
		sortable => true,
		no_render => true
	);

	column first_name => (
		type => "string",
		mandatory => true,
		filterable => true,
		sortable => true,
	);

	column last_name => (
		type => "string",
		mandatory => true,
		filterable => true,
		sortable => true,
	);

	column diagnosis => (
		type => "string",
		mandatory => true,
		filterable => true,
		sortable => true,
	);

	1;

	...

	package ResultSet::Patient; 

	use YAOO;

	extends 'ODS::Table::ResultSet";

	has miss_diagnosis => isa(object);
	
	sub licenced_doctors {
		my ($self, %name) = @_;

		$self->miss_diagnosis($self->find(
			%name	
		));
	}

	...

	package Row::Patient;

	use YAOO;

	extends 'ODS::Table::Row';

	...

	my $data = Table::Patient->connect('File::YAML', {
		file => 't/filedb/patients'
	});

	my $all = $data->all();

	my $miss_diagnosis = $data->licenced_doctors({ first_name => 'Anonymous', last_name => 'Object' });

	$miss_diagnosis->update(
		diagnosis => 'pyschosis'
	);

=head1 AUTHOR

LNATION, C<< <thisusedtobeanemail at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ods at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=ODS>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ODS


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=ODS>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/ODS>

=item * Search CPAN

L<https://metacpan.org/release/ODS>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by LNATION.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of ODS
