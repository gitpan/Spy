# $Id: Code.pm,v 1.5 2003/03/02 16:31:23 xmath Exp $

package Spy::Code;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Variable';

use Carp;
use B::More;

sub type : method { "CODE" }
sub noun : method { "a sub" }

sub stash : method { Spy::Stash->_new(B::CV::STASH($_[0])->svref) }
sub glob : method { Spy::Glob->_new(B::CV::GV($_[0])->svref) }
sub file : method { B::CV::FILE($_[0]) }
sub depth : method { B::CV::DEPTH($_[0]) }
sub outside : method { Spy::Code->_new(B::CV::OUTSIDE($_[0])->svref) }

1;

__END__

=head1 NAME

Spy::Code - Spy on a code variable

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
