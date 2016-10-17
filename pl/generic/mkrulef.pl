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

{
my ($p,@l,$l,$i,$src);

#add line to resulting perl source
sub addline
{
#	print join('',@_);
	$i=join('',@_);
	$p.=$i;
	for($i=($i=~tr/\n//);$i;$i--)
	{
		$l[++$l]=$.;
	}
	$src=$1 if $_[0]=~/#src:(\S+)/;

}

#check resulting perl source for errors
sub errchk
{
	local $SIG{'__WARN__'} = sub {$@.="WARN:$_[0]"};
	local $SIG{'__DIE__'} = sub { die "ERROR:$_[0]"};

	#print $@ if !eval($p)&&$@;
	#exit;
	print $p;
	eval($p);
	$_=$@;
	if($_)
	{
	#	delete $SIG{'__DIE__'};
	#	delete $SIG{'__WARN__'};
		s/, <> line \d+//;
		s/line (\d+)/line $l[$1]/g;
		s/eval \d+/$src/g;
		s/Unrecognized character (\\x[\dA-F]+)/$&.eval("\" ($1)\"")/eg;
		die "syntax error in $src, Perl error messages:\n$_";
	}
}
}

#add or remove properties and requirements
sub pr_list
{
	my $m=shift;
	for(my $i=0;$i<=$#rr;$i++)
	{
		next unless $rr[$i];
		die "Required attr: prefix missing from field ".($i+2)." in line $.:\n$_\n" unless $Rr[$i];
		#if it is a requirement list: add requirements or remove with ~ prefix
		if($Rr[$i]=~/$rvar/o)
		{
#			$rr[$i]="$m\->{'$Rr[$i]'}.=\" $rr[$i]\";";
			@chk=split(/[\s&]+/,$rr[$i]);
			$rr[$i]='';
			$rp1='';
			for(@chk)
			{
				#deleting properties
				s/([^\\]|^)\./$1\[^\\s&]/g, #change unquoted dots to [^\s&] if deleting
				$rr[$i].="$m\->{'$Rr[$i]'}=~s/(?:^|[\\s&])(?:$_)(?=\$|[\\s&])//g;",next if s/^~//;
				#adding properties
				$rp1.=" $_";
			}
			if($rp1){$rp1="$m\->{'$Rr[$i]'}.=\"$rp1\";";}
			$rr[$i].=$rp1;
		}
		#if it is a property list: add or remove properties
		elsif($Rr[$i]=~/$pvar/o)
		{
			@chk=split(/[\s&]+/,$rr[$i]);
			$rr[$i]='';
			$rp1='';
			for(@chk)
			{
				#deleting properties
				s/([^\\]|^)\./$1\[^\\s&]/g, #change unquoted dots to [^\s&] if deleting
				$rr[$i].="$m\->{'$Rr[$i]'}=~s/(?:^|[\\s&])(?:$_)(?=\$|[\\s&])//g;",next if s/^[~!]//;
				#adding properties
				$rp1.=" $_";
			}
			if($rp1){$rp1="$m\->{'$Rr[$i]'}.=\"$rp1\";";}
			$rr[$i].=$rp1;
		}
		#non-list attributes are simply overwritten
		else
		{
			$rr[$i]="$m\->{'$Rr[$i]'}=\"$rr[$i]\";";
		}
	}
	@rr=grep{$_}@rr;
}

sub mkrulefile
{
my($subname,$dp,$dr)=@_;

addline("use utf8;\n");;
addline("#src:$ARGV[0]\n");;
while(defined($_=<>) and m/^\s*([\$@#])|^\s*$/){addline($_);} #print comments and var. assignments

$addsubs=qq/

#remove tags from {allomfs} and move them to {cats} if any
sub almftags
{
 my \$t=shift;

 if(\$t->{'allomf'}=~m#\\[#)
 {
  \$t->{'cats'}=\$t->{'allomf'};
  \$t->{'allomf'}=~s#\\[.*?\\]##g;
  \$t->{'cats'}=~s#[^+[]*(\\+|\\[[^]]*\\]|\$)#\$1#g;
 }
}

#add morpheme level properties
#unless the allomorph has the property no_lexprops
sub ${subname}_addprops
{
 my \$t=shift;
 if(!(\$t\->{'$dp'}=~s#(?:^|[\\s&])no_lexprops(?=\$|[\\s&])##))
 {
  \$t\->{'$dp'}.=" \$$dp" if \$$dp;
  \$t\->{'$dr'}.=" \$$dr" if \$$dr;
  for \$frm(\@proptags)
  {
   \$t\->{\$frm}.=" \$mrf->{\$frm}" if \$mrf->{\$frm}
  }
 }
 almftags(\$t);
}

#add lexical morpheme level properties
sub ${subname}_addlexprops
{
 my \$t=shift;
 for \$frm(\@proptags2){\$t\->{\$frm}.=" \$mrf->{\$frm}" if \$mrf->{\$frm}}
 almftags(\$t);
}
/;

addline ('
@proptags=qw/lr lp glr grr gp restr/;
@proptags2=qw/rp rr lr lp glr grr gp restr/;'.
$addsubs.
qq/

#fix !X ... X sequences in $dp by removing both (expensive!!!)
sub ${subname}_fixdp
{
 my \$t=shift;
 while(\$t\->{'$dp'}=~s#(?:^|\\s)!(\\S+)(?=\\s)(.*?)\\s\\1(?=\$|\\s)#\$2#g){}
 \$t\->{'$dp'}=~s#!(\\S+)##g;
}

#fix !X ... X and X ... !X sequences in $dp by removing both (expensive!!!)
sub ${subname}_fixprops
{
 my \$t=shift;
 while(\$t\->{'$dp'}=~s#(^|\\s)(\\S+)(?=\\s)(.*?)\\s\\2(?=\$|\\s)#\$1\$2\$3#g){}
 while(\$t\->{'$dp'}=~s#(?:^|\\s)!(\\S+)(?=\\s)(.*?)\\s\\1(?=\$|\\s)#\$2#g
 || \$t\->{'$dp'}=~s#(?:^|\\s)([^!]\\S+)(?=\\s)(.*?)\\s!\\1(?=\$|\\s)#\$2#g){}
 while(\$t\->{'$dr'}=~s#(?:^|\\s)~(\\S+)(?=\\s)(.*?)\\s\\1(?=\$|\\s)#\$2#g
 || \$t\->{'$dr'}=~s#(?:^|\\s)([^~]\\S+)(?=\\s)(.*?)\\s~\\1(?=\$|\\s)#\$2#g){}
}
/);

$addsubs=~s/_add/_/g;
$addsubs=~s/.=" (.*?)" if/=$1 if/g;

addline ("$addsubs

sub $subname".'
{
 local $mrf=shift;
 local($frm,$alm,$open);
 my $almptr=shift;
 local @allomfs=@$almptr;'."
 local(\$$dp,\$$dr);

 \$$dr=\$mrf->{$dr};
 \$$dp=\$mrf->{$dp};

");

$l=1; #indentation
$global=1; #properties are global or allomorph-local
$first=1;
$this0='$_';
$prvar='(?:gp|g?[lr][rp])'; #property and requirement varible names
$rvar='(?:g?[lr]r)'; #requirement varible names
$pvar='(?:[glr]p)'; #property varible names
$alm_atr='(?:gp|g?[lr][rp]|allomf|restr|cats)'; #allomf attributes

#allomorph addition subroutines
#this sub adds allomorphs without adding any morpheme level properties
$alm_only=sub
{
	@RR=();
	for(my $i=0;$i<=$#rr;$i++)
	{
		next unless $rr[$i];
		push(@RR,"'$Rr[$i]'");
		push(@RR,"\"$rr[$i]\"");
	}
	"\$alm=\$frm;$chk\{push \@allomfs,\{'allomf',\$alm,".join(',',@RR)."\};}";
};

#this sub adds allomorphs with all morpheme level properties
$alm_morf=sub
{
	pr_list('$almp');
	$"='';
	"\$alm=\$frm;$chk\{\$almp={};${subname}_props(\$almp);@rr push \@allomfs,\{'allomf',\$alm,\%\$almp};}";
};

#this sub adds allomorphs with lexically specified morpheme level properties
$alm_lex=sub
{
	pr_list('$almp');
	$"='';
	"\$alm=\$frm;$chk\{\$almp={};${subname}_lexprops(\$almp);@rr push \@allomfs,\{'allomf',\$alm,\%\$almp};}";
};

%alm_subs=(
'',$alm_morf,
'M',$alm_morf,
'L',$alm_lex,
'0',$alm_only,
);

%alm_subs=(
'',$alm_only,
'M',$alm_only,
'L',$alm_only,
'0',$alm_only,
);

$frstX=1;
while($frstX or defined($_=<>))
{
	$frstX=0;
	$alm=0;
	addline ($_),next if /^\s*(#|$)/; #print comments
	s/^\s*//; #remove initial whitespace
	chomp;
	$line="$_#line:$.\n";
	addline (' ' x $l,$line),next if /^\s*[\$\@]\w+\s*=/; #indent assignments
#	if(/^\s*(?:my(\*)? \$?(\w+)|[\$#]|$)/) #process my variables
	if(/^\s*(?:my(\*)? \$?(\w+))/) #process my variables
	{
		addline(' ' x $l,$line),next if !$2;
		addline(" local \$$2=\$mrf->{'$2'};#line:$.\n") if !$locals{$2};
		$locals{$2}=1;
		$back{$2}=1 if $1;
		$locals="(?:".join('|',keys %locals).")";# if !$locals;
		next;
	}
	chomp;
#	s/#.*//;
	$line=$_;
	#fix $C[aieou] in regexps on which some perl versions fail
	#$C[aieou] to $C(?:[aieou]) within /.../
	{
		my $b;

		s#(/.*?[^\\]/)#$b=$1,$b=~s/(\$[{\w}]+)(\[[^\d\$][^]]+\])/$1(?:$2)/g,$b#eg;
	}
	$qmap=1 if /^dup/;
	if(/(?:if|unless|dup|while)\s*\((.*)\)/)#processing if's
	{
		if($global)
		{
			$this='$mrf';
		}
		else
		{
			$this='$_';
		}
#		@chk=split(/(\)*(?:&&|\|\|)\(*|\)+$|^\(+)/,$1);
		@chk=split(/(&&|\|\|)/,$1);
		for(@chk)
		{
#			next if /(&&|\|\||^\(|\)$)/;
			next if /(&&|\|\||^\s*!?\$)/;
			s/^\s+|\s+$//g;
			$op=s/^!//?'!':'=';
			s/([^\\]|^)\./$1\[^\\s&]/g;#modify .* type regex's
			if($global)
			{
				next if s/^(.*?):(s?\/)/$this\->{'$1'}$op~$2/;#attr:// regex forms
				next if s/^(.*?):(.*)/$this\->{'$1'}$op~\/(?:^|\\s)(?:$2)(?=\$|\\s)\//;#attr:val forms
				#other conditions test rp
				$_="\$$dp$op~/(?:^|[\\s&])(?:$_)(?=\$|[\\s&])/", next if $global || s/^\^//; #global $rp is checked
			}
			else
			{
				next if s/^(?:(?!$alm_atr|\^)|\^)([^\^].*?):(s?\/)/\$mrf->{'$1'}$op~$2/o;#checking global attributes
				#(non-allomf attributes are always global, others only if marked by ^)
				next if s/^(?:(?!$alm_atr|\^)|\^)([^\^].*?):(.*)/\$mrf->{'$1'}$op~\/(?:^|[\\s&])(?:$2)(?=\$|[\\s&])\//;
				next if s/^(.*?):(s?\/)/$this\->{'$1'}$op~$2/o;#checking local list attributes
				next if s/^(.*?):(.*)/$this\->{'$1'}$op~\/(?:^|[\\s&])(?:$2)(?=\$|[\\s&])\//;
				$rp1=(s/^\^//)?"\$$dp":"$this\->{'$dp'}";#global properties are marked by ^
				s/([^\\]|^)\./$1\[^\\s&]/g;
				$_="$rp1$op~/(?:^|[\\s&])(?:$_)(?=\$|[\\s&])/";
			}
		}
		$chk=join '',@chk;
		s/(if|unless|while)\(.*\)/$1($chk)/;
		s/dup\(.*\)/map\n{\nif($chk)/;
	}
	if(/(.*?;){2}/)#lines where properties are set
	{
#		s/([^\\]|^)\./$1\[^\\s&]/g; #change unquoted dots to [^\s&]
#		($chk,$rr,$rp,$if)=split(/;\s*/);
		($chk,@rr)=split(/;\s*/);
		undef $if;
		#remove eol comment
		pop(@rr) while $#rr>=0&&$rr[$#rr]=~/^#|^\s*$/;
		#checking whether there is an if/unless clause at the end of line
		$if=pop(@rr) if($rr[$#rr]=~/^(if|unless)\s*\(/);
		#overriding the default with attr:
		@Rr=map {s/^(.*?)://?$1:''} @rr;
		#fields 2 and 3 default to rr and rp
		$Rr[0]=$dr unless $Rr[0];
		$Rr[1]=$dp unless $Rr[1];
#		($Rr,$Rp)=($dr,$dp);#fields 2 and 3 default to rr and rp
#		$Rr=$1 if $rr=~s/^(.*?)://;#overriding the default with attr:
#		$Rp=$1 if $rp=~s/^(.*?)://;
		$if=~s/#.*//;#delete comments at the end of line
		$else=$chk=~s/^(els)e //?$1:'';
#		$comma=',',$if='' if $if eq ',';
		@chk=split(/(&&|\|\|)/,$chk);
#		@chk=split(/(\)*(?:&&|\|\|)\(*|\)+$|^\(+)/,$chk);
		if($global&&$chk!~/^\+/)#global property checking and setting
		{
			for(@chk)
			{
				next if /(&&|\|\||^\s*!?\$)/;
				s/([^\\]|^)\./$1\[^\\s&]/g; #change unquoted dots to [^\s&]
				s/^\s+|\s+$//g;
#				next if /(&&|\|\||^\(|\)$)/;
				$op=s/^!//?'!':'=';
				next if s/^(.*?):((?:s|tr)?\/)/\$mrf->{'$1'}$op~$2/;#attr:// regex forms
				next if s/^(.*?):(.*)/\$mrf->{'$1'}$op~\/(?:^|[\\s&])(?:$2)(?=\$|[\\s&])\//;#attr:val forms
				s/([^\\]|^)\./$1\[^\\s&]/g;#modify .* type regex's
				$_="\$$dp$op~/(?:^|[\\s&])(?:$_)(?=\$|[\\s&])/";#other conditions test rp
			}
			$chk=join '',@chk;
			$chk="${else}if($chk)" if $chk;
			$chk='else ' if !$chk&&$else;
			pr_list('$mrf');
=comment
			if($rr){($Rr=~/$prvar/o and $rr="\$mrf->{'$Rr'}.=\" $rr\";") or #add properties to rr
			 $rr="\$mrf->{'$Rr'}=\"$rr\";";} #non-list attributes are overwritten
			@chk=split(/[\s&]+/,$rp);
			if($Rp=~/$prvar/o)
			{
				$rp='';
				$rp1='';
				for(@chk)
				{
					$rp.="\$mrf->{'$Rp'}=~s/(?:^|\\s)(?:$_)(?=\$|\\s)//g;",next if s/^!//;#deleting properties from rp
					$rp1.=" $_"; #adding properties to rp
				}
				if($rp1){$rp1="\$mrf->{'$Rp'}.=\"$rp1\";";}
				$rp.=$rp1;
			}
			else
			{
				$rp="\$mrf->{'$Rp'}=\"$rp\";"; #non-list attributes are overwritten
			}
#			if($rp){$rp="\$$Rp.=\" $rp\";";}
#			elsif($rp){$rp=~s/^!//;$rp="\$$Rp=~s/(^| )$rp(?= |\$)/\$1/;";}
=cut
			$"='';
			$_=$if?"$chk\{do{@rr} $if;\}\n":"$chk\{@rr}\n";
		}
		elsif($chk=~/^\+/)#adding an allomorph and setting its local properties
		{
			($addp)=$chk=~/^\+([ML0]?)/;
			die "Only modifiers M|L|0 allowed after + in line $.:\n$_\n" unless $addp=~/^[ML0]?$/;
			$chk=~s/^\+[ML0]/+/;
			$chk=~s!^\+//!\+/$pat/!;
			$chk=~s!^\+/!\$alm=~s/!;#/!
			$chk=~s!^\+!1!;
			$if=~s/^\s*if(.*)/$1&&/;
			$if=~s/^\s*unless(.*)/!$1&&/;
			$chk=($chk eq '1')?($if?"if(${if}1)":''):"if($if($chk))";
#			$rr=",'$Rr',\"$rr\"" if $rr ne '';
#			$rp=",'$Rp',\"$rp\"" if $rp ne '';
			$alm=1;
#			$_="\$alm=\$frm;$chk\{push \@allomfs,\{'allomf',\$alm,".join(',',@RR)."\};}";
			$add_alm=$alm_subs{$addp};
			$_=&$add_alm;
			if($chk=~s/\@\{([^}]*)\}/\$$1\[\$i]/g)
			{
#				for(@RR)
#				{
#					s/\@\{([^}]*)\}/\$$1\[\$i]/g;
#				}
				$_="for(my \$i=0;\$i<=\$#$1;\$i++){$_}\n";
				s/\@\{([^}]*)\}/\$$1\[\$i]/g;
			}
			$_.="\n";
			$open=1;
		}
		elsif(!$global)#setting and resetting allomorph properties
		{
			if($qmap)
			{
				$this='$qmpp';
			}
			else
			{
				$this=$this0;
			}
			for(@chk)
			{
				next if /(&&|\|\||^[\s(]*!?\$)/;
				s/^\s+|\s+$//g;
				s/([^\\]|^)\./$1\[^\\s&]/g;
#				next if /(&&|\|\||^\(|\)$)/;
				$op=s/^!//?'!':'=';
				next if s/^(?:(?!$alm_atr|\^)|\^)([^\^].*?):(s?\/)/\$mrf->{'$1'}$op~$2/o;#checking global attributes
				#(non-allomf attributes are always global, others only if marked by ^)
				next if s/^(?:(?!$alm_atr|\^)|\^)([^\^].*?):(.*)/\$mrf->{'$1'}$op~\/(?:^|[\\s&])(?:$2)(?=\$|[\\s&])\//;
				next if s/^(.*?):(s?\/)/$this\->{'$1'}$op~$2/o;#checking local list attributes
				next if s/^(.*?):(.*)/$this\->{'$1'}$op~\/(?:^|[\\s&])(?:$2)(?=\$|[\\s&])\//;
				$rp1=(s/^\^//)?"\$$dp":"$this\->{'$dp'}";#global properties are marked by ^
#				$rp1=(s/^\^//)?'$rp':"$this\->{'rp'}";#global properties are marked by ^
				$_="$rp1$op~/(?:^|[\\s&])(?:$_)(?=\$|[\\s&])/";
			}
			$chk=join '',@chk;
			$chk="${else}if($chk)" if $chk;
			$chk='else ' if !$chk&&$else;
			pr_list($this);
=comment
#			if($rr){$rr="\$$Rr.=\" $rr\";";} #add rr's
			if($rr){$rr="$this\->{'$Rr'}.=\" $rr\";";} #add rr's
			@chk=split(/[\s&]+/,$rp);
			$rp='';
			$rp1='';
			for(@chk)
			{
				$rp.="$this\->{'$Rp'}=~s/(?:^|\\s)(?:$_)(?=\$|\\s)//g;",next if s/^!//;#deleting properties from rp
				$rp1.=" $_"; #adding properties to rp
			}
			if($rp1){$rp1="$this\->{'$Rp'}.=\"$rp1\";";}
			$rp.=$rp1;
#			elsif($rp){$rp=~s/^!//;$rp="\$$Rp=~s/(^| )$rp(?= |\$)/\$1/;";}
=cut
			$"='';
			$_=$if?"$chk\{do{@rr} $if;\}\n":"$chk\{@rr}\n";
#			$_="$chk\{do{$rr$rp} $if;\}\n";
			$_="\$qmpp=avscpy($this0);${_}",s/}$/push(\@qmpp,\$qmpp);}/ if ($qmap);
		}
		else{s/^/###/;}

#	addline($_);
	}
	elsif(m#^[^;]*!?(root):/([^;/]*)/([^;]*)$#)#root:// lines preceding allomorph adding + lines
	{
		($var,$pat,$chk)=($1,$2,$&);
#		@chk=split(/(\)*(?:&&|\|\|)\(*|\)+$|^\(+)/,$chk);
		undef $plst;
		$plst="&&(($1)||1)", $chk=~s/#!!(.*)// if $chk=~/#!!(.*)/;
		@chk=split(/(&&|\|\|)/,$chk);
		for(@chk)
		{
			next if /(&&|\|\||^\s*!?\$)/;
			s/^\s+|\s+$//g;
#			next if /(&&|\|\||^\(|\)$)/;
			$op=s/^!//?'!':'=';
			next if s/^(.*?):(s?\/)/\$mrf->{'$1'}$op~$2/;
			next if s/^(.*?):(.*)/\$mrf->{'$1'}$op~\/(?:^|[\\s&])(?:$2)(?=\$|[\\s&])\//;#attr:val forms
			$_="\$$dp$op~/(?:^|[\\s&])(?:$_)(?=\$|[\\s&])/";
		}
		$chk=join ('',@chk).$plst;
		$_="if($chk)\n{\n\$frm=\$mrf->{'$var'};\n";
		s/^/els/ if !$first; #an else is added to every non-first such line in a block
		$first=0;
	}
	elsif(s/&almftags;/almftags($this0);/){}
	elsif(s/&addprops;/${subname}_addprops($this0);${subname}_fixdp($this0);/){}
	elsif(s/&addlexprops;/${subname}_addlexprops($this0);/){}
	elsif(s/&fixprops;/${subname}_fixprops($this0);/){}
	elsif(s/for\([\@\$]allomfs/return [] unless \@allomfs;\n$&/)
	{
		$global=0;
	}
#	$global=0 if /^for\(.allomfs|^map/m;#allomorph manipulating blocks
	$global=0 if s/^map\((.*?)\)/$1=map/;
	if(/^{$/)#the beginning of a block
	{stbl:{
		$first=1;
		push(@stack,$pline);
		$_.="\nundef \@qmpp;",last stbl if $pline=~/^dup/;
	}}
	elsif(/^}$/)
	{endbl:{
		$stktop=pop(@stack);
		$global=1,last endbl if $stktop=~/^for\(.allomfs/;
#		$global=1,$_="\@mpp;\n$_",last endbl if $stktop=~/^map/;
		$global=1,$_="(\$_);\n}\n$1;\n",last endbl if $stktop=~/^map\((.*?)\)/;
		$qmap=0,$_="\@qmpp;\n}\nelse{(\$_)}\n}\n" if $stktop=~/^dup/;
	}}
	s/^/}\n/,$open=0 if $open && !$alm;
	s!~s/.*?/.*?/!$&o!g;#adding an o switch to all
	s!~/.*?/!$&o!g;
	s!(~s/.*?/.*?/)oa!$1!g;#adding an o switch to all except if marked ///a
	s!(~/.*?/)oa!$1!g;
	s/\$mrf->\{'($dp|$dr|$locals)'}/\$$1/g;#modifying lines referring to my variables
	s/\$mrf->\{'\^/\$mrf->{'/og;#fixing ^attr cases
	s/else if/elsif/g;#fixing elsif
	for(split /\n/)#computing indentation
	{
		$l-- if /^}$/;
		addline(' ' x $l,$_,"#line:$.\n");
		$l++ if /^{$/;
	}
	$pline=$line;
}

addline(' ' x --$l."}#line:$.\n") if $open;

for(keys %back)
{
	addline(" \$mrf->{'$_'}=\$$_;\n");;
}
addline(" \\\@allomfs;\n}\n1;\n");;

errchk();
}

1;
