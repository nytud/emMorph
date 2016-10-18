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
#  The Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA)
#  license is available at: https://creativecommons.org/licenses/by-nc-sa/4.0/
#  
#  Disclaimer of Warranties and Limitation of Liability.
#  
#  Unless otherwise separately undertaken by the Licensor, to the extent possible,
#  the Licensor offers the Licensed Material as-is and as-available, and makes no
#  representations or warranties of any kind concerning the Licensed Material,
#  whether express, implied, statutory, or other. This includes, without
#  limitation, warranties of title, merchantability, fitness for a particular
#  purpose, non-infringement, absence of latent or other defects, accuracy, or the
#  presence or absence of errors, whether or not known or discoverable. Where
#  disclaimers of warranties are not allowed in full or in part, this disclaimer
#  may not apply to You.
#  
#  To the extent possible, in no event will the Licensor be liable to You on any
#  legal theory (including, without limitation, negligence) or otherwise for any
#  direct, special, indirect, incidental, consequential, punitive, exemplary, or
#  other losses, costs, expenses, or damages arising out of this Public License or
#  use of the Licensed Material, even if the Licensor has been advised of the
#  possibility of such losses, costs, expenses, or damages. Where a limitation of
#  liability is not allowed in full or in part, this limitation may not apply to You.
#
################################################## END OF LICENSE ##################################################

!ifndef ROOT
ROOT      = e:\humor.hu\hpl
!endif
!ifndef PLE
PLE       = e:\perl\bin
!endif
DTN       = $(ROOT)\src\dtn
PL        = $(ROOT)\pl\generic
PLMK      = $(ROOT)\pl\mkavs
SRC       = $(ROOT)\src
SFX       = $(ROOT)\src
HSRC      = $(ROOT)\src
GENDIR    = $(ROOT)\gen
HGEN      = $(ROOT)\gen
AVSDIR    = $(ROOT)\avs
HUM       = $(ROOT)\gen

#full generator (exact inverse of analyzer)
!ifdef FULLGEN
FULLGEN	= -fullgen
ENCSW = "-excl=;restr:[gGm]+"
!endif

#select the encoding to use
#the default is to use the one belonging to the application
#otherwise the encoding is not recalculated
!ifndef USEENC
USEENC = $(APP)
!else
KEEPENC = 1
!endif

!if "$(USEENC)" == "."
USEENC = 
!endif

#do not simplify matrixes by removin bit encoded properties
!ifdef BIT2MTX
BIT2MTX=bit2mtx
BIT2=1
ENCSW = $(ENCSW) -bit2matrix
!endif

!ifndef METADICT
METADICT  = metadict$(GSFX)
!endif

!ifndef NODERSFX
DERSFX = -dersfx=$(SRC)\dersfx.lst
!endif

!ifndef NOBASE
STEMPRONLX2 = $(GENDIR)\prongen$(APP0).lx2 $(GENDIR)\stemgen$(APP0).lx2 $(GENDIR)\stems2addgen$(APP0).lx2
STEMPRONPS = $(GENDIR)\prongen$(APP0).propsets $(GENDIR)\stemgen$(APP0).propsets $(GENDIR)\stems2addgen$(APP0).propsets
!endif

#words may be excluded for certain applications
#HLXSW contains switches passed to humlex.pl
#EXCL may contain additional specific excludes e.g. |badorth
#EXCL must begin with |
!ifdef APP
HLXSW= $(HLXSW) "-excl=excl=[^]*$(APP)$(EXCL)"
!endif

!ifdef GEN
GEN	= gen
SW	= -noseg -generator -gen=gen -useenc=$(USEENC) -bit2mtx=$(BIT2MTX) $(MORESW)

#do:	$(GENDIR)\timestamp ps_cache.tmp $(HUM)\hugen$(APP)l.lex $(HUM)\hu$(APP)l.lex $(HUM)\hugenl.lex $(HUM)\hul.lex $(HUM)\sfxseq.srt $(HUM)\$(METADICT).txt
do:	$(GENDIR)\timestamp ps_cache_proplst$(GSFX).hpl$(BIT2).tmp $(HUM)\hugen$(APP)l.lex $(HUM)\hu$(APP)l.lex $(HUM)\sfxseq.srt $(HUM)\$(METADICT).txt $(HUM)\dercat.lst
	$(PLE)\perl -e "print STDERR scalar(localtime),\"\n\""
	echo done

!else
SW	= -noseg -gen= -useenc=$(USEENC) -bit2mtx=$(BIT2MTX) $(MORESW)

do:	$(GENDIR)\timestamp $(HUM)\hu$(APP)l.lex $(HUM)\$(METADICT).txt
	$(PLE)\perl -e "print STDERR scalar(localtime),\"\n\""
	echo done

xlx:	$(GENDIR)\timestamp $(HUM)\$(METADICT).txt $(GENDIR)\encoding$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\gen$(APP).lx2 $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2
	$(PLE)\perl -e "print STDERR scalar(localtime),\"\n\""
	echo done

!endif

$(GENDIR)\timestamp:
	@if not exist $(PLE)\perl.exe echo Active Perl v5.6.1 must be installed to $(PLE). If it is installed somewhere else, then adjust the line beginning set PLE=... in hpl\mak\setroot.bat
	@$(PLE)\perl -e "die 'Active Perl v5.6.1 must be installed to $(PLE)'.\"\nIf it is installed somewhere else, then adjust the line beginning \nset PLE=... in hpl\\mak\\setroot.bat\n\".'To check the version of perl type: $(PLE)\perl -v'.\"\n\" unless $$]>=5.006001"
	$(PLE)\perl -e "print STDERR scalar(localtime),\"\n\""

$(HUM)\dercat.lst:	$(PLMK)\sfxtaglst.pl
	$(PLE)\perl $(PLMK)\sfxtaglst.pl >$(HUM)\dercat.lst

!ifdef ENGUESS

$(HUM)\hu$(APP)l.lex:

$(HUM)\hugen$(APP)l.lex:	$(PLMK)\stat2lex.pl $(PL)\diewarn.pl $(PL)\banner.pl $(PL)\m2getopt.pl $(GENDIR)\gen$(APP).st $(HUM)\hugen$(APP)d.lex
	$(PLE)\perl $(PLMK)\stat2lex.pl -=$(HUM)\hugen$(APP)l.lex $(GENDIR)\gen$(APP).st
	type $(HUM)\hugen$(APP)d.lex >>$(HUM)\hugen$(APP)l.lex

$(GENDIR)\gen$(APP).st:	$(PLMK)\prd2stat.pl $(PL)\diewarn.pl $(PL)\banner.pl $(PL)\m2getopt.pl $(SRC)\$(APP)norm.pl $(GENDIR)\gen$(APP).prd
	$(PLE)\perl $(PLMK)\prd2stat.pl -do=$(SRC)\$(APP)norm.pl -=$(GENDIR)\gen$(APP).st $(GENDIR)\gen$(APP).prd

$(GENDIR)\gen$(APP).prd:	$(PLMK)\lex2prd.pl $(PL)\diewarn.pl $(PL)\banner.pl $(PL)\m2getopt.pl $(PL)\strdiff.pl $(HUM)\hugen$(APP)s.lex
	$(PLE)\perl $(PLMK)\lex2prd.pl "-excl=$$restr=~/a/" -=$(GENDIR)\gen$(APP).prd $(HUM)\hugen$(APP)s.lex

$(HUM)\hugen$(APP)s.lex $(HUM)\hugen$(APP)d.lex $(HUM)\hugen$(APP)r.lex $(HUM)\sfxseq$(GSFX).lst:	$(PL)\humlex.pl $(GENDIR)\encodinggen$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\gen$(APP).lx2 $(GENDIR)\sfxgen$(APP0).lx2 $(PLMK)\ana2gen.pl $(SRC)\dersfx.lst
	$(PLE)\perl -s $(PL)\humlex.pl $(HLXSW) $(SW) $(HUM)\hugen$(APP) $(GENDIR)\gen$(APP).lx2 $(GENDIR)\sfxgen$(APP0).lx2
       	$(PLE)\perl -i.ana -s $(PLMK)\ana2gen.pl $(NOSURF) $(DERSFX) -sfxseq=$(HUM)\sfxseq$(GSFX).lst $(HUM)\hugen$(APP)d.lex $(HUM)\hugen$(APP)r.lex
       	del $(HUM)\hugen$(APP)d.lex.ana $(HUM)\hugen$(APP)r.lex.ana

!else
!ifdef GEN
#generate humor lexfiles

$(HUM)\hugen$(APP)r.lex $(HUM)\hugen$(APP)l.lex $(HUM)\sfxord.lst:	$(PLMK)\ana2gen.pl $(PLMK)\genfix.pl $(SRC)\dersfx.lst $(HUM)\hu1gen$(APP)r.lex $(HUM)\hu1gen$(APP)l.lex
	echo . > $(HUM)\tmpr.tmp
	echo . > $(HUM)\tmpl.tmp
       	$(PLE)\perl -i.ana -s $(PLMK)\ana2gen.pl $(NOSURF) $(FULLGEN) $(DERSFX) -sfxseq=$(HUM)\sfxord.lst -sfxlst=$(HUM)\sfxseq.lst $(HUM)\hu1gen$(APP)l.lex $(HUM)\hu1gen$(APP)r.lex
	- del $(HUM)\hu1gen$(APP)?.lex.ana
	ren $(HUM)\hu1gen$(APP)l.lex hu1gen$(APP)l.lex.ana
#sort generator to make removal of erroneous analyses of [MN] as [FN] possible
       	sort $(HUM)\hu1gen$(APP)l.lex.ana /O $(HUM)\hu1gen$(APP)l.lex
#	- del $(HUM)\hu1gen$(APP)?.lex.ana
#removal of erroneous analyses of [MN] as [FN]
       	$(PLE)\perl -i.ana -s $(PLMK)\genfix.pl $(HUM)\hu1gen$(APP)l.lex
	- del $(HUM)\hu1gen$(APP)?.lex.ana $(HUM)\hugen$(APP)?.lex
       	ren $(HUM)\hu1gen$(APP)r.lex hugen$(APP)r.lex
	ren $(HUM)\hu1gen$(APP)l.lex hugen$(APP)l.lex
	ren $(HUM)\tmpr.tmp hu1gen$(APP)r.lex
	ren $(HUM)\tmpl.tmp hu1gen$(APP)l.lex

!ifdef FULLGEN

$(HUM)\hu1gen$(APP)r.lex $(HUM)\hu1gen$(APP)l.lex:	$(PL)\humlex.pl $(GENDIR)\encodinggen$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\gen$(APP).lx2 $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2
	$(PLE)\perl $(PL)\ana_only.pl $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2 $(GENDIR)\gen$(APP).lx2 | $(PLE)\perl -s $(PL)\humlex.pl $(HLXSW) -gen=gen$(USEENC)$(BIT2MTX) $(HUM)\hu1gen$(APP)

!else

$(HUM)\hu1gen$(APP)r.lex $(HUM)\hu1gen$(APP)l.lex:	$(PL)\humlex.pl $(GENDIR)\encodinggen$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\gen$(APP).lx2 $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2
	$(PLE)\perl -s $(PL)\humlex.pl $(SW) $(HLXSW) $(HUM)\hu1gen$(APP) $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2 $(GENDIR)\gen$(APP).lx2

!endif

!ifndef ANA

$(HUM)\hu$(APP)l.lex:

!else

$(HUM)\hu$(APP)r.lex $(HUM)\hu$(APP)l.lex:	$(PL)\humlex.pl $(GENDIR)\encoding$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\gen$(APP).lx2 $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2 $(PL)\ana_only.pl $(SRC)\inexad.pat $(PL)\greplace.pl
	$(PLE)\perl $(PL)\ana_only.pl $(GENDIR)\gen$(APP).lx2 $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2| $(PLE)\perl -s $(PL)\humlex.pl $(HLXSW) -gen=$(USEENC)$(BIT2MTX) $(HUM)\hu$(APP)
#filter out [INL] etc. for analyzers
	$(PLE)\perl $(PL)\greplace.pl -all -inpl $(SRC)\inexad.pat $(HUM)\hu$(APP)r.lex
	- del $(HUM)\hu$(APP)r.lex.bak

!endif

#$(HUM)\hur.lex $(HUM)\hul.lex:	$(PL)\humlex.pl $(GENDIR)\encoding$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\sfx.lx2 $(GENDIR)\stemgen$(APP0).lx2 $(GENDIR)\prongen$(APP0).lx2 $(PL)\ana_only.pl
#	$(PLE)\perl $(PL)\ana_only.pl $(STEMPRONLX2) $(GENDIR)\sfx.lx2 | $(PLE)\perl -s $(PL)\humlex.pl $(HUM)\hu

$(HUM)\sfxseq.srt:	$(HUM)\sfxord.lst $(PL)\bsort.pl
	$(PLE)\perl $(PL)\bsort.pl $(HUM)\sfxord.lst >$(HUM)\sfxseq.srt

!else
#GEN is undefined
#generate humor analyzer lexfiles
$(HUM)\hu$(APP)r.lex $(HUM)\hu$(APP)l.lex:	$(PL)\humlex.pl $(GENDIR)\encoding$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\gen$(APP).lx2 $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2 $(PL)\ana_only.pl $(SRC)\inexad.pat $(PL)\greplace.pl
	$(PLE)\perl $(PL)\ana_only.pl $(GENDIR)\gen$(APP).lx2 $(STEMPRONLX2) $(GENDIR)\sfxgen$(APP0).lx2| $(PLE)\perl -s $(PL)\humlex.pl $(HLXSW) -gen=$(USEENC)$(BIT2MTX) $(HUM)\hu$(APP)
#filter out [INL] etc. for analyzers
	$(PLE)\perl $(PL)\greplace.pl -all -inpl $(SRC)\inexad.pat $(HUM)\hu$(APP)r.lex
	- del $(HUM)\hu$(APP)r.lex.bak

#$(HUM)\hu$(GEN)$(APP)r.lex $(HUM)\hu$(GEN)$(APP)l.lex:	$(PL)\humlex.pl $(GENDIR)\encoding$(GEN)$(USEENC)$(BIT2MTX).hpl $(PL)\normform.pl $(GENDIR)\sfx$(GEN)$(APP0).lx2 $(GENDIR)\stem$(GEN)$(APP).lx2 $(GENDIR)\pron$(GEN)$(APP0).lx2
#	$(PLE)\perl -s $(PL)\humlex.pl $(SW) $(HLXSW) $(HUM)\hu$(GEN)$(APP) $(GENDIR)\pron$(GEN)$(APP0).lx2 $(GENDIR)\stem$(GEN)$(APP).lx2 $(GENDIR)\sfx$(GEN)$(APP0).lx2

!endif
!endif

#convert word grammar
$(HUM)\$(METADICT).txt $(SRC)\metacteg.new:	$(PL)\metadict.pl $(PL)\banner.pl $(PL)\m2getopt.pl $(SRC)\files$(GSFX).hpl $(PL)\diewarn.pl $(SRC)\$(METADICT).txt $(SRC)\proplst$(GSFX).hpl
	$(PLE)\perl $(PL)\metadict.pl -files=$(SRC)\files$(GSFX).hpl $(SRC)\$(METADICT).txt >$(HUM)\$(METADICT).txt

#delete ps_cache.tmp if proplst$(GSFX).hpl is newer
ps_cache_proplst$(GSFX).hpl$(BIT2).tmp:	$(SRC)\proplst$(GSFX).hpl
	if exist ps_cache_proplst$(GSFX).hpl$(BIT2).tmp del ps_cache_proplst$(GSFX).hpl$(BIT2).tmp

#calculate humor encoding
#for generator

#!ifdef FULLGEN
!ifndef KEEPENC

$(GENDIR)\encodinggen$(USEENC)$(BIT2MTX).hpl:	$(PL)\encode.pl $(SRC)\files$(GSFX).hpl $(SRC)\proplst$(GSFX).hpl $(PL)\dumpsh.pl $(STEMPRONPS) $(GENDIR)\sfxgen$(APP0).propsets $(GENDIR)\gen$(APP).propsets $(SRC)\proplst.new $(SRC)\metacteg.new
	$(PLE)\perl -s $(PL)\encode.pl -files=$(SRC)\files$(GSFX).hpl -store -gen=gen$(APP) $(ENCSW) -out=$(GENDIR)\encodinggen$(USEENC)$(BIT2MTX).hpl $(GENDIR)\sfxgen$(APP0).propsets $(STEMPRONPS) $(GENDIR)\gen$(APP).propsets

#calculate humor encoding
#for analyzer

$(GENDIR)\encoding$(USEENC)$(BIT2MTX).hpl:	$(PL)\encode.pl $(SRC)\files$(GSFX).hpl $(SRC)\proplst$(GSFX).hpl $(PL)\dumpsh.pl $(GENDIR)\sfxgen$(APP0).propsets $(STEMPRONPS) $(GENDIR)\gen$(APP).propsets $(SRC)\proplst.new $(SRC)\metacteg.new
	$(PLE)\perl -s $(PL)\encode.pl -files=$(SRC)\files$(GSFX).hpl -store -gen=$(APP) "-excl=;restr:[gGm]+" $(ENCSW) -out=$(GENDIR)\encoding$(USEENC)$(BIT2MTX).hpl $(GENDIR)\sfxgen$(APP0).propsets $(STEMPRONPS) $(GENDIR)\gen$(APP).propsets

!endif

#check for new properties

$(SRC)\proplst.new:	$(PL)\newproplst.pl $(PL)\dumpsh.pl $(SRC)\proplst$(GSFX).hpl $(GENDIR)\sfx$(APP0).propsets $(STEMPRONPS) $(GENDIR)\gen$(APP).propsets
	$(PLE)\perl $(PL)\newproplst.pl -proplst=$(SRC)\proplst$(GSFX).hpl $(GENDIR)\sfx$(APP0).propsets $(STEMPRONPS) $(GENDIR)\gen$(APP).propsets >$(SRC)\proplst.new

#add new words to the stem lexicon
$(HGEN)\st5dbw3s1.lx1:	$(PLMK)\addfea.pl $(PL)\m2getopt.pl $(HSRC)\st5dbw2s.lx1 $(HSRC)\inon2.lx1
#	$(PLE)\perl $(PLMK)\addfea.pl -errtofile -strictcat=0 -warnaddonly=0 -=$(HGEN)\st5dbw3s1.lx1 $(HSRC)\st5dbw2s.lx1 $(HGEN)\2adds.lx1
#temporarily commented out inon2
#	$(PLE)\perl $(PLMK)\addfea.pl -errtofile -noaddonly -addpropfirst -=$(HGEN)\st5dbw3s.lx1 $(HGEN)\st5dbw3s1.lx1 $(HSRC)\inon2.lx1
	$(PLE)\perl $(PLMK)\addfea.pl -errtofile -noaddonly -addpropfirst -=$(HGEN)\st5dbw3s1.lx1 $(HSRC)\st5dbw2s.lx1 $(HSRC)\inon2.lx1
#	- del $(HGEN)\st5dbw3s.lx1
#	ren $(HGEN)\st5dbw3s1.lx1 st5dbw3s.lx1
#	del $(HGEN)\st5dbw3s1.lx1
#$(HGEN)\st5dbw3s.lx1:	$(PL)\sort.pl $(HSRC)\rev.srt $(HGEN)\st5dbw3s1.lx1 $(PLMK)\uniq.pl $(PL)\bsort.exe
$(HGEN)\st5dbw3s.lx1:	$(PL)\sort.pl $(HSRC)\rev.srt $(HGEN)\st5dbw3s1.lx1 $(PLMK)\uniq.pl $(PL)\bsort.pl
	$(PLE)\perl $(PL)\sort.pl -q $(HSRC)\rev.srt $(HGEN)\st5dbw3s1.lx1 | $(PLE)\perl $(PLMK)\uniq.pl >$(HGEN)\st5dbw3s.lx1
#	$(PLE)\perl $(PL)\sort.pl -uniq -q $(HSRC)\rev.srt $(HGEN)\st5dbw3s1.lx1 >$(HGEN)\st5dbw3s.lx1

#do inheritance to words to be added
$(HGEN)\2addsi.lx1:	$(PLMK)\inherit.pl $(PL)\greplace.pl $(HSRC)\fixrps.pat $(HGEN)\2adds1.lx1
	$(PLE)\perl -s $(PLMK)\inherit.pl -noovr "-noovrpat=\s*(?:(?:loc|zarte|isa|X|lexseg):.*?|rp:(?:BAD|[& ]|atomic|badorth)+);\s*" "-noinhpat=\s*(?:(?:isa):.*?|rp:(?:BAD|[& ]|atomic)+);\s*" $(HGEN)\2adds1.lx1 | $(PLE)\perl $(PL)\greplace.pl -all $(HSRC)\fixrps.pat>$(HGEN)\2addsi.lx1

#add irregularity info to words to be added
$(HGEN)\2adds1.lx1:	$(HGEN)\irreg.lx1 $(HGEN)\2adds.lx1
	$(PLE)\perl $(PLMK)\addfea.pl -errtofile -strictcat=1 -warnaddonly=0 -=$(HGEN)\2adds1.lx1 $(HGEN)\irreg.lx1 $(HGEN)\2adds.lx1

#sort words to be added
#$(HGEN)\2adds.lx1:	$(PL)\sort.pl $(HSRC)\rev.srt $(HSRC)\2add.lx1 $(PLMK)\uniq.pl $(PL)\bsort.exe
$(HGEN)\2adds.lx1:	$(PL)\sort.pl $(HSRC)\rev.srt $(HSRC)\2add.lx1 $(PLMK)\uniq.pl $(PL)\bsort.pl
	$(PLE)\perl $(PL)\sort.pl -q $(HSRC)\rev.srt $(HSRC)\2add.lx1 | $(PLE)\perl $(PLMK)\uniq.pl >$(HGEN)\2adds.lx1
#	$(PLE)\perl $(PL)\sort.pl -uniq -q $(HSRC)\rev.srt $(HSRC)\2add.lx1 >$(HGEN)\2adds.lx1

#gather irregular stems
$(HGEN)\irreg.lx1:	$(PLMK)\irreg.pl $(HGEN)\st5dbw3s.lx1 $(PL)\mtouch.pl
	$(PLE)\perl $(PLMK)\irreg.pl -=$(HGEN)\irreg.lx1 $(HGEN)\st5dbw3s.lx1
	$(PLE)\perl -e "sleep 1"
	$(PLE)\perl $(PL)\mtouch.pl $(HGEN)\gen.lx2 $(HGEN)\gen.propsets

#apply stem rules to generate stem allomorphs and properties
$(HGEN)\st5dbw3si.lx1:	$(PLMK)\inherit.pl $(HGEN)\st5dbw3s.lx1 $(PL)\greplace.pl $(HSRC)\fixrps.pat
	$(PLE)\perl -s $(PLMK)\inherit.pl -noovr "-noovrpat=\s*(?:(?:loc|zarte|isa|X|lexseg):.*?|rp:(?:BAD| |atomic|badorth)+);\s*" "-noinhpat=\s*(?:(?:isa):.*?|rp:(?:BAD|[& ]|atomic)+);\s*" $(HGEN)\st5dbw3s.lx1 | $(PLE)\perl $(PL)\greplace.pl -all $(HSRC)\fixrps.pat>$(HGEN)\st5dbw3si.lx1

$(GENDIR)\stemgen$(APP0).avs $(GENDIR)\stemgen$(APP0).lx2 $(GENDIR)\stemgen$(APP0).propsets:	$(PLMK)\stmlex2.pl $(PL)\dumpsh.pl $(GENDIR)\stemalt1.pl $(SRC)\vhrm.pl $(PL)\unif.pl $(PL)\normform.pl $(PL)\lex2.pl $(HGEN)\st5dbw3si.lx1 $(GENDIR)\sfxtags.hpl
	$(PLE)\perl -s $(PLMK)\stmlex2.pl -avs=$(AVS) $(SW) $(GENDIR)\stemgen$(APP0) $(HGEN)\st5dbw3si.lx1

$(GENDIR)\stems2addgen$(APP0).avs $(GENDIR)\stems2addgen$(APP0).lx2 $(GENDIR)\stems2addgen$(APP0).propsets:	$(PLMK)\stmlex2.pl $(PL)\dumpsh.pl $(GENDIR)\stemalt1.pl $(SRC)\vhrm.pl $(PL)\unif.pl $(PL)\normform.pl $(PL)\lex2.pl $(HGEN)\2addsi.lx1 $(GENDIR)\sfxtags.hpl
	$(PLE)\perl -s $(PLMK)\stmlex2.pl -avs=$(AVS) $(SW) $(GENDIR)\stems2addgen$(APP0) $(HGEN)\2addsi.lx1

#apply stem rules to generate application specific stem allomorphs and properties
$(GENDIR)\gen$(APP).avs $(GENDIR)\gen$(APP).lx2 $(GENDIR)\gen$(APP).propsets:	$(PLMK)\stmlex2.pl $(PL)\dumpsh.pl $(GENDIR)\stemalt1.pl $(SRC)\vhrm.pl $(PL)\unif.pl $(PL)\normform.pl $(PL)\lex2.pl $(HGEN)\$(APP)si.lx1 $(GENDIR)\sfxtags.hpl
	$(PLE)\perl -s $(PLMK)\stmlex2.pl -avs=$(AVS) $(SW) $(GENDIR)\gen$(APP) $(HGEN)\$(APP)si.lx1

#!ifdef GEN

#stem lexicon for the generator is produced by merging
#the source with the application-specific lexicon file

#Make application-specific lexicon file

#do inheritance to words to be added
$(HGEN)\$(APP)si.lx1:	$(PLMK)\inherit.pl $(PL)\greplace.pl $(HSRC)\fixrps.pat $(HGEN)\$(APP)s1.lx1
	$(PLE)\perl -s $(PLMK)\inherit.pl -noovr "-noovrpat=\s*(?:(?:loc|zarte|isa|X|lexseg):.*?|rp:(?:BAD| |atomic|badorth)+);\s*" "-noinhpat=\s*(?:(?:isa):.*?|rp:(?:BAD|[& ]|atomic)+);\s*" $(HGEN)\$(APP)s1.lx1 | $(PLE)\perl $(PL)\greplace.pl -all $(HSRC)\fixrps.pat>$(HGEN)\$(APP)si.lx1

#add irregularity info to application specific lexicon file
$(HGEN)\$(APP)s1.lx1:	$(HGEN)\irreg.lx1 $(HGEN)\$(APP)su.lx1
	$(PLE)\perl $(PLMK)\addfea.pl -errtofile -strictcat=1 -warnaddonly=0 -=$(HGEN)\$(APP)s1.lx1 $(HGEN)\irreg.lx1 $(HGEN)\$(APP)su.lx1

#sort application-specific lexicon file
$(HGEN)\$(APP)su.lx1:	$(PL)\sort.pl $(HSRC)\rev.srt $(HSRC)\$(APP).lx1 $(PLMK)\uniq.pl $(HSRC)\inon2.lx1 $(PL)\bsort.pl
	$(PLE)\perl $(PL)\sort.pl -q $(HSRC)\rev.srt $(HSRC)\$(APP).lx1 | $(PLE)\perl $(PLMK)\uniq.pl >$(HGEN)\$(APP)su1.lx1
!ifndef GUESS
	$(PLE)\perl $(PLMK)\addfea.pl -errtofile -noaddonly -addpropfirst -=$(HGEN)\$(APP)su.lx1 $(HGEN)\$(APP)su1.lx1 $(HSRC)\inon2.lx1
!else
	- del $(HGEN)\$(APP)su.lx1
	ren $(HGEN)\$(APP)su1.lx1 $(APP)su.lx1
!endif

$(HSRC)\.lx1:
	echo off >$(HSRC)\.lx1

$(HSRC)\all.lx1: $(HSRC)\khsz.lx1
	copy /b $(HSRC)\khsz.lx1 $(HSRC)\all.lx1

#$(GENDIR)\hax.avs $(GENDIR)\hax.lx2 $(GENDIR)\hax.propsets:	$(PLMK)\stmlex2.pl $(PL)\dumpsh.pl $(GENDIR)\stemalt1.pl $(SRC)\vhrm.pl $(PL)\unif.pl $(PL)\normform.pl $(PL)\lex2.pl $(SRC)\hax.lx1
$(GENDIR)\hax.avs $(GENDIR)\hax.lx2 $(GENDIR)\hax.propsets:	$(PLMK)\stmlex2.pl $(PL)\dumpsh.pl $(PL)\unif.pl $(PL)\normform.pl $(PL)\lex2.pl $(SRC)\hax.lx1
	$(PLE)\perl -s $(PLMK)\stmlex2.pl -avs=$(AVS) $(SW) $(GENDIR)\hax $(SRC)\hax.lx1

#make FSA describing suffix sequences contain derivational suffix sequences as well
$(SRC)\sfxfsagen.hpl:	$(SRC)\sfxfsa.hpl
	copy $(SRC)\sfxfsa.hpl $(SRC)\sfxfsagen.hpl

$(GENDIR)\sfx$(APP0).lx2 $(GENDIR)\sfx$(APP0).propsets:	$(GENDIR)\sfxgen$(APP0).lx2 $(GENDIR)\sfxgen$(APP0).propsets
	copy $(GENDIR)\sfxgen$(APP0).lx2 $(GENDIR)\sfx$(APP0).lx2
	copy $(GENDIR)\sfxgen$(APP0).propsets $(GENDIR)\sfx$(APP0).propsets

#apply stem rules to generate pronoun allomorphs and properties
$(GENDIR)\prongen$(APP0).avs $(GENDIR)\prongen$(APP0).lx2 $(GENDIR)\prongen$(APP0).propsets:	$(PLMK)\inherit.pl $(PLMK)\stmlex2.pl $(PL)\dumpsh.pl $(GENDIR)\stemalt1.pl $(SRC)\vhrm.pl $(PL)\unif.pl $(PL)\normform.pl $(PL)\lex2.pl $(HSRC)\pron.lx1 $(GENDIR)\sfxtags.hpl $(PLMK)\fixpron.pl
	$(PLE)\perl -s $(PLMK)\inherit.pl -noovr "-noovrpat=\s*(?:(?:loc|zarte|isa|X|lexseg):.*?|rp:(?:BAD| |atomic|badorth)+);\s*" "-noinhpat=\s*(?:(?:isa):.*?|rp:(?:BAD|[& ]|atomic)+);\s*" $(HSRC)\pron.lx1 | $(PLE)\perl -s $(PLMK)\stmlex2.pl -avs=$(AVS) $(SW) $(GENDIR)\prongen$(APP0)
        $(PLE)\perl -i.bak -s $(PLMK)\fixpron.pl $(SW) $(GENDIR)\prongen$(APP0).lx2

#apply suffix and stem rules to generate suffix allomorphs and properties
$(GENDIR)\sfxgen$(APP0).avs $(GENDIR)\sfxgen$(APP0).lx2 $(GENDIR)\sfxgen$(APP0).propsets:	$(PLMK)\sfxlex2.pl $(PL)\dumpsh.pl $(PL)\selrep.pl $(GENDIR)\sfxalt1.pl $(GENDIR)\stemalt1.pl $(SRC)\vhrm.pl $(PL)\unif.pl $(PL)\set.pl $(PL)\normform.pl $(SFX)\sfx.1 $(PL)\lex2.pl $(GENDIR)\sfxtags.hpl $(SRC)\sfxfsagen.hpl
	$(PLE)\perl -s $(PLMK)\sfxlex2.pl -avs=$(AVS) -sfxfsa=$(SRC)\sfxfsagen.hpl $(SW) $(GENDIR)\sfxgen$(APP0) $(SFX)\sfx.1

#create suffix morphological category conversion table
$(GENDIR)\sfxtags.hpl:	$(PLMK)\getsfxtags.pl $(SRC)\sfx.1 $(SRC)\vhrm.pl
	$(PLE)\perl $(PLMK)\getsfxtags.pl $(SRC)\sfx.1 >$(GENDIR)\sfxtags.hpl

#convert stem rule file to perl source
$(GENDIR)\stemalt1.pl:	$(PL)\stemalt.pl $(PL)\mkrulef.pl $(SFX)\stemalt.rul
	$(PLE)\perl $(PL)\stemalt.pl $(SFX)\stemalt.rul >$(GENDIR)\stemalt1.pl

#convert suffix rule file to perl source
$(GENDIR)\sfxalt1.pl:	$(PL)\sfxalt.pl $(PL)\mkrulef.pl $(SFX)\sfxalt.rul
	$(PLE)\perl $(PL)\sfxalt.pl $(SFX)\sfxalt.rul >$(GENDIR)\sfxalt1.pl

#convert suffix source to level 1 format
$(SFX)\sfx.1:	$(PLMK)\sfxlex1.pl $(SFX)\sfx.txt
	$(PLE)\perl $(PLMK)\sfxlex1.pl $(SFX)\sfx.txt >$(SFX)\sfx.1

