package ODS::Attributes;

use strict;
no strict 'refs';
use warnings;
use Carp qw/croak/;

our %object;
our %TYPES;
use Tie::IxHash;

sub make_keyword {
	my ($called, $key, $cb) = @_;
	*{"${called}::$key"} = $cb;
}

sub import {
	my ($package, @attributes) = @_;
	my $called = caller();
	
	for my $is (qw/ro rw/) {
		make_keyword($called, $is, sub { is => $is });
	}

	for my $key (qw/isa default coerce required trigger/) {
		make_keyword($called, $key, sub {
			my (@value) = @_;
			return $key => @value;
		});
	}

	for my $isa ( qw/any scalar scalarref integer float boolean ordered_hash hash array object fh/ ) {
		make_keyword($called, $isa, sub { 
			my (@args) = @_;
			my @return = (
				\&{"${package}::${isa}"}, 
				type => $isa, 
				build_default => \&{"${package}::build_${isa}"} 
			);
			push @return, (default => ($isa eq 'ordered_hash' ? sub { deep_clone_ordered_hash(@args) } : sub { deep_clone( scalar @args > 1 ? $isa eq 'hash' ? {@args} : \@args : @args) }))
				if (scalar @args);
			@return;
		});
	}

	make_keyword($called, 'auto_build', sub { $object{auto_build} = 1; });

	$object{has} = {};

	*{"${called}::has"} = sub {
		my ($name, @attrs) = @_;

		if ( $object{has}{$name} ) {
			croak sprintf "%s attribute already defined for %s object.", $name, $called;
		}

		if ( scalar @attrs % 2 ) {
			croak sprintf "Invalid attribute definition odd number of key/value pairs (%s) passed with %s in %s object", scalar @attrs, $name, $called;
		}

		$object{has}{$name} = {@attrs};

		$object{has}{$name}{is} = 'rw'
			if (! $object{has}{$name}{is});

		$object{has}{$name}{isa} = $TYPES{all}
			if (not defined $object{has}{$name}{isa});

		if ($object{has}{$name}{default}) {
			if ($object{has}{$name}{default} =~ m/^1$/) {
				$object{has}{$name}{value} = $object{has}{$name}{build_default}();		
			} elsif (ref $object{has}{$name}{default} eq 'CODE') {
				$object{has}{$name}{value} = $object{has}{$name}{default}();
			} else {
				$object{has}{$name}{value} = $object{has}{$name}{type} eq 'ordered_hash'
					? deep_clone_ordered_hash($object{has}{$name}{default})
					: deep_clone($object{has}{$name}{default});
			}
		}
	
		*{"${called}::$name"} = sub {
			my ($self, $value) = @_;
			if ($value && ( 
				$object{has}{$name}->{is} eq 'rw'
					|| [split '::', [caller(1)]->[3]]->[-1] =~ m/^new|build|set_defaults|auto_build$/
			)) {
				$value = $object{has}{$name}->{coerce}($value, $name)
					if ($object{has}{$name}->{coerce});
				$object{has}{$name}->{required}($value, $name)
					if ($object{$name}->{required});
				$object{has}{$name}->{isa}($value, $name);
				$self->{$name} = $value;
				$object{has}{$name}->{trigger}($value, $name)
					if ($object{has}{$name}->{trigger});
			}
			$self->{$name};
		};		
	};

	*{"${called}::new"} = sub {
		my ($pkg) = shift;
		my $self = bless { }, $pkg;
		set_defaults($self);
		auto_build($self, @_) if ($object{auto_build});
		$self->build(@_) if ($self->can('build'));
		return $self;
	};

}

sub set_defaults {
	my ($self) = @_;
	(defined $object{has}{$_}{value} && $self->$_($object{has}{$_}{type} eq 'ordered_hash'
		? deep_clone_ordered_hash($object{has}{$_}{value})
		: deep_clone($object{has}{$_}{value})
	)) for keys %{$object{has}};	
	return $self;
}

sub auto_build {
	my ($self, %build) = (shift, scalar @_ == 1 ? %{ $_[0] } : @_);
	for my $key (keys %build) {
		$self->$key($build{$key}) if $self->can($key);
	}
}

sub required {
	my ($self, $value, $name) = @_;
	if ( not defined $value ) {
		croak sprintf "No defined value passed to the required %s attribute.",
			$name; 
	}

}

sub any { $_[1] }

sub build_scalar { "" }

sub scalar {
	my ($value, $name) = @_;
	if (ref $value) {
		croak sprintf "The value passed to the %s attribute does not match the scalar type constraint.", 
			$name;
	} 
	return $value;
}

sub build_integer { 0 }

sub integer {
	my ($value, $name) = @_;
	if (ref $value || $value !~ m/^\d+$/) {
		croak sprintf "The value passed to the %s attribute does not match the type constraint.", 
			$name;
	} 
	return $value;
}

sub build_float { 0.00 }

sub float {
	my ($value, $name) = @_;
	if (ref $value || $value !~ m/^\d+\.\d+$/) {
		croak sprintf "The value passed to the %s attribute does not match the float constraint.", 
			$name;
	}
	return $value;
}

sub build_scalarref { \"" }

sub scalarref {
	my ($value, $name) = @_;
	if (ref $value ne 'SCALAR' ) {
		croak sprintf "The value passed to the %s attribute does not match the scalarref constraint.", 
			$name;
	}
	return $value;
}

sub build_boolean { \0 }

sub boolean {
	my ($value, $name) = @_;
	if (ref $value ne 'SCALAR' || $$value !~ m/1|0/) {
		croak sprintf "The value passed to the %s attribute does not match the scalarref constraint.", 
			$name;
	}
	return $value;
}

sub build_ordered_hash { { } }

sub ordered_hash { hash(@_); }

sub build_hash { {} }

sub hash {
	my ($value, $name) = @_;
	if (ref $value ne 'HASH') {
		croak sprintf "The value passed to the %s attribute does not match the hash type constraint.", 
			$name;
	} 
	return $value;
}

sub build_array { [] }

sub array {
	my ($value, $name) = @_;
	if (ref $value ne 'ARRAY') {
		croak sprintf "The value passed to the %s attribute does not match the array type constraint.", 
			$name;
	} 
	return $value;
}

sub fh {
	my ($value, $name) = @_;
	if (ref $value ne 'GLOB') {
		croak sprintf "The value passed to the %s attribute does not match the glob type constraint.", 
			$name;
	} 
	return $value;
}

sub object {
	my ($value, $name) = @_;
	if ( ! ref $value || ref $value !~ m/SCALAR|ARRAY|HASH|GLOB/) {
		croak sprintf "The value passed to the %s attribute does not match the object type constraint.", 
			$name;
	} 
	return $value;

}

sub deep_clone {
	my ($data) = @_;
	my $ref = ref $data;
	if (!$ref) { return $data; }
	elsif ($ref eq 'SCALAR') { return \deep_clone($$data); }
	elsif ($ref eq 'ARRAY') { return [ map { deep_clone($_) } @{ $data } ]; }
	elsif ($ref eq 'HASH') { return { map +( $_ => deep_clone($data->{$_}) ), keys %{ $data } }; }
	else { return $data };
}

sub deep_clone_ordered_hash {
	my (@hash) = scalar @_ == 1 ? %{ $_[0] } : @_;
	my %hash = ();
        tie(%hash, 'Tie::IxHash');
	$hash{shift @hash} = deep_clone(shift @hash) while @hash;
	return \%hash;
}



1;
