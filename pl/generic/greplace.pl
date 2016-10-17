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

do 'banner.pl';

start_banner('Regex pattern driven replace') if $banner_loaded;

$oflag='o';
#getopt...
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
#end of getopt
$vals=8;
sub dosel1
{
	if($sel0)
	{
		$todo.='$c=$_;$d=\'\';while($a=($c=~'."$sel0$oflag)".($exc?',$a||$c':'').'){($a,$b,$c)=!$a?($c,\'\',\'\'):(($& eq $1.$2.$3)?($`.$1,$2,$3.$\'):($`,$&,$\'));'."\n";
		{
			$spc='$a',last if $exc;
			$spc='$b';
		}
		$spc2=$spc."\n";

	}
	elsif(!$sel)
	{
		$spc='$_';
		$spc2='$_';
	}
}

sub dounsel
{
		$todo.='$d=$d.$a.$b;$_=$d.$c;}'."\n" if ($sel);
}

sub dosel2
{
		if($unsel&&$sel)
		{
			&dounsel;
			undef $sel;
		}
}

sub shiftall
{
	$rep=shift(@PR);
	$pr=shift(@PR);
	$if=shift(@PR);
	$g=shift(@PR);
	$doall=($g=~s/a//);
	$j=shift(@PR);
	$sel0=shift(@PR);
	$exc=shift(@PR);
	if ($sel0)
	{
		&dounsel;
		$sel=$sel0 ;
	}
#	print STDERR "pr=$pr;;";
#	print STDERR "sel=$sel;;";
	if($pr==-1||($pr>=0&&$sel0))
	{
		$unsel=1;
	}
	else
	{
		$unsel=0;
	}
	&dosel1;
}

if($#ARGV<0&&!$nohelp)
{
print STDERR <<EOM;
greplace does pattern replacement on a file
usage:
greplace [switches] patfile infile
the switches are:
-all		process inputfile
-pat=file	use patterns in given file (otherwise: 1st file in filelist)
-inpl		process in place (when using -all)
-bak=.ext	make backup with the extension .ext when processing in place
-nobak		make no backup
-log		log changed lines
-chk		check replacements (line printed after each replacement)
-res		check result (print only changed lines and only once)
-grp		print matching groups
-lst		list matching entries (lines)
-ln		list matching line numbers
-out=file	use file as output
-i=#		use only pattern on line number #
-from=#		use only patterns from line number #
-to=#		use only patterns up to line number #
-v		verbose operation
Matching lines/selected parts are listed, but no replacement is done if 
no chk/res/all/grp switch given.
Patterns prefixed by - are not printed when checking.
EOM
exit -1;
}

$bak='.bak' if !$bak;
if(!defined $pat)
{
	$pat=shift;
}

open(PT,$pat);

if($out&&!$inpl)
{
	open(OUT,$out);
	select(OUT);
}

while(<PT>)
{
	($pr,$if,$exc,$sel,$p,$r,$g)=/^(-?) *(?:if *(\(.*[^\\]\)) +)?(?:sel(exc)? *(\/.*?[^\\](?:\\\\)*\/[ims]*) +)?(\/.*?[^\\](?:\\\\)*\/|\/\/)(\/|.*[^\\](?:\\\\)*\/)([1egimsa]*)\s*(\#.*)?$/;
	if($if)
	{
#		($if,$exc,$sel)=($`,$1,$2) if $if=~/ sel(exc)? *(\/.*)$/
		$if.='&&';
	}
	if($pr){$pr=0}else{$pr=1}
	if($g!~s/1// && $g!~/a/){$g.='g'};
	if($p && $r) {push(@PR,($p,$r,$pr,$if,$g,$.,$sel,$exc));}
	else
	{
		($asg)=/^([\$\%\@].*=.*;) *$/;
		if($asg) {$asgl.=$asg."\n";}
		elsif(/^ *(?:sel(exc)? *(\/.*?[^\\](?:\\\\)*\/[ims]*))/)
		{
			$exc=$1;
			$sel=$2;
			$pr=-2;
			{push(@PR,('x','',-2,'','',$.,$sel,$exc));}
		}
		elsif(/^ *unsel[ \n]/)
		{
			$pr=-1;
			{push(@PR,('x','',-1,'','',$.,'',''));}
		}
		elsif($_!~/^#|^$/)
		{
			die "Invalid pattern line: $_";
		}
	}
#	print STDERR "pr0=$pr;sel0=$sel;;";
}

undef $sel;

#print STDERR "\n";

$todo="while(<>){\n";
eval $asgl;
do $include if($include);
if($inpl&&$all)
{
#	$todo.='if ($ARGV ne $oldargv) {rename($ARGV, $ARGV . $bak);open(ARGVOUT, ">$ARGV");select(ARGVOUT);$oldargv = $ARGV;}';
#	@ARGVOUT=@ARGV;
#	for($k=0;$k<=

#	$todo.='if ($ARGV ne $oldargv) {$fn=$ARGV;$fn=~s/\.[^.]*$//;close ARGV;rename($ARGV, $fn . $bak);open(ARGV, "$fn$bak");print STDOUT "\nfile $ARGV:\n\n" if $log;open(ARGVOUT, ">$ARGV");select(ARGVOUT);$oldargv = $ARGV;next;}';
	$todo.='if ($ARGV ne $oldargv) {$fn=$ARGV;$fn=~s/\.[^.]*$//;close ARGV;die "ERROR: Unable to rename $ARGV\n" unless rename($ARGV, $ARGV . $bak);open(ARGV, "$ARGV$bak");print STDOUT "\nfile $ARGV:\n\n" if $log;open(ARGVOUT, ">$ARGV");select(ARGVOUT);$oldargv = $ARGV;next;}';
#;print STDERR $ARGV,$fn.$bak;
}

if($i)
{
	$from=$to=$i;
}

if($from)
{
#	print "$from,$#PR,$PR[5];";
	while($#PR>=0&&$PR[5]<$from)
	{
		for($l=$vals;$l>0;$l--)
		{
			shift(@PR);
		}
	}
	$j=$from;
}

if($to)
{
#	print "$to,$#PR,$PR[$#PR-2];";
	while($#PR>=0&&$PR[$#PR-$vals+6]>$to)
	{
		for($l=$vals;$l>0;$l--)
		{
			pop(@PR);
		}
	}
}

if($all)
{
	$todo.="\$match=0;\n" if $log;
	$todo.='print "=$.:";' if $ln;
	while($pat=shift(@PR))
	{
		&shiftall;
		if($v){$pref=",print \"$j:\"";}
#		$todo.='$match++ if ' if $log;
		if($pr>=0)
		{
			$todo.="if($if $spc=~s$pat$rep$g"."o){".((!$watch||$watch==$j)?"\$match++$pref;":';');
			$todo.="while($spc=~s$pat$rep$g"."o){}" if($doall);
			$todo.="}\n";
		};
		&dosel2;
	}
	$todo.="print;\n";
	if($log)
	{
		if ($inpl||$out){$todo.="print STDOUT if \$match;\n";}
		else {$todo.="print STDERR if \$match;\n";}
	}
}
elsif($chk)
{
	while($pat=shift(@PR))
	{
		&shiftall;
		if($v){$pref="$j:";}
		if($pr>=0)
		{
			$todo.="if($if $spc=~s$pat$rep$g"."o && $pr){print \"$pref$spc2\";";
			$todo.="while($spc=~s$pat$rep$g"."o){}" if($doall);
			$todo.='}'
		};
		&dosel2;
		$j++;
	}
}
elsif($res)
{
	$todo.="\$match=0;\n";
	while($pat=shift(@PR))
	{
		&shiftall;
		if($v){$pref="$j:";}
		$todo.='print "=$.:"if !$match;' if $ln;
		if($pr>=0)
		{
			$todo.="if($if $spc=~s$pat$rep$g"."o && $pr){".((!$watch||$watch==$j)?"\$match++,print \"$pref\";":';');
			$todo.="while($spc=~s$pat$rep$g"."o){}" if($doall);
			$todo.="}\n".($watch==$j?"else{next;}\n":'');
		};
		&dosel2;
		$j++;
	}
	if($pfn)
	{
		$fn='<$ARGV>:';
	}
	else
	{
		$fn='';
	}
	$todo.="print \"$fn\".\$_ if \$match;\n";
}
elsif($ln)
{
	$todo.="\$match=0;\n";
	while($pat=shift(@PR))
	{
		&shiftall;
		if($pr>=0)
		{
			$todo.="if($if $spc=~s$pat$rep$g"."o && $pr){\$match++;";
			$todo.="while($spc=~s$pat$rep$g"."o){}" if($doall);
			$todo.='}'
		};
		&dosel2;
		$j++;
	}
	$todo.="print \"=\$.:\$&\n\" if \$match;\n";
}
elsif($grp)
{
	$"='#';
	while($pat=shift(@PR))
	{
		&shiftall;
		if($v){$pref="$j:";}
#		$todo.="print \"$pref\@F\" if \@F=$pat"."o;\n";
		$todo.="\@F=$pat"."o;print \"$pref\@F\\n\" if $if$spc=~$pat"."o;\n" if($pr>=0);
		&dosel2;
		$j++;
	}
}
elsif($lst)
{
	while($pat=shift(@PR))
	{
		&shiftall;
		if($v)
		{
			$pref="$j:";
		}
		$todo.="print \"$pref\$_\" if $if$spc=~$pat"."o;\n";
		&dosel2;
		$j++;
	}
}
else
{
	while($pat=shift(@PR))
	{
		&shiftall;
		if($v)
		{
			$pref="$j:";
			$todo.="print \"$pref\$`==>\$&<==\$'\" if $if$spc=~$pat$g"."o;\n";
		}
		else
		{
			$todo.="print \"$spc2\" if $if$spc=~$pat$g"."o && $pr;\n";
		}
		&dosel2;
		$j++;
	}
}
&dounsel;
$todo.="}";
if($inpl&&$all)
{
	$todo.='select(STDOUT);';
}

print STDERR $asgl.'do $include if($include);'.$todo."\n\n" if $v;
if($pato)
{
	die "unable to create $pato" unless open(PATO,'>'.$pato);
	print PATO $asgl.'do $include if($include);'.$todo."\n\n";
	close PATO;
}

eval $todo;warn $@ if $@;

end_banner() if $banner_loaded;
