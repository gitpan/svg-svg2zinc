package SVG::SVG2zinc::Backend::Exec;

#	Backend Class for SVG2zinc
# 
#	Copyright 2003
#	Centre d'Études de la Navigation Aérienne
#
#	Author: Christophe Mertz <mertz@cena.fr>
#
#       An concrete class for code generation and execution
#
# $Id: Exec.pm,v 1.4 2003/09/17 14:22:31 mertz Exp $
#############################################################################

use SVG::SVG2zinc::Backend;

@ISA = qw( SVG::SVG2zinc::Backend );

use vars qw( $VERSION);
($VERSION) = sprintf("%d.%02d", q$Revision: 1.4 $ =~ /(\d+)\.(\d+)/);

use strict;
use Carp;
use Tk::Zinc::SVGExtension;

sub new {
    my ($class, %passed_options) = @_;
    my $self = {};
    bless $self, $class;
    $self->_initialize(%passed_options);
    return $self;
}

sub _initialize {
    my ($self, %passed_options) = @_;
    if ($passed_options{-zinc_var}) {
	$self->{-zinc_var} = delete $passed_options{-zinc_var};
    } else {
	carp "-zinc_var option is mandatory for an Exec Backend";
    }
    $self->SUPER::_initialize(%passed_options);
    return $self;
}


sub treatLines {
    my ($self,@lines) = @_;
    my $verbose = $self->{-verbose};
    my $z_var = $self->{-zinc_var};
    foreach my $l (@lines) {
	my $expr = $l;
	$expr =~ s/->/$z_var->/g;

	my $r = eval ($expr);
	if ($@) {
#	    &myWarn ("While evaluationg:\n$expr\nAn Error occured: $@\n");
	    print "While evaluationg:\n$expr\nAn Error occured: $@\n";
	} elsif ($verbose) {
	    if ($l =~ /^add/) {
		print "$r == $expr\n" if $verbose;
	    } elsif ($l =~ /^->/ ) {
		print $z_var,$expr,"\n" if $verbose;
	    } else {
		print "$expr\n" if $verbose;
	    }
	}
    }
}


sub fileHeader {
#    my ($self) = @_;
}


sub fileTail {
#    my ($self) = @_;
}


1;

