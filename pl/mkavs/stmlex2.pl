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

#generate Hungarian level 2 stem lexicon from level 1
BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";
use lib "$hpldir/gen";

$tagname='tag';

sub abcphon{$_[0]}
sub cat2hum{$_[0]}
sub hum2cat
{
	local $_=shift;
	s/(?:.*[+>]|^)(.*)/$1/;
	s/\|.*//;
	$_;
}
sub hum2cat{$_[0]}

require 'dumpsh.pl';
require 'stemalt1.pl';
require 'vhrm.pl';
require 'unif.pl';
require 'lex2.pl';
require 'diewarn.pl';

$avs=1 if !defined $avs;

sub noalm
{
	open(NOA,">$out.noalm"),$noalm=1 unless $noalm;
	print NOA $_;
}

sub chkline
{
	my($c,$err,$w);
#	for $w(split(/(?<!\+)(?=\+\+)/))
	for $w(split(/(?=;\+\+)/))
	{
		$w=~s/;.*/;/;
		if($w=~/^\+\+=/)
		{
			for $c($w=~/((?:^|\++)[^+;]*)/g)
			{
#				$err="Stem category tag should not appear in allomorph declaration at: $c" if $c=~/^\+\+[^+].*\[/;
				$err="Stem category tag should not appear in allomorph declaration at: $c" if $c=~/^\+\+.*\[.*\]/;
#				$err="Stem category tag is missing at: $c" if $c=~/^(?!\+\+)[^[]+$/;
				die1("Ill formed lexicon entry: at line $.\n$_$err\n") if $err;
			}
		}
		elsif($w=~/^\+\+/)
		{
			for $c($w=~/((?:^|\++)[^+;]*)/g)
			{
#				$err="Stem category tag should not appear in allomorph declaration at: $c" if $c=~/^\+\+[^+].*\[/;
				$err="Stem category tag should not appear in allomorph declaration at: $c" if $c=~/^\+\+.*\[.*\]/;
				$err="Stem category tag is missing at: $c" if $c=~/^(?!\+\+)[^[]+$/;
				die1("Ill formed lexicon entry: at line $.\n$_$err\n") if $err;
			}
		}
		else
		{
			$err="Stem category tag is missing at: $w" if $w=~/^(?!\+\+).*[^]];$/;
		}
	}
}

#$stm=time;
$out=shift;
require 'banner.pl';
start_banner('Level 2 stem lexicon generator');

open(LX2,">$out.lx2") or dienow("Unable to create level2 lexicon file $out.lx2");
(open(AVS,">$out.avs") or dienow("Unable to create level2 avs lexicon file $out.avs")),$avs='AVS' if $avs;

while(<>)
{
	next if /^\s*\*|^\s*$/;#||$excl && /$excl/o;
	s/;\s*\*.*/;/;
	chkline();
	#lines ending in a backslash are merged with the next line
	$_=$prevline.$_,undef $prevline if defined $prevline;
	$prevline=$_,next if s/\\+\s*\n//;
	#the entry may contain lexically specified allomorphs, these begin with ++
	@almfs1=split(/(?<=;)\s*\+\+\s*/);
	undef @almfs2;
	for(@almfs1)
	{
#		($seg,$hum,$r)=/\s*(.*?)\[([^]]*)\];(.*)/;
		($seg,$r)=/^\s*(;?(?:[^&;]|\&[^&;\[\]]+;)*?|.*?\[[^][;]*\]);\s*(.*)/;
		while ($r=~s/((?:;|^)r[pr]:[^;]*?)&/$1 /g){}; #change & to space after rp:/rr:
		@fd=split /;\s*/,$r;#split into properties
		undef $mrf;
		$mrf->{'allomf'}=$seg if defined $seg;
		for(@fd)
		{
			($attr,$val)=split/:/;#separate attr and value
			if(defined $val)
			{
#			$val=[split /,\s*/,$val] if $val=~/,/||$attr=~/_/;
			$val=~s/,\s*/ /g;#multiple values separated by space
			blk:{
				do{
				if(!$mrf->{$attr}){$mrf->{$attr}=$val;}#if mrf has no such attribute yet
				else{$mrf->{$attr}.=" $val";}#else add new value
                        	last blk;
				}if $attr!~/_/;#if attribute has no path prefix
				($prp,$attr)=split(/_/,$attr);#else split path
				blk2:{
				#adding an array value to path
				push(@{$mrf->{$prp}{$attr}},@$val),last blk2 if ref $val eq 'ARRAY';
				#or a single scalar value
				$mrf->{$prp}{$attr}=$val;
				}
			}}
		}
		push @almfs2,$mrf;
	}
	$mrf=shift(@almfs2);
        ($seg)=$mrf->{'allomf'}=~/\s*(.*?)$/;
	$seg=~s/([^]\\])\+(?![@#=])/$1*/g; #change compound separator from + to * unless preceded by [CAT] or backslash or followed by @ or # or =
	$hum=join('+',$seg=~/\[([^][]*)\](?=\+|$)/g); #create segmented category tag list
        $seg=~s/\[([^][]*)\](?=\+|$)//g; #remove tags from $seg
#	$seg=~s/([^\\]\+)(?![@#=])/$1*/g; #change + to +* unless followed by @ or # or =
#	($seg,$hum)=$mrf->{'allomf'}=~/\s*(.*?)\[([^][]*)\]$/;

        if (($seg0)=$seg=~/^(.*[*#+])/)
        {
        	$seg0=~s/$srf2rm//og if defined $srf2rm;#remove whatever is defined in $srf2rm (e.g. parentheses)
		for(@almfs2)
		{
			$_->{'allomf'}=~s/^(?!=)/$seg0/ or
			$_->{'allomf'}=~s/^=//;
		}
	}
        elsif(/\+\+=/&&$seg!~/^\s*(=)/)
        {
		for(@almfs2)
		{
			$_->{'allomf'}=~s/^=//;
		}
        }
	$mrf->{'seg'}=$seg if defined $seg;
	$mrf->{phon}=abcphon($seg) if !$mrf->{phon}&&$hum=~/\|ABC(?!x)|\|BETU/;
	#push as many copies of $mrf into @mrfs as there are different cat's in $hum
        @mrfs=map
	{
		$mrf->{cat}=hum2cat($_) unless $mrf->{cat}&&$hum!~/&/;
		$mrf->{$tagname}=$_;
		$hum!~/&/?$mrf:avscpy($mrf);
	}
	(split /&/,$hum);
	#split morphs having multiple pronunciations
        if($mrf->{phon}=~/&/)
        {
        	@ph=split (/&/,$mrf->{phon});
                @mrfs=map
		{
			$mrf=avscpy($_);
			map
			{
				$mrf->{phon}=$_;
				avscpy($mrf);
			}
			@ph;
		}
		@mrfs;
	}
	#split morphs having multiple equivalents
        if($mrf->{equ}=~/&/)
        {
        	@ph=split (/&/,$mrf->{equ});
                @mrfs=map
		{
			$mrf=avscpy($_);
			map
			{
				$mrf->{equ}=$_;
				avscpy($mrf);
			}
			@ph;
		}
		@mrfs;
	}
	warn1 ("Possible syntax error in input lexicon:\n\n$_\n(No allomorphs)"),$error++ if $#mrfs<0;
	for(@mrfs)
	{
#		$alm2=stemalt($_,\@almfs2);
		$almfs2=$hum!~/&/?\@almfs2:avscpy(\@almfs2);
		$alm2=stemalt($_,$almfs2);
		warn1 ("No allomorphs for $_->{seg}\[$_->{cat}\/$_->{$tagname}]"),$error++ if $#$alm2<0;
		$_->{allomfs}=$alm2;#add allomorphs
		$_->{hcat}=cat2hum($_->{cat});
		if($avs)
		{
			#remove allomorph-level properties from the root level:
			delete @$_{lr,rr,lp,rp,gp,glr,grr,allomf};
			$a=dumpsh([$_],['mrf']);
			$a=~s/=> ' +(?![ '])/=> '/g;
			print $avs $a,"\n";
		}
		lex2($_);
        }
}
close(LX2);
close(AVS);
print_propsets($out);
savenormfrm();
#$end=time-$stm;
#warn sprintf "elapsed: %02d:%02d",$end/60,$end%60;
warn1("$error entries produced no allomorphs") if $error;
die_if_errors();
end_banner();
