package ODS;

use 5.006;
use strict;
use warnings;

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

ODS - The great new ODS!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use ODS;

    my $foo = ODS->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

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
