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

#generate Hungarian level 1 suffix lexicon file sfx.1 from sfx.txt (Excel file)
BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";

require 'banner.pl';
start_banner('Level 1 suffix lexicon generator');

$glossfld=25;
while(<>)
{
	chomp;
	next if /^#|^\t{19}|^$|^\@ME.FORMAT/;
	@attr=split /\t/;
	splice @attr,20,0,splice(@attr,2,1);
	last if $attr[0] eq '';
}

while(<>)
{
        $type=$1 if /^[^\t].*(deriv|infl)/;
        $cat=$2.$3 if /^[^\t]*((Nom)inal|(V)erbal)/;
        next if /^#|^\t{21}|^$|^\@ME.FORMAT/;
	s/\t+//,print("#$_"),next if /\t{21}/|!/\S\t/;
	chomp;
	@a=split /\t/;
	$a[$glossfld]='' unless $a[$glossfld]; #just to make sure that $a[20] exists (splice needs this)
	splice @a,20,0,splice @a,2,1;
	$a[0]='',@lbl=@a,$l=$#lbl,next if $a[0] eq 'props';
	@f=split m#/#,$a[2] if $a[2]!~/^\+/;
	@f=($a[2]) if $#f<0;#to save 0 morphs
	$c='';
	$c=$a[2],$c=~s/^\+// if $a[2]=~/^\+/;
	next if $a[1]=~/\.\./;
	$fvl='';
	$low='';
	$fvl="L" if $a[6]=~/^\+/;# && $a[2]!~/^\+/;
	$low="L" if $a[14]=~/^\+/;
#	$a[2]="L$a[2]" if $a[6]=~/^\+/ && $a[2]!~/^\+/;
#	$a[2].="L" if $a[13]=~/^\+/;
	$a[$glossfld]="#$a[$glossfld]";
	print ("#$a[0]\n"),$a[0]='' if $a[0];
	$f='';
	$a[20]=$a[1] if $a[20]=~/:$|^$/&&$a[1]!~/:$|^$/;
	$a[1]=$tag if $a[1]=~/:$|^$/;
	$a[20]=$hum if $a[20]=~/:$|^$/;
	$tag=$a[1];
	$hum=$a[20];
	for $b(@f)
	{
		@b=@a;
		for($i=1;$i<=$l;$i++)
		{
			$b[$i]='' if $b[$i]=~/^%/; # % marks a feature commented out
			$b[$i]='+' if $b[$i]=~/^A\+?$/ && $b=~/^[AU]/;
			$b[$i]='-' if $b[$i]=~/^A\+?$/ && $b!~/^[AU]/;
			$b[$i]="$lbl[$i]_$b[$i]" if $b[$i]!~/[\*-]|^\s*$/ && $lbl[$i]!~/^(\s*|\*)$/;
			do
			{
				$b[$i]="$attr[$i]:$b[$i]";
				$b[$i]="props_$b[$i]" if $lbl[$i]!~/^\s*$/ 
			} if $attr[$i]!~/^\s*$/;
			$b[$i]=~s/_\+//g;
			$b[$i]=~s/(^|:)[^:]*[-*][^:]*$/$1/g if $lbl[$i]!~/^\*?$/;
		}
		$b="F$b" if $b[4]!~/VH/;#$b~!/AÁOÓUÚV/;
		if(!$c)
		{
			$b[2]=$b;
		}
		else
		{
			$b[2]=$b.$c;
		}
		$b[2]="phon:$fvl$b[2]$low";
		$_=join ',',@b;
		s/(lp:.*)VH_([BF])/lr:VH$2,$1/;
		while(s/(lp:.*?)(VH(_[^,]+)?|RH)/$1/){};
		s/,+/,/g;
		s/^,+//;
		s/\n(.+)/$1\n/;
		s/,(?=[^:,]+:)/;/g;
		s/;(?!phon:)[^:,;]+:(?=;|,#)//g;
		s/,#/;#/g;
		s/:,/:/g;
		s/props_rp:.*?;// if $type eq 'infl';
#		$f='phon:d;' if s/Ad\/d;/Ad;/;
                $f="phon:$1Ál;" if s/([^:]+)\/\+Ál/$1/;
                #derivational suffixes (mcat:lcat>rcat)
                #have lr:cat_lcat category requirement (unless lcat=*) and
                #rp:cat_rcat right category
                $lcat=$cat;
                $lcat=$1 if /mcat:.*?([^" ;:,\]]+)\]?>/;
                ($rcat)=/mcat:.*?>=?([^" ;:,]+)/;
                $frt="type:$type;props_rp:mcat_$type;";
                $frt.="props_lr:cat_$lcat inflable;" if $lcat ne '*';
                $frt.="props_rp:cat_$rcat;" if $rcat;
		print "$frt$_\n";
		s/phon:.*?;/$f/,print "$frt$_\n" if $f=~/phon:[jsz]/
	}
#	s/phon:.*?;/$f/,print "$frt$_\n" if $f eq 'phon:d;';
}
end_banner();
