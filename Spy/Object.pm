# $Id: Object.pm,v 1.2 2003/03/06 16:30:16 xmath Exp $

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
	'==' => sub { ref($_[0]) eq ref($_[1]) && 0+$_[0] == 0+$_[1] },
	fallback => 1;

use Carp;
use B::More;

sub _new : method {
	my ($class, $ref) = @_;
	bless \$ref, $class
}

sub ref : method { ${$_[0]} }
sub noun : method { undef }
sub type : method { undef }

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
