package SVG::SVG2zinc::Backend::Print;

#	Backend Class for SVG2zinc
# 
#	Copyright 2003
#	Centre d'Études de la Navigation Aérienne
#
#	Author: Christophe Mertz <mertz@cena.fr>
#
#       An concrete class for code printing for Perl Scripts/Modules
#       This Backend is for svg2zinc debug purpose mainly
#
# $Id: Print.pm,v 1.4 2003/10/17 16:25:47 mertz Exp $
#############################################################################

use SVG::SVG2zinc::Backend;

@ISA = qw( SVG::SVG2zinc::Backend );

use vars qw( $VERSION);
($VERSION) = sprintf("%d.%02d", q$Revision: 1.4 $ =~ /(\d+)\.(\d+)/);

use strict;
use Carp;

sub treatLines {
    my ($self,@lines) = @_;
    foreach my $l (@lines) {
	print "$l\n";
    }
}


sub fileHeader {
#    my ($self) = @_;
}


sub fileTail {
#    my ($self) = @_;
}


1;

