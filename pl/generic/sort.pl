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
$bsort=$ENV{'bsort'} if !$bsort;
$bsort.='/' unless !$bsort||$bsort=~/(^|\/)$/;
$bsort=$ENV{'PL'} if !$bsort;
$bsort.='/' unless !$bsort||$bsort=~/(^|\/)$/;
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";

require 'banner.pl';
start_banner('Regex pattern driven sort program');

	while ( $_=shift(@ARGV) ) 
	{
		print SDTERR $_;
		if(/^-([^-])/)
		{
			if($1 eq '=')
			{
				$OutFileName=$';
				s//>/;
				die "unable to open $_ for writing" unless open (GO_OUT,$_);
				print STDERR "Output to $_\n";
				select(GO_OUT);
			}
			else
			{
				s//\$$1/;
				$_.='=1;' if($_!~/=/);
				s/=(.*)/='$1'/ if($_!~/=[0-9]/);
				print STDERR "$_\n";
				eval $_;
			}
		}
		elsif($_)
		{
			unshift(@ARGV,$_);
			last;
		}
		else
		{
			last;
		}
	}
#	print STDERR "@ARGV\n";

#$stime0=time;
if($#ARGV<0&&!$nohelp)
{
print STDERR <<EOM;
sort sorts files
usage:
perl -s sort.pl [options] script infile >outfile
scriptfile 'script' is eval'd before sorting
The options are:
-pat="s///;"	pattern to sort by (expression 'eval'ed on each input line)
-\$/=''		set input record separator
-00		paragraph mode
-0oct		set input record separator as octal number 'oct'
-sw="-[a-z]..."	switches to pass to bsort
-keeptmp	keep tmpfile
-q		quiet operation (no progress indication)
EOM
exit -1;
}

sub dispperc
{
	local(*IN)=@_;
	my($pos,$perc,$now,$gone,$left);
	$pos=tell(IN);
	$perc=$pos/$len;
	$now=time;
	$gone=$now-$stime;
	if($now-$ptime)
	{
		$avg=.1*($pos-$ppos/($now-$ptime))+.9*$avg;
		$ppos=$pos;
		$ptime=$now;
	}
	$left=($len-$pos)/$avg;
	printf STDERR "$pos of $len (%0.4f%%) %02d:%02d %02d:%02d   \r",100*$perc,$gone/60,$gone%60,$left/60,$left%60;
	$i=0;
}

sub getlen
{
	local(*IN)=@_;
	$stime=time;
	seek(IN,0,2);
	$len=tell(IN);
	seek(IN,$start,0);
	$avg=1;
}

#$pat='/.*/$&/' if(!$pat);
#if(0)
#{
#	die "Unable to open script file $f\n" unless open(SCR,$f);
#	while(<SCR>)
#	{
#		eval; die "Invalid script file $f:\n $@" if $@;
#	}
#	close SCR;
#}

$f=shift if !defined $f &&!defined $pat;
$file=shift;
$out=shift;
#$file eq '-' && IN=STDIN or
die "Unable to open input file: $file\n" unless (open(IN,$file));
print STDERR "Sorting $file...\n";
require $f if defined $f;
$sw.=' -q' if $q;
$RSep=$/;
goto doout if $doout;
#die "szar: $doout";
&getlen(*IN);
$expr='while(<IN>)
{
'.$pat.';
'.($q?'':'	if($i&0x800)
	{
		&dispperc(*IN);
	}
	$i++;
').' chomp;
 @keys=($_) if(!@keys);
 foreach $key(@keys)
 {
  if (length($key)>240)
	{
	 warn "line too long (".length($key)."):\n$key";
	 $key=substr($key,0,240);
	}
  printf TMP "%s\001%09d\n",$key,$pos if defined $key;
  die "\\\\n in string:\n$key" if $key=~/\n/;
 }
 $pos=tell;
 undef @keys;
}';
#".pack("L",$pos)."
print STDERR "Running script:\n$expr\n" if $v;
print STDERR "Creating tempfile...\n";
open(TMP,">_plsort.tmp");
$pos=0;
eval $expr; die "Error eval'ing expression:\n $expr\n$@" if $@;
close TMP;
#print STDERR "${bsort}bsort _plsort.tmp _plsrt2.tmp $sw\n";
die if system("perl ${bsort}bsort.pl $sw _plsort.tmp >_plsrt2.tmp");
unlink '_plsort.tmp' if !$keeptmp;
doout:
print STDERR "Creating output...\n";
select OUT if (open(OUT,">$out"));
open(IN,$file);
open(TMP,"_plsrt2.tmp");
$outexpr='
&getlen(*TMP);
while(!eof(TMP))
{
	$/="\n";
	$_=<TMP>;
'.($q?'':'	if($i&0x800)
	{
		&dispperc(*TMP);
	}
	$i++;
').'	($key,$pos)=/^(.*?)\001([0-9]+)$/;
	die "Error positioning in file $file\n" unless seek(IN,$pos,0);
	$/=$RSep;
	$_=<IN>;
	'.$opat.';print;
}';
print STDERR "Running script:\n$outexpr\n" if $v;
eval $outexpr; die "Error eval'ing expression:\n $outexpr\n$@" if $@;
$pos=$.;
close TMP;
if(!$keeptmp)
{
	print STDERR "Deleting tempfile...\n";
	unlink '_plsrt2.tmp';
}
#$end=time-$stime0;
#printf STDERR "elapsed: %02d:%02d\n",$end/60,$end%60;
$.=$pos;
end_banner();
