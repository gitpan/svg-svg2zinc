#!/usr/bin/perl -w

use SVG2zinc::Backend;
my $backend = SVG2zinc::Backend->new(-svgfile => "titi.svg",
				     -svg2zincversion => "1.2.3",
				     -outfile => "/tmp/backend.txt");

$backend->fileHeader;
$backend->comment("comment1", "comment2");
$backend->fileTail;


use SVG2zinc::Backend::PerlScript;
my $perlscript = SVG2zinc::Backend::PerlScript->new(-svgfile => "toto.svg",
						    -svg2zincversion => "3.4.5",
						    -outfile => "/tmp/perlscript.pl");

$perlscript->fileHeader;
$perlscript->comment("comment1", "comment2");
$perlscript->treatLines("->add('text',2,-text => 'essai');");
$perlscript->fileTail;


use SVG2zinc::Backend::PerlModule;
my $perlmodule = SVG2zinc::Backend::PerlModule->new(-svgfile => "toto.svg",
						    -svg2zincversion => "3.4.5",
						    -outfile => "/tmp/perlmodule.pm");

$perlmodule->fileHeader;
$perlmodule->comment("comment1", "comment2");
$perlmodule->treatLines("->add('text',2,-text => 'essai');");
$perlmodule->fileTail;

