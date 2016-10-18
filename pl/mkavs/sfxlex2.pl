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

#generate Hungarian level 2 suffix lexicon (sfx.avs) containing suffix sequences
#from the level 1 suffix lexicon (sfx.1)

BEGIN{
$hpldir=$ENV{'hpldir'} if !$hpldir;
$hpldir='../..' if !$hpldir;
}

use lib "$hpldir/pl/generic";
use lib "$hpldir/src";
use lib "$hpldir/gen";

#$stm=time;

require 'dumpsh.pl';
require 'sfxalt1.pl';
require 'stemalt1.pl';
require 'unif.pl';
require 'lex2.pl';
require 'banner.pl';
require 'diewarn.pl';
start_banner('Level 2 suffix lexicon generator');

$sfxfsa='sfxfsa.hpl' unless $sfxfsa;
require $sfxfsa;

$avs=1 if !defined $avs;

$out=shift;

#%typech=qw/infl = deriv @/;#separator character indicates the type of following morpheme

#alternations within suffix sequences
#empty by default
sub sfxalt0
{
	return @_;
}

#calculate allomorphs of $mrf as determined by vowel harmony
#empty by default
sub sfxalt2
{
	return @_;
}

$tagname='tag';

#vhrm.pl is language specific: it may be empty
require 'vhrm.pl';

#generate sequences described by the fsa $m and add them to @sfxseqs
#@sfxseqs is a list of lists of transitions stepped over
# until getting into a final state
#$o is an auxiliary list of transitions stepped over until now
sub genseqs
{
	my $m=shift;
	my $o=shift;
#	print join(',',@$o),"\n" if !keys %$m;
	push @sfxseqs,$o if !keys %$m;
	for (sort keys %$m)
	{
		genseqs($m->{$_},$o), next if !$_; #empty transitions are skipped
		genseqs($m->{$_},[@$o,$_]);
	}
}

genseqs($sfxfsa,[]);

for(@sfxseqs)
{
	for $i(@$_)
	{
		$keys{$i}++;
	}
}
# the keys of %keys are now the patterns used to label the transitions
# e.g. 'mcat:CASE;'

#we generate a disjunctive pattern of all keys to check against morphemes
$keypat=join '|',keys %keys;

#read the suffix descriptions from sfx.1
#and add each morpheme to the list @{$morphs{$key}},
#where $key is the pattern that matches the morpheme (e.g. 'mcat:CASE;')
#
for(<>)
{

	s/#.*//;#remove comments
#	print "$&\n";#print them on a line of their own
	next if /^$/;#next if bare comment line
	chomp;
	s/props_//g;#remove props_ prefix
	@fd=split /;/;#split into properties
	undef $mrf;
	for(@fd)
	{
		($attr,$val)=split/:/;#separate attr and value
		if(defined $val)
		{
#		$val=[split /,\s*/,$val] if $val=~/,/||$attr=~/_/;
		$val=~s/,\s*/ /g;#multiple values separated by space
		$val=~s/&+/ /g if $attr=~/([rgl][pr])$/;#change & to space
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
#	$m=scalar((/($keypat)/g));
#	$key=$&;
#	print STDERR "$mrf->{phon}\[$mrf->{tag}] $key($m)\n";
#	if($m==1)#OK only if exactly 1 pattern matched the morpheme
#	{
#		push @{$morphs{$key}},avscpy($mrf);
#	}
#	else
#	{
#		warn1("$m suffix patterns matched $_") unless /^#/;
#	}
	@keys=(/($keypat)/g);
#	print STDERR "$mrf->{phon}\[$mrf->{tag}] @keys ($m)\n";
	if($#keys)
	{
		warn1($#keys+1," suffix patterns matched $_") unless /^#/;
	}
	for(@keys)
	{
		push @{$morphs{$_}},avscpy($mrf);
	}
}
#print STDERR "$keypat\n",dumpsh([\@sfxseqs,\%keys,\%morphs],[qw/sfxseqs keys morphs/]);

# for the suffix sequence $s from @sfxseqs generate and print all morph
# sequences that match the keys in the sequence;
# matching morphemes are taken from @{$morphs{$s->[$i]}}

# $s: a suffix pattern sequence from @sfxseqs (e.g. ['mcat:PL;','mcat:CASE;'])
# $i: the index of the actual pattern in the sequence
# $mrf: the level 2 representation of the morph sequence gathered this far
sub makemorfseq
{
	my($s,$i,$mrf)=@_;
	my($mrf2);

	for(@{$morphs{$s->[$i]}})
	{
		if(!$i)#if this is the first morph in the sequence
		{
			if($i!=$#$s)#and not the last at the same time
			{
				$mrf=avscpy($_);
                                #remove right attributes
				delete @$mrf{qw/type rp rr mcat stmalt/};
				#add next morpheme
				makemorfseq($s,$i+1,$mrf);
			}
			else
			{
				prmrfseq($_);#print it if it's the first and the last at the same time
			}
		}
		elsif($i==$#$s)#if this is the last morph in the sequence
		{
			$mrf2=avscpy($_);
                        #remove left attributes
			delete @$mrf2{qw/sfxalt lp lr/};
			#add to the sequence
			$mrf2=unify($mrf,$mrf2,'STRCONCAT') if defined $mrf2;
			#remove changed properties from gp
			do{1 while $mrf2->{gp}=~s/(?:^|[&\s])!?([^&\s]+)(?=[&\s])(.*?[&\s]!?\1)(?=[&\s]|$)/$2/g} if defined $mrf2->{gp};
			#change space to + in these:
			for(qw/phon tag humor/)
			{
				$mrf2->{$_}=~s/ /+/g if defined $mrf2->{$_};
			}
			prmrfseq($mrf2);#print it
		}
		else #this is a morph in between
		{
			$mrf2=avscpy($_);
                        #remove left and right attributes
			delete @$mrf2{qw/sfxalt lp lr type rp rr mcat stmalt/};
			#add to the sequence
			$mrf2=unify($mrf,$mrf2,'STRCONCAT') if defined $mrf2;
			#remove changed properties from gp
			do{1 while $mrf2->{gp}=~s/(?:^|[&\s])!?([^&\s]+)(?=[&\s])(.*?[&\s]!?\1)(?=[&\s]|$)/$2/g} if defined $mrf2->{gp};
			#add next morpheme
			makemorfseq($s,$i+1,$mrf2);
		}
	}
}

#print the morph sequence (level 2 lexicon representation)
sub prmrfseq
{
	my $mrf=avscpy(shift);
	my ($a);
	local $_;

#	push @mrfseqs,avscpy($mrf);
#	print dumpsh([$mrf],['mrf']),"\n";
	$type=$typech{$mrf->{type}};#get separator character indicating morph type
	$_='';
	for $a (keys %$mrf)
	{
		$_.="$a:$mrf->{$a};";
	}
	$almfs1=sfxalt1($mrf);#generate allomorphs determined by the given sfxalt
	@almfs=();
	#generate harmonic variants
       	for $m(@$almfs1)
	{
		push(@almfs,sfxalt2($m));
	}
	$cat=$mrf->{mcat};
	undef $cat unless $cat=~s/.*>//;
	#intransitive unless V>V suffix:
#	$mrf->{gp}.=' trans0' if $mrf->{type} eq 'deriv' && $cat ne 'V' && $mrf->{gp}!~/trans/;
	#non-human unless Mrs, DIM or infl ## this is not needed anymore, we changed human to the local property -ék
	#$mrf->{gp}.=' !-ék' if $mrf->{type} eq 'deriv' && $mrf->{tag}!~/(^DIM|Mrs|NNs)$/;
	warn1("No allomorphs for $mrf->{allomf} ($mrf->{$tagname})"),$error++ if $#almfs<0;#error if no allomorphs were generated
	#$phon=$mrf->{phon};
	#$phon=~s/$lexchars//go if $lexchars;#remove lengthening/lowering(L)/opacity(F) markers
	$phon=sfxalt0($mrf->{phon});
	delete @$mrf{qw/type sfxalt phon mcat/};#delete these properties
	$mrf->{'UR'}=$phon;
	for(@almfs)
	{
#		$_=unify($_,$mrf->{props},'CONCAT') if defined $mrf->{props};
		#unify morpheme properties with allomorph properties
		$_=unify($_,$mrf,'STRCONCAT') if defined $mrf;
		$_->{seg}="$type$_->{allomf}";
                #add phon if this is a zero allomorph (of @i):
		$_->{phon}=$phon if !$_->{allomf}&&$phon;
		$_->{cat}=$cat if defined $cat;
                #calculate allomorphs determined by stem alternation 
                #and add all suffixation properties:
		$alm2=stemalt($_);
		warn1("No allomorphs for $_->{seg}"),$error++ if $#$alm2<0;
		$_->{allomfs}=$alm2;#add allomorphs
                #remove allomorph-level properties from the root level:
		if($avs)
		{
	                #remove allomorph-level properties from the root level:
			delete @$_{lr,rr,lp,rp,gp,glr,grr};
			$a=dumpsh([$_],['mrf']);
			$a=~s/=> ' +/=> '/g;
        	        print $avs $a,"\n";
        	}
        	lex2($_);
	}
#	$mrf->{allomfs}=$almfs;
#	print dumpsh([$mrf],['mrf']);
#	print dumpsh([$almfs],['allomfs']);
}

open(LX2,">$out.lx2") or dienow("Unable to create level2 lexicon file $out.lx2");
(open(AVS,">$out.avs") or dienow("Unable to create level2 avs lexicon file $out.avs")),$avs='AVS' if $avs;

# for each suffix sequence in @sfxseqs generate and print all morph sequences
# that match the keys in the sequence

for $s(@sfxseqs)
{
	makemorfseq($s,0,undef);
}

#print dumpsh([\@mrfseqs],[qw/mrfseqs/]);

close(LX2);
close(AVS);
print_propsets($out);
savenormfrm();

#$end=time-$stm;
#warn sprintf "elapsed: %02d:%02d",$end/60,$end%60;
warn1("$error entries produced no allomorphs") if $error;
die_if_errors();
end_banner();
