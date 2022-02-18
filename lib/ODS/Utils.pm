package ODS::Utils;

use YAOO;
no strict 'refs';
use Data::GUID;
use File::Copy qw/move/;
use Carp qw/croak/;
use Scalar::Util qw//;
use Data::Dumper qw/Dumper/;

our ( %EX, %EX2);

BEGIN {
	%EX = (
		load => [qw/all/],
		clone => [qw/all/],
		unique_class_name => [qw/all/],
		build_temp_class => [qw/all/],
		move => [qw/all/],
		deep_unblessed => [qw/all/],
		croak => [qw/error/],
		Dumper => [qw/error/]
	);
	for my $ex (keys %EX) {
		for (@{ $EX{$ex} }) {
			push @{ $EX2{$_} }, $ex;
		}
	}
}

sub import {
	my ($self, @functions) = @_;

	my $caller = caller();

	for my $fun (@functions) {
		if ($EX{$fun}) {
			YAOO::make_keyword($caller, $fun, *{"${self}::${fun}"});
		} elsif ($EX2{$fun}) {
			for (@{ $EX2{$fun} }) {
				YAOO::make_keyword($caller, $_,  *{"${self}::${_}"});
			}
		}
	}

}

sub clone {
	my ($c) = @_;
	my $n = bless YAOO::deep_clone_ordered_hash($c), ref $c;
	return $n;
}

sub load {
	my ($module) = shift;
	(my $require = $module) =~ s/\:\:/\//g;
	require $require . '.pm';
	return $module;
}

sub unique_class_name {
	return 'A' . join("", split("-", Data::GUID->new->as_string()));
}

sub build_temp_class {
	my ($class) = @_;
	load $class;
	my $temp = $class . '::' . unique_class_name();
	my $c = sprintf(
                q|
                        package %s;
			use YAOO;
			extends '%s';
                        1;
                |, $temp, $class );
        eval $c;
	return $temp;
}

sub deep_unblessed {
	my ($obj) = @_;

	if ((ref($obj) || "SCALAR") !~ m/ARRAY|HASH|SCALAR/) {
		$obj = {%{ $obj }};
	}

	if ((ref($obj) || "") eq 'HASH') {
		for my $key (keys %{ $obj }) {
			$obj->{$key} = deep_unblessed($obj->{$key});
		}
	}

	return $obj;
}

1;
