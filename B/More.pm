# $Id: More.pm,v 1.4 2003/03/03 14:49:39 xmath Exp $

package B::More;

use 5.006;
use strict;
use warnings;
no warnings 'redefine';

our $VERSION = "1.01_01";

use Carp;
use B;

require XSLoader;
XSLoader::load('B::More', $VERSION);

sub B::PVMG::magic : method {
	my $x = shift->MAGIC;
	my $type = shift;
	croak "Too many arguments for 'magic'" if @_;
	if (not defined $type) {
		for (; $x && $$x; $x = $x->MOREMAGIC) {
			$type .= $x->TYPE;
		}
		return $type;
	}
	for (; $x && $$x; $x = $x->MOREMAGIC) {
		return $x if $x->TYPE eq $type;
	}
	return;
}

*B::SVs_PADBUSY = \&B::More::SVs_PADBUSY;
*B::SVs_OBJECT  = \&B::More::SVs_OBJECT;

*B::IV::UVX = \&B::More::SvUVX;
*B::IV::int_value = sub {
	my $self = $_[0];
	(B::SV::FLAGS($self) & B::SVf_IVisUV) ?
		B::IV::UVX($self) : B::IV::IV($self)
};

1;

__END__

=head1 NAME

B::More - Additional introspection methods and functions

=head1 DESCRIPTION

Adds stuff I needed in B and wasn't there :-)

Feel free to email me with suggestions for other methods I can add.

=head2 B::SV METHODS

=over 4

=item svref

Inverse of B::svref_2object.

=back

=head2 B::PVMG METHODS

=over 4

=item magic

Returns a string containing the types of all MAGIC.

=item magic TYPE

Returns the B::MAGIC object for the magic with specified type, or undef if 
no magic with that type was found.

=back

=head1 FUNCTIONS

=over 4

=item defstash

Returns the default stash (main::) as B::HV object.

=item curstash

Returns the current stash (package) as B::HV object.  Note that this only 
makes sense at compile time (in a BEGIN-block or in eval-string).

=back

=head1 SEE ALSO

L<B>, F<perlguts>

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
