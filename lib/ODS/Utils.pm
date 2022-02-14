package ODS::Utils;

use base 'Import::Export';

use YAOO;

use Data::GUID;
 
our %EX = (
        load => [qw/all/],
	clone => [qw/all/],
	unique_id => [qw/all/],
	build_temp_class => [qw/all/]
);

sub clone { 
	my ($c) = @_;
	my $n = bless YAOO::deep_clone_ordered_hash($c), ref $c;
	return $n;
}

sub load {
	my ($module) = shift;
	$module =~ s/\:\:/\//g;
	require $module . '.pm';	
	return 1;
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

1;
