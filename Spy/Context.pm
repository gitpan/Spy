# $Id: Context.pm,v 1.5 2003/03/06 16:30:16 xmath Exp $

package Spy::Context;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Object';

use overload
	'0+' => sub { $_[0][0] + $_[0][1] / 10000 },
	'""' => sub { "$_[0][0]->[$_[0][1]]" },
	fallback => 1;

use Carp;
use B::More;

sub _new : method { bless(\@_, shift)->rebless }

sub type : method { "CONTEXT" }
sub noun : method { "a context" }
sub ref : method { croak "Can't call ref on Spy::Context object" }

sub prev : method {
	my ($s, $i) = @{+shift};
	($i -= (@_ ? $_[0] : 1)) >= 0 or return;
	$s->context($i)
}

my @cx_types = qw(sort sub eval loop subst block format);
my @cx_classes = qw(Block Sub Eval Loop Subst Block Format);

sub rebless : method {
	my $t = $cx_classes[B::SI::cx_type(@{$_[0]}) & 255];
	$t ? bless $_[0], "Spy::Context::$t" : $_[0]
}

sub kind : method {
	my $t = B::SI::cx_type(@{$_[0]}) & 255;
	$cx_types[$t] || $t
}


package Spy::Context::Block;
BEGIN { our @ISA = 'Spy::Context' }

package Spy::Context::Sub;
BEGIN { our @ISA = 'Spy::Context::Block' }

package Spy::Context::Eval;
BEGIN { our @ISA = 'Spy::Context::Block' }

package Spy::Context::Loop;
BEGIN { our @ISA = 'Spy::Context::Block' }

sub itercur : method {
	my @x = @{$_[0]};
	my $a = B::SI::loop_iterary @x;
	$$a or return;
	my $l = B::SI::loop_iterlval @x;
	my $i = B::SI::loop_iterix @x;
	$a->SvTYPE != 10 ? $$l ? () : $i-1 : $i
}

sub iternext : method {
	my @x = @{$_[0]};
	my $a = B::SI::loop_iterary @x;
	$$a or return;
	my $i = B::SI::loop_iterix @x;
	if ($a->SvTYPE == 10) {
		my $m = ($$a == ${$x[0]}) ? B::SI::blk_oldsp(@x) : @{$a->svref};
		return (++$i >= $m) ? () : $i;
	}
	my $l = B::SI::loop_iterlval @x;
	$$l	? ($l->FLAGS & 0x00030000) ? () : $a->PV
		: ($i > B::SI::loop_itermax @x) ? () : $i
}

package Spy::Context::Format;
BEGIN { our @ISA = 'Spy::Context::Block' }

package Spy::Context::Subst;
BEGIN { our @ISA = 'Spy::Context' }

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
