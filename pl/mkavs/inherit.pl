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

#implement inheritance of features on the level 1 stem lexicon
#the lexicon must be reverse sorted and the compounds '+' segmented

#switches:
#-noovr		the properties of words with nonempty feature set are not overwritten
#-del_same	if the property set of a compound would be identical
#		to those to be inherited then they are deleted,
#		mismatches are marked by *!!
#-nolexseg	do not put suffixed forms marked by ++! on a separate line
#-noovrpat	define regex pattern for properties not to be overwritten eg: loc:.*?;
#-noinhpat	define regex pattern for properties not to be inherited eg: isa:.*?;

#the properties of words containing the no_inh feature are never overwritten
BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";

sub chkline
{
	my($c,$err,$w);
	for $w(split(/(?=; *\+\+)/))
	{
		$w=~s/;.*/;/;
		if($w=~/^\+\+!?=/)
		{
			for $c($w=~/((?:^|\++)[^+;]*)/g)
			{
				$err="Stem category tag should not appear in allomorph declaration at: $c" if $c=~/^\+\+.*\[.*\]/;
#				$err="Stem category tag is missing at: $c" if $c=~/^(?!\+\+)[^[]+$/;
				die1("Ill formed lexicon entry: at line $.\n$_$err\n") if $err;
			}
		}
		elsif($w=~/^\+\+/)
		{
			for $c($w=~/((?:^|\++)[^+;]*)/g)
			{
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

require 'm2getopt.pl';
require 'diewarn.pl';
require 'banner.pl';
require 'vhrm.pl';

$lc='a-záéíóúöüőű' unless defined $lc;#lower case letters
$uc='A-ZÁÉÍÓÚÖÜŐŰ' unless defined $uc;#upper case letters

$csiga='@' unless defined $csiga;

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

start_banner('Inheritance processor');

$del=0;

while(<>)
{
        print($_),next if /^\s*\*(?!\*\.\.\.)|^\s*$/;
	#lines ending in a backslash are merged with the next line
	$_=$prevline.$_,undef $prevline if defined $prevline;
	$prevline=$_,next if s/\\+\s*\n//;
	chkline();
	chomp;
	undef @prlines;
        ($sh,$seg,$hum,$r)=/^(\s*;?(.*?)\[([^]]*)\]);(.*)/;
	$a=$seg;
#	$a=~s/[?!#=%@^(){}]|[<["].*?[]>"]|\.\.\.$|^\*\*\.{3}//g;
	$a=~s/[?!#=%@^(){}]|[<["].*?[]>"]|^\*\*\.{3}|_.*//g;
	$a=alllc($a);
	$a=~tr/.-//d;
	$lastseg=$b=$a;
	$b=~tr/+//d;
	$lastseg=~s/.*\+//;
	#delete items that did not match more than 4 times
=cmt
	for($i=0,$j=5;$i<=$#pat;$i++)
	{
		$pat[$i]->[2]++,next if $b!~/$pat[$i]->[0]$/;
		last;# if !$j;
		$j--;
	}
	for($i=$#pat,$j=5;$i>=0;$i--)
	{
		$pat[$i]->[2]++,next if $b!~/$pat[$i]->[0]$/;
		last;# if !$j;
		$j--;
	}
	while(@pat&&$pat[0]->[2]>4)
	{
		delete $line{$pat[0]->[1]};
		shift @pat;
	}
	while(@pat&&$pat[-1]->[2]>4)
	{
		delete $line{$pat[-1]->[1]};
		pop @pat;
	}
=cut
	#overwrite properties if the last segment with this humor tag
	#has been recorded and it is a compound
	if($lastseg eq $b)
	{
		$l='';
	}
	else
	{
		$key=$lastseg."[$hum]";
		$l=$line{$key}->[0];
		if(!$l&&$hum=~/\|(?!NM|pro)/i)
		{
			($hum1=$hum)=~s/\|.*//;
			$key=$lastseg."[$hum1]";
			$l=$line{$key}->[0];
		}
	}
	$l=~s/^\s*;//;
#	$_="$sh;inh:$l" if $l;
	if($l)
	{
		$del++;
#		push (@prlines,$sline{"$lastseg\[$hum\]"}), delete $sline{"$lastseg\[$hum\]"} if $sline{"$lastseg\[$hum\]"};
#		next;
		#inherited properties
		$inhprops=$line{$key}->[1];
		$rsave='';
		if($noovrpat)
		{
			#save properties not to be overwritten if they are defined for the compound
			$l=~s/$noovrpat//og,$r=~s/$noovrpat//go if $rsave=join('',$r=~/($noovrpat)/go);
		}
#		unless($noovr&&/\];.+/||/no_inh:/)
		#remove comments
		$r=~s/(;|^)\s*(?:\*.*)?/$1/;
		unless($noovr&&$r||/no_inh:/)
		{
			if($del_same)
			{
				$_="  $sh;".($r ne $inhprops?"$r*!!":'');
			}
			else
			{
				$_="  $sh;${rsave};inh:$l";
				$_.="*<ovr:$r>" if $r && $r ne $inhprops;
			}
		}
	}
        $r=~s/l[rp]:[^;]*;|no_inh:.*|$noinhpat//go; #left properties and anything after no_inh: or matching $noinhpat should not be inherited;
        $ll=$_;
        #left properties should not be inherited;
        #or whatever is after no_inh
        #restrictions either
        $ll=~s/l[rp]:[^;]*;|^\s*\*\*|no_inh:.*|restr:.*?;|$noinhpat//g;
        #oh it is bad this way!!
#	$line{"$a\[$hum\]"}=[$ll,$r], push(@pat,$a) unless /not_cmp2|\];no_inh:/;
#	$line{"$a\[$hum\]"}=[$ll,$r], push(@pat,[quotemeta($b),"$a\[$hum\]"]) unless /not_cmp2|\];no_inh:/;
	#store it if it is not a compound
        unless(/not_cmp2|\];no_inh:/||$a=~/\+/)
        {
		$line{"$a\[$hum\]"}=[$ll,$r];
		$line{"$a\[$hum1\]"}=[$ll,$r] if ($hum1=$hum)=~s/\|(?!NM|pro).*//i;
	}
#	print;
	push (@prlines,$_);
	#for homographs: select the one which contains no no_inf tag and add that without the _ suffix
	#e.g. szél_légmozgás[FN];... / szél_perem[FN];no_inh:;
        s/_([^_\[;]*\[)/[/,s/((?:^|\+\+!).*?;)/${1}restr:g;/g,push (@prlines,"$_") if($seg=~/_/&&$_!~/no_inh:/);

#	s/^(\s*;?).*\+(?=.*\[)/$1**.../,$line{"$lastseg\[$hum\]"}=[$_,$r], push(@pat,$lastseg),
#		$sline{"$lastseg\[$hum\]"}=$_,
##		print " ##sfx"
#		unless $lastseg eq $b||$l||!$lastseg;
#	print "\n";

	#NOW: put suffixed forms marked by ++! on a separate line

	#jó[MN];... ++!jo+bb[CMP];...
	# ->
        #jó[MN];...
	#jo[MN]+@bb[CMP];lexseg:jó+@bb;...
	for(@prlines)
	{
	print("$_\n"), next if $nolexseg;
        #remove comments
	s/;\s*\*.*/;/;
	#(jó[MN];rp:...;)(jo+bb[CMP];rp:...)
	@stm_almf=split(/\s*\+\+!\s*(?![;\[])/);
	if(/\s*\+\+!\s*/)
	{
		#(jó[MN]),(rp:...)
		($seg)=/^\s*(;?[^&;]*?|.*?\[[^][;]*\]);/;
		($ddd)=$seg=~/^(\.\.\.)/;
		$rsave=join('',$stm_almf[0]=~/($noovrpat)/go);
#		($stm,$hum)=/^\s*(.*?)\[([^][;]*)\];/;
		for(my $i=1;$i<=$#stm_almf;$i++)
		{
			#(jo+bb[CMP]),(rp:...)
			($seg1,$r1)=$stm_almf[$i]=~/^\s*(;?[^&;]*?|.*?\[[^][;]*\]);(.*)/;
			$seg1=$ddd.$seg1;
                        #(jo),(bb[CMP])
			($root,$sfx)=split(/\+/,$seg1,2);
                        #tök+jó[MN]
		        if (($seg0)=$seg=~/^(.*[*+#])/)
        		{
        			#jo -> tök+jo
				$root=~s/^(?!=)/$seg0/ or
                                #=jo -> jo
				$root=~s/^=//;
			}
			#jó([MN])
			$seg=~/(\[[^][;]*\])$/;
			#jo[MN]
			$root.=$1;
			$sfx=~s/\+/+$csiga/g;
			#jo[MN]+@bb[CMP]
			$seg1=$root;
			$seg1=$seg if $root=~/^\[/;
			$seg1=~s/^=//;
			$seg1.="+$csiga".$sfx if $sfx ne '';
			#jó[MN]+@bb[CMP]
			$seg2=$seg;
			$seg2.="+$csiga".$sfx if $sfx ne '';
                        #jó+bb
#			$seg2=~s/^\.\.\.(?=.)//g;
			undef $seg2 if $seg2 eq $seg1;
			$seg2=~s/([^]])\+/$1*/g;
			$seg2=~s/\[[^][;]*\]//g;
			$r1="$rsave;$r1" unless $r1=~/($noovrpat)/go;
			$stm_almf[$i]=(($r1=~/lexseg:/||! defined $seg2)?"$seg1;$r1":"$seg1;lexseg:$seg2;$r1");
		}
	}
	for(@stm_almf)
	{
		print "$_\n";
	}
	}
}
print STDERR "$del entries were eligible for inheritance\n";
die_if_errors();
end_banner();
