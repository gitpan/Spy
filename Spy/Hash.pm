# $Id: Hash.pm,v 1.7 2003/03/02 16:31:23 xmath Exp $

package Spy::Hash;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Variable';

use Carp;
use B::More;

sub type : method { "HASH" }
sub noun : method { "a hash" }

sub _new : method {
	my ($class, $ref) = @_;
	$ref or return;
	$class =~ s/Spy::Hash/Spy::Stash/ if defined B::HV::NAME \$ref;
	return $class->SUPER::_new($ref);
}

1;

__END__

=head1 NAME

Spy::Hash - Spy on a hash variable

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
