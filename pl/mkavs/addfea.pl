################################################## START OF LICENSE ##################################################
#
#  This file is part of the emMorph / Humor morphological analyzer description for Hungarian.
#  Copyright (C) 2001-2016 Attila Novák
#  
#  The author of the database and the database compilation environment is Attila Novák (novakat@gmail.com).
#  The resource is available from: https://github.com/dlt-rilmta/emMorph
#  
#  The database files are licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0
#  (CC BY-NC-SA) license, the compilation scripts under the GNU General Public License (GPL v3)
#  with the following amendments:
#  
#  By downloading/cloning this database and tools you accept the following terms:
#  1. Please inform the author at novakat@gmail.com about your use of the database/tools clearly indicating what you use them for
#  as soon as you start working on your application/experiment/resource involving this database or tool.
#  2. Even in the case of non-academic use, you promise to publish a scientific paper about 
#  each application, experimental system or linguistic resource you create or experiment you perform using this resource quoting
#  the articles below, and inform the author at novakat@gmail.com about each article you publish.
#  If you definitely cannot publish an article, please contact the author.
#  
#  Articles to quote are listed at https://github.com/dlt-rilmta/emMorph, the list is currently the following:
#  (See the BibTeX file quotethis.bib in the root directory):
#  
#  Attila Novák (2014): A New Form of Humor – Mapping Constraint-Based Computational Morphologies to a Finite-State Representation.
#  In: Proceedings of the 9th International Conference on Language Resources and Evaluation (LREC-2014). Reykjavík, pp. 1068–1073 (ISBN 978-2-9517408-8-4)
#  
#  Attila Novák; Borbála Siklósi; Csaba Oravecz (2016): A New Integrated Open-source Morphological Analyzer for Hungarian
#  In: Proceedings of the Tenth International Conference on Language Resources and Evaluation (LREC 2016). Portorož, pp. 1315–1322.
#  
#  Novák Attila (2003): Milyen a jó Humor? [What is good Humor like?] In: Magyar Számítógépes Nyelvészeti Konferencia (MSZNY 2003). Szegedi Tudományegyetem, pp. 138–145
#  
#  3. Please do share your adaptations of the morphology (vocabulary extensions etc.) using the same licenses.
#  4. If you are interested in using or adapting the resource for commercial purposes, please contact the author.
#  ***
#  
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#
################################################## END OF LICENSE ##################################################

use utf8;
use open qw/:encoding(utf8)/;
use open qw/:std :encoding(utf8)/;

BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";

require 'banner.pl';
start_banner('Level 1 stem lexicon unifier');
require 'm2getopt.pl';

$warnaddonly=1 unless defined $warnaddonly;
$strictcat=1 unless defined $strictcat;

die "Add properties from addlex to baselex (the files must be identically sorted):
Usage: perl addfea.pl [-switches] {baselex.lx1} {addlex.lx1} >{result.lx1}
Switches:
-errtofile	write error comments to output file
-warnbaseonly	warn about base entries not in additional lexicon
-warnaddonly=0	do not warn about additional entries not in base lexicon
-strictcat=0	do not be strict on category match
-ignorecase	ignore case mismatches
-addonlytag=..	define tag to be added to additional entries not in base lex.
-baseonlytag=..	define tag to be added to base entries not in add. lex.
-noaddonly	do not add additional entries not in base lexicon
		(only add features to already existing entries)
-nobaseonly	do not add base entries not in the additional lexicon
-baseonly	list entries which only appear in base lexicon
-addonly	list entries which only appear in additional lexicon
-addseg		use segmented form as it appears in additional lexicon
-addpropfirst	properties coming form the additional lexicon should precede those
		coming from the base lexicon

" unless $#ARGV==1;

if($errtofile)
{
	open(ERR, ">&STDOUT") || die "Can't dup stdout";
}
else
{
	open(ERR, ">&STDERR") || die "Can't dup stderr";
}
select(ERR); $| = 1;
select(STDOUT); $| = 1;

#remove segmentation characters
sub rmsgm
{
	local $_=shift;
#	s/[?!#=+%@&^(){}"]|[<[].*?[]>]|\.\.\.|_.*//g;
	s/[?!#=+%@&^(){}"]|[<[].*?[]>]|_.*//g;
        tr/A-ZÁÉÍÓÚÖÜŐŰ.-/a-záéíóúöüőű/d if $ignorecase;
	$_;
};

#read and parse an input word
sub readwd
{
        $a=shift;
        local $_=<$a>;
        chomp;
	my ($as,$acat,$ap)=/^(\s*;?[^;]*?)\[([^\]]+)\];(.*)/;
	#segmented form, category, properties
	$aw=$as;
	$aw=~s/^\s*;?//;
	my $aw=reverse(rmsgm($aw));
        my $awlc=$aw;
        $awlc=~tr/A-ZÁÉÍÓÚÖÜŐŰ.-/a-záéíóúöüőű/d;
	($_,$aw,$awlc,$as,$acat,$ap);
}

$cats='(?:[FM]N|SZN|HA|IGE|IK|NU)';
sub compatible
{
	my ($a,$b)=@_;

	return 1 if $a=~/^\??$/||$b=~/^\??$/;
	$a=join '#',sort map{s/\|[^&]*//g;s/($cats)[a-z]+/$1/go;$_}($a,$b);
#	return 1 if $a=~/FN#MN/;
	$a=~/($cats)(?:\&$cats)*#(?:$cats\&)*\1/o;

}

sub merge2
{
	my $f;
	open(B,$f=shift) or die "Unable to open base lexicon file $f";
	open(A,$f=shift) or die "Unable to open additional lexicon file $f";

	my $files=2;
	undef($a),$files-- if eof(A);
	undef($b),$files-- if eof(B);
	my ($a,$aw,$awlc,$as,$acat,$ap)=readwd(\*A);
	my ($b,$bw,$bwlc,$bs,$bcat,$bp)=readwd(\*B);
	while($files)
	{
		while(defined $b && (!defined($a)||$bwlc lt $awlc||($bwlc eq $awlc&&$bw lt $aw)))
		{
			unless($nobaseonly||$addonly)
			{
				print ERR ("*$b*WARN:Base lexicon entry missing from additional lexicon\n") if $warnbaseonly;
				print "$b$baseonlytag\n";
			}
			undef($b),$files--,last if eof(B);
			($b,$bw,$bwlc,$bs,$bcat,$bp)=readwd(\*B);
		}
		while(defined $a && (!defined($b)||$bwlc gt $awlc||($bwlc eq $awlc&&$bw gt $aw)))
		{
			unless($noaddonly||$baseonly)
			{
				print ERR ("*$a*WARN:Additional lexicon entry missing from base lexicon\n") if $warnaddonly;
				print "$a$addonlytag\n";
			}
			undef($a),$files--,last if eof(A);
			($a,$aw,$awlc,$as,$acat,$ap)=readwd(\*A);
		}
		while(defined $a && defined $b && ($bw eq $aw))
		{
			if(!$strictcat&&compatible($bcat,$acat)||$bcat eq $acat)
			{
				unless($baseonly||$addonly)
				{
					print ERR ("*$bs\[$bcat];$bp$ap*WARN:Category mismatch $bcat/$acat (base category $bcat assumed)\n") if $bcat ne $acat;
					$prop=$addpropfirst?"$ap$bp":"$bp$ap";
					$seg=$addseg?$as:$bs;
					print "$seg\[$bcat];$prop\n";
				}
				undef($a),$files-- if eof(A);
				undef($b),$files-- if eof(B);
				($a,$aw,$awlc,$as,$acat,$ap)=readwd(\*A);
                                while($bcat=~/&/&&defined $a && defined $b && ($bw eq $aw)&&(compatible($bcat,$acat)||$bcat eq $acat))
                                {
					unless($baseonly||$addonly)
					{
						print ERR ("*$as\[$acat];$ap*WARN:Category mismatch $bcat/$acat (additional entry skipped)\n") if $bcat ne $acat;
					}
					undef($a),$files-- if eof(A);
					($a,$aw,$awlc,$as,$acat,$ap)=readwd(\*A);
                                }
				($b,$bw,$bwlc,$bs,$bcat,$bp)=readwd(\*B);
			}
			elsif($bcat lt $acat)
			{
				unless($nobaseonly||$addonly)
				{
					print ERR ("*$b*WARN:Category mismatch $bcat/$acat: base lexicon entry\n");
					print "$b$baseonlytag\n";
				}
				undef($b),$files--,last if eof(B);
				($b,$bw,$bwlc,$bs,$bcat,$bp)=readwd(\*B);
			}
			else
			{
				unless($noaddonly||$baseonly)
				{
					print ERR ("*$a*WARN:Category mismatch $bcat/$acat: additional lexicon entry\n");
					print "$a$addonlytag\n";
				}
				undef($a),$files--,last if eof(A);
				($a,$aw,$awlc,$as,$acat,$ap)=readwd(\*A);
			}
		}
	}
}

merge2(shift,shift);
end_banner();
