# $Id: Makefile.PL,v 1.3 2003/03/06 22:38:59 xmath Exp $

use 5.006;
use ExtUtils::MakeMaker;

print STDERR q(
############################################
Development of Spy is suspended - see README
############################################

);

WriteMakefile(
	NAME		=> 'Spy',
	DIR		=> [ 'B' ],
	PMLIBDIRS	=> [ 'Spy' ],
        VERSION_FROM	=> 'Spy.pm',
	ABSTRACT_FROM   => 'Spy.pm',
	AUTHOR          => 'Matthijs van Duin <xmath@cpan.org>',
);
