# $Id: Ref.pm,v 1.1 2003/03/06 22:41:15 xmath Exp $

package Spy::Ref;

use 5.006;
use strict;
use warnings;

use Spy;
our $VERSION = $Spy::VERSION;

use base 'Spy::Object';

use Carp;
use B::More;
use Spy::_property;

sub _new : method { bless \@_, shift }

sub ref : method { croak "Can't call ref on a Spy::Ref object" }

BEGIN {
*value = _property sub { shift->getref(@_) }, sub { shift->setref(@_) };
}

sub target : method { spy($_[0]->getref) }


package Spy::Ref::Pointer;
BEGIN { our @ISA = 'Spy::Ref' }

sub noun : method { "a pointer reference" }
sub type : method { "REF/POINTER" }

sub _new {
	$_[1] or return;
	$_[2] = $_[2] ? \&B::swapsv_noinc : \&B::swapsv;
	shift->SUPER::_new(@_)
}

sub getref : method { B::readsv($_[0][0])->svref }

sub setref : method {
	ref $_[1] or croak "Argument not a reference";
	$_[0][1]->($_[0][0], \$_[1])
}

1;
