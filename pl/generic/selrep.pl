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

sub selrep0
{
	my($exc_,$str_,$sel_,@rep_)=@_;
	my($a_,$b_,$c_,$d_,$spc_,$todo_);
	$todo_='$c_=$str_;$d_=\'\';while($a_=($c_=~'.$sel_.')'.($exc_?',$a_||$c_':'').'){($a_,$b_,$c_)=!$a_?($c_,\'\',\'\'):(($& eq $1.$2.$3)?($`.$1,$2,$3.$\'):($`,$&,$\'));'."\n";
	{
		$spc_='$a_',last if $exc_;
		$spc_='$b_';
	}
	foreach $pat_(@rep_)
	{
		$todo_.="$spc_=~".$pat_.";\n"	
	}
	$todo_.='$d_=$d_.$a_.$b_;}';
#	print $todo_;
	eval $todo_;
	return $d_.$c_;
}

#selective replace
#replace only in selected part
#selrep($in_what,$selection,@subst_expr_list)
#e.g.:
#$selection='/\{@.*?@\}/g';
#@subst_expr_list=('s/[|+=]//g');
sub selrep
{
	selrep0(0,@_);
}

#selective replace
#replace only outside the selected part
sub selexrep
{
	selrep0(1,@_);
}

1;