# $Id: Array.pm,v 1.9 2003/02/27 12:46:42 xmath Exp $

package Spy::Array;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Variable';

use Carp;
use B::More;
use Spy::_property;

sub type : method { "ARRAY" }
sub noun : method { "an array" }

use overload
	'@{}' => sub { tie +(my @x), __PACKAGE__, @_; \@x },
	fallback => 1;

sub item : method { &EXISTS ? spy \${$_[0]}->[$_[1]] : undef }


sub _refs {
	wantarray
		? map \undef == $_ ? undef : $_, @_
		: \undef == $_[-1] ? undef : $_[-1]
}

sub TIEARRAY : method { $_[1] }
sub FETCH : method { &EXISTS ? \${$_[0]}->[$_[1]] : undef }
sub STORE : method {
	my ($x, $i, $v) = @_;
	defined $v or return delete $$x->[$i];
	ref $v or croak "Bad value for Spy::Array element";
	B::AV::store $x, $i, \$v;
}
sub FETCHSIZE : method { my $x = $_[0]; scalar @$$x }
sub STORESIZE : method { my $x = $_[0]; $#$$x = $_[1] - 1; }
sub EXTEND : method { B::AV::extend $_[0], $_[1] - 1; }
sub EXISTS : method { exists ${$_[0]}->[$_[1]] }
sub DELETE : method { _refs \delete ${$_[0]}->[$_[1]] }
sub CLEAR : method { @${$_[0]} = (); }
sub PUSH : method {
	my $x = shift;
	ref $_ or croak "Bad value for Spy::Array element" for @_;
	B::AV::push $x, \$_ for @_;
}
sub POP : method { _refs \pop @${$_[0]} }
sub SHIFT : method { _refs \shift @${$_[0]} }
sub UNSHIFT : method {
	my $x = shift;
	ref $_ or croak "Bad value for Spy::Array element" for @_;
	B::AV::unshift $x, scalar @_;
	my $i = 0;
	B::AV::store $x, $i++, \$_ for @_;
}
sub SPLICE : method {
	my ($x, $i, $l) = splice(@_, 0, 3);
	$i = 0 unless defined $i;
	$i += @$$x if $i < 0;
	$i >= 0 or croak "Splice offset out of bounds";
	$l = @$$x - $i unless defined $l;
	$l = @$$x - $i + $l if $l < 0;
	$l >= 0 or croak "Splice length out of bounds";
	ref $_ or croak "Bad value for Spy::Array element" for @_;
	_refs \splice(@$$x, $i, $l, (undef) x @_),
			map B::AV::store($x, $i++, \$_), @_
}

# lowercase aliases
BEGIN {
	no strict 'refs';
	*{lc $_} = \&$_ for qw(FETCH STORE EXTEND EXISTS DELETE CLEAR PUSH
				POP SHIFT UNSHIFT SPLICE);
	*size = _property \&FETCHSIZE, \&STORESIZE;
}

1;

__END__

=head1 NAME

Spy::Array - Spy on an array variable

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
