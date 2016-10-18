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

require 'm2getopt.pl';

$transl=q`
#mind[FN|NM][NOM] mind[Adv|Pro]
#mely[FN mely[Adj/N
zért[HA|PRO zért[Adv|Pro|C
egyéb[FN egyéb[Adj/N
vala[S_IGE] van[S_V.Pst.Narr]
volt[S_IGE] van[S_V.Pst]
volna[S_IGE] van[S_V.Cond]
legyen[S_IGE] van[S_V.Sbjv]
légyen[S_IGE] van[S_V.Sbjv]
[MNhum [Adj_(hum)
[FN [N #noun
[MN [Adj #adjective
[MNi [Adj
[SZN [Num #numeral
[IGE [V #verb
|NM |Pro #pronoun
[HA [Adv #adverb
[HA|(FN0 [Adv|(N0
[HA|(SZN [Adv|(Num
[IK [Prev #verbal prefix
[KOT [Cnj #conjunction
[ISZ [Inj-Utt #interjection
[DET [Det #determiner
[NU [Post #postposition
|BETU |Ltr #letter
|ROV |Abbr #abbreviation
[MSZ [Inj-Utt #utterance word
(NU) (Post)
[KSZ [QPtcl #question particle -e
[INR [Inf. 
e1] 1S]
e2] 2S]
e3] 3S]
t1] 1P]
t2] 2P]
t3] 3P]
t3*] 3P*]
[PSe1i] [Pl.Poss.1S]
[PSe2i] [Pl.Poss.2S]
[PSe3i] [Pl.Poss.3S]
[PSt1i] [Pl.Poss.1P]
[PSt2i] [Pl.Poss.2P]
[PSt3i] [Pl.Poss.3P]
e1= 1S:
e2= 2S:
e3= 3S:
t1= 1P:
t2= 2P:
t3= 3P:
[PSe1i= [Pl.Poss.1S:
[PSe2i= [Pl.Poss.2S:
[PSe3i= [Pl.Poss.3S:
[PSt1i= [Pl.Poss.1P:
[PSt2i= [Pl.Poss.2P:
[PSt3i= [Pl.Poss.3P:
[PSe1i?= [Pl?.Poss.1S:
[PSe2i?= [Pl?.Poss.2S:
[PSe3i?= [Pl?.Poss.3S:
[PSt1i?= [Pl?.Poss.1P:
[PSt2i?= [Pl?.Poss.2P:
[PSt3i?= [Pl?.Poss.3P:
[PS [Poss. #possessive
[Ve1] [Prs.NDef.1S]
[Ve2] [Prs.NDef.2S]
[Ve3] [Prs.NDef.3S]
[Vt1] [Prs.NDef.1P]
[Vt2] [Prs.NDef.2P]
[Vt3] [Prs.NDef.3P]
[Ne1] [1S]
[Ne2] [2S]
[Ne3] [3S]
[Nt1] [1P]
[Nt2] [2P]
[Nt3] [3P]
[Me [Pst.NDef.S #past tense
[Mt [Pst.NDef.P
[Pe [Sbjv.NDef.S #subjunctive
[Pt [Sbjv.NDef.P
[Fe [Cond.NDef.S #conditional
[Ft [Cond.NDef.P
[Ee [Pst.Narr.NDef.S
[Et [Pst.Narr.NDef.P
[Te [Prs.Def.S #defininite conjugation
[Tt [Prs.Def.P
[TMe [Pst.Def.S
[TMt [Pst.Def.P
[TPe [Sbjv.Def.S
[TPt [Sbjv.Def.P
[TFe [Cond.Def.S
[TFt [Cond.Def.P
[TEe [Pst.Narr.Def.S
[TEt [Pst.Narr.Def.P
[Ie1 [Prs.1S›2 #1sg subject 2 pers object
[IMe1 [Pst.1S›2
[IPe1 [Sbjv.1S›2
[IFe1 [Cond.1S›2
[IEe1 [Pst.Narr.1S›2
[T?Me [Pst.Def?.S
[T?Mt [Pst.Def?.P
[T?Pe [Sbjv.Def?.S
[T?Pt [Sbjv.Def?.P
[T?Fe [Cond.Def?.S
[T?Ft [Cond.Def?.P
[T?Ee [Pst.Narr.Def?.S
[T?Et [Pst.Narr.Def?.P
[POS [AnP #anaphoric possessive
[POSi [AnP.Pl
[DET|def [Det|Art.Def
[DET|indef [Det|Art.NDef

[_HAT	[Mod #modal -hAt
[_SZENV	[Pass #passive -t?Atik
[_MUV	[Caus #causative (factitive) -t?At
[_MED	[MedPass #medial -Ódik
[_GYAK	[Freq #frequentative -O?gAt
[IF	[Ger #gerund -Ás
[_DES	[Des #desiderative -hatnék
[_OKEP	[ImpfPtcp #imperfect (present) participle -Ó
[_MIB	[PerfPtcp #perfect (past) participle -O?tt
[_HATO	[ModPtcp #modal ('-able') participle -hAtÓ
[_MIA	[FutPtcp #future (passive) participle ('to be ...-d') -AndÓ
[_HATATLAN	[NegModPtcp #negative modal ('in-...-able') participle -hAtAtlAn
[_IFOSZT	[NegPtcp #negative passive ('un-...-ed') participle -AtlAn
[_HIN	[AdvPtcp #adverbial participle -vA
[_HINN	[AdvPerfPtcp #adverbial perfect participle -vÁn
[_FI	[NVbz_Ntr:zik #intransitive noun verbalizer suffix -zik
[_FIT	[NVbz_Tr:z #transitive noun verbalizer suffix -z
[_FIL	[NVbz:l #transitive noun verbalizer suffix -l
[_MIGY	[Vbz:kOd #noun verbalizer suffix -s?kOdik
[_DIM	[Dim:cskA #diminutive suffix -VcskA
[_DIMKA	[Dim:kA #diminutive suffix -kA
[_MRS	[Mrs #Mrs. suffix ('wife of') -né
[_IKEP	[Adjz:i #adjectivizer suffix -i
[_SKEP	[Adjz:s #adjectivizer suffix -Vs
[_UKEP	[Adjz:Ú #adjectivizer suffix -Ú
[_SZERU	[Adjz_Type:szerű #adjectivizer type suffix -szerű
[_FELE	[Adjz_Type:féle #adjectivizer type suffix -féle
[_FAJTA	[Adjz_Type:fajta #adjectivizer type suffix -fajta
[_FORMA	[Adjz_Type:forma #adjectivizer type suffix -forma
[_NEMU	[Adjz_Type:nemű #adjectivizer type suffix -nemű
[_MENTES	[Adjz_Neg:mentes #adjectivizer negative suffix -mentes
[_FFOSZT	[Abe #abessive = adjectivizer negative suffix -A?tlAn, -tAlAn
[_BELI	[Adjz_Loc:beli #adjectivizer locative suffix -beli
[_DIS	[Distr:nként #distributive -Vnként
[_SOC	[Com:stUl #comitative -stUl
[_SOC*	[Com:stÓl #comitative variant form: -stÓl
[_NTA	[DistrFrq:ntA #frequency suffix -VntA
[_FOK	[Comp #comparative -bb
[_FF	[Supl #superlative leg-
[_FFF	[ExSupl #excessive legesleg-
[_KIEM	[Design #designative -(bb)ik
[_DIMKAMN	[Dim:kA
[_DIMMN	[Dim:cskA
[_PROP	[Nz_Abstr #nominalizer suffix ('-ness') for abstract nouns -sÁg
[_COL	[Nz_Abstr 
[_ESSMOD	[Manner #adverbializer "essive modal" suffix ('-ly') -An, -Ul
[_ESSMOD=	[Manner:
[_MI	[AdjVbz_Ntr #intransitive adjective verbalizer suffix -Vs?Odik -Ul
[_FAK	[AdjVbz_Tr #transitive adjective verbalizer suffix -ít
[_SORSZ	[Ord #ordinal -Vdik
[_TORT	[Frac #fractional -Vd
[_ESSNUM	[Aggreg #aggregate -An
[_MUL	[Mlt-Iter #multiplicative/iterative -szOr
[_SZORTA	[MltComp #comparative multiplicative -szOrtA
[_DATUM	[OrdDate #date suffix -Vdika
[_JOV [Fut
[_HIN=AttA [AdvPtcp:AttA
[_HINST [AdvPtcp:vÁst
[_HIN=ttOn [AdvPtcp:ttOn
[FOR	[EssFor:ként #essive formal suffix -ként
[KEPPEN	[EssFor:képpen #essive formal suffix -képpen
[KEPP	[EssFor:képp #essive formal suffix -képp
[FAC	[Transl #translative -vÁ
_SUBJ _Subj
|NM][INL |Pro.Ade
|NM][EXL |Pro.Abl
|NM][ADL |Pro.All
[IS	[Ptcl:is #particle (enclitic) 'too' is
|ME	|Unit #unit of measure
|ABC	|Acron #acronym
[SUP	[Supe #superessive -On
[SUB	[Subl #sublative -rA
[TEM	[Temp #temporal -kor

[_IF= [Ger:

[_FELESEG	[Nz_Type:féleség #nomanalizer of type suffix -féleség
[_SZERUSEG	[Nz_Type:szerűség #nomanalizer of type suffix -szerűség
[_MER	[Adjz_Quant #quantification -nyi
[_NIVALOFN	[VNz:nivaló #nominalizer suffix ('to be ...-d') -nivaló
[_NIVALO*	[VAdjz:nivaló #adjectivizer suffix ('to be ...-d') -nivaló *orth substd, std: ...ni való
[_SZAM	[Advz_Quant:szám #adverbializer suffix of quantity -szám
[_SZERTE	[Advz_LocDistr:szerte #adverbializer suffix of locational distribution -szerte
[_TMP_ANTE	[Tmp_Ante #temporal anteriority -jA (két éve)
[_TMP_INL	[Tmp_Loc #temporal location (various manifestations, -vAl, -0)
[_OMN	[Adjz:Ó #adjectivizer -Ó, only for inflected forms with low linking vowel
[_SFN	[Nz:s #nominalizer suffix -Vs
_SUPx	_Supe
[_ILAG	[NAdvz:ilAg #noun adverbializer -ilAg
[_OLAG	[VAdvz:ÓlAg #verb adverbializer -ÓlAg
_KJ	_Hyph
_HKJ	_Dash
_PER	_Slash
|VEGY	|ChemSym #Chemical symbol
[ELO	[CmpdPfx #compound prefix
(POSS	(Poss
[MNa	[Adj|Attr #attributive-only adjective 
[MNp	[Adj|Pred #predicative-only adjective 
[SZNa	[Num|Attr #attributive-only numeral 
|MODMN	|AdjMod #adjective modifier
|DIGIT	|Digit #digit
[_DLAGOS	[Adjz_Ord:VdlAgOs #Numeral adjectivizer -VdlAgOs
[_SZOK	[Adjz_Hab #adjectivizer: habitual -Ós
[_LAG	[Advz:lAg #Adj adverbializer -lAg
[_RET	[Advz:rét #Num adverbializer -rét
[FAM	[Fam.Pl #Familiar plural
[ROMAN	[Num|Roman
[INL	[Loc #locative
|indef	.NDef
`;

$transl=~s/ *#.*|^\s+|\s+$//g;
$transl=~s/^\s+|\s+$//g;
%transl=(split /\s+/,$transl);

warn ">$transl<\n" if $debug;

#`,('[PUNCT]','','|ME','','[NOM]',''));
#`,('[PUNCT]','','|ME','','|col','','|mat','','[NOM]',''));
$trpat=join '|', map {s/\\?\[(?!S_)\\?_?/(?<=[\[=_(])/;$_} map {quotemeta} sort {$b cmp $a} keys %transl;
warn ">$trpat<\n" if $debug;
for(keys %transl)
{
	$a=$transl{$_};
	$a=~s/^\[//;
	$a=~s/:/%:/;
	delete $transl{$_};
	s/^\[(?!S_)_?//;
        $transl{$_}=$a;
}

warn join(' ',keys %transl),"\n" if $debug;

sub convert
{
	local $_=shift;
	s/(\|NM.*_)([et][1-3]\])/$1N$2/g;
	s/(\[I?_?)([et][1-3]\])/$1V$2/g;
	s/($trpat)(?!\@)/$transl{$1}/og;
	s/S([1-3])|([1-3])S/$1$2Sg/g;
	s/P([1-3])|([1-3])P/$1$2Pl/g;
#	s/([\[.(][ISP]?_?)([A-Z])([A-Z_]+)(?=$|[].:=)])/$1$2\L$3/g;
	s#\[S_#[/#g;
	s#\[D=+(.*?)(_.*?)\]#[$2/$1]#g;
	s#\[I_#[#g;
	s#\[H_#[Hyph%:#g;
	s/([\[.(]\/?)([A-Z])([A-Z_]+)(?=$|[]\%.:=)])/$1$2\L$3/g;
	s#\?(?!Def)##g;
	return $_;
}

if($listtags)
{
	while(<>)
	{
		s/(\|NM.*_)([et][1-3]\])/$1N$2/g;
		for(/(\[.*?\])/g)
		{
			$t=$_;
			print $t,"\t",convert($t),"\n" unless $have{$t}++;
		}
	}
}
else
{
	while(<>)
	{
		print($_), next if !/\[/;
		print convert($_);
	}
}
