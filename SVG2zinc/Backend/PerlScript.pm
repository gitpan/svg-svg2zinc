package SVG::SVG2zinc::Backend::PerlScript;

#	Backend Class for SVG2zinc
# 
#	Copyright 2003
#	Centre d'Études de la Navigation Aérienne
#
#	Author: Christophe Mertz <mertz@cena.fr>
#
#       A concrete class for code generation for Perl Scripts
#
# $Id: PerlScript.pm,v 1.8 2003/09/18 08:54:04 mertz Exp $
#############################################################################

use SVG::SVG2zinc::Backend;

@ISA = qw( SVG::SVG2zinc::Backend );

use vars qw( $VERSION);
($VERSION) = sprintf("%d.%02d", q$Revision: 1.8 $ =~ /(\d+)\.(\d+)/);

use strict;
use Carp;

sub new {
    my ($class, %passed_options) = @_;
    my $self = {};
    bless $self, $class;
    $self->_initialize(%passed_options);
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
    my $file = $self->{-svgfile}; # print "file=$file\n";
    my $VERSION = $self->{-svg2zincversion} || "unknown";
    $self->printLines("#!/usr/bin/perl -w

####### This file has been generated from $file by SVG::SVG2zinc.pm Version: $VERSION
");


    $self->printLines(
<<'HEADER'
use Tk::Zinc;
use Tk::Zinc::Debug;
use Tk::PNG;  # only usefull if loading png file
use Tk::JPEG; # only usefull if loading png file

use Tk::Zinc::SVGExtension;

my $mw = MainWindow->new();
$mw->title('$file');

my ($WIDTH,$HEIGHT) = (800,600);
my $zinc = $mw->Zinc(-width => $WIDTH, -height => $HEIGHT,
		     -borderwidth => 0,
                     -backcolor => "white", # pourquoi blanc?
		     -render => 1,
		      )->pack;
&Tk::Zinc::Debug::finditems($zinc);
&Tk::Zinc::Debug::tree($zinc, -optionsToDisplay => '-tags', -optionsFormat => 'row');
my $top_group = 1; ###$zinc->add('group', 1);

my $_zinc=$zinc;

{ ###

HEADER
    );
}


sub fileTail {
    my ($self) = @_;
    $self->printLines(
<<'TAIL'
	   }

### on va retailler et translater les objets créés!

my @bbox = $_zinc->bbox($top_group);
$_zinc->translate($top_group, -$bbox[0], -$bbox[1]);
@bbox = $_zinc->bbox($top_group);
my $ratio = 1;
$ratio = $WIDTH / $bbox[2] if ($bbox[2] > $WIDTH);
$ratio = $HEIGHT/$bbox[3] if ($HEIGHT/$bbox[3] lt $ratio);
$zinc->scale($top_group, $ratio, $ratio);

### on ajoute quelques binding bien pratiques pour la mise au point

$_zinc->Tk::bind('<ButtonPress-1>', [\&press, \&motion]);
$_zinc->Tk::bind('<ButtonRelease-1>', [\&release]);
$_zinc->Tk::bind('<ButtonPress-2>', [\&press, \&zoom]);
$_zinc->Tk::bind('<ButtonRelease-2>', [\&release]);

# $_zinc->Tk::bind('<ButtonPress-3>', [\&press, \&mouseRotate]);
# $_zinc->Tk::bind('<ButtonRelease-3>', [\&release]);
$_zinc->bind('all', '<Enter>',
	[ sub { my ($z)=@_; my $i=$z->find('withtag', 'current');
			my @tags = $z->gettags($i);
			pop @tags; # pour enlever 'current'
			print "$i (", $z->type($i), ") [@tags]\n";}] );

&Tk::MainLoop;


##### bindings for moving, rotating, scaling the items
my ($cur_x, $cur_y, $cur_angle);
sub press {
    my ($zinc, $action) = @_;
    my $ev = $zinc->XEvent();
    $cur_x = $ev->x;
    $cur_y = $ev->y;
    $cur_angle = atan2($cur_y, $cur_x);
    $zinc->Tk::bind('<Motion>', [$action]);
}

sub motion {
    my ($zinc) = @_;
    my $ev = $zinc->XEvent();
    my $lx = $ev->x;
    my $ly = $ev->y;
    my @res = $zinc->transform($top_group, [$lx, $ly, $cur_x, $cur_y]);
    $zinc->translate($top_group, $res[0] - $res[2], $res[1] - $res[3]);
    $cur_x = $lx;
    $cur_y = $ly;
}

sub zoom {
    my ($zinc, $self) = @_;
    my $ev = $zinc->XEvent();
    my $lx = $ev->x;
    my $ly = $ev->y;
    my $maxx;
    my $maxy;
    my $sx;
    my $sy;
    
    if ($lx > $cur_x) {
	$maxx = $lx;
    } else {
	$maxx = $cur_x;
    }
    if ($ly > $cur_y) {
	$maxy = $ly
    } else {
	$maxy = $cur_y;
    }
    return if ($maxx == 0 || $maxy == 0);
    $sx = 1.0 + ($lx - $cur_x)/$maxx;
    $sy = 1.0 + ($ly - $cur_y)/$maxy;
    $cur_x = $lx;
    $cur_y = $ly;
    $zinc->scale($top_group, $sx, $sx); #$sy);
}

sub mouseRotate {
    my ($zinc) = @_;
    my $ev = $zinc->XEvent();
    my $lx = $ev->x;
    my $ly = $ev->y;
    my $langle = atan2($ly, $lx);
    $zinc->rotate($top_group, -($langle - $cur_angle));
    $cur_angle = $langle;
}

sub release {
    my ($zinc) = @_;
    $zinc->Tk::bind('<Motion>', '');
}
TAIL
);
    $self->close;
}


1;

