# $Id: Scalar.pm,v 1.11 2003/03/02 16:31:23 xmath Exp $

package Spy::Scalar;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Variable';

use Carp;
use B::More;
use Spy::_property;

sub type : method {
	my $obj = shift;
	$obj->flag('reference') ? "REF" :
		13 == B::SV::SvTYPE($obj) ? "GLOB" : "SCALAR"
}

sub noun : method {
	my $obj = shift;
	$obj->flag('reference') ? "a reference" :
		13 == B::SV::SvTYPE($obj) ? "a glob" : "a scalar"
}

sub integer : method {
	my $obj = shift;
	$obj->flag('integer') &&
		($obj->flag(0x80000000) ? 'unsigned' : 'signed')
}

sub number : method { $_[0]->flag('number') && 'number' }
sub string : method { $_[0]->flag('string') && 'string' }

sub value : lvalue method { $${$_[0]} }

sub target : method {
	my $obj = shift;
	my $type = $obj->type;
	return spy($$$obj) if $type eq 'REF';
	return undef if $type ne 'GLOB';
	Spy::Glob->_new(B::GV::EGV($obj)->svref)
}

BEGIN {

*intvalue = _property
	sub { $_[0]->flag('integer') && B::IV::int_value $_[0] },
	sub {
		my $obj = $_[0];
		$obj->flag('readonly') and
			croak "Modification of a read-only value attempted";
		defined $_[1] or return B::SV::chflags $obj, 0, 0x01010000;
		my $type = B::SV::SvTYPE $obj;
		if ($type == 3 || $type > 8) {
			croak "Can't set intvalue of " . $obj->noun;
		} elsif (!$type) {
			B::SV::UPGRADE $obj, 1;
		} elsif ($type > 1 && $type < 5) {
			B::SV::UPGRADE $obj, 5;
		}
		B::IV::setIVX $obj, $_[1];
		B::SV::chflags $obj, 0x01010000, 0;
	};

*numvalue = _property
	sub { $_[0]->flag('number') && B::NV::NVX $_[0] },
	sub {
		my $obj = $_[0];
		$obj->flag('readonly') and
			croak "Modification of a read-only value attempted";
		defined $_[1] or return B::SV::chflags $obj, 0, 0x02020000;
		my $type = B::SV::SvTYPE $obj;
		if ($type == 3 || $type > 8) {
			croak "Can't set numvalue of " . $obj->noun;
		} elsif ($type < 2) {
			B::SV::UPGRADE $obj, 2;
		} elsif ($type < 6) {
			B::SV::UPGRADE $obj, 6;
		}
		B::NV::setNVX $obj, $_[1];
		B::SV::chflags $obj, 0x02020000, 0;
	};

*strvalue = _property
	sub { $_[0]->flag('string') && B::PV::PV $_[0] },
	sub {
		my $obj = $_[0];
		$obj->flag('readonly') and
			croak "Modification of a read-only value attempted";
		defined $_[1] or return B::SV::chflags $obj, 0, 0x04040000;
		my $type = B::SV::SvTYPE $obj;
		if ($type == 3 || $type > 8) {
			croak "Can't set strvalue of " . $obj->noun;
		} elsif ($type < 4) {
			B::SV::UPGRADE $obj, 4;
		}
		B::PV::setPVX $obj, $_[1];
		B::SV::chflags $obj, 0x04040000, 0;
	};

}

1;

__END__

=head1 NAME

Spy::Scalar - Spy on a scalar variable

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
