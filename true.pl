#!/usr/bin/perl -wl

# Who said Perl couldn't have true and false keywords? :)

use Spy;  # fun fun fun
use strict;
use Carp;


BEGIN {
    package FALSE;
    use overload
        '""' => sub { 'FALSE' },
        '0+' => sub { 0 },
        cmp  => sub { '' cmp $_[1] },
        bool => sub { 0 },
        '${}' => sub { ::croak "Not a SCALAR reference" },
        fallback => 1;
    package TRUE;
    use overload
        '""' => sub { 'TRUE' },
        '0+' => sub { 1 },
        cmp  => sub { '1' cmp $_[1] },
        bool => sub { 1 },
        '${}' => sub { ::croak "Not a SCALAR reference" },
        fallback => 1;

    package main;
    spy(\!0)->readonly = 0;           spy(\!1)->readonly = 0;
    ${\!0} = bless \my $x, 'TRUE';    ${\!1} = bless \my $y, 'FALSE';
    spy(\!0)->readonly = 1;           spy(\!1)->readonly = 1;
}


sub TRUE  () { !0 }
sub FALSE () { !1 }

print 1 != 1;
print ! ! "Juerd is having fun with Spy.pm";  # so very true
print( (1 == 1) == TRUE );
print( (1 == 1) eq TRUE );
print( (1 == 1) eq 'TRUE');  # false, as it should be
print( (1 == 1) == 1 );

__END__


output:

FALSE
TRUE
TRUE
TRUE
FALSE
TRUE
