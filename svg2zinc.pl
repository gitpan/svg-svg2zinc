#!/usr/bin/perl -w
#
#      svg2zinc.pl, a Perl/zinc display SVG files or to generate zinc-perl code
# 
#      Copyright (C) 2002-2003
#      Centre d'Études de la Navigation Aérienne
#
#      Authors: Christophe Mertz <mertz@cena.fr>
#
# $Id: svg2zinc.pl,v 1.14 2003/09/08 15:06:00 mertz Exp $
#-----------------------------------------------------------------------------------

my $TAG= q$Name: cpan_0_05 $;
my $REVISION = q$Revision: 1.14 $ ;
my ($VERSION) = $TAG =~ /^\D*([\d_]+)/ ;
if (defined $VERSION and $VERSION ne "_") {
    $VERSION =~ s/_/\./g;
} else {
    $VERSION = $REVISION;
}

use strict;
use XML::Parser;
use SVG::SVG2zinc;
use Getopt::Long;
#use Tk::PNG;

################ commande line options treatment
my ($out, $displayResult);
my $verbose = 0;
my $render = 1;
my $namespace = 0;
my $zinc_version;
GetOptions("help" => \&usage,
	   "out:s" => \$out,
	   "test" => \$displayResult,
	   "verbose" => \$verbose,
	   "render:i" => \$render,
	   "namespace" => \$namespace,
	   "version" => \&displayVersion,
	   "zinc_version:s" => \$zinc_version,
           );

sub usage {
    my ($error) = @_;
    print "$0 options svgfile\n";
    print " where options are :\n";
    print "  -help           : to get this little help\n";
    print "  -verbose        : to get more warning or prints\n";
    print "  -version        : to print the current SVG::SVG2zinc version\n";
    print "  -render (0|1|2) : to select Zinc rendering mode (default to 1)\n";
    print "  -namespace      : to treat XML namespace\n";
    print "  -out filename   : the file to be generated\n";
    print "       filename should end either with .pl (a perl script)\n";
    print "                               or with .pm (a perl module)\n";
    print "  -test           : to display in a Zinc\n";
    print "  -zinc_version version : to select a zinc version. Only possible with -out option\n";
    print "  -test and -out are exclusive. If none is selected,\n";
    print "   $0 just try to interpret the svgfile and prints some code\n";
    print "$error\n" if defined $error;
    exit;
}

&usage unless ($#ARGV == 0);
&usage ("-test and -out options are exclusive\n") if $out and $displayResult;
&usage ("Bad value ($render) for -render option. Must be 0, 1 or 2") unless ($render == 0 or $render == 1 or $render == 2);

my $file = $ARGV[0];

my $zinc;
my $mw;
my ($WIDTH,$HEIGHT) = (600,600);
my $top_group;

if ($displayResult) {
    ### the SVG file is parsed and the result displayed in a TkZinc widget
    require Tk::Zinc;
    require ZincDebug;

    $mw = MainWindow->new();
    $mw->title($file);
    $zinc = $mw->Zinc(-width => $WIDTH, -height => $HEIGHT,
		      -borderwidth => 0,
		      -render => $render,
		      -backcolor => "white", ## Pourquoi blanc?
		      )->pack(qw/-expand yes -fill both/);
    &ZincDebug::finditems($zinc);
    &ZincDebug::tree($zinc, -optionsToDisplay => "-tags", -optionsFormat => "row");
    $top_group = $zinc->add('group', 1, -tags => ['topsvggroup']);
    $SVG::SVG2zinc::zinc = $zinc;
    $SVG::SVG2zinc::zinc = $zinc; # repetition avoids annoying error message "SVG2zinc::zinc used only once"
    &SVG::SVG2zinc::parse($file,
			  -result_type => "\$SVG::SVG2zinc::zinc",
			  -group => $top_group,
			  -verbose => $verbose,
			  -namespace => $namespace,
			  -zinc_version => $Tk::Zinc::VERSION,
#		          -prefix => "my_prefix",  # used for prefixing every tags generated 
			  );
}
elsif ($out) {
    ### the result will be save in a file
    ### this filename should either be a .pl (script) or .pm (module)
    ### and will generate a perl script or module
    &SVG::SVG2zinc::parse($file,
		     -result_type => $out,
		     -verbose => $verbose,
		     -group => "\$top_group", # this might be useful only for .pm not for .pl
		     -zinc_version => $zinc_version,
		     );
} else {
    ### the svgfile is just parsed, some (partial) code generated
    ### and this partial code printed on stdout
    print "file=$file\n";
    &SVG::SVG2zinc::parse($file,
			  -result_type => 0,
			  -verbose => $verbose,
			  -group => "\$top_group",
			  -zinc_version => $zinc_version,
			  );
}

my $zoom;
if ($displayResult) {
    my @bbox = $zinc->bbox($top_group);
#    print "bbox=@bbox\n";
    $zinc->translate($top_group, -$bbox[0], -$bbox[1]) if defined $bbox[0] and $bbox[1];
    @bbox = $zinc->bbox($top_group);
    my $ratio = 1;
    $ratio = $WIDTH / $bbox[2] if ($bbox[2] and $bbox[2] > $WIDTH);
    $ratio = $HEIGHT/ $bbox[3] if ($bbox[3] and $HEIGHT/$bbox[3] lt $ratio);

#    print "Ratio = $ratio\n";
    $zoom=1;
    $zinc->scale($top_group, $ratio, $ratio);
    $zinc->Tk::bind('<ButtonPress-1>', [\&press, \&motion]);
    $zinc->Tk::bind('<ButtonRelease-1>', [\&release]);
    
    $zinc->Tk::bind('<ButtonPress-2>', [\&press, \&zoom]);
    $zinc->Tk::bind('<ButtonRelease-2>', [\&release]);

    $zinc->Tk::bind('<Control-ButtonPress-1>', [\&press, \&mouseRotate]);
    $zinc->Tk::bind('<Control-ButtonRelease-1>', [\&release]);
    $zinc->bind('all', '<Enter>',
		[ sub { my ($z)=@_; my $i=$z->find('withtag', 'current');
			my @tags = $z->gettags($i);
			pop @tags; # to remove the tag 'current'
			print "$i (", $z->type($i), ") [@tags]\n";}] );
    &Tk::MainLoop;
}






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
    $zinc->translate($top_group, ($res[0] - $res[2])*$zoom, ($res[1] - $res[3])*$zoom);
    $cur_x = $lx;
    $cur_y = $ly;
}

sub zoom {
    my ($zinc, $self) = @_;
    my $ev = $zinc->XEvent();
    my $lx = $ev->x;
    my $ly = $ev->y;
    my ($maxx, $maxy);
    
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
    my $sx = 1.0 + ($lx - $cur_x)/$maxx;
    my $sy = 1.0 + ($ly - $cur_y)/$maxy;
    $cur_x = $lx;
    $cur_y = $ly;
    $zoom = $zoom * $sx;
    $zinc->scale($top_group, $sx, $sx); #$sy);
}

sub mouseRotate {
    my ($zinc) = @_;
    my $ev = $zinc->XEvent();
    my $langle = atan2($ev->y, $ev->x);
    $zinc->rotate($top_group, -($langle - $cur_angle), $cur_x, $cur_y);
    $cur_angle = $langle;
}

sub release {
    my ($zinc) = @_;
    $zinc->Tk::bind('<Motion>', '');
}


sub displayVersion {
    print $0, " : Version $VERSION\n\tSVG::SVG2zinc.pm Version : $SVG::SVG2zinc::VERSION\n";
    exit;
}

__END__

=head1 NAME

svg2zinc.pl - displays a svg file or generates either a perl script or perl module

=head1 SYNOPSIS

B<svg2zinc.pl> [options] <svgfile>

To display a svgfile:

B<svg2zinc.pl> -test <svgfile>

To convert in a script:

B<svg2zinc.pl> -o <script.pl> <svgfile>

To convert in a perl module:

B<svg2zinc.pl> -o <script.pm> <svgfile>

=head1 DESCRIPTION

Please, use -h option, for more info on options

=head1 BUGS and LIMITATIONS

Caveat: When generating a .pm this module requires the Toccata::Subject module, not publicly available. Will be corrected

Mainly the same bugs and limitations of SVG::SVG2zinc(3pm)

=head1 SEE ALSO

SVG::SVG2zinc(3pm) Tk::Zinc(3pm) TkZinc is available at www.openatc.org

=head1 AUTHORS

Christophe Mertz <mertz@cena.fr>

=head1 COPYRIGHT
    
CENA (C) 2002-2003

This program is free software; you can redistribute it and/or modify it under the term of the LGPL licence.

=cut

