# $Id: Spy.pm,v 1.9 2003/03/06 22:40:36 xmath Exp $

package Spy;

use 5.006;
use strict;
use warnings;

use Carp;
use B::More;

our $VERSION = "0.00_02";

use base 'Exporter';
our @EXPORT = qw(spy spy_ref spy_scalar spy_var spy_list spy_refs spy_stack
		spy_context);

my @types = (
	('Spy::Scalar') x 9,
	'Spy::LValue',
	'Spy::Array',
	'Spy::Hash',
	'Spy::Code',
	'Spy::Scalar',
	'Spy::Format',
	'Spy::IO'
);

# Spy a referenced variable, or a glob, or a list, or a list of refs
sub spy ($;@) {
	my $x = shift;
	if (not ref $x) {
		if (B::SV::SvTYPE(\\$x) != 13) {
			$x eq 'list' and return spy_list(@_);
			$x eq 'refs' and return spy_refs(@_);
			croak "Can't spy on '$x'";
		}
		@_ and croak "Unexpected arguments for spy(GLOB)";
		return Spy::Glob->_new(B::GV::EGV(\\$x)->svref);
	}
	@_ and croak "Unexpected arguments for spy(REFERENCE)";
	($types[B::SV::SvTYPE \$x] || 'Spy::Variable')->_new($x)
}

# Spy a referenced variable
sub spy_ref ($) {
	ref $_[0] or croak "Argument to spy_ref not a reference";
	($types[B::SV::SvTYPE \$_[0]] || 'Spy::Variable')->_new(@_)
}

# Spy a scalar variable
sub spy_scalar ($) { spy(\$_[0]) }

# Spy any variable
BEGIN {
*spy_var = ($^V ge v5.8.0)
	? sub (\[$@%&*]) { spy(@_) }
	: sub ($) { croak "Spy::Var requires perl 5.8.0" };
}

# Spy a list of scalars
sub spy_list (@) { Spy::List->_new(map \$_, @_) }

# Spy a list of references to scalars
sub spy_refs (@) {
	ref $_ or croak "Argument to spy_refs not a reference" for @_;
	Spy::List->_new(@_)
}

# Spy on the current stack / context
sub spy_stack () { Spy::Stack->_new(B::curstackinfo) }
sub spy_context () { spy_stack->context(-4) }

# make sure all classes are loaded
require Spy::Variable;
require Spy::Scalar;
require Spy::LValue;
require Spy::Array;
require Spy::Hash;
require Spy::Code;
require Spy::Format;
require Spy::IO;
require Spy::Glob;
#require Spy::List;
require Spy::Stack;
require Spy::Context;

1;

__END__

=head1 NAME

Spy - Perl introspection classes

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
