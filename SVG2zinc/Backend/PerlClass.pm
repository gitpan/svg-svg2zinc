package SVG::SVG2zinc::Backend::PerlClass;

#	Backend Class for SVG2zinc
# 
#	Copyright 2003
#	Centre d'Études de la Navigation Aérienne
#
#	Author: Christophe Mertz <mertz@cena.fr>
#
#       An concrete class for code generation for Perl Class
#
# $Id: PerlClass.pm,v 1.2 2003/10/10 14:30:57 mertz Exp $
#############################################################################

use SVG::SVG2zinc::Backend;
use File::Basename;

@ISA = qw( SVG::SVG2zinc::Backend );

use vars qw( $VERSION);
($VERSION) = sprintf("%d.%02d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/);

use strict;
use Carp;

sub new {
    my ($class, %passed_options) = @_;
    my $self = {};
    bless $self, $class;
    $self->_initialize(%passed_options);
#    my $file = $self->{-svgfile}; print "file=$file=", $passed_options{-svgfile},"\n";
    return $self;
}


sub treatLines {
    my ($self,@lines) = @_;
    foreach my $l (@lines) {
	$l =~ s/->/\$_zinc->/g;
	$self->printLines($l);
    }
}

sub fileHeader {
    my ($self) = @_;
    my $file = $self->{-in}; # print "file=$file\n";
    my ($svg2zincPackage) = caller;
    my $VERSION = eval ( "\$".$svg2zincPackage."::VERSION" );
    my ($package_name) = basename ($self->{-out}) =~ /(.*)\.pm$/ ;
    
    $self->printLines("package $package_name;

####### This file has been generated from $file by SVG::SVG2zinc.pm Version: $VERSION

");
    $self->printLines(
<<'HEADER'
use Tk;
use Tk::Zinc 3.295;
use Tk::PNG;  # only usefull if loading png file
use Tk::JPEG; # only usefull if loading png file
use Tk::Zinc::SVGExtension;
use strict;

use Carp;
		      

sub new {
    my ($class, %passed_options) = @_;
    my $self = {};
    bless $self, $class;

    my $_zinc = $passed_options{-zinc};
    croak ("-zinc option is mandatory at instanciation") unless defined $_zinc;

    if (defined $passed_options{-topGroup}) {
	$self->{-topGroup} = $passed_options{-topGroup}; ## CM10
    } else {
	$self->{-topGroup} = 1;
    }
    

# on now items creation!
HEADER
);
}


sub fileTail {
    my ($self) = @_;
    $self->comment ("", "Tail of SVG2zinc::Backend::PerlScript", "");
    $self->printLines(
<<'TAIL'
return $self;
}

1;
TAIL
);
    $self->close;
}


1;

