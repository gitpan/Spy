package Spy::_property;

# $Id: _property.pm,v 1.1 2003/02/25 01:08:58 xmath Exp $

use 5.006;
use strict;
use warnings;

use Carp;
$Carp::Internal{+__PACKAGE__}++;

our $VERSION = '1.00';

our @EXPORT = qw( _property );
use base 'Exporter';

sub _property {
	my ($fetch, $store) = @_;
	return
		sub : lvalue method {
			return $store->(@_) if @_ > 1;
			tie my $foo, __PACKAGE__, $_[0], $fetch, $store;
			$foo
		};
}

sub TIESCALAR { bless \@_, shift }  # @_ = (class, obj, fetch, store)
sub FETCH { my $x = shift; $x->[1]->($x->[0], @_) }
sub STORE { my $x = shift; $x->[2]->($x->[0], @_) }

1;
