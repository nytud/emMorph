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
use lib "$hpldir/gen";

#use Data::Dump qw(dump);

require 'm2getopt.pl';

require 'diewarn.pl';
require 'banner.pl';

start_banner('X word grammar lexicon generator');

$encoding="encoding$gen.hpl" unless $encoding;
$trans="metadict.txt.trans.hpl" unless $trans;

require "$encoding.morphclasses.hpl";
require $trans;
require $encoding;

sub getencoding
{
	my($pr)=$_[0];
	if($pr)
	{
		$mc=$Gpropset->{$pr}[6]?-1:$Gpropset->{$pr}[0];#mark matrix-unjoinable morphs with #-1
		die1("Encoding not found for: $pr ($ssrf)\n") if !$Gpropset->{$pr}[0];
	}
	else
	{
		$mc=0; # default id is #0; it matches anything
	}
	$mc;
}

#generate root lexicon with start conditions defined in encoding

die "\$startcond_propset not defined in $encoding\n" if !defined $startcond_propset;

$rc=getencoding($startcond_propset);
@rm=@{$Gpropset->{$startcond_propset}[3]};#right matrix

if($guess)
{
print "\nLEXICON Root\n";
print "<";
print "?* " if $guess;
print "%\@U%.St%.$root%\@> M_$rm[0]_$rc;\n";
}
else
{
print "\nLEXICON Root\n\@U.St.$root\@ M_$rm[0]_$rc;\n";
}

for(sort keys %$Rclasses)
{
	($cc=$_)=~s/([\s!\%;"<>])/\%$1/go;#escape special characters in lexicon name
	print "\nLEXICON $cc\n";
	($wcat,$rmrc)=/R_\((.*?)\)(_.*)/;
	for(@{$transitions->{$wcat}})
	{
#		warn "$_\n";
		($s1,$s2,$cond)=/^(.*?)->(.*?);(.*)/;
#		warn "$s1\t$s2\t$cond\n";
		print "\@U.St.$s1\@\@P.St.$s2\@${cond} M$rmrc;\n";
#		print "\@U.St.$s1\@\@P.St.$s2\@${cond}+:\@U.St.$s1\@\@P.St.$s2\@${cond}0 M$rmrc;\n";
		#for final states: add a transition to #
		print "\@U.St.$s1\@\@P.St.$s2\@${cond} #;\n" if $final->{$s2};
	}
	#to make empty lexicons OK
	if(!@{$transitions->{$wcat}})
	{
		print "\@D.St\@ #;\n";
	}
}

die_if_errors();
end_banner();

