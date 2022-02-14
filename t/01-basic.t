use Test::More;

use lib 't/ODS';

use Table::User;
use Table::Test;

my $user = Table::User->connect('File::JSON', {
	file => 't/filedb/users.json'
});

my $data = $user->all();

is(scalar @{$data}, 1);

my %row = %{ $data->[0] };

my $test = Table::Test->connect('File::JSON', {
	file => 't/filedb/test.json'
});

my $data2 = $test->all();

is($data2->[0]->username, 'lnation');
is($data2->first->username, 'lnation');
is($data2->last->username, 'lnation3');
while (my $data3 = $data2->next) {
	like($data3->username, qr/^lnation/);
}

while (my $data3 = $data2->prev) {
	like($data3->username, qr/^lnation/);
}

$data2->foreach(sub {
	my ($row) = @_;
});

my $hash = $data2->array_to_hash();

is_deeply($hash,  {
	'lnation' => {
		'username' => 'lnation',
		'last_name' => 'test',
		'first_name' => 'test'
	},
	'lnation2' => {
		'username' => 'lnation2',
		'last_name' => 'test2',
		'first_name' => 'test2'
	},
	'lnation3' => {
		'first_name' => 'test3',
		'last_name' => 'test3',
		'username' => 'lnation3'
	}
});

my $find = $data2->find(sub {
	$_[0]->{username} eq 'lnation2'
});

is_deeply($find, {
	'username' => 'lnation2',
	'last_name' => 'test2',
	'first_name' => 'test2'
});

my $find_index = $data2->find_index(sub {
	$_[0]->{username} eq 'lnation2'
});

is($find_index, 1);

my $reverse = $data2->reverse();

is($reverse->[0]->username, 'lnation3');

is($data2->table->rows->[0]->username, 'lnation3');

$data2->reverse();

my @records = $data->filter(sub { $_->{username} eq 'lnation' });

is (scalar @records, 1);
is ($records[0]->username, 'lnation');

my $one = $test->select(
	username => 'lnation2'
);

is(scalar @{ $one }, 1);

$test->create({
	username => 'xyzabc',
	first_name => 'xyz',
	last_name => 'abc',
});

=pod
$user->update(
	username => 'xyzabc',
	{
		first_name => 'testing'
	}
);
=cut

is($test->table->rows->[-1]->{username}, 'xyzabc');

$test->delete(
	username => 'xyzabc'
);





=pod

my $one = $user->select(
	first_name => 'xyz',
	last_name => 'abc'
);

my $success = $one->update(
	email => 'xyz@lnation.org'
);

my $success = $one->delete();






=cut

done_testing();
