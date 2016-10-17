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
#require 'umlaut.pl';

sub union
{
	my ($a,$b)=@_;
	my (%a);
	@a{@$a}=();
	@a{@$b}=();
	return [keys(%a)];
}

sub intersect
{
	my ($a,$b)=@_;
	my($x,$y);
	my (@c,%a);
	for(@$a){$a{$_}++};
	for(@$b){$a{$_}--};
	while(($x,$y)=each(%a)){push(@c,$x) if !$y}
	return \@c;
}

sub issubset
{
	my ($a,$b)=@_;
	my ($res,%b);
	@b{@$b}=();
	$res=1;
	for(@$a){$res&&=exists($b{$_})};
	return $res;
}

sub equal1
{
	my ($a,$b)=@_;
	return join('\xff',sort(@$a)) eq join('\xff',sort(@$b));
}

sub equal2
{
	my ($a,$b)=@_;
	my (%a,%b);
	@a{@$a}=();
	@b{@$b}=();
	return join('\xff',keys(%a)) eq join('\xff',keys(%b));
}

=cmt
sub mergecatcomps
{
	my ($a,$b)=@_;
	my (@a,@b,%a);
	my ($x,$y,$z,$ay,$bx);
#	@a=split(/\+/,$a);
#	@b=split(/\+/,$b);
	($x)=$a=~s/^(.*(?:\+|$))//;
	($y)=$b=~s/^(.*(?:\+|$))//;
	while($x||$y)
	{
		if($x eq $y)
		{
			$z.=$x;
			($x)=$a=~s/^(.*(?:\+|$))//;
			($y)=$b=~s/^(.*(?:\+|$))//;
		}
		else
		{
			($bx)=$b=~/(.*?\+?)$x/;
			($ay)=$a=~/(.*?\+?)$y/;
			if(!defined $bx)
			{
				$z.=$x;
				($x)=$a=~s/^(.*(?:\+|$))//;
			}
			elsif(!defined $ay)
			{
				$z.=$y;
				($y)=$b=~s/^(.*(?:\+|$))//;
			}
			elsif(length($bx)<length($ay))
			{
			}
		}
	}
	
}

my @hstr=('','^','@','|','+');
my $hypmrk='|+';

sub mergehyphs
{
	my($old,$new)=@_;
#	$old=~s/[`_]//go;
#	$new=~s/[`_]//go;
	my ($o,$n)=($old,$new);
	$o=~s/[$hypmrk]//go;
	$n=~s/[$hypmrk]//go;
	return undef if($o ne $n);
	$old=~s/.([$hypmrk])/$1/go;
	$new=~s/.([$hypmrk])/$1/go;
	$old=~s/[^$hypmrk]/ /go;
	$new=~s/[^$hypmrk]/ /go;
	my @w=split(//,$o);
	my @o=split(//,$old);
	my @n=split(//,$new);
	my $hyph="";
	my ($w,$hval);
	while($w=shift(@w))
	{
		$o=shift(@o);
		$n=shift(@n);
		$hval=2*($o eq '|')+($n eq '|');
		$hval=5 if $o eq '+' || $n eq '+';
		$hyph.=$w;
		$hyph.=$hstr[$hval];
	}
}

sub hyphofform
{
	my($form,$hyph)=@_;
	my $hyps=$hyph;
	$hyps=~s/[$hypmrk]//go;
	if($hyps ne $form)
	{
		$rt=&root(hyps);
		if($rt eq $form)
		{
			$hyph=&root($hyph);
		}
		else
		{
			$rt=&umlaut($rt);
			if($rt eq $form)
			{
				$hyph=&umlaut(&root($hyph));
			}
			else
			{
				my $hyp0=$hyph;
				$hyp0=~s/.([$hypmrk])/$1/go;
				$hyp0=~s/[^$hypmrk]/ /go;
				my @s=split(//,$form);
				my @w=split(//,$hyps);
				my @h=split(//,$hyp0);
				$hyph="";
				my($s,$h,$w);
				while($s=shift(@s))
				{
					$h=shift(@h);
					$w=shift(@w);
					$hyph.=$s;
					last if $w ne $s;
					if($h ne ' '){$hyph.=$h;}
				}
				while($s=shift(@s))
				{
					$hyph.=$s;
				}
			}
			$hyph=~s/\|([qwrtpsdfghjklzxcvbnmá]*)$/$1/i;
		}
	}
	return $hyph;

}
=cut
1;
