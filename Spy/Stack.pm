# $Id: Stack.pm,v 1.4 2003/03/04 23:25:12 xmath Exp $

package Spy::Stack;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Object';

use Carp;
use B::More;

sub type : method { "STACK" }
sub noun : method { "a stack" }

sub _new : method {
	my ($class, $si) = @_;
	$si or return; 
	$class->SUPER::_new($$si)
}

my @si_types = qw(unknown undef main magic sort signal overload destroy
	warnhook diehook require);

sub kind : method {
	my $t = B::SI::type(@_);
	$t >= -1 && $si_types[$t+1] || $t
}

sub prev : method { Spy::Stack->_new(B::SI::prev(@_)) }

sub contexts : method { B::SI::cxix(@_)+1 }

sub context : method {
	my ($stack, $index) = @_;
	my $count = $stack->contexts;
	$index += $count if $index < 0;
	$index >= 0 && $index < $count or return;
	Spy::Context->_new($stack, $index);
}

1;

__END__

=head1 NAME

Spy::Stack - Spy on a perl stack

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
