# $Id: Stash.pm,v 1.6 2003/02/27 15:11:22 xmath Exp $

package Spy::Stash;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Hash';
use overload
	'""' => \&name,
	fallback => 1;

use Carp;
use B::More;

sub noun : method { "a stash" }
sub type : method { "STASH" }

sub name : method { B::HV::NAME $_[0] }

1;

__END__

=head1 NAME

Spy::Stash - Spy on a symbol table

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
