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
require 'set.pl';
require 'selrep.pl';
use Data::Dumper;
use Storable qw/dclone/;

#package unif;

#set the $procs variable to a defined value if you use procedural attribute values
my $procs=undef;

sub parse
{
	my $i=shift;
	$i=~s/\\,/ţţ/g;
	my @s=split(/((?:=|^)\s*[{\[][{\[\s]*|[}\],\s]*(?:,|=>)[{\[\s]*|[}\]][}\],;\s]*$)/,$i);
#	my @s=split(/((?:=|^)\s*[{\[][{\[\s]*|[}\]\s]*(?:=>)[{\[\s]*|[}\]][}\];\s]*$)/,$_[0]);
	my $j;
	$i=1;
	for (@s)
	{
		$i=!$i;
		next if $i;
		if($reserved{$_}||((/\W/||(eval($_) ne $_)) && ($_!~/^[\$\@\%]/)))
#		if($reserved{$_}||eval($_) ne $_)
#		if($_!~/^[\$\@\%]|$/)
		{
			if(!$reserved{$_} && $_!~/\W/)
			{
				$reserved{$_}=1;
				print RESLST "'$_',1,";
			}
			$_=~s/'/\\'/g;
			$_="'$_'";
		}
	}
#	print join('',@s)."\n";#.keys(%reserved)."\n";
	$i=join('',@s);
	$i=~s/ţţ/,/g;
	$i=selrep($i,'/(,\')(\\\\\'.*?\\\\\')(\',)/g',('s/^\\\\\'|\\\\\'$//g','s/\'?,\'?/,/g'))
	 if $i=~/,'\\\'.*?\\\'',/;
	 return $i;
}

sub dumpit {
    unless (defined &main::dumpValue) {
	do 'dumpvar.pl';
    }
    if (defined &main::dumpValue) {
	&main::dumpValue(shift);
    } else {
	print $OUT "dumpvar.pl not available.\n";
    }
}

sub printstr
{
	$Data::Dumper::Terse=1;
	$Data::Dumper::Indent=1;
	print Data::Dumper->Dumpxs(\@_,[]);
}

sub printstr0
{
	$Data::Dumper::Terse=1;
	$Data::Dumper::Indent=0;
	print Data::Dumper->Dumpxs(\@_,[]);
}

use Scalar::Util 'reftype';
#use UNIVERSAL qw(isa);
#%arrays=('ARRAY',1,'EQARRAY',1,'STRUNI',1);
#%atoms=('',1,'HYPH',1);
%nobless=('',1,'ARRAY',1,'HASH',1);
$idch=" ";
sub printstr1
{
	my ($y,$nobl,$noq)=@_;
	my ($z,$ry);
	$ry=ref($y);
	print 'bless(' if !($nobl||$nobless{$ry});
#	elsif($arrays{$ry})
	if(reftype($ry) eq 'ARRAY')
	{
		my $q;
		print "[";
		for $q(@$y)
		{
			printstr($q);
			print ', ';
		}
		print "]";
	}
#	elsif($ry eq 'HASH')
	elsif(reftype($ry) eq 'HASH')
	{
		my $q;
		my $r=[sort(keys(%$y))];
		print "\n".$idch x $id if $#$r;
		print "{";
		$id++;
		for $q(@$r)
		{
			print "\n".$idch x $id if $#$r;
			print "$q => ";
			printstr($y->{$q});
			print ', ' if $#$r;
		}
		$id--;
		print "\n".$idch x $id if $#$r;
		print "}";
	}
#	if($atoms{$ry})
	else
	{
		$z=$y;
		if(!$noq)
		{
			$z=~s/'/\\'/g;
			$z="'$z'";
		}
		print "$z";
	}
	print ', '.$ry.')' if !($nobl||$nobless{$ry});
}

#calculate the meet of types
#$dat=default array type, e.g. 'MEETARRAY';
sub typemeet
{
	my($x,$y,$dat)=@_;
	if($x eq $y)
	{
#		return $x if $x ne 'ARRAY';
#		return $dat;
		return $x;
	}
	if($x=~/CONCAT|ARRAY|STRUNI|^OR|^PROC|SUBSET$/ && $y=~/CONCAT|ARRAY|STRUNI|^OR|^PROC|SUBSET$/)
	{
		my $t="#$x##$y#";
		$t=~s/#ARRAY#/#$dat#/g;
		return 'PROC' if($t=~/#PROC#/ && $t=~/#(MEET)?ARRAY#/);
		return 'OR' if($t=~/#OR#/ && $t=~/#(MEET)?ARRAY#/);
		return 'EQARRAY' if($t=~/#EQARRAY#/ && $t=~/#(MEET)?ARRAY#/);
		return 'STRUNI' if ($t=~/#STRUNI#/ && $t=~/#(MEET)?ARRAY#/);
		return 'CONCAT' if ($t=~/#(STR)?CONCAT#/ && ($t=~/#((MEET)?ARRAY|STRUNI)#/));
		return 'SUBSET' if ($t=~/#SUBSET#/ && $t=~/#(MEET)?ARRAY#/);
		return 'MEETARRAY' if $t=~/#MEETARRAY#/;
		return undef;
	}
	elsif($x ne $y)
	{
		return undef;
	}
}

# return an independent copy of the structure in $x while keeping track of
# procedures (arrays of type 'PROC')
# the latter is done only if the packge variable unif::procs is true

sub avscpy
{
        my($x)=@_;
	my $r;
	if(ref($x) eq '')
	{
		$r=$x;
	}
	elsif(!$procs)
	{
	        return dclone($x);
	}
	elsif(reftype($x) eq 'ARRAY')
	{
		$r=[];
		for(@$x)
		{
			push(@$r,avscpy($_));
			push(@procs,\$r->[$#$r]) if ref($r->[$#$r]) eq 'PROC';
		}
		bless($r,ref($x)) if ref($x) ne 'ARRAY';
	}
	elsif(reftype($x) eq 'HASH')
	{
		$r={};
		for(keys %$x)
		{
			$r->{$_}=avscpy($x->{$_});
			push(@procs,\$r->{$_}) if ref($r->{$_}) eq 'PROC';
		}
	}
	return $r;
}

# unification

# If the $default parameter is either 1 or 2, then the 1st/2nd structure
# supplies only default values. Unification is always successful if the 
# types are compatible, but the similarity measure (see below) does not 
# make sense. 
# The value of any array or atomic feature present in the non-default 
# structure is taken from the non-default structure.

# Only atomic values may individually be marked as default by prefixing 
# them by <d> in the structures to be unified. 
# Two defaults may only be unified if they are identical.

# Atomic values may also be of type regexp. A regexp is of the form /.../,
# and must be a valid regular expression. A regexp may also match a default.

# The unification of arrays is determined by their type:
# 'MEETARRAY', 'OR': the intersection may not be empty
# 'OR': the result contains only the intersection
# 'MEETARRAY': the result contains every element (i.e. it is their union)
# 'EQARRAY': each respective element from the lists must be unifiable
# 'STRUNI': the union of the arrays is taken, the elements must be atomic
# 'SUBSET': the second array must be a subset of the first one
# 'CONCAT': any two arrays can be unified by concatenation, the result is 
#	    [@$x,@$y]
# 'STRCONCAT': same as CONCAT but atomic values are also concatenated
# 'PROC': the lists must be the same; the first element is interpreted as
#	  a procedure name, the other elements as arguments to it.
# Arrays are by default of the type given in $listtype, which defaults to 
# MEETARRAY

# If $listtype is 'SUBSET', the returned value is simply a reference to the 
# second structure (i.e. is equal to $y). This can be used to check whether
# $x satisfies all the requirements defined by $y.

# If $sim is defined then it must be a reference to (an empty) hash. 
# In this case, a similarity measure between the structures to be unified 
# is returned in $sim:
# the fields of $sim contain:
# $lem	the number of identical leaves ('leaves exactly match')
# $lm	leaves match (lem+defaults and regexp)
# $nm	internal nodes match
# $n	  the number of internal nodes in the result
# $l   the number of leaves in the result
# 'STRUNI' nodes do not count

sub unify_0
{
	my($x,$y,$listtype,$default,$sim)=@_;#$x, $y ref; 
	my($t,$arr);
	$listtype='MEETARRAY' if !$listtype;
#	$sim={} if !defined $sim;
#	$sim_lem=$sim_lm=$sim_nm=$sim_n=$sim_l==0;
#	return undef if !defined($x)||!defined($y);
	$t=typemeet(ref($x),ref($y),$listtype);
	if(!defined($t))
	{
		warn "Type mismatch: ".ref($x)."/".ref($y).":\n".Data::Dumper->Dumpxs([$x,$y],[])."\n" ;
		return undef;
	}
	if($default&&($t eq '' || reftype($y) eq 'ARRAY'))
	{
		if($default==1)
		{
			return $y;
		}
		elsif($default==2)
		{
			return $x;
		}
	}
	if($t eq 'ARRAY')
	{
		$arr=1;
		$t=$listtype;
	}
	if($t eq '')
	{
	        if($listtype eq 'STRCONCAT') #atomic values are concatenated if $listtype is STRCONCAT
	        {
	        	return "$x $y";
	        }
                if(defined $sim)
		{
			$sim->{l}++;
		}
		my $z;
		if(($x=~/[$hyphchars]/||$y=~/[$hyphchars]/)&& ($z=unifhyph($x,$y)))
		{
			if(defined $sim)
			{
				$sim->{lm}++;
				$sim->{lem}++;
			}
			return $z;
		}
		elsif($x eq $y)
		{
			if(defined $sim)
			{
				$sim->{lm}++;
				$sim->{lem}++;
			}
			return $x;
		}
		else
		{
			my $def=($x=~/^<d>/+2*$y=~/^<d>/); #defaults are defeasible
			$sim->{lm}++ if(defined $sim);
			return $y if($def==1);
			return $x if($def==2);
			$def=($x=~/^\//)+2*($y=~/^\//); #regexps must match -- they may match defaults
			return $y if($def==1&& ($x=~s/\///,eval "\$y=~/(<d>)?$x"));
			return $x if($def==2&& ($y=~s/\///,eval "\$x=~/(<d>)?$y"));
			$sim->{lm}-- if(defined $sim);
			return undef;
		}
	}
#	elsif($t eq 'STRUNI'|| ($listtype eq 'STRUNI' && $t eq 'ARRAY'))
	elsif($t eq 'STRUNI')
	{
		my $u=union($x,$y);
		bless($u,$t) if !$arr && $u;
		return $u;
	}
	elsif($t=~/CONCAT/)
	{
		my $u=[@{avscpy($x)},@{avscpy($y)}];
#		my $i=0;
#		for(@$x,@$y)
#		{
#			push(@$u,$_);
#			push(@procs,$u[$i]) if ref($_) eq 'PROC';
#			$i++;
#		}
		bless($u,$t) if !$arr;
		return $u;
	}
	elsif(reftype($y) eq 'ARRAY')
	{
#		if($t=~/^(MEETARRAY|OR)$/||(!$eqlist&&$t ne 'EQARRAY'))
#		if($t eq 'EQARRAY'|| ($listtype eq 'EQARRAY' && $t eq 'ARRAY'))
		if($t=~/EQARRAY|PROC/)
		{
			my ($q,$u);
			my $r=[];
			return undef if $#$x!=$#$y;
			for($q=0;$q<=$#$x;$q++)
			{
				$u=(unify_0($x->[$q],$y->[$q],$listtype,$default,$sim));
				return undef if !defined $u;
				push(@{$r},$u);
				if(defined $sim)
				{
					$sim->{nm}+=2;
					$sim->{n}+=2;
				}
			}
#			push(@procs,$r) if $t eq 'PROC';
			bless($r,$t) if !$arr && $r;;
			return $r;
		}
		else
		{
			my ($u,$q,$r,@q,@r,$rcnt);
			@q=@$x;
			@r=@$y;
			if(defined $sim)
			{
				$sim->{n}+=$#q+$#r+2;
			}
			my @res;
			@res=();
			$rcnt=$#r+1;
			for $q(@q)
			{
				for $r(@r)
				{
					next if !defined($r);
					$u=unify_0($q,$r,$listtype,$default,$sim);
					if(defined($u))
					{
						if(defined $sim)
						{
							$sim->{nm}+=2;
						}
						push(@res,$u);
						push(@procs,\$res[$#res]) if ref($u) eq 'PROC';
						$q=undef;
						$r=undef;
						$rcnt--;
						last;
					}
				}
			}
#			if(@res&&($t eq 'OR'||($listtype eq 'OR'&&$t eq 'ARRAY')))
			if($rcnt==0&&$t eq 'SUBSET')
			{
				return $y if $listtype eq 'SUBSET'; #optimized for speed!!!
				return bless(\@res,$t);
			}
			elsif(@res&&$t eq 'OR')
			{
				return bless(\@res,$t) if !$arr;
				return \@res;
			}
			elsif(@res) #copy items appearing only in one array
			{
				for $q(@q,@r)
				{
					push(@res,avscpy($q)) if defined($q);
					push(@procs,\$res[$#res]) if ref($q) eq 'PROC';
				}
				return bless(\@res,$t) if !$arr;
				return \@res;
			}
			else
			{
				return undef;
			}
		}
	}
	elsif($t eq 'HASH')
	{
		my(@a,@b,$a,$b);
		my %res;
	#	return undef if ref($x)!='HASH'||ref($y)!='HASH';
		@a=sort(keys(%{$x}));
		@b=sort(keys(%{$y}));
		$a=shift(@a);
		$b=shift(@b);
		while(defined($a)||defined($b))
		{
			if($a eq $b)
			{
##				return undef if(ref($x->{$a})!=ref($y->{$b}));
	#			if(defined($b)&&ref($x->{$a})!=ref($y->{$b}))
	#			{
#					elsif(ref($y->{$b}) eq 'HASH')
					{
						my $q;
						$q=unify_0($x->{$a},$y->{$b},$listtype,$default,$sim);
						if(defined($q))
						{
							if($listtype ne 'SUBSET')
							{
								$res{$a}=$q;
								if(defined $sim)
								{
									$sim->{nm}+=2;
									$sim->{n}+=2;
								}
								push(@procs,\$res{$a}) if ref($q) eq 'PROC';
#								push(@procs,\%res,$a) if ref($q) eq 'PROC';
							}
						}
						else
						{
							return undef;
						}
					}
	#			}
				$a=shift(@a);
				$b=shift(@b);
			}
			while(defined($a) && ($a lt $b||!defined($b)))
			{
				if($listtype ne 'SUBSET')
				{
					$res{$a}=avscpy($x->{$a});
					push(@procs,\$res{$a}) if ref($x->{$a}) eq 'PROC';
				}
				$a=shift(@a);
				$sim->{n}++ if defined $sim;
			}
			while(defined($b) && ($b lt $a||!defined($a)))
			{
				return undef if($listtype eq 'SUBSET');
				$res{$b}=avscpy($y->{$b});
				push(@procs,\$res{$b}) if ref($y->{$b}) eq 'PROC';
				$b=shift(@b);
				$sim->{n}++ if defined $sim;
			}
		}
		return $y if($listtype eq 'SUBSET');
		return \%res;
	}
}

# unify evaluates all procedures (array values of type 'PROC') after a
# successful unification of two structures and subtitutes the result
# of the procedure call for the procedure if the call is successful
# The first arument to the procedures is always a reference to the unified
# structure ($u).

sub unify
{
	my($x,$y,$listtype,$default,$sim)=@_;#$x, $y ref; 
	local @procs;
	# @procs is a list of features that have a procedural value
	my ($ref,$f,$proc,$u,@args);

	$u=unify_0($x,$y,$listtype,$default,$sim);
	
	if(defined($u) && $#procs>=0) 
	{
		while($ref=shift(@procs))
		{
#			$f=shift(@procs)
#			@args=reftype($ref) eq 'HASH'?@{$ref->{$f}}:@{$ref->[$f]};
			@args=@$$ref;
			$proc=shift(@args);
			$proc=eval "$proc \$u,\@args";
			$$ref=$proc;
		}
	}
	return $u;
}

sub unifyw
{
	my($x,$y)=@_;
	my($u);
	$Data::Dumper::Terse=1;
	$Data::Dumper::Indent=0;
	$u=unify(@_);
	if(!$u)
	{
		warn "#Unification failed:\n".Data::Dumper->Dumpxs([$x,$y],[])."\n";
		print "#Unification failed:\n".Data::Dumper->Dumpxs([$x,$y],[])."\n";
	}
	return $u;
}

# check if $x satisfies $y (i.e. $y is a substructure of $x);
# $y is returned if yes, undef otherwise.

sub avs_satisfies
{
	my($x,$y)=@_;#$x, $y ref; 
	local @procs;
	unify_0($x,$y,'SUBSET',0,undef);
}

# unification with similarity measure calculation
sub unif_sim
{
	my($x,$y,$ltype,$default,$sim)=@_;#$x, $y ref; 
	$sim={};
	return unify($x,$y,$ltype,$default,$sim);
}

# unify each pair in two lists and return a list of the unified structures 
# sorted by their similarity measure
# $x and $y are pointers to lists, $ltype is the default list type
sub unifyall
{
	my($x,$y,$ltype)=@_;
	my(@u,$q,$r,@q,@r,$s,$u);
	@q=@$x;
	@r=@$y;
	my @res;
	for($q=0;$q<=$#q;$q++)
	{
		for($r=0;$r<=$#r;$r++)
		{
			$s={};
			$u=unify($q[$q],$r[$r],$ltype,undef,$s);
			push(@u,[$q,$r,$u,$s->{nm}/$s->{n}]) if defined($u);
		}
	}
	return sort {$b->[3]<=>$a->[3]} @u;
}

#does not work
sub unifiable
{
	my($x,$y)=(shift,shift);
	my(@a,@b,$a,$b);
#	return undef if !defined($x)||!defined($y);
	return undef if ref($x)!='HASH'||ref($y)!='HASH';
	@a=sort(keys(%{$x}));
	@b=sort(keys(%{$y}));
	$a=shift(@a);
	$b=shift(@b);
	while(defined($a)||defined($b))
	{
		if($a eq $b)
		{
			return undef if(ref($x->{$a})!=ref($y->{$b}));
#			if(defined($b)&&ref($x->{$a})!=ref($y->{$b}))
#			{
				if(ref($y->{$b}) eq '')
				{
					return undef if($x->{$a} ne $y->{$b});
				}
				elsif(ref($y->{$b}) eq 'HASH')
				{
					return undef if !unifiable($x->{$a},$y->{$b});
				}
#			}
			$a=shift(@a);
			$b=shift(@b);
		}
		while(defined($a) && ($a lt $b||!defined($b)))
		{
			$a=shift(@a);
		}
		while(defined($b) && ($b lt $a||!defined($a)))
		{
			$b=shift(@b);
		}
	}
	return 1;
}

#$a={a,a,b,b,c,{a,a,c,c}};
#$b={d,a,c,{a,a,b,b}};
# eval('$a='.parse('{a,<d>d,w,`ab+geben,b,{a,[r,e],g,[-\']},i,[1]}'));
# eval('$b='.parse('{a,a,w,ab|ge|ben,b,{a,[s,e],g,[-\',f],p,[0]},i,[2]}'));
#eval('$a='.parse('{a,<d>d,b,{a,[r,e],g,[-s]},i,[1]}'));
#eval('$b='.parse('{a,a,b,{a,[s,e],g,[-s,f],p,[0]},i,[2]}'));

# bless $a->{i},'STRUNI';
# bless $b->{i},'STRUNI';
#bless $a->{w},'HYPH';
#bless $b->{w},'HYPH';
#print"\$a=\n";
#dumpit($a);
#printstr($a);
#print"\n\$b=\n";
#dumpit($b);
#printstr($b);

#print"\n\$c=\n";
# $c=unify($a,$b);
#dumpit($c);
# printstr($c);

1;
