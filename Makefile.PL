# $Id: Makefile.PL,v 1.1 2003/02/25 01:08:57 xmath Exp $

use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'Spy',
	DIR		=> [ 'B' ],
	PMLIBDIRS	=> [ 'Spy' ],
        VERSION_FROM	=> 'Spy.pm',
	ABSTRACT_FROM   => 'Spy.pm',
	AUTHOR          => 'Matthijs van Duin <xmath@cpan.org>',
);
