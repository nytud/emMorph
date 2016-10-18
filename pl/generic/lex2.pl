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

BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";
#use Storable;

require 'normform.pl';
require 'sfxtags.hpl';

do 'delim.hpl' unless $delim;
$delim="\x1" unless $delim;
sub linechange
{
}
#if linechange() is defined in linechange.pl,
#it should return true if it changed $lx2line
do 'linechange.pl';

#my $propsets=retrieve('propsets.tmp');

{
my %mtags;

#convert category tag sequences: add a prefix denoting morphological category
#to each tag as given in %mcat (loaded from sfxtags.hpl)

#usually:
#I_	inflection
#D=POS_	derivational suffix converting to POS
#S_	stem (this is the default)
#P_	prefix

sub mtags
{
	my($tags,$hcat)=@_;
	return $mtags{$tags} if defined $mtags{$tags};
	my($res)=join('+',map{($mcat{$_}?$mcat{$_}:'S').'_'.$_}split(/\+/,$tags));
#	$res=~s/D=(?:[^_]+)_(?!.*\+[PSD][=_])/D=${hcat}_/ if $hcat;
	warn $res if $res=~/((?:^|\+)(?:S_([^+]+)|D=([^=_]+)_[^+]+)\+D=)=[^_]+/;
	while($res=~s/((?:^|\+)(?:S_([^+]+)|D=([^=_]+)_[^+]+)\+D=)=[^_]+/$1$2$3/){warn $res};
	$mtags{$tags}=$res unless $tags=~/rov|abbr/i;
	$res;
}
}

sub segcat
{
	my ($seg,$cat)=@_;
	my @seg=split(/\+/,$seg);
	my @cat=split(/\+/,$cat);
	my $res;

	for(my $i=0;$i<=$#cat;$i++)
	{
		$res.="$seg[$i]\[$cat[$i]\]";
	}
	$res;
}

my @lr=('r','l');
my @lr1=('right','left');

#$srf: surface form
#$ssrf: +-segmented surface form
#$slex: +-segmented lexical form
#$scat: +-separated list of morpheme category names
#$smcat: +-separated list of morpheme categories, each prefixed
#	with morphological category P_, S_ (stem), D=POS_ (deriv sfx) or I_ (inflection)
#$lem: lemma
#$hyph: hyphenated form
#$srf1: surface form of 1st morpheme
#$cat: category tag of 1st morpheme
#$hcat:	head category of the morph sequence

sub lex2
{
#	my $out=shift;
	my $mrf=shift;

	my $cat=$mrf->{$tagname};
	$cat='?' if !$cat;#!!! if we do not know category
	my $seg=$mrf->{'seg'};
	$seg=~s/(^|\+)[=@*]/$1/;
	if(defined $mrf->{'equ'}&&!$noequtag)
	{
		my $equ=$mrf->{'equ'};
		$equ=~tr/+@#//d;
		$equ=~s/ +/_/g;
		$mrf->{gseg}=$seg unless defined $mrf->{gseg};
		$seg.="_$equ";#add what it is an abbreviation for
	}
	my ($srf,$scat,$srf1,$slex,$ssrf,$lem,$lemmrfs,$pr,$smcat,$AB63);
	#$AB63 is used for 6-3 rule in Hungarian
	for(@{$mrf->{'allomfs'}}) #generate allomorphs
	{

		next if !defined $_->{'allomf'}||($_->{'allomf'}=~/\@$/&&!$generator);
#		next if $mrf->{'lemma'}=~/,/; # avoid ji, ji, ji
		$srf=$_->{'allomf'}; #surface form
#		$srf=~s/[\*|\@](?!$)|[;].+//g;
#		$srf=~s/[*\@]|[;].+//g;
#		$scat=$srf; #segmented category
		$scat=$_->{'cats'}; #segmented category
		$srf=~s/\[.*?\]//g; #remove tags from srf form
		$slex=$srf;
		$slex=~s/[*\@]//g;
		#change {a>á} to a in lex form, to á in srf form
#		$srf=~s/\{[^}>]*>([^}>]*)\}/$1/g;
#		$slex=~s/\{([^}>]*)>[^}>]*\}/$1/g;
		$srf1=$ssrf=$slex;
		$hyph=$srf;
		$srf=~s/[\+\*@]//go; #remove +'s from srf form 
		$srf1=~s/\+.*//; # srf form of 1st morpheme
		#the lexseg feature may contain a segmented lexical form which differs from seg
		#but it must contain just as many segments
		#the first segment of the segmented lexical form (slex)
		#is the value of the seglex feature or if that's empty
		#it is the value of the seg feature or if that's empty
		#and $mrf->{'seg'} is not empty
		#it is the first surface segment
		$lem=$_->{'lexseg'} or $lem=$mrf->{'lexseg'} or $lem=$seg or !$mrf->{'seg'} or $lem=$srf1;
		#count the morphs in the lemma (minus 1)
		$lemmrfs=$lem=~tr/+//;
#		$lem=~s/[+,].*//;
#		$slex=~s/^[^+]*/$lem/;
		#substitute the lemma for the first $lemmrfs+1 morphs in slex
		$slex=~s/^[^+]*(?:\+[^+]*){$lemmrfs}/$lem/;
		#remove everything from scat other than categories and +'s
		if($scat=~/\[./)
		{
			$scat=~s/\+/\[+\]/g;
			$scat=~s/.*?\[(.*?)\]/$1/g;
			$scat=~s/^\++/+/;
		}
		else
		{
			$scat='';
		}
		$scat=$cat.$scat if $scat=~/^\+|^$/;
		$ssrf=~s/\+//g,$slex=~s/\+//g if $scat!~/\+/; #remove +'s if no + in cat
		#create property set of allomorph
		$mtxbit='';
		norm_allomf($_);#normalize allomorph
		for $k('r','l')
		{
			$pr=$_->{"${k}p"};
			$pr.=','.$_->{"${k}r"} if $_->{"${k}r"};
			if($pr)
			{
				$pr="$k,$pr";
				$pr1="$pr;<<";
				#restrictions (if any) are part of the key
				$pr1.=";restr:$_->{'restr'}" if $_->{'restr'};
				#store to $propsets hash
				$propsets->{$pr1}="$_->{'allomf'}" if !defined $propsets->{$pr1};
			}
			$mtxbit.="$pr${delim}";
		}
		$smcat=mtags($scat,$mrf->{'hcat'});
		$AB63="$1$2" if $mtxbit=~/A=(.)[& ]B=(.)/;
=cmt
		#gather possible suffix category sequences
		if($smcat=~/(?:^|\+)[DI]/)
		{
			$sfxcat=$smcat;
			$sfxcat=~s/(^|\+)(?:[SP]_[^+]*|I_|D=[^_]*)/$1/g;
			$sfxcat=~s/^\++//;
			$sfxcat=~s/\|[^+]*//g;
			$sfxcat=~s/\+/][/g;
			$sfxcat{'['.$sfxcat.']'}++;
		}
=cut
		$cat!~/\+/ and $segcat="$seg\[$cat]" or $segcat=segcat($seg,$cat);
		for($srf,$ssrf,$slex,$scat,$smcat,$lem){s/(?=$delim)/\\/go;}
		$lx2line="$mtxbit$srf${delim}$ssrf${delim}$slex${delim}$scat${delim}$lem${delim}$hyph${delim}$_->{'restr'}${delim}$smcat${delim}$segcat${delim}$mrf->{'phon'}${delim}$mrf->{'root'}${delim}$mrf->{'UR'}${delim}$mrf->{'X'}${delim}$AB63`\n";
		print LX2 $lx2line;
		print LX2 $lx2line if linechange();
		if($mrf->{'gseg'}&&$_->{'restr'}!~/a/)
		{
#			$slex=~s/^\Q$seg/$mrf->{'gseg'}/;
			$slex=~s/^[^+]*/$mrf->{'gseg'}/;
			$lem=$slex;
			$lem=~s/\+.*//;
			$lx2line="$mtxbit$srf${delim}$ssrf${delim}$slex${delim}$scat${delim}$lem${delim}$hyph${delim}$_->{'restr'}G${delim}$smcat${delim}$segcat${delim}$mrf->{'phon'}${delim}$mrf->{'root'}${delim}$mrf->{'UR'}${delim}$mrf->{'X'}${delim}$AB63`\n";
			print LX2 $lx2line;
			print LX2 $lx2line if linechange();
		}
	}
}

sub print_propsets
{
	my $out=shift;
	open(PPS,">$out.propsets") or die "Unable to create property list file $out.propsets";
	for(sort(keys(%$propsets)))
	{
		print PPS "$_;$propsets->{$_}>>\n";
	}
	close(PPS);
=cmt
	#print gathered suffix category sequences
	open(PPS,">$out.sfxseq") or die "Unable to create suffix tag sequence file $out.sfxseq";
	for(sort(keys(%sfxcat)))
	{
		print PPS "$_\n";
	}
	close(PPS);
=cut
}
