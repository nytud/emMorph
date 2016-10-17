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

require 'banner.pl';
start_banner('Word grammar converter');

require 'm2getopt.pl';
require 'diewarn.pl';

do 'files.hpl' if !$files || !defined do $files;

do 'delim.hpl' unless $delim;
$delim="\x1" unless $delim;

$proplst='proplst.hpl' if !$proplst;
$humsrc='.' if !$humsrc;

require $proplst;

$bits_set='=';
$bits_neg='!';

#convert flag expressions to binary flag strings
#individual flags are delimited by space or &

#the binary pattern for each flag must be defined in $flags hash in input;

#operator	example	result
#none		flag	..1...	
#negation !	!flag	..0...
#increment (+	(+flag1	..(++)... (stop when reaching ..11...)
#decrement (-	(+flag1	..(--)... (stop when reaching ..00...)
#increment [+	{+flag1	..[++]... (..00... follows ..11...)
#decrement [-	{+flag1	..[--]... (..11... follows ..00...)

sub genbits
{
	my($expr)=@_;
	my(@bits)=('.') x 32;
	my($op,$mask,@mask,$par,$flag,$ovr_);
	for $flag(split /[& ]+/,$expr)
	{
		$flag=~s/^([([]?)([!+\-]?)//;
		$par=$1;
		$op=$2;
		$flag=~s/[])]$//;
		$flags->{$flag}=~s/[<>](\d+)/'.' x $1/e;
		$mask=$flags->{$flag};
		$op eq ''  && $mask=~tr#x#1# or
		$op eq '!' && $mask=~tr#01x#10# or
		$op eq '+' && $mask=~tr#01x#+# or
		$op eq '-' && $mask=~tr#01x#-#;
		$par eq '(' && $mask=~s#([\-+]+)#($1)#g or
		$par eq '[' && $mask=~s#([\-+]+)#[$1]#g;
		@mask=$mask=~/[([]?[+\-01.][])]?/g;
		$i=0;
		for $m(reverse @mask)
		{
			if($m eq '.')
			{
				$bits[$i]=$m if !defined $bits[$i];
				$i++;
				next;
			}
			$ovr_.="$expr:$bits[$i] -> $m at $i;" if $bits[$i] && $bits[$i] ne '.' && ($bits[$i] ne $m);
			$bits[$i]=$m;
			$i++;
		}
	}
	$bits=join('',reverse @bits);
	$bits=~s/^\.+//;
	die1("Inconsistent bit operations:\n$ovr_\nResult:$bits\nin: $expr\n\n") if $ovr_;
	$bits;
}

sub printlines
{
	my $cat;
	for(@_)
	{
		#translate bit checking and setting expressions ?{}, ={}, LCF{} etc.
		s/\{(.*?)(?=\}\s)/'{'.genbits($1)/eg;
		#check if the (meta)category at the beginning of the line is defined
		if(($cat)=/^\s*(\S+)\s*->/)
		{
			if(!$metacteg->{$cat}&&!$undef{$cat})
			{
				my($cat1,$constr,$side);
				$undef{$cat}++;
				die1("Category $cat is not defined in \$metacteg section of $proplst\n");
				#for category names containing '_' or '&', cut parts beginning with _/&
				#successively from end and try to find the definition of the rest
				#then add the cut part as an additional constraint
                                $cat1=$cat;
                                $side='l';
				while($cat1=~s/(.*)[_&](.*)/$1/)
				{
					#add constraint
					$constr.="&$2";
					#check if the base category is defined
					#and add constrints if found
					$side=$metacteg->{$cat1}[0],
					$constr=$metacteg->{$cat1}[1].$constr,
					last
					if($metacteg->{$cat1});
				}
				print MC "'$cat' =>	['$side','$constr'],\n";
			}
			else
			{
				$used{$cat}++;
			}
		}
		print;
	}
}

open MC,">$hpldir/src/metacteg.new";

my($l,$i,$wait_for_semi,%vars,@vars,$var,$i,$j,@l);

while(<>)
{

	s/^[ \t]+//;
	#ignore comments and multiedit format line
	next if /^#|^\Q\@ME.FORMAT/;
	#if line looks like a variable (macro) definition, then wait for semicolon
	if(/^[\$\@]\w+\s*=/)
	{
		$l='';
		$wait_for_semi=1;
	}
	#wait until the definition is finished
	#then evaluate it
	if($wait_for_semi)
	{
		$l.=$_;
		if(/;\s*$/)
		{
                        $wait_for_semi=0;
			eval $l;
			#check if the definition is syntactically correct
			die1($@) if $@;
		}
		next;
	}
	#print line if no macro expansion character (@) is present
	printlines($_), next unless /\@/;
	#gather all macro variables used in the line
	undef %vars;
	for(/\@([A-Za-z\d]+\[?)/g)
	{
		$vars{$_}++;
	}
	@vars=keys %vars;
	@l=($_);
	#substitute each variable with all its possible values respectively
	while($var=shift @vars)
	{
		#if the variable contains a list of lists, the reference must contain a numeric index
		if($var=~s/\[$//)
		{
			@l=map
			{
				$i=$_;
				map
				{
					$j=$i;
					$j=~s/\@$var\[(\d+)\]/$_->[$1]/g;
					#check if the macro is defined
					die1("macro $_\[$1] is not defined") if !defined $_->[$1];
					$j;
				}@$var;
			}@l;
		}
		#no index if the variable is a simple list
		else
		{
			@l=map
			{
				$i=$_;
				map
				{
					$j=$i;
					$j=~s/\@$var(?![a-zA-Z\d])/$_/g;
					#check if the macro is defined
					die1("macro $_ is not defined") if !defined $_;
					$j;
				}@$var;
			}@l;
		}
	}
	printlines(@l);
}

close MC;
#check if all defined categories are actually used in the grammar
for(sort keys %$metacteg)
{
	warn("Category $_ is defined in $proplst but not used in the grammar.\n") if !$used{$_};
}
die_if_errors();
end_banner();

