# $Id: 1.t,v 1.1 2003/02/25 01:08:58 xmath Exp $
# make; perl -Iblib/lib t/1.t
# vim: ft=perl

use Test::Simple tests => 6;
use B::More;

my $obj = "foo";
my $sv = B::svref_2object(\$obj);
ok( $sv->svref == \$obj );

my @obj;
my $av = B::svref_2object(\@obj);
ok( $av->svref == \@obj );

my %obj;
my $hv = B::svref_2object(\%obj);
ok( $hv->svref == \%obj );

sub obj {}
my $cv = B::svref_2object(\&obj);
ok( $cv->svref == \&obj );

my $ok = \&ok;

my $main = B::defstash->svref;
$ok->( B::curstash->svref == $main );

package Foo;

my $cur = eval "B::curstash->svref"; 
my $foo = *{$main->{'Foo::'}}{HASH};
$ok->( $cur == $foo );
