package SVG::SVG2zinc::Backend;

#	Backend for SVG2zinc
# 
#	Copyright 2003
#	Centre d'Études de la Navigation Aérienne
#
#	Author: Christophe Mertz <mertz@cena.fr>
#
#       An abstract class for code generation
#       Concrete sub-classes can generate code for perl (script / module), tcl,
#       printing, or direct execution
#
# $Id: Backend.pm,v 1.5 2003/09/09 14:35:57 mertz Exp $
#############################################################################

use strict;
use Carp;
use FileHandle;

use vars qw( $VERSION);
($VERSION) = sprintf("%d.%02d", q$Revision: 1.5 $ =~ /(\d+)\.(\d+)/);

sub new {
    my ($class, %passed_options) = @_;
    my $self = {};
    bless $self, $class;
    $self->_initialize(%passed_options);
    return $self;
}

my %new_options = (
		   -outfile => "",
		   -svgfile => "",
		   -svg2zincversion => "",
		   -zincversion => "",
		   -verbose => "",
);

sub _initialize {
    my ($self, %passed_options) = @_;
    my %options = %new_options;
    foreach my $opt (keys (%passed_options)) {
	if (defined ($new_options{$opt})) {
	    $self->{$opt} = $passed_options{$opt};
	} else {
	    carp ("Warning: option $opt unknown for a ".ref($self)."\n");
	}
    }
    croak("undefined mandatory -svgfile options") unless defined $self->{-svgfile};
    if (defined ($self->{-outfile})) {
	my $fh = FileHandle->new("> " . $self->{-outfile});
	if ($fh) {
	    $self->{-filehandle} = $fh;
	} else {
	    carp ("unable to open " . $self->{-outfile});
	}
    }

    return $self;
}

# returns true if code is put in a file
sub inFile {
    my ($self) = @_;
    return (defined $self->{-filehandle});
}

sub printLines {
    my ($self, @lines) = @_;
    if ($self->inFile) {
	my $fh = $self->{-filehandle};
	foreach my $l (@lines) {
	    print $fh "$l\n";
	}
    }
}

sub treatLines {
    my ($self, @lines) = @_;
    if ($self->inFile) {
	$self->printLines(@lines);
    }
}


## in case of file generation, should print a comment
## the default is to print comment starting with #
sub comment {
    my ($self, @lines) = @_;
    if ($self->inFile) {
	foreach my $l (@lines) {
	    $self->printLines("##  $l");
	}
    }
}

sub close {
    my ($self) = @_;
    if ($self->inFile) {
	$self->{-filehandle}->close;
    }
}

sub fileHeader {
    my ($self) = @_;
    $self->comment ("", "default Header of SVG::SVG2zinc::Backend", "");
}


sub fileTail {
    my ($self) = @_;
    $self->comment ("", "default Tail of SVG::SVG2zinc::Backend", "");
    $self->close;
}


	
1;
