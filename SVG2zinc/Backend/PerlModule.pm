package SVG::SVG2zinc::Backend::PerlModule;

#	Backend Class for SVG2zinc
# 
#	Copyright 2003
#	Centre d'Études de la Navigation Aérienne
#
#	Author: Christophe Mertz <mertz@cena.fr>
#
#       An concrete class for code generation for Perl Modules
#
# $Id: PerlModule.pm,v 1.6 2003/09/17 14:22:31 mertz Exp $
#############################################################################

use SVG::SVG2zinc::Backend;

@ISA = qw( SVG::SVG2zinc::Backend );

use vars qw( $VERSION);
($VERSION) = sprintf("%d.%02d", q$Revision: 1.6 $ =~ /(\d+)\.(\d+)/);

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

#sub _initialize {
#    my ($self, %passed_options) = @_;
#    $self->SUPER::_initialize(%passed_options);
#    return $self;
#}

sub treatLines {
    my ($self,@lines) = @_;
    foreach my $l (@lines) {
	$l =~ s/->/\$_zinc->/g;
	$self->printLines($l);
    }
}

sub fileHeader {
    my ($self) = @_;
    my $file = $self->{-svgfile}; # print "file=$file\n";
    my $VERSION = $self->{-svg2zincversion} || "unknown";
    my ($package_name) = $self->{-outfile} =~ /([^\/]*)\.pm$/ ;
    
    $self->printLines("package $package_name;

####### This file has been generated from $file by SVG::SVG2zinc.pm Version: $VERSION

");
    $self->printLines(
<<'HEADER'
use Tk;
use Tk::Zinc;
use Tk::PNG;  # only usefull if loading png file
use Tk::JPEG; # only usefull if loading png file
use Tk::Zinc::ZincExtension;
use strict;
require Toccata::Subject;
use vars '@ISA';
@ISA = 'Toccata::Subject';


sub populate {
  my ($self, $args) = @_;
  $self->SUPER::populate ($args);
  $self->configspec (-zinc =>	['PASSIVE'],
		     -top_group => ['PASSIVE'],
		    );
}

sub new{
  
  my $proto = shift;
  my $type = ref ($proto) || $proto;
  my $self = $type->SUPER::new (@_);
  bless $self;
  
  my $_zinc = $self -> {-zinc};
  my $top_group = $self -> {-top_group};

{ ###
HEADER
);
}


sub fileTail {
    my ($self) = @_;
    $self->comment ("", "Tail of SVG2zinc::Backend::PerlScript", "");
    $self->printLines(
<<'TAIL'
		      }
}

1;
TAIL
);
    $self->close;
}


1;

