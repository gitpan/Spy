# $Id: IO.pm,v 1.4 2003/02/26 18:57:47 xmath Exp $

package Spy::IO;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Variable';

use Carp;
use B::More;

sub type : method { "IO" }
sub noun : method { "a file handle" }

1;

__END__

=head1 NAME

Spy::IO - Spy on a file handle (IO variable)

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
