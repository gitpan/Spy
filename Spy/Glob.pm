# $Id: Glob.pm,v 1.3 2003/02/28 19:50:49 xmath Exp $

package Spy::Glob;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Object';

use Carp;
use B::More;

sub type : method { "GLOBDATA" }
sub noun : method { "glob data" }
sub ref : method { $${$_[0]} }

1;

__END__

=head1 NAME

Spy::Glob - Spy on glob data

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
