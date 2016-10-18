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
#  By downloading/cloning/using this database and tools you accept the following terms:
#  
#  1. Please inform the author at [novakat@gmail.com](mailto:novakat@gmail.com) about your use of the database/tools
#  clearly indicating what you use this database or tool for in your application/experiment/resource.
#  
#  2. If possible, please publish a scientific paper about each application, experimental system
#  or linguistic resource you create or experiment you perform using this resource quoting the articles below,
#  and inform the author at [novakat@gmail.com](mailto:novakat@gmail.com) about each article you publish. 
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
#  
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

#-addplus:	add plus marks between suffix morphs
#-conv2lgr:	convert lexical forms to Rebrus lgr specification
#-rmseg:	remove segmantation marks from lexical forms

BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";
use lib "$hpldir/gen";

#use Data::Dump qw(dump);
use Data::Dumper;
$Data::Dumper::Terse=0;
$Data::Dumper::Indent=1;
$Data::Dumper::Deepcopy=1;

require 'm2getopt.pl';

$encoding="encoding$gen.hpl" unless $encoding;
require $encoding;
$defaultmtx='n' unless defined $defaultmtx;
=cmt
$trans="metadict${gen}_trans.hpl" unless $trans;
require $trans;
$mtx="mtx${gen}.hpl" unless $mtx;
require $mtx;
=cut

require 'diewarn.pl';
require 'banner.pl';

$lc='a-záéíóúöüőű' unless defined $lc;#lower case letters
$uc='A-ZÁÉÍÓÚÖÜŐŰ' unless defined $uc;#upper case letters

$C="(?:dzs|[ds]z|[cz]s|[ltgn]y|[rtpsdfghjklcvbnmz])" unless defined $C; #consonants

#capitalize word
eval
'
sub capit
{
	my($a,$b)=$_[0]=~/(.)(.*)/;
	$a=~tr/'.$lc.'/'.$uc.'/;
	$a.$b;
}
';

#turn word to all lower case
eval
'
sub alllc
{
	my($a)=$_[0];
	$a=~tr/'.$uc.'/'.$lc.'/;
	$a;
}
';

#turn word to all upper case
eval
'
sub alluc
{
	my($a)=$_[0];
	$a=~tr/'.$lc.'/'.$uc.'/;
	$a;
}
';

do 'delim.hpl' unless $delim;
$delim="\x1" unless $delim;

@lr=('r','l');
@lr1=('right','left');

start_banner('X allomorph lexicon generator');

warn("Using encoding file $encoding\n");

sub getencoding
{
	my($pr)=$_[0];
	my($mc);
	if($pr)
	{
		$mc=$Gpropset->{$pr}[6]?-1:$Gpropset->{$pr}[0];#mark matrix-unjoinable morphs with #-1
		die1("Encoding not found for: $pr ($ssrf, $restr)\n") if !$Gpropset->{$pr}[0];
	}
	else
	{
		$mc=0; # default id is #0; it matches anything
	}
	$mc;
}

$zeroch="\x1";
$joinch="\x2";
sub align
{
	my($ssrf,$slex,$smcat)=@_;
	if($conv2lgr&&length $slex>1)
	{
		$slex=~tr/@#%=(){}^()?!"/~~~~/d;
		$slex=~s/_([^[+]*)/_'$1'/;
	}
	elsif($rmseg&&length $slex>1)
	{
		$slex=~tr/@#%=(){}^()?!"//d;
		$slex=~s/_([^[+]*)//;
		$slex=~s/\*(?![* ])//g;
	}
	my(@ssrf)=split/\+/,$ssrf,-1;
        @ssrf=('') unless @ssrf;
	my(@slex)=split/\+/,$slex,-1;
        @slex=('') unless @slex;
	my(@smcat)=split/\+/,$smcat,-1;
        @smcat=('') unless @smcat;
	my($i,$srf,$lex,$cat,$n,@l,$pos,@s,$srfpcl,$sl,$ll,@rsrf,@rlex);

	for($n=0;$n<=$#ssrf;$n++)
	{
		$srf=$ssrf[$n];
		$lex=$slex[$n];
		$cat=$smcat[$n];
		$lex=~s/\[.*?\]//g;
		if(!$srfonly&&!/^\%/)
		{
		@l=split(/(?<!&)([~*@#%(){}^=()?!"]+)|\[.*?\]/,$lex,-1);
		for($i=0,$pos=0,undef @s;$i<=$#l;$i+=2)
		{
			#$l[$i]
			$srfpcl=$srfpc=substr($srf,$pos,length($l[$i]));
			#$srfpcl=~tr/A-ZÁÉÍÓÚÖÜŐŰ/a-záéíóúöüőű/;
			$srfpcl=alllc($srfpcl);
			#$l[$i]=~tr/A-ZÁÉÍÓÚÖÜŐŰ/a-záéíóúöüőű/;
			$l[$i]=alllc($l[$i]);
			if($srfpcl eq $l[$i])
			{
#				push(@s,$srfpc,$l[$i+1]);
				push(@s,$srfpc,$zeroch x length($l[$i+1]));
				$pos+=length($l[$i]);
				next if $i<$#l;
			}
			push(@s,substr($srf,$pos)),last;
		}
		$srf=join('',@s) if @l;
#		$srf=~s/=$//;
#		$srf=~s/((?:[*@#%(){}^=()?!]+)|\[.*?\]|_.*)/$zeroch x length $1/eg;
		$sl=length($srf);
		$ll=length($lex);
		$lex.=${zeroch}x ($sl-$ll) if $sl>$ll;
		$srf.=${zeroch}x ($ll-$sl) if $sl<$ll;
		}
		$lex.="\[$cat]",$srf.=${zeroch} if $cat;
		$lex.='+',$srf.=${zeroch} if $n<$#ssrf && $addplus;
		push @rsrf,$srf;
		push @rlex,$lex;
	}
#	warn(join ("\t",@rsrf)."\n");
#	warn(join ("\t",@rlex)."\n");
	join('',@rlex).$joinch.join('',@rsrf);
}

eval '
sub zeroch
{
	$entry=~tr/'.$zeroch.$joinch.'/0:/;
}
';

#add start conditions to matrix continuation classes
die "\$startcond_propset not defined in $encoding\n" if !defined $startcond_propset;

$rc=getencoding($startcond_propset);
@rm=@{$Gpropset->{$startcond_propset}[3]};#right matrix

$mtx->{"M_$rm[0]_${rc}"}++;

warn "Excl.: $excl\n" if defined $excl;
while(<>)
{
	chomp;
#	s/&plus;/\\+/g; #turn &plus; to \+
	($prr,$prl,$srf,$ssrf,$slex,$scat,$lem,$hyph,$restr,$smcat)=split /${delim}/;
	$_.="restr:$restr;";
	next if defined $excl && /$excl/o;
#	if(!$generator)
#	{
#		next if $restr=~/g/i;
#		#$ssrf=~s/\*$//;
#	}
	if($Gpropset->{$prr}[6] || $Gpropset->{$prl}[6])
	{
		warn("Unjoinable morph (sequence) skipped:\n$ssrf,$slex,$smcat,$restr\n");
		next;
	}

	$rc=getencoding($prr);#right code
	$lc=getencoding($prl);#left code
	@cat=@{$Gpropset->{$prr}[5]};#list of compatible word grammar categories
#	@trns=map{@{$transitions->{$_}}}@cat;#list of all word grammar transitions
	@rm=$rc?@{$Gpropset->{$prr}[3]}:($defaultmtx);#right matrix
	@lm=$lc?@{$Gpropset->{$prl}[3]}:($defaultmtx);#left matrices
=cmt
	for(@trns)
	{
		($s1,$s2)=/(.*?)->(.*)/;
		for $lm(@lm)
		{
			
		}
	}
=cut
	if($nocat)
	{
		$entry=$srf;
	}
	else
	{
		if($srfonly)
		{
			$entry=align($ssrf,$ssrf,$smcat);
		}
		else
		{
			#Hungarian specific: align VZA stems
			$ssrf=~s/($C)($C)$/${1}$zeroch$2/o if $prr=~/[^!]VZA/;
                        $entry=align($ssrf,$slex,$smcat);#align surface and lexical form
		}
	}
	$entry=~s/([\s!\%0:;"<>])/\%$1/go;#escape special characters in entry
	zeroch();#fix zero character and :

#	warn("$srf,$ssrf,$slex,$smcat, > $entry rm:@rm, rc:$rc, lm:@lm, lc:$lc\n");
	for $wcat(@cat)
	{
		for $lm(@lm)
		{
			for $rm(@rm)
			{
				$cc="R_(${wcat})_${rm}_${rc}";
				($cc1=$cc)=~s/([\s!\%;"<>])/\%$1/go;#escape special characters in lexicon name
				$lex="L_${lm}_${lc}";
				$line="lex:$lex\t$entry\t$cc1;\trestr:$restr;\n";
				next if defined $excl && $line=~/$excl/;
				print $line;
				$ccs->{$cc}++;
				$lexs->{$lex}++;
				$mtx->{"M_${rm}_${rc}"}++;
			}
		}
	}
}

open O,">$encoding.morphclasses.hpl" or die "$encoding.morphclasses.hpl could not be created\n";
#print O "\$Rclasses=\n";
#$a=dump($ccs);
#print O "$a;\n\n";
$a=Data::Dumper->Dumpxs([$ccs],['Rclasses']);
$a=~s/ {8,}/    /g;
print O "$a\n\n";

#print O "\$Lclasses=\n";
#$a=dump($lexs);
#print O "$a;\n\n";
$a=Data::Dumper->Dumpxs([$lexs],['Lclasses']);
$a=~s/ {8,}/    /g;
print O "$a\n\n";

#print O "\$Mclasses=\n";
#$a=dump($mtx);
#print O "$a;\n\n";

$a=Data::Dumper->Dumpxs([$mtx],['Mclasses']);
$a=~s/ {8,}/    /g;
print O "$a\n";
close O;
#warn1 time-$stm." seconds elapsed";
die_if_errors();
end_banner();
