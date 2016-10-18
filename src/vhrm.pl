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

#these are global variables
%typech=qw/infl = deriv @/;#separator character indicates the type of following morpheme
$lexchars='[LF]+'; #lengthening/lowering(L)/opacity(F) markers
$tagname='humor';
$stemtags='\||^(?:FN|MN|SZN|IGE|HA|NU)(?=$|[+|])';
#regex of characters to remove from surface forms
$srf2rm='(?<=.)\)|\((?=.)';

{

#definition of pattern variables

my($V0)="aeiouáéíóöőúüűAÁVOQÓUÚBFë";
my($V)="[$V0]";
my($C)="[^+$V0]";
my($B)="[aáoóuúB]";
my($F)="[öőüűiíeéë]";
my($FR)="[öőüű]";
my($FU)="[iíeéë]";
my($N)="[iíé]";

### sfxalt($wd): calculate multiply suffixed SR form for UR given in $wd
# returns SR form and vowel harmonic status at the left edge (VHB/VHFU/VHFR)

# Handles:
# vowel harmony
# lowering
# final vowel lengthening
# v-assimilation
# unstable sfx-initial vowel

#A a/e (+LbAn)
#Á á/é (+LnÁl)
#O o/e/ö (+LhOz)
#Ó ó/ő (+LbÓl)
#U u/ü (+LjUk)
#Ú ú/ű (+LjÚ)
#V a/e/o/ö/0 (+Vt)
#Q o/ö (used for internal handling of V)
#L+ lowering (házL)
#+L final vowel lengthening (+LbAn)
#B back harmony (hídB, hidBL)
#[OAU]0 unstable sfx-initial vowel: (+O0n,+U0nk,+A0cskA etc.)
#v0 underspecified consonant slot (v-assimilation): (v0Al,v0Á)

my (@hrmid)=qw(VHFU VHB VHFR);

=cmt
my (@vharm)=sort{$a[0] cmp $b[0]}
(
['B','',3,3,3],
['F','',2,2,2],
['A','e',2,0,2],
['Á','é',2,0,2],
['O','e',2,0,0],
['O','ö',0,0,4],
['Q','ö',0,0,4],
['Ó','ő',4,0,4],
['U','ü',4,0,4],
['Ú','ű',4,0,4],
['A','a',0,3,0],
['Á','á',0,3,0],
['O','o',0,3,0],
['Q','o',0,3,0],
['Ó','ó',0,3,0],
['U','u',0,3,0],
['Ú','ú',0,3,0],
['a','a',3,3,3],
['á','á',3,3,3],
['o','o',3,3,3],
['ó','ó',3,3,3],
['u','u',3,3,3],
['ú','ú',3,3,3],
['i','i',2,3,2],
['í','í',2,3,2],
['e','e',2,2,2],
['é','é',2,3,2],
['ö','ö',4,4,4],
['ő','ő',4,4,4],
['ü','ü',4,4,4],
['ű','ű',4,4,4]
);
=cut

#FST ("kimmo") state table for vowel harmony
#states are numbered beginning with 1
#0 is failure

my (%vharm)=
(
'B',[['',2,2,2]],
'F',[['',1,1,1]],
'A',[['e',1,0,1],['a',0,2,0]],
'Á',[['é',1,0,1],['á',0,2,0]],
'O',[['e',1,0,0],['ö',0,0,3],['o',0,2,0]],
'Q',[['ö',0,0,3],['o',0,2,0]],
'Ó',[['ő',3,0,3],['ó',0,2,0]],
'U',[['ü',3,0,3],['u',0,2,0]],
'Ú',[['ű',3,0,3],['ú',0,2,0]],
'a',[['a',2,2,2]],
'á',[['á',2,2,2]],
'o',[['o',2,2,2]],
'ó',[['ó',2,2,2]],
'u',[['u',2,2,2]],
'ú',[['ú',2,2,2]],
'i',[['i',1,2,1]],
'í',[['í',1,2,1]],
'e',[['e',1,1,1]],
'é',[['é',1,2,1]],
'ö',[['ö',3,3,3]],
'ő',[['ő',3,3,3]],
'ü',[['ü',3,3,3]],
'ű',[['ű',3,3,3]]
);

if($zarte_ana)
{
%vharm=
(
'B',[['',2,2,2]],
'F',[['',1,1,1]],
'A',[['e',1,0,1],['a',0,2,0]],
'Á',[['é',1,0,1],['á',0,2,0]],
'O',[['ë',1,0,0],['ö',0,0,3],['o',0,2,0]],
'Q',[['ö',0,0,3],['o',0,2,0]],
'Ó',[['ő',3,0,3],['ó',0,2,0]],
'U',[['ü',3,0,3],['u',0,2,0]],
'Ú',[['ű',3,0,3],['ú',0,2,0]],
'a',[['a',2,2,2]],
'á',[['á',2,2,2]],
'o',[['o',2,2,2]],
'ó',[['ó',2,2,2]],
'u',[['u',2,2,2]],
'ú',[['ú',2,2,2]],
'i',[['i',1,2,1]],
'í',[['í',1,2,1]],
'e',[['e',1,1,1]],
'ë',[['ë',1,1,1]],
'é',[['é',1,2,1]],
'ö',[['ö',3,3,3]],
'ő',[['ő',3,3,3]],
'ü',[['ü',3,3,3]],
'ű',[['ű',3,3,3]]
);
}

#alternations within suffix sequences
sub sfxalt0
{
	my($st)=shift;

	$st=~tr/ë/e/ unless $zarte_ana;

	#the following are only needed for generated derivational suffix sequences
	$st=~s/=ik\+/{=ik>}+/g; #remove =ik if further suffixed
	$st=~s/(\+L?)[OA]0(?=gAt|tA0|n$V)/$1/go; #gAt, ni after any deriv. sfx.
	$st=~s/\+L?Vs0(?=kOd)/+/g; #kOd(ik) after any deriv. sfx.
	#the following are always needed
	$st=~s/A\+L/{A>Á}+/g; #final vowel lengthening
	$st=~s/a\+L/{a>á}+/g; #final vowel lengthening
	$st=~s/e\+L/{e>é}+/g; #final vowel lengthening
	$st=~s/([ëaeiouáéíóöőúüűAÁOQÓUÚ]\}?\+[LF]*)(V|[OAU]0)/$1/g; #On,Unk,AcskA etc.
	$st=~s/L\+([LF]*)V/+$1A/g; #lowering
	$st=~s/\+V/O/g; #no lowering
#	$st=~s/L\+L?|\+L/+/g; #delete L's
	$st=~s/L(?=\+|$)//g; #delete L's
	$st=~s/([^Aae]\+)L/$1/g; #delete L's
	$st=~s/([rtpsdfghjklzcvbnm])\+v0/$1+$1/g; #vAl,vÁ
#	$st=~s/0//g;
	$st;
}

sub sfxalt
{
	my($st)=shift;

	$st=~tr/ë/e/ unless $zarte_ana;

	#the following are only needed for generated derivational suffix sequences
	$st=~s/=ik\+/{=ik>}+/g; #remove =ik if further suffixed
	$st=~s/(\+L?)[OA]0(?=gAt|tA0|n$V)/$1/go; #gAt, ni after any deriv. sfx.
	$st=~s/\+L?Vs0(?=kOd)/+/g; #kOd(ik) after any deriv. sfx.
	#the following are always needed
	$st=~s/A\+L/{A>Á}+/g; #final vowel lengthening
	$st=~s/a\+L/{a>á}+/g; #final vowel lengthening
	$st=~s/e\+L/{e>é}+/g; #final vowel lengthening
	$st=~s/([ëaeiouáéíóöőúüűAÁOQÓUÚ]\}?\+[LF]*)(V|[OAU]0)/$1/g; #On,Unk,AcskA etc.
	$st=~s/L\+([LF]*)V/+$1A/g; #lowering
	$st=~s/V/O/g; #no lowering
#	$st=~s/L\+L?|\+L/+/g; #delete L's
	$st=~s/L(?=\+|$)//g; #delete L's
	$st=~s/([^Aae]\+)L/$1/g; #delete L's
	$st=~s/([rtpsdfghjklzcvbnm])\+v0/$1+$1/g; #vAl,vÁ
	$st=~s/0//g;
	my(@s)=split(/(\[.*?\]|\{[^}>]*?>\}|=ik|[ëaeiouáéíóöőúüűAÁOQÓUÚBF])/,$st);
	my($i,$s,$c);
	#running the deterministic FST
	for($i=1,$s=1;$i<=$#s;$i+=2)
	{
		next if $s[$i]=~/^[{[]|^=ik/;
		for(@{$vharm{$s[$i]}})
		{
			$s[$i]=$_->[0],$s=$_->[$s],last if $_->[$s];
		}
	}
	$st=join('',@s);
	$c=$st;
	$c=~s/\[.*?\]//g;
	return $st,$hrmid[$s-1] if $c!~/[VAÁOQÓUÚ]/;
	undef;
}

sub vhrm
{
#	(&sfxalt)[1];
	local($_)=shift;
	#harmony is simple if final vowel is back and front rounded
	return 'VHB' if /$B$C*$/o;
	return 'VHFR' if /$FR$C*$/o;
#	return 'VHFU' if /[\%\@=]$C*e$C*$/o;
	#front unrounded vowel at the end: this is complicated and heuristic
	my($s)=$_;
	#cases involving 'né';
	return 'VHVB' if /$B$C*\+né$/o;
	return 'VHVF' if /$B$C*$N$C*\+né$/o;
#	s/\+(?=né$)//;
	s/.*\+//; #remove non-final compound members
	s/e$/é/;  # final e behaves more like é
	s/$C+//go;#remove non-vowels
	return 'VHFU' if /^$F*$FU$|[eë]$/o;
	return 'VHB' if /$B$N$/o;
	return 'VHV' if /$B$N*e$N+$|$B$N+$/o;
	(sfxalt($s))[1];
}

sub vhrm1
{
#	(&sfxalt)[1];
	local($_)=shift;
	s/\+/\F/g;
	(sfxalt($_))[1];
}

sub dovhrm
{
	(&sfxalt)[0];
}

my (@stms)=qw/or er ör/;#sample B/FU/FR stems to which suffixes are attached
my (@vhid)=qw/VHB VHF VHFU VHFR/;#harmony types

#calculate allomorphs of $mrf as determined by vowel harmony
#
sub sfxalt2
{
	my($mrf)=shift;
	my(@frm,@vh,@res);
	my($frm,$vh,$mrf2);

#	print "###$mrf->{allomf}###\n";
	for(@stms)
	{
		#attach sfx to B/FU/FR stem and determine form + vowel harmony
		($frm,$vh)=sfxalt("$_+$mrf->{'allomf'}");
#		print "#$frm#$vh#";
		$frm=~s/$_\+//;
		push @vh,$vh;
		push @frm,$frm;
	}
	$mrf2=avscpy($mrf);
	$mrf2->{allomf}=$frm[0];
	#return single allomorph if there is no suffix form alternation
	#and it is an inflection or forms an adverb
	push(@res,$mrf2), return @res if "$frm[0]#$vh[0]" eq "$frm[1]#$vh[1]" || ($frm[0] eq $frm[1] && /type:infl|mcat:.*>Adv/);
	$mrf2->{lr}.=' VHB';
	#add right harmony property if inflectable derivational sfx:
	$mrf2->{rp}.=$vh[0] if /type:deri/ && $_!~/mcat:.*>Adv/;
	push(@res,$mrf2);#push back allomorph
	do{
	$mrf2=avscpy($mrf);
	$mrf2->{allomf}=$frm[1];
	#if inflectable derivational sfx:
        if(/type:deri/ && $_!~/mcat:.*>Adv/)
        {
		#add right harmony property:
		$mrf2->{rp}.=$vh[1];
		#return if there is only a single front allomorph:
	        $mrf2->{lr}.=' VHF', push(@res,$mrf2), return @res if $frm[2] eq $frm[1] && $vh[2] eq $vh[1];
	}
	else
	{
		#return if there is only a single front allomorph:
	        $mrf2->{lr}.=' VHF', push(@res,$mrf2), return @res if $frm[2] eq $frm[1];
	}
        #if there are two: the first is the unrounded one
	$mrf2->{lr}.=' VHFU'; push(@res,$mrf2);
	} if defined $frm[1];
	#the front rounded allomorph:
        $mrf2=avscpy($mrf);
	$mrf2->{allomf}=$frm[2];
	$mrf2->{rp}.=$vh[2] if /type:deri/ && $_!~/mcat:.*>Adv/;
	$mrf2->{lr}.=' VHFR'; push(@res,$mrf2);
	return @res;
}

my %abc=qw/f ef h há k ká l el ly elipszilon m em n en ny eny q ku r er
s es sz esz w vé x iksz y ipszilon/;
#s es sz esz w duplavé x iksz y ipszilon 1 egy 2 kettő 3 három 4 négy 5 öt 6 hat 7 hét 8 nyolc 9 kilenc 0 nulla/;
my $V1="[ëaeiouüöáéíóúőű]";
my $C1="(?:dzs|[ds]z|[cz]s|[ltgn]y|[rtpsdfghjklcvbnmzx])";

sub abcphon
{
	my $a=shift;
	my(@a);
	$a=~s/.*\+//;
        $a=~s/[?!#=%@^()]|[{<[].*?[]>}]|\.\.\.$//g;
        $a=~tr/A-ZÁÉÍÓÚÖÜŐŰË./a-záéíóúöüőűë/d;
	$a=~s/x/ksz/g,return $a if (defined $mrf->{phon} && $mrf->{phon} eq '') ||
		($a!~/^(?:$V1$C1|($V1)\1)$/ &&
		$a=~/^((sz|s)?([ptkbdg][rl]|$C1)?$V1$C1??)+$/);
#	@a=split /(dzs?|[cz]s|sz|[glnt]y)/,$a;
	@a=split /($C1|$V1)/,$a;
	$a='';
	for(@a)
	{
		next unless $_;
		$a.=$_,next if /[aeiouáéíóúöüőűë0-9]/;
		$a.=$abc{$_}?$abc{$_}:"$_é";
	}
	$a;
}

sub alllc
{
	my $a=shift;
        $a=~tr/A-ZÁÉÍÓÚÖÜŐŰË/a-záéíóúöüőűë/;
        $a;
}

my $no_more_stemcat='(?!.*\+(?:[MF]N|SZN|IGE|HA|NU|BETU|DATUM))';
sub hum2cat
{
	local($_)=shift;
	return 'N'	if /(?:^|\+)(FN|BETU|DATUM)$no_more_stemcat/o;
	return 'Adj'	if /(?:^|\+)MN$no_more_stemcat/o;
	return 'V'	if /(?:^|\+)IGE$no_more_stemcat/o;
	return 'Adv'	if /(?:^|\+)(HA|NU)$no_more_stemcat/o;
	return 'Num'	if /(?:^|\+)SZN$no_more_stemcat/o;
	return 'Vpfx'	if /(?:^|\+)IK$no_more_stemcat/o;
	return 'Sup'	if /(?:^|\+)FF$no_more_stemcat/o;
	return 'X'	if /^\?.*/;
	return 'X'	if /.*/;
}
%cat2hum=(qw/N FN Adj MN Num SZN V IGE Adv HA Vpfx IK Sup FF Part MN/,'X','');
sub cat2hum
{
	die1("cat2hum not defined for $_[0]") unless defined $cat2hum{$_[0]};
	$cat2hum{$_[0]};
}

#add zarte info to seg
sub zarte
{
	my($lem0,$zarte,$cat)=@_;
	my $lem=$lem0;
	$lem=~s/_.*|\[.*?\]//g;
        $zarte=~tr/EeËë//cd;
	warn("Mid E ERROR: $lem0\[$cat]:$zarte \n") if ($lem=~tr/EeËë//) != ($zarte=~tr/EeËë//);
	return $lem0 if !$zarte||$lem0!~/[EeËë]/;
	my @lem0=split(/([EeËë])/,$lem0);
	my @zarte=split(/([EeËë])/,$zarte);
	my $res;
	for(my $i=0;$i<=$#lem0;$i+=2)
	{
		$res.=$lem0[$i];
		$res.=$zarte[$i+1]?$zarte[$i+1]:'e' if $lem0[$i+1]=~/[EeËë]/;
	}
	$res;
}

1;
}

=cmt
sub test
{
	my(@a)=qw/drabális szar+LVt bizakodóL+LVkL+LVt felül[NU]+LrA[SUB] kutya[FN]+sÁg+Á+tÓl föld+hOz köb+Vk+hOz földL+Vk+hOz föld+nAk májL+VtOk zsák+jAink+bÓl zsák+jA+LO0n zsák+jA+Lv0Al zsák+jA+LnÁl kilenc+Vd+lAg+Os nadrág+Vm+Lv0Á nyílB+nAk szar=ik+tAk szar+OskOd=ik+hAtnA kutya+LA0tA0lAn tör=ik+O0t0t nadrág+LVmL+LO0n er+AnÁnAk víz+nAk kriszmösztrí/;
	for(@a)
	{
		print CP1250CP852(sfxalt($_)),' ',vhrm($_),"\n";
#		print sfxalt($_),"\n";
	}
}

require 'cp.pl';
cpxl2subs(1250,852);
test;
1;
