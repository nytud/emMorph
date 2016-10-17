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

eval 'use Pod::Usage';

=head1 NAME

encode.pl - Humor encoding generator

=head1 DESCRIPTION

The program generates the Humor encoding of property sets given in the .propsets files input to it.

It uses the definition of the Humor encoding of individual properties, matrix selection and
word grammar categories given in proplst.hpl (or the file given by -proplst=file).

It generates the following files:

=over 2

=item encoding$gen.hpl (and Gpropset$gen.str if -store given)

which contain the encoding of property sets ($gen can be defined using -gen=...)

=item $humsrc\meta$mtx.txt

matrix selection declaration ($humsrc and $mtx can be defined using -humsrc=... and -mtx=...)

=item $humsrc\$mtx.lay

matrix layout file

=item $humsrc\${mtx}_$m.txt

matrix files, for all matrix names ($m) declared in proplst.hpl

=item $humsrc\metacteg.txt

word grammar category definition file

=item $humsrc\lr$gen.sw

switch file, which contains the length of bit vectors and matrix codes

=back

=head1 SYNOPSIS

perl encode.pl [switches] file.propsets [file2.propsets ...]

=head1 OPTIONS

=over 2

=item -h or -help

More help.

=item -out=file

Name of the output file, requred.

=item -humsrc=path

Path to humor source directory, defaults to .

=item -proplst=file

File is the name of the file containing the definition of the Humor encoding of individual
properties, matrix selection and word grammar categories. Defaults to proplst.hpl.

=item -store

Use the Storable module to store the result. The generated dummy encoding.hpl loads this.
If -store is not given, the generated encoding is output to encoding.hpl using Data::Dumper.

=item -gen=string

Use the given string to indicate that the created files belong to the generator.

=item -mtx=string

Use the given string as a prefix of the names of matrix files to generate. Defaults to mtx$gen.

=item -excl=regexp

Skip entries in .propsets input file which match regexp.

=item -bit2matrix

Encode all properties in matrices even the ones marked to be encoded as bits

=cut

undef $@;
eval 'pod2usage(-msg,"$0: No files given.",-verbose,1)' if ((@ARGV == 0) && (-t STDIN));
 die 'No files given.' if $@;

BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";
#use strict vars;

require 'banner.pl';
start_banner('Humor encoding generator');
$stm=time;

require 'm2getopt.pl';
require 'dumpsh.pl';
require 'diewarn.pl';

pod2usage(-verbose,2)  if $h or $help;

die 'Output file must be given as -out=file before input files.' if !defined $out;

do 'delim.hpl' unless $delim;
$delim="\x1" unless $delim;

do 'files.hpl' if !$files || !defined do $files;

$proplst='proplst.hpl' if !$proplst;
$mtx="mtx$gen" if !$mtx;
$humsrc='.' if !$humsrc;

require $proplst;
my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
$atime,$plist_mtime)=stat("$hpldir/src/$proplst");
my $cache_mtime;
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
$atime,$cache_mtime)=stat("${out}_rp_cache.tmp");
warn ("${out}_rp_cache.tmp=$cache_mtime;$hpldir/src/$proplst=$plist_mtime\n");
warn ("Deleting ${out}_rp_cache.tmp\n"),unlink "${out}_rp_cache.tmp" if $cache_mtime<=$plist_mtime || !-r $out;

#do whatever else is required
require $require if defined $require;

use Storable;
eval
{
$sat_cache=retrieve('sat_cache.tmp') if -r 'sat_cache.tmp';
$Gpropsets_cache=retrieve("ps_cache_$proplst$bit2matrix.tmp") if -r "ps_cache_$proplst$bit2matrix.tmp";
#$sat_sub_cache=retrieve('sat_sub_cache.tmp') if -r 'sat_sub_cache.tmp';
$rp_cache=retrieve("${out}_rp_cache.tmp") if -r "${out}_rp_cache.tmp";
};

sub printmsg
{
	print MSG time-$stm,": ",shift,"\n";
}

#sub die1
#{
#	warn(@_); $errorflag++;
#}

$l_idx=0;
$r_idx=1;

$bits_ignore='i';
$bits_set='=';
$bits_neg='!';

#open(DBG,'>&STDERR');
#open(DBG2,'>&STDERR');
#open(DBG1,'>&STDERR');
#select(DBG1);$|=1;select(STDOUT);
open(MSG,'>&STDERR');
select(MSG);$|=1;select(STDOUT);

#convert an integer to a binary string of $bits bits length
sub dec2bin
{
	my ($bits,$num)=@_;
	print "$bits,$num;";
	substr(unpack("B32", pack("N", $num)),-$bits);
}

#procedure to check that the set of properties in $prop satisfies the
#propositional formula in $req;

#$prop is <prop>&...&<prop>;
#$req may contain |&();

#a property list containing the property 'match_any' satisfies any req.

sub satisfies
{
	my($prop,$req)=@_;
	return 1 if $req eq '' || !defined $req || $req==1 || $prop=~/match_any/;
	$satcache_found++, return $sat_cache->{"$prop\x4$req"} if defined $sat_cache->{"$prop\x4$req"};
	$satcache_miss++;
	local($_);
	$_='&'.$prop.'&';
	s/,/&/;
	return &{$sat_sub_cache->{$req}}() if defined $sat_sub_cache->{$req};
#	return $sat_cache->{"$prop\x4$req"}=&{$sat_sub_cache->{$req}}() if defined $sat_sub_cache->{$req};
#	return 1 if /&match_any&/;
#	$req="follow_any|($req)";

	my(@req,$r,$op,$p,$req0);
	$req0=$req;
	$req0=~s/\&+(?=$|,)//g;
	$req0=~s/(^|,)\&+/$1/g;
	@req=split(/([()|&]+)/,$req0);
	for(@req)
	{
		next if /^[01]?$/;
		s/&/&&/g,s/\|/||/g,next if /[()|&]+/;
		($op,$p)=/(!?)(.*)/;
		$_="/&\Q$_\E&/";
		next if !$op;
		$_="($_||\$_!~/&\Q$p\E&/)";
	}
	eval '$sat_sub_cache->{$req}=sub{'.join('',@req).'};';
	die1("Ill-formed requirement specification:\n$req\nError:\n$@"),return 0 if $@;
#	print DBG "$prop sat @req=$r;\n";
#	print DBG "\$_='$_',@req==$r;\n";
	$sat_cache->{"$prop\x4$req"}=&{$sat_sub_cache->{$req}}();
}

# add derived properties in $Gcmp_prop to $Gprops;
# the bit-encoded properties referenced in $Gcmp_prop should be non-x props

# also sets %Gentail that contains entailments of properties and
# $Gre_entail, a disjunctive regular expression that matches properties
# which have entailments

sub derive_props
{
#	mk_cmpentail();
	my($lr,$prop,$mexp,$bits,$mtxsel);
	local($FLAGno_x_props);
	$FLAGno_x_props=1;
	$Gre_entail='(?:';
	for(sort {reverse($a) cmp reverse($b)} keys %$Gcmp_prop)
#	for(keys %$Gcmp_prop)
	{
		($lr,$prop)=$Gcmp_prop->{$_}=~/([lr]),(.*)/;
		$Gentail{$_}=$prop;
		$Gre_entail.="\Q$_\E|";
		($mexp,$bits)=gen_mtx_expr_bits($prop,'',$lr,$Gprops->{$_}[1]);
		$bits=~/[01]/ and
		($Gprops->{$_}[1] || #properties given as bit-encoded are not overwritten:
		(defined $Gprops->{$_} and ($Gprops->{$_}[1]=$bits))||
		($Gprops->{$_}=[$lr,$bits,'']));
		print DBG1 "'$_' =>\t['",join('\',\'',@{$Gprops->{$_}}),"'],\n";
	}
	$Gre_entail=~s/\|$/)/;
	for(keys %$matrixsel)
	{
		$prop=entailments($_);
		$mtxsel->{$prop}=$matrixsel->{$_};
		if($prop=~/\|/)
		{
			for $mexp(split(/\|/,$prop))
			{
				$mexp=~s/^\(|\)$//g;
				die1("Matrix selection expression must be in disjunctive normal form:\n $prop\n") if $mexp=~/[()]/;
				$mtxsel->{$mexp}=$matrixsel->{$_};
			}
		}
	}
	$matrixsel=$mtxsel;
}

#Make lookup table for complex entailments 
sub mk_cmpentail
{
	for(keys %$entail)
	{
		$cmpentail{$entail->{$_}}=$_;
	}
}

#calculate complex entailments of the expr.
sub cmpentail
{
	my($expr)=@_;
	
	for(my($i)=0;$i<=$#entail;$i+=2)
	{
		$expr.="&$entail[$i]" if (satisfies($expr,$entail[$i+1])&&$expr!~/match_any/);
	}
	$expr;
}

#add atomic entailments of complex properties to the expression
sub entailments
{
	my($prop)=@_;
	my ($b,$lr,$p,$r,$c);

	($lr)=$prop=~/^([lr],)/;
	$prop=~s///;#remove /[lr],/ form $prop
	$prop=~s/(^|[&,])($Gre_entail)(?=$|[&,])/$1$2\&$Gentail{$2}/go;
#	for(keys %$Gcmp_prop)
#	{
#		$b=$Gcmp_prop->{$_};
#		$b=~s/^[lr],//;
#		$prop=~s/(^|[&,])\Q$_\E(?=$|[&,])/$&\&$b/g;
#	}
	($p,$c,$r)=split /(,)/,$prop;
	$p=cmpentail($p);
	$r=cmpentail($r);
	return $lr.$p.$c.$r;
}

#add atomic entailments of complex properties to the expression
sub entailments_old
{
	my($prop)=@_;
	my ($b,$lr);

	print DBG1 "$prop>>\nenew:",&entailments1,"\n";
	($lr)=$prop=~/^([lr],)/;
	$prop=~s///;#remove /[lr],/ form $prop
	for(keys %$Gcmp_prop)
	{
		$b=$Gcmp_prop->{$_};
		$b=~s/^[lr],//;
		$prop=~s/(^|[&,])\Q$_\E(?=$|[&,])/$&\&$b/g;
	}
	print DBG1 "eorg:",$lr.$prop,"\n";
	return $lr.$prop;
}

# add the third field of $Gprops to $Gcmp_prop
sub add_Gcmp_props
{
	for(keys %$Gprops)
	{
		next unless $Gprops->{$_}[3];
		$Gcmp_prop->{$_}="$Gprops->{$_}[0],$Gprops->{$_}[3]";
	}
}

#Return the matrices from $mtxsel the property-list of which
#a) is satisfied by the right props. in $expr if $lr=='r';
#b) satisfies the left req. in $expr otherwise;

#In case a), the list must contain exactly one matrix (unless the morpheme
# appears only in final position, so that a unique
# continuation mtx can be selected);
#in case b), the list must contain at least one (unless the morpheme appears
# only at the beginning of words, so that the morpheme be reachable).

#### CHANGED:
#Return the matrices from $mtxsel the property-list of which
#a) is satisfied by the right props. in $expr if $lr=='r';
#b) is either satisfied by or satisfies the left req. in $expr otherwise;

sub matrices_match
{
	my($expr,$lr,$mtxsel)=@_;
	my($r);

	$r={};
	for(keys(%$mtxsel))
	{
		$r->{$mtxsel->{$_}}++ if ($lr eq 'r' && satisfies($expr,$_))
			|| ($lr eq 'l' && (satisfies($_,$expr)||satisfies($expr,$_)));
#		push(@$r,$mtxsel->{$_}) if ($lr eq 'r' && satisfies($expr,$_))
#			|| ($lr eq 'l' && (satisfies($_,$expr)||satisfies($expr,$_)))
	}
#	print DBG "$r\n";
	return [keys %$r];
}

#Make lexicon lookup direction table from $metacteg
sub mk_lookuptbl
{
	for(keys %$metacteg)
	{
		$lookuptbl->{$metacteg->{$_}[1]}=[$metacteg->{$_}[0],$_];
		#store used lookup directions in $lookupdirs
		$lookupdirs->{$metacteg->{$_}[0]}++;
	}
}

#Calculate the lexicon lookup direction for a morpheme having
#the right expression as defined in $metacteg
sub lookup_direction
{
	my($expr)=@_;
	my($r,@r);

	$r={};
	for(keys(%$lookuptbl))
	{
		@r=@{$lookuptbl->{$_}};
		push (@{$r->{$r[0]}},$r[1]) if (satisfies($expr,$_));
	}
	die1("Lexicon lookup direction is ".(scalar(keys %$r)>1?'contradictory':'undetermined')." for:\n$expr\n") if scalar(keys %$r)!=1;
	return (keys %$r)[0], values %$r;
}

#This procedure generates the logical formula expressed by the matrix letter
#from a property set of the form 'props&reqs' by eliminating bit-encoded
#properties from the formula.

#It also generates the bit vector for the property set.

#Rules for setting bit-encoded properties:
#Non-binary properties (b) are set only if they explicitly appear,
#otherwise dots fill the space;
#the bits for binary x-properties are always set according
#to the following rules.

#Rules for setting x-properties (see sub setbits):
#In property list:
#property present -> use the set operation;
#property missing -> use the neg operation;
#property negated -> use the neg operation;
#In requrements list:
#property present -> use the set operation;
#property missing -> use the ignore operation;
#property negated -> use the neg operation;

sub gen_mtx_expr_bits
{
	my($prop,$req,$lr,$bits)=@_;
	my($nest);
	local($ovr_);
	my($exp,$mexp,@exp,$i,$b,$op,$p,@x);

	#procedure to set bits in $all appropriately as determined by
	#$mask (which bits and how), $op (ignore, set, negate)
	#and $propside (left/right side properties)

	#$bits is [01.]+;
	#$mask is [01.x]+;
	#$op is {$bits_ignore='i', $bits_set='=' or $bits_neg='!'} as set above;
	#$propside is [lr];

	#Rules for setting x-properties:
	#In property list:
	#property present -> use the set operation;
	#property missing -> use the neg operation;
	#property negated -> use the neg operation;
	#In requrements list:
	#property present -> use the set operation;
	#property missing -> use the ignore operation;
	#property negated -> use the neg operation;

	#Encoding of the operations:
	#for right-hand side (e.g. stem) properties (i.e. left-hand side requirements)
	#set=1
	#neg=0
	#ignore=.
	#for left-hand side (e.g. sfx) properties (i.e. right-hand side requirements)
	#set=.1
	#neg=1.
	#ignore=11

	#The variable $ovr_ accumulates inconsistent bit operations.

	sub setbits
	{
		my($bits,$op,$prop)=@_;
		my($a,$m,$r,$opm,$b,$i,$ml,$mask,$propside);
		$mask=$Gprops->{$prop}[1];
		$propside=$Gprops->{$prop}[0];
		$mask=~/^(\.*)/;
		$i=length $1;
		$r=substr($bits,0,$i);
		$ml=length $mask;
		while($i<$ml)
		{
			$a=substr($bits,$i,1);
			$m=substr($mask,$i,1);
			$i++;
			$r.=$a,next if $m eq '.';
			blk:
			{
				if($propside eq 'r')
				{
					$b='.',last blk if $op eq 'i';
					$opm=$op.$m;
					$b=($opm=~/=[1x]|!0/)?'1':'0';
				}
				elsif($propside eq 'l' && $m eq 'x')
				{
					$a.=substr($bits,$i,1);
					$m.=substr($mask,$i,1);
					$i++;
					$b='11',last blk if $op eq 'i';
					$b='.1',last blk if $op eq '=';
					$b='1.';
				}
				else
				{
					$opm=$op.$m;
					$b=($opm=~/=1|!0/)?'1':'0';
				}
			}
			$ovr_.="$prop:$a -> $b at $i;" if $a!~/^\.+$/ && ($a ne $b);
			$r.=$b;
		}
		$r.=substr($bits,$i);
		print DBG1 "$bits,$mask,$op,$propside\t> $r\n" if $ovr_;
		return $r;
	}

	$nest=0;
	die1('$bitlength must be one of {8,16,24,32}') if !$bitlength || $bitlength%8;
#	print STDERR length($bits),">";
	$bits.=('.' x ($bitlength-length($bits)));
#	print STDERR length($bits),":$bits\n";
#	die1 ("\nLength of bit vector is not $bitlength (".length($bits).")\n$bits\n$exp\n\n") if length($bits)!=$bitlength;

	$exp="$prop,$req";
	$prop='&'.$prop.'&';
	$req='&'.$req.'&';
	$ovr_='';
	#encode x-properties
	if(!$FLAGno_x_props){for(keys(%$x_props))
	{
		print DBG2 "$_,$lr:$exp SAT $Gprops->{$_}[2]=".satisfies($exp,$Gprops->{$_}[2])."\n";
		if(satisfies($exp,$Gprops->{$_}[2]))
		{
			if($lr ne $Gprops->{$_}[0])
			{
				($op,$p)=$req=~/&(!?)(\Q$_\E)&/;
				$op='=' if !$op;
				if(!$p)
				{
					$bits=setbits($bits,'i',$_);
				}
				else
				{
					$bits=setbits($bits,$op,$_);
				}
			}
			else
			{
				($op,$p)=$prop=~/&(!?)(\Q$_\E)&/;
				$op='=' if !$op;
				if(!$p)
				{
					$bits=setbits($bits,'!',$_);
				}
				else
				{
					$bits=setbits($bits,$op,$_);
				}
			}
		}
	}}
	#encode and remove bit-encoded properties
	#remove them only if $bit2matrix is not set
	@exp=split(/([,&|()]+)/,$exp);
	prs:while(defined ($i=shift(@exp)))
	{
#		shift(@exp),next if $i eq '';

		if($i=~/[()]/)
		{
			$nest+=($i=~tr/(//); #update () nesting level
			$nest-=($i=~tr/)//);
			last prs unless defined ($i=shift(@exp));
		}
		($op,$p)=$i=~/(!?)(.*)/;
		die1("Property '$p' undefined in $exp\n") if $i ne '' && !defined $Gprops->{$p} && $p ne 'match_any';
		$b=shift(@exp);
		if($Gprops->{$p}[1]=~/^[.01x]+$/) #if $p is bit-encoded
		{
			$mexp.=$i if $bit2matrix;
			die1("Only properties outside parentheses may be bit-encoded:\n$i in $exp\n")
				if $nest;
#			while($b=~/\(/g){$nest++}; #update () nesting level
#			while($b=~/\)/g){$nest--};
			die1("Only conjunctive properties may be bit-encoded:\n$i in $exp\n")
				if $b&&$b!~/^[,&]/;
			$b=~s/^&// unless $bit2matrix; #remove the & belonging to the property
			#set bits for the bit-encoded property $p
			if($Gprops->{$p}[1]=~/^[.01x]+$/)
			{
				$op='=' if !$op;
				$bits=setbits($bits,$op,$p);
			}
		}
		elsif($Gprops->{$p}[1] eq '*') #ignore property if marked '*'
		{
			$b=~s/^[&|]//; #remove the & belonging to the property
		}
		else #otherwise add to matrix expression
		{
			$mexp.=$i;
		}
		$nest+=($b=~tr/(//); #update () nesting level
		$nest-=($b=~tr/)//);
		$mexp.=$b;
	}
	die1("Unmatched parentheses ($nest) in $exp\n") if $nest;
	$mexp=~s/\&+(?=$|,)//g;
	$mexp=~s/(^|,)\&+/$1/g;
#	print DBG1 "<$ovr_>";
	die1("Inconsistent bit operations:\n$ovr_\nResult:$bits\nin: $exp\n$Gmorf\n\n") if $ovr_;
#	$mexp="$lr,$mexp";
#	for(keys(%$x_props))
#	{
#		setbits($bits,$Gprops->{$_}[1],'i',$Gprops->{$_}[0])
#		if !$x{$_} && satisfies($exp,$Gprops->{$_}[2]);
#	}
#	print DBG "===$bits,$mexp===\n\n";
	die1("Length of bit vector is not $bitlength (".length($bits).")\n$bits\n$exp\n\n") if length($bits)!=$bitlength;
	return ($mexp,$bits);
}

#This procedure partially encodes a property set of the form 'side,props,reqs'.
#What is not done is determining the matrix letter since that depends on the
#result of this.

sub encode_propset
{
	my($lpre,$Gmorf,$mtx)=@_;
	return $Gpropsets_cache->{$lpre} if defined $Gpropsets_cache->{$lpre};
	my($lpr,$lr,$prop,$req,$mtxlst,$mtxexp,$bits,$lexdir,$mcats);

	$lpr=entailments($lpre);
	($lr,$prop,$req)=split(/,/,$lpr);
	#get the matrices for the property-set
#	$mtxlst=matrices_match("$prop,$req",$lr,$matrixsel);
	#for startcond, the matrix must be externally defined
	if($mtx)
	{
		$mtxlst=[$mtx];
		($lexdir,$mcats)=('l',[]);
	}
	elsif($lr eq 'r')
	{
		$mtxlst=matrices_match($prop,$lr,$matrixsel);
#		die1("Not exacly one matrix matched:\n$lpr\n".join(',',@$mtxlst)) if $#$mtxlst!=0;
		warn1("No matrix matched:\n$lpr\n".join(',',@$mtxlst)) if $#$mtxlst<0;
		die1("More than one matrix matched:\n$lpr\n".join(',',@$mtxlst)) if $#$mtxlst>0;
		($lexdir,$mcats)=lookup_direction($prop);
	}
	else
	{
		my(@breq,@exp,$op,$p,$i);
		$bits=$req;
		$bits=~s/&\(.*\)//g; #remove parenthesized props: they cannot be bit-encoded
		@exp=split(/&/,$bits);
		while(defined ($i=shift(@exp)) && $i ne '')
		{
			($op,$p)=$i=~/(!?)(.*)/;
#			die "Property '$p' undefined!\n" if !defined $Gprops->{$p};
			push(@breq,$i) if($mtxsel_props->{$p}) #if $p is a property used for matrix selection
		}
		$bits=join('&',@breq);
		$mtxlst=matrices_match($bits,$lr,$matrixsel);
		warn1("No matrix matched:\n$lpr\n".join(',',@$mtxlst)) if $#$mtxlst<0;
#		warn1("More than one matrix matched:\n$lpr\n".join(',',@$mtxlst)) if $#$mtxlst>0;
	}
	($mtxexp,$bits)=gen_mtx_expr_bits($prop,$req,$lr);
	$Gpropsets_cache->{$lpre}=[undef,$bits,$mtxexp,$mtxlst,$lexdir,$mcats,undef,$Gmorf];
}

sub mkmtxexp
{
	my ($exp,$mtxexp,$lr);
	for $exp(keys %$Gpropset)
	{
		$lr=substr($exp,0,1);
		$mtxexp=$Gpropset->{$exp}[2];#this is the matrix encoded subexpression of $exp
		for(@{$Gpropset->{$exp}[3]})#this is the list of matrices matching $exp
		{
			$matrices->{$_}{$lr}[0]{$mtxexp}++;
			$mtxexps->{$lr}{$mtxexp}[0]{$_}++;
			$mtxexps->{$lr}{$mtxexp}[5]=$Gpropset->{$exp}[7];#copy example morph;
		}
	}
}

#procedure that calculates the dimensions of matrices and adds that info to
#$matrices->{mtx}{lr}[1]
sub mtxdim
{
	my(@keys,$lr);
	for(keys(%{$matrices}))
	{
		for $lr('l','r')
		{
			@keys=keys(%{$matrices->{$_}{$lr}[0]});
			print STDERR "$_,$lr: ",$#keys+2,"\n";
			$matrices->{$_}{$lr}[1]=$#keys+2;
#			$matrices->{$_}{$lr}[2]=0;
#			$matrices->{$_}{$lr}[3]=[];
			$next_ltr->{$lr}{$_}=1;
			$used_ltrs->{$lr}{$_}=[];
		}
	}
}

#procedure that calculates the 'rank' of matrix expressions
#as the sum  ä(1-mxtdim/1000) for each matrix the expression participates in
#and adds that info to $mtxexps->{lr}{expr}[1]
sub mtxexp_rank
{
	my($lr,$m);
	for $lr('l','r')
	{
		for(keys(%{$mtxexps->{$lr}}))
		{
			for $m(keys(%{$mtxexps->{$lr}{$_}[0]}))
			{
				$mtxexps->{$lr}{$_}[1]+=1-$matrices->{$m}{$lr}[1]/1000;#/
			}
		}
	}
}

#sort matrix expressions according to their rank
sub mtxexp_sort
{
	my($mexp_sort)=@_;
	my($r,$lr);
	for $lr('l','r')
	{
		$r=[];
		@$r=(sort{$mtxexps->{$lr}{$b}[1] <=> $mtxexps->{$lr}{$a}[1]}
			keys(%{$mtxexps->{$lr}}));
		$mexp_sort->{$lr}=$r;
	}
}

sub max
{
	my($m);
	$m=-1e100;
	for(@_){$m=$m<$_?$_:$m}
	return $m;
}

#version 1 of the matrix letter generator that produces mtx-s with holes in
#them

sub mtx_letters
{
	my($mexp_sort)=@_;
	my($m,@mxs,$lr,$max,$nl);
	for $lr('l','r')
	{
		for(@{$mexp_sort->{$lr}})
		{
#			print DBG1 "$_\n";
			@mxs=keys %{$mtxexps->{$lr}{$_}[0]}; #the matrices the expr. participates in
			$nl=$next_ltr->{$lr}; #the next letter for the matrices
			$max=max(@$nl{@mxs});
#			print DBG1 "@mxs,@$nl{@mxs}\n";

			$mtxexps->{$lr}{$_}[2]=$max; #assign the letter to the expr.
			for $m(@mxs)
			{
				$nl->{$m}=$max+1; #this updates $next_ltr->{$lr}{$m} as well
				$matrices->{$m}{$lr}[0]{$_}=$max;
				$matrices->{$m}{$lr}[2][$max-1]=$_; #add the expr to $matrices->{$m}{$lr}[2]
				$matrices->{$m}{$lr}[4][$max-1]=$#mxs; #add the number of matrices the expr participates in to $matrices->{$m}{$lr}[4]
				#$matrices->{$m}{$lr}[5][$max-1]=$max if $#mxs; #mark that the letter may not be changed in the matrix minimization process is the mtxexp participates in more than one matrix
			}
		}
	}
}

#assign mtx letter to $Gpropset{lpr_expr}[0]
sub ltr2propset
{
	my($lr,$m);
	for $lr('l','r')
	{
		#mark unjoinable matrix expressions as such
		for(keys %{$mtxexps->{$lr}})
		{
			$m=$mtxexps->{$lr}{$_};
			#if the list of matrices and the list of matrices in which unjoinable are the same
			$m->[4]=1 if join(':',sort keys %{$m->[0]}) eq join(':',sort keys %{$m->[3]});
		}
	}
	for(keys %$Gpropset)
	{
		($lr)=split(/,/);
		$m=$mtxexps->{$lr}{$Gpropset->{$_}[2]};#reference to the description of the matrix expression
		$Gpropset->{$_}[0]=$m->[2];#matrix letter
		$Gpropset->{$_}[6]=$m->[4];#joinability
		#$mtxexps->{$lr}{$mtxexp}[2] is the mtx letter assigned to $mtxexp
		#$Gpropset->{$exp}[2] is the mtxexp part of $exp
	}
}

@mtxc=('-','*');

#generate humor matrices
#row 0 matches if the right expr has no non-negative requirements
#clmn 0 matches if the left expr has no non-negative requirements

sub mk_matrices
{
	my($m,$l,$r,$lc,$rc,@me,$ast,$c);
	my($lprop,$lreq,$rprop,$rreq);
	for $m(keys %$matrices)
	{
		printmsg("generating matrix $m...");
		for $lr('l','r')
		{
			$matrices->{$m}{$lr}[3]=$next_ltr->{$lr}{$m};
		}
		$mtxenc->{$m}=[];
		print DBG1 "\n$m\n";
		@me=(' ' x 6);
		$me[1]=sprintf("0#%-6d",0);
		for($rc=0;$rc < $next_ltr->{'r'}{$m};$rc++)
		{
#			print DBG1 "$rc=$matrices->{$m}{'r'}[2][$rc]\n";
			$ast=$matrices->{$m}{'r'}[4][$rc-1]?'0':'1';#letters of mexp's participating in more than one matrix are marked by a 0
			$ast='0' unless $rc;
			$me[0].=" $ast#$rc";
			#row 0 is all *'s #THIS IS NO LONGER TRUE, SEE BELOW
#			$me[1].='*'.' ' x (length("$rc")+1);
			#row 0 matches if the right expr has no non-negative requirements
			$me[1].=$mtxc[$matrices->{$m}{'r'}[2][$rc-1]!~/,[^ !(]|,.*[ (]+[^ (!]/].' ';# x (length($rc)+1);
		}
		print DBG1 "$me[0]\n";
#		$me[0].="\n";
		$lc=1;
		#$matrices->{$m}{$lr}[0]{$mtxexp} is the letter assigned to $mtx exp in matrix $m
		#$matrices->{$m}{$lr}[1] is the size of the matrix
		#$matrices->{$m}{$lr}[2] is a list of mxtexp's referring to mtx $m
		$c=0;
		for $l(@{$matrices->{$m}{'l'}[2]})
		{
			$ast=$matrices->{$m}{'l'}[4][$lc-1]?'0':'1';#letters of mexp's participating in more than one matrix are marked by a 0
			$me[$lc+1]=sprintf("$ast#%-6d",$lc);
			($lprop,$lreq)=split(/,/,$l);
#			$me[$lc+1].='*  ';#clmn 0 is all *'s #THIS IS NO LONGER TRUE, SEE BELOW
			#clmn 0 matches if the left expr has no non-negative requirements
			$me[$lc+1].=$mtxc[$lreq!~/^[^ !(]|[ (]+[^ (!]/].'  ';
			$rc=1;
			for $r(@{$matrices->{$m}{'r'}[2]})
			{
				($rprop,$rreq)=split(/,/,$r);
				$c++;
				print STDERR '.' if !($c & 0xfff);
				print STDERR "\n" if !($c & 0x3ffff);
				if($l&&$r)
				{
					$me[$lc+1].=$mtxc[satisfies($rprop,$lreq)&&satisfies($lprop,$rreq)];
				}
				else
				{
					$me[$lc+1].='-';
				}
				$me[$lc+1].=' ';# x (length($rc)+1);
				$rc++;
			}
#			print DBG1 "$l\n$me[$lc+1]\n";
#			$me[$lc+1].="\n";
			$lc++;
		}
		print STDERR "$c cells\n";
#		print DBG1 join("\n",@me),"\n\n";
		minimize_mtx($m,'l',\@me);
		transpose_fast(\@me);
		minimize_mtx($m,'r',\@me);
		transpose(\@me);
		@{$mtxenc->{$m}}=@me;
	}
}

#transpose matrix
sub transpose
{
	my($me)=shift;
	my(@met,$i);
	printmsg("transposing matrix...");
	for($i=0;$i<=$#$me;$i++)
	{
		$j=0;
		for(split / +/,$me->[$i])
		{
			unless($i)
			{
				$met[$j]=$_.' ' x (6-length($_));
			}
			elsif($j)
			{
				$met[$j].=$_.' ' x (length($i-1)+1);
			}
			else
			{
				$met[$j].=$_.' ';
			}
			$j++;
		}
	}
	@$me=@met;
}

#transpose matrix without formatting (faster)
sub transpose_fast
{
	my($me)=shift;
	my(@met,$i);
	printmsg("transposing matrix...");
	for($i=0;$i<=$#$me;$i++)
	{
		$j=0;
		for(split / +/,$me->[$i])
		{
			unless($i)
			{
				$met[$j]=$_.' ';
			}
			elsif($j)
			{
				$met[$j].=$_.' ';
			}
			else
			{
				$met[$j].=$_.' ';
			}
			$j++;
		}
	}
	@$me=@met;
}

#minimize matrix by eliminating identical rows
#set global $maxmtxdim to the maximum matrix dimension
sub minimize_mtx
{
	my($m)=shift;
	my($lr)=shift;
	my($me)=shift;
	my(@mes,@used,$aa,$bb,$i,$j);

	printmsg("minimizing matrix $m,$lr...");

	@mes=sort{($aa=$a)=~s/#\d+\s*//;($bb=$b)=~s/#\d+\s*//;$aa cmp $bb} @$me;
	$aa=shift(@mes);#keep the header row
	#add the 0-initial rows (i.e. exps participating in more than one matrix) intact
	while($mes[0]=~/^0/)
	{
		$bb=shift(@mes);
		$used[$1]=$bb if $bb=~s/^0#(\d+)/#$1/;
	}
	$i=1;
	$bb='';
	for(@mes)
	{
		s/^1#(\d+)\s*//;
		$j=$1;
		unless($bb eq $_){$i++ while $used[$i]};
		print DBG1 "Modifying $lr:$j to $i\n";
		$mtxexps->{$lr}{$matrices->{$m}{$lr}[2][$j-1]}[2]=$i;#modify the letter assignment in $mtxexps
		if(/^(\*\s+)?(-\s+)+$/&&defined $matrices->{$m}{$lr}[2][$j-1])
		{
			warn1("Not joinable $m,$lr,$j=$i: $matrices->{$m}{$lr}[2][$j-1]; $mtxexps->{$lr}{$matrices->{$m}{$lr}[2][$j-1]}[5]\n");
			$mtxexps->{$lr}{$matrices->{$m}{$lr}[2][$j-1]}[3]{$m}=1; #mark unjoinability in $mtxexps
		}
		$used[$i]=sprintf("#%-6d",$i).$_ unless $bb eq $_;#add the row to the mtx unless an identical row has already been added
		$bb=$_;
	}
	$i=$#used+1 unless scalar(@mes);
	$maxmtxdim=$i if $maxmtxdim<$i;
	printmsg("$m,$lr:$i");
	@$me=($aa,@used);
}

#convert '23' to chr(23)
sub num2vec
{
	pack("N",shift);
}

#convert '10111' to chr(23)
sub bit2vec
{
	pack("B$bitlength", substr("0" x $bitlength . shift, -$bitlength));
}

#convert chr(23) to ('1','0','1','1','1')
sub vec2bitarr
{
	split(//, unpack("B*", shift));
}

#convert chr(23) to '10111'
sub vec2bit
{
	unpack("B*", shift);
}

#id's of the left/right paged dictionary files
$dicfileid=
{
 'L','0x100',
 'R','0x200',
};

sub print_hummtx
{
	my ($m,$mi,$i,$f,$mtxexp,$bits,$maskv,$mask,%mtxsel,@mask,@mpos,$tmp);
	local($FLAGno_x_props);
	$FLAGno_x_props=1;
	open(M,">$humsrc/meta$mtx.txt") or die1("Unable to create metamtx file: $humsrc/meta$mtx.txt\n");
	open(L,">$humsrc/$mtx.lay") or die1("Unable to create layout file: $humsrc/$mtx.lay\n");
	$i=0x401;#id of actual matrix file
	$maskv=bit2vec('0');#initialize mask vector
	#create the matrix files
	for $m(keys %$mtxenc)
	{
		$f="$humsrc/${mtx}_$m.txt";
		for(keys %$matrixsel)
		{
			next if /\|/;
			next if $matrixsel->{$_} ne $m;
			($mtxexp,$bits)=gen_mtx_expr_bits($_,'','r');
			$mask=$bits; #this bit-pattern selects this matrix
			$mask=~tr/0./10/;#set relevant bits to 1
			$maskv|=bit2vec($mask);#mark all relevant bits in the global mask
			!defined $mtxsel{$bits}?$mtxsel{$bits}=$i:die1("Matrix selection multiply defined: $bits, $_\n");

			printf DBG "0x%x: %s\n",$i,$bits;
		}
		#print the id to the layout file
		printf L "..\\TMP\\${mtx}_$m.mat\t0x%03x\t1\n",$i;
		#create the matrix file
		open(O,">$f") or die1("Unable to create matrix file: $f\n");
		#write the matrix file
		for(@{$mtxenc->{$m}})
		{
			print O "$_\n";
		}
		close O;
		$i++;
	}
	$i=0;
	@mask=vec2bitarr($maskv);
	#push all relevant mask bit positions into @mpos
	for $bits(@mask)
	{
		if($bits eq '1')
		{
			push(@mpos,$i),$bits='0';
		}
		else
		{
			$bits='.';
		}
		$i++;
	}
#	@mask=split(//,'0' x $bitlength);
	#generate the metamatrix (i.e. the matrix selection) file
	for($i=(1<< ($#mpos+1));$i;$i--)
	{
		$mask=join('',@mask);
		undef $m;
		undef $mi;
		for(keys %mtxsel)#mtxsel contains the mtx_id selected by each mask
		{
			if($mask=~/$_/)
			{
				if(!defined $m)
				{
					#print the id and the mask to the metamtx file
					printf M "0x%x: %s\n",$mtxsel{$_},$mask;
					printf DBG "0x%x: %s\n",$mtxsel{$_},$mask;
					$m=$_,$mi=$mtxsel{$_},next;
				}
				$m.=",$_";
				die1("Ambiguous matrix selection: $mask: $m\n") if $mi!=$mtxsel{$_};
			}
		}
		die1("No matrix matches: $mask\n") if !defined $m;
		#generate the next mask by incrementing it
		for(@mpos)
		{
			$mask[$_]=$mask[$_]?'0':'1';
			last if $mask[$_];
		}
	}
	close(M);
	#add the metamtx file to the layout file
	printf L "..\\TMP\\meta$mtx.bin\t0x%03x\t1\n",0x400;
	$f="$humsrc/metacteg$gen.txt";
	#generate the metactg file
	open(M,">$f") or die1("Unable to create metactg file: $f\n");
	for $m(keys %$metacteg)
	{
		$metacteg->{$m}[0]=~tr/a-z/A-Z/;
		$metacteg->{$m}[1]=entailments($metacteg->{$m}[1]);
		($tmp,$bit2matrix)=($bit2matrix,0);
		($mtxexp,$bits)=gen_mtx_expr_bits($metacteg->{$m}[1],'','r');
		$bit2matrix=$tmp;
		warn1("Metacategory entry $metacteg->{$m}[1] contains non-bit-encoded properties: $mtxexp") if $mtxexp ne ',';
		print M "$m:\t$metacteg->{$m}[0], $dicfileid->{$metacteg->{$m}[0]}, $bits\n";
	}
#	printf L "..\\TMP\\metadict.bin\t0x%03x\t1\n",0x800;
	close(M);
	close(L);
	open(L,">$humsrc/lr$gen.sw") or die1("Unable to create switch file: $humsrc/lr$gen.sw\n");
	print L "ng=$bitlength\nnc=".($maxmtxdim<256?8:16)."\nfd=$delim\n";
	close(L);
}

#Generate a hash of x-properties containing the conditions when they must be set.
sub x_props
{
	my($props)=shift;
	my $x={};

	for(keys(%$props))
	{
		warn1("$_ is not an x property. Appropriateness conditions ($props->{$_}[2]) are ineffective.\n") if $props->{$_}[1]!~/x/&&$props->{$_}[2];
		$x->{$_}=$props->{$_}[2] if $props->{$_}[1]=~/x/;
	}
	return $x;
}

#Generate a hash of matrix-selection properties.
sub mtxsel_props
{
	my($props)=shift;
	my $x={};

	for(keys(%$props))
	{
		for(split(/[&|()!]+/))
		{
			$x->{$_}=1;
		}
	}
	return $x;
}
sub dumpencoding
{
	my($ref,$name)=@_;
#	require 'dumpsh.pl';
	if($store)
	{
		use Storable;
		store ($ref,"$name$gen$bit2matrix.str") or die1("Failed to store \$$name to $name$gen$bit2matrix.str\n");
		return "
		use Storable;
		\$$name=retrieve('$name$gen$bit2matrix.str') or die \"Failed to load \$$name from $name$gen$bit2matrix.str\";\n";
	}
	else
	{
		use Data::Dumper;
		$Data::Dumper::Terse=0;
		$Data::Dumper::Indent=1;
		$Data::Dumper::Deepcopy=1;

		return Data::Dumper->Dumpxs([$ref],[$name]);
	}

#	print Data::Dumper->Dumpxs([$mexp_sort],['mexp_sort']);
#	print Data::Dumper->Dumpxs([$mtxexps],['mtxexps']);
#	print Data::Dumper->Dumpxs([$matrices],['matrices']);
#	print Data::Dumper->Dumpxs([$mtxenc],['mtxenc']);
#	print Data::Dumper->Dumpxs([$Gprops],['Gprops']);
#	print dumpsh([$Gprops],['Gprops']);
#	print Data::Dumper->Dumpxs([$matrixsel],['matrixsel']);
#	print dumpsh([$Gpropset],['Gpropset']);
}

sub do_encoding
{
	printmsg("\nStarting encode.pl\n");
	#store file argument list
	@ARGVtmp=@ARGV;
	#check whether the input has really changed
	$doit=0;
	while(<>)
	{
		chomp;
		next if $excl && /$excl/o;
#		print DBG "$_ :::\n";
		s/;(<<.*>>)$//;
		
		$rps{$_}=1,$cnt++ if !$rps{$_};
		#a req/prop string is missing from the previous version (stored in $rp_cache)
		$doit=1, printmsg("New propset found: $_\nRegenerating encoding..."),last if !$rp_cache->{$_};
	}
	$cnt++ if($startcond);
	#the number of req/prop strings differs from the previous version
	$oldcnt=scalar keys %{$rp_cache};
	printmsg("# of propsets is different; old:$oldcnt, new:$cnt\nRegenerating encoding..."),$doit=1 if $oldcnt != $cnt;
	undef $rp_cache;
	undef %rps;
	#if the input really changed do encoding
	if($doit)
	{
	@ARGV=@ARGVtmp;
	#change '3>x' to '...x', '11,3>01' to '11...01' etc.
	for(keys %$Gprops)
	{
		$Gprops->{$_}[1]=~s/(?:^|,)(\d+)>/'.' x $1/eg;
		$Gprops->{$_}[1]=~s/\$(\d+)(\w+)/dec2bin($1,$$2++)/eg;
	}
	mk_lookuptbl;#make lexicon lookup direction table from $metacteg
	$x_props=x_props($Gprops);
	$mtxsel_props=mtxsel_props($matrixsel);
#	$Gpropset={};
	$mexp_sort={};
	add_Gcmp_props;
#	print dumpsh([$Gcmp_prop],['Gcmp_prop']);
	printmsg("Computing derived properties...");
	derive_props;
#	print dumpsh([$Gprops],['Gprops']);
	printmsg("Encoding property sets...");
	$cnt=0;
	while(<>)
	{
		chomp;
		next if $excl && /$excl/o;
#		print DBG "$_ :::\n";
		$cnt++;
		print STDERR "." if !($cnt % 100);
		s/;(<<.*>>)$//;
		$rp_cache->{$_}=1;
		$Gmorf=$1;
		$Gpropset->{$_}=encode_propset($_,$Gmorf) if(!defined $Gpropset->{$_});
	}
	print STDERR "\n";
	if($startcond)
	{
		$_="r,".join ',',@{$startcond}[0..1];
		$startcond_propset=$_;
		$rp_cache->{$_}=1;
		$Gmorf="<<STARTCOND>>";
		$Gpropset->{$_}=encode_propset($_,$Gmorf,$startcond->[2]) if(!defined $Gpropset->{$_});
	}
	store ($Gpropsets_cache,"ps_cache_$proplst$bit2matrix.tmp") or warn "Failed to create ps_cache_$proplst$bit2matrix.tmp\n" if defined $Gpropsets_cache;
	printmsg("Listing matrix expressions...");
	mkmtxexp;
	printmsg("Calculating matrix dimensions...");
	mtxdim;
	printmsg("Sorting matrix expressions...");
	mtxexp_rank;
	mtxexp_sort($mexp_sort);
	printmsg("Assigning matrix letters to expressions...");
	mtx_letters($mexp_sort);
	printmsg("Generating matrices...");
	mk_matrices;
	ltr2propset;

	printmsg("Writing matrix and layout files...");
	print_hummtx;

	printmsg("Writing encoding file...");

	die "unable to open $_ for writing" unless open (GO_OUT,">$out");
	print STDERR "Output to >$out\n";
	open(STDOUT, ">&GO_OUT") || die "Can't dup stdout";

	print "\$bitlength=$bitlength;\n";
	print "\$startcond_propset='$startcond_propset';\n" if defined $startcond;
	use Data::Dumper;
	$Data::Dumper::Terse=0;
	$Data::Dumper::Indent=1;
	$Data::Dumper::Deepcopy=1;

	print Data::Dumper->Dumpxs([$lookupdirs],['lookupdirs']);

	print dumpencoding($Gpropset,'Gpropset');
#	print dumpencoding($matrices,'matrices');
#	print dumpencoding($mtxexps,'mtxexps');
	printmsg ("Sat cache: $satcache_found found, $satcache_miss missing");
	}
	#if the input did not change just touch the result
	else
	{
		printmsg("Propsets did not change. No new encoding created.\n");
		my $now = time;
		utime $now, $now, $out;
	}
	printmsg("Encoding finished.\n");
}

sub test_hummtxgen
{
	require 'encoding.hpl';
	print_hummtx;
}

#test_hummtxgen;
do_encoding;

#eval
{
store ($sat_cache,'sat_cache.tmp') or warn "Failed to create sat_cache.tmp\n"  if defined $sat_cache;
#store ($sat_sub_cache,'sat_sub_cache.tmp') if defined $sat_sub_cache;
store ($rp_cache,"${out}_rp_cache.tmp") or warn "Failed to create ${out}_rp_cache.tmp\n" if defined $rp_cache;
};

#die "$errorflag error(s) occured.\n" if $errorflag;
die_if_errors();
end_banner();
