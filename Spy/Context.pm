# $Id: Context.pm,v 1.2 2003/03/03 14:49:13 xmath Exp $

package Spy::Context;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use overload
	bool => sub { 1 },	# should become false if context is gone
	'0+' => sub { $_[0][0] + $_[0][1] },
	'""' => sub { "$_[0][0]->[$_[0][1]]" },
	'==' => sub { ref($_[0]) eq ref($_[1]) && $_[0][0] == $_[1][0]
						&& $_[0][1] == $_[1][1] },
	fallback => 1;

use Carp;
use B::More;

sub _new : method { bless \@_, shift }

sub type : method { "CONTEXT" }
sub noun : method { "a context" }

sub stack : method { $_[0][0] }
sub index : method { $_[0][1] }

sub prev : method {
	my ($s, $i) = @{+shift};
	($i -= (@_ ? $_[0] : 1)) >= 0 or return;
	$s->context($i)
}

my @cx_types = qw(sort sub eval loop subst block format);

sub kind : method {
	my $t = B::SI::CXTYPE(@{$_[0]}) & 255;
	$cx_types[$t] || $t
}

1;

__END__

=head1 NAME

Spy::Context - Spy on a context

=head1 DESCRIPTION

=head1 AUTHOR

Matthijs van Duin <xmath@cpan.org>

Copyright (C) 2003   Matthijs van Duin.  All rights reserved.
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
