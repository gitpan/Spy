# $Id: LValue.pm,v 1.5 2003/02/26 18:57:47 xmath Exp $

package Spy::LValue;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Scalar';

use Carp;
use B::More;

sub type : method { "LVALUE" }
sub noun : method { "an lvalue" }

sub target : method {
	my $targ = B::PVLV::TARG $_[0] or return;
	Ref($targ->svref)
}

1;

__END__

=head1 NAME

Spy::LValue - Spy on an lvalue variable

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
