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

ifndef ROOT
ROOT      := ..
endif

PL        := $(ROOT)/pl/generic
PLMK      := $(ROOT)/pl/mkavs
SRC       := $(ROOT)/src
GENDIR    := $(ROOT)/gen
HUM       := $(ROOT)/gen
LEXC      := $(ROOT)/lexc

BASELEX=$(GENDIR)/stemgen.lx2 $(GENDIR)/prongen.lx2 $(GENDIR)/stems2addgen.lx2 

ifdef GUESS
BASELEX=
endif

ifdef NOBASE
BASELEX=
endif

ifdef LEX
LEX      := $(GENDIR)/$(LEX)
endif

$(LEXC)/hu$(S).xlx:	$(GENDIR)/multich$(X).xlx $(GENDIR)/mrf$(S).xlx $(GENDIR)/mtx$(X).xlx $(GENDIR)/meta$(X).xlx | $(LEXC)
	cat $(GENDIR)/multich$(X).xlx $(GENDIR)/meta$(X).xlx $(GENDIR)/mrf$(S).xlx $(GENDIR)/mtx$(X).xlx >$(LEXC)/hu$(S).xlx

$(LEXC):
	mkdir $(LEXC)

$(GENDIR)/multich$(X).xlx:	$(PL)/multich.pl $(GENDIR)/mrf$(S).xlx $(GENDIR)/mtx$(X).xlx $(GENDIR)/meta$(X).xlx
	perl $(PL)/multich.pl $(GENDIR)/mrf$(S).xlx $(GENDIR)/mtx$(X).xlx $(GENDIR)/meta$(X).xlx >$(GENDIR)/multich$(X).xlx

$(GENDIR)/mrf$(S).xlx:	$(PL)/lx3lex.pl $(PL)/m2getopt.pl $(PL)/banner.pl $(GENDIR)/mrf$(S).s
	perl $(PL)/lx3lex.pl -=$(GENDIR)/mrf$(S).xlx $(GENDIR)/mrf$(S).s

$(GENDIR)/mtx$(X).xlx:	$(PL)/mtxlex.pl $(PL)/m2getopt.pl $(PL)/diewarn.pl $(PL)/banner.pl $(GENDIR)/encoding$(X)bit2mtx.hpl $(GENDIR)/encoding$(X)bit2mtx.hpl.mtxcont.hpl $(GENDIR)/encoding$(X)bit2mtx.hpl.morphclasses.hpl
	perl $(PL)/mtxlex.pl -encoding=$(GENDIR)/encoding$(X)bit2mtx.hpl -=$(GENDIR)/mtx$(X).xlx

$(GENDIR)/meta$(X).xlx:	$(PL)/metalex.pl $(PL)/m2getopt.pl $(PL)/diewarn.pl $(PL)/banner.pl $(GENDIR)/encoding$(X)bit2mtx.hpl $(GENDIR)/metadict$(GUESS).txt.trans.hpl
	perl $(PL)/metalex.pl $(SRFONLY) -guess=$(GUESS) -encoding=$(GENDIR)/encoding$(X)bit2mtx.hpl -trans=$(GENDIR)/metadict$(GUESS).txt.trans.hpl -=$(GENDIR)/meta$(X).xlx

$(GENDIR)/mrf$(S).s:	$(GENDIR)/mrf$(S).lx3 $(PL)/bsort.pl
	perl $(PL)/bsort.pl -uniq $(GENDIR)/mrf$(S).lx3 >$(GENDIR)/mrf$(S).s

$(GENDIR)/mrf$(S).lx3 $(GENDIR)/encoding$(X)bit2mtx.hpl.morphclasses.hpl:	$(PL)/morphlex.pl $(PL)/m2getopt.pl $(PL)/diewarn.pl $(PL)/banner.pl $(GENDIR)/encoding$(X)bit2mtx.hpl $(GENDIR)/sfxgen.lx2 $(BASELEX) $(LEX) $(PL)/banner.pl
	perl $(PL)/morphlex.pl $(EXCL) $(SRFONLY) -encoding=$(GENDIR)/encoding$(X)bit2mtx.hpl -=$(GENDIR)/mrf$(S).lx3 $(GENDIR)/sfxgen.lx2 $(BASELEX) $(LEX)

$(GENDIR)/encoding$(X)bit2mtx.hpl.mtxcont.hpl:	$(PL)/mtx2hash.pl $(PL)/m2getopt.pl $(PL)/banner.pl $(PL)/diewarn.pl $(PL)/dumpdata.pl $(HUM)/mtx$(X)_n.txt $(HUM)/mtx$(X)_v.txt
	perl $(PL)/mtx2hash.pl -=$(GENDIR)/encoding$(X)bit2mtx.hpl.mtxcont.hpl $(HUM)/mtx$(X)_n.txt $(HUM)/mtx$(X)_v.txt

$(GENDIR)/metadict$(GUESS).txt.trans.hpl:	$(PL)/scanmeta.pl $(HUM)/metadict$(GUESS).txt
	perl $(PL)/scanmeta.pl $(HUM)/metadict$(GUESS).txt >$(GENDIR)/metadict$(GUESS).txt.trans.hpl

