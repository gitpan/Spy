# $Id: Object.pm,v 1.1 2003/02/28 15:45:01 xmath Exp $

package Spy::Object;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use overload
	bool => sub { 1 },
	'0+' => sub { int ${$_[0]} },
	'""' => sub { sprintf "%s(0x%x)", ref($_[0]), int(${$_[0]}) },
	'==' => sub { ref($_[0]) eq ref($_[1]) && ${$_[0]} == ${$_[1]} },
	fallback => 1;

use Carp;
use B::More;

sub _new : method {
	my ($class, $ref) = @_;
	$ref && $class->can('type') or return;
	my $addr = int \$ref;
	my $obj = bless \$ref, $class;
#	B::SV::chflags \$addr, B::SVf_READONLY, 0;
	$obj
}

sub ref : method { ${$_[0]} }
sub noun : method { undef }

1;

__END__

=head1 NAME

Spy::Object - Abstract base class for spy-objects

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
