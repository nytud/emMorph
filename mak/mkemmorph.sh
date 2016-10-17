#!/bin/bash
bash mkX.sh xlx &&\
bash mkxlxrmseg.sh &&\
bash xlx2lglexc.sh huX &&\
bash mkhuhfst.sh &&\
mkdir ../hfst
mv ../lexc/hu.hfstol ../hfst/hu.hfstol 
