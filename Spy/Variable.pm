# $Id: Variable.pm,v 1.12 2003/03/02 16:31:23 xmath Exp $

package Spy::Variable;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Object';

use Carp;
use B::More;
use Spy::_property;

sub noun : method { "a variable" }

sub refcount : method {
	B::SV::REFCNT($_[0]) - 1	# exclude ourself from refcount
}

my %flags = (
	lexical		=> B::SVs_PADBUSY,
	blessed		=> B::SVs_OBJECT,
	integer		=> B::SVf_IOK | B::SVp_IOK,
	number		=> B::SVf_NOK | B::SVp_NOK,
	string		=> B::SVf_POK | B::SVp_POK,
	reference	=> B::SVf_ROK,
	readonly	=> B::SVf_READONLY,
);

sub flag : method {
	! !(($flags{$_[1]} || int $_[1]) & B::SV::FLAGS $_[0])
}

sub flags : method {
	my $flags = B::SV::FLAGS $_[0];
	my %flags;
	while (my ($k, $v) = each %flags) { $flags{$k}++ if $flags & $v }
	\%flags
}

BEGIN {
*readonly = _property(
	sub : method { shift->flag('readonly') },
	sub : method {
		B::SV::chflags $_[0],
			$_[1] ? (B::SVf_READONLY, 0) : (0, B::SVf_READONLY);
	});

*tainted = _property(
	sub : method { B::SV::TAINTED(@_) || undef },
	sub : method {
		($_[1] ? \&B::SV::TAINTED_on : \&B::SV::TAINTED_off)->($_[0]);
	});

*blessed = _property(
	sub : method { $_[0]->flag('blessed') &&
			Spy::Stash->_new(B::PVMG::SvSTASH(@_)->svref) },
	sub : method {
		my ($obj, $s) = @_;
		defined $s or return B::SV::curse $obj;
		if (!ref $s) {
			no strict 'refs';
			$s =~ s/(::)?\z/::/;
			$s = *{$s}{HASH};
		}
		if (ref $s eq 'Spy::Stash') {
			$s = $$s;
		} elsif (spy($s)->type ne 'STASH') {
			croak $_[1], " is not a valid stash or package name";
		}
		B::SV::bless $obj, \$s;
	});
}

sub lexical  : method { shift->flag('lexical') }

1;

__END__

=head1 NAME

Spy::Variable - Spy on a perl variable

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
