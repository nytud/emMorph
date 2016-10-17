# emMorph (Humor) Hungarian morphological analyzer

## Requirements

The morphological analyzer can be compiled on Unix systems.
You'll need perl and hfst.

### Installing hfst

```
wget http://apertium.projectjj.com/rpm/install-nightly.sh -O - | sudo bash
sudo apt-get install hfst
```

## Compilation of the morphology

```
cd mak
bash mkemmorph.sh
```

The compiled lexicon is `hfst/hu.hfstol`

## Usage

```
hfst-lookup --cascade=composition hu.hfst
```

If you want to redirect input from a file, use:

```
hfst-lookup --pipe-mode=input --cascade=composition hu.hfstol <intext >outtext
```

### Lemmatized output

If you want lemmatized output, download the lemmatizer from [https://github.com/dlt-rilmta/hunlp-GATE/tree/master/Lang_Hungarian/resources/hfst](https://github.com/dlt-rilmta/hunlp-GATE/tree/master/Lang_Hungarian/resources/hfst).

One way to download only this tool from the repository:
Visit [http://kinolien.github.io/gitzip/](http://kinolien.github.io/gitzip/) and paste the link above.

### Using the compiled lexicon on Windows

Install hfst from: [http://apertium.projectjj.com/win32/nightly/hfst-latest.7z](http://apertium.projectjj.com/win32/nightly/hfst-latest.7z).

Usage is the same as above.

## License

Copyright (C) 2001-2016 Attila Novák

The database files are licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA) license, the compilation scripts under the GNU General Public License (GPL v3)
with the amendments below under Publication.                                                                         

If you are interested in using or adapting the resource for commercial purposes, please contact the author at: [novakat@gmail.com](mailto:novakat@gmail.com)

## Publication

If you use this database and/or the tools:

1. Please inform the author at [novakat@gmail.com](mailto:novakat@gmail.com) about your use of the database/tools clearly indicating what you use them for as soon as you start working on your application/experiment/resource involving this database or tool.

2. Even in the case of non-academic use, you promise to publish a scientific paper about each application, experimental system or linguistic resource you create or experiment you perform using this resource quoting the articles below, and inform the author at [novakat@gmail.com](mailto:novakat@gmail.com) about each article you publish. If you definitely cannot publish an article, please contact the author.

  Articles to quote are the following: (See the BibTeX file quotethis.bib in the root directory):

  * Attila Novák (2014): A New Form of Humor – Mapping Constraint-Based Computational Morphologies to a Finite-State Representation. In: Proceedings of the 9th International Conference on Language Resources and Evaluation (LREC-2014). Reykjavík, pp. 1068–1073 (ISBN 978-2-9517408-8-4)

  * Attila Novák; Borbála Siklósi; Csaba Oravecz (2016): A New Integrated Open-source Morphological Analyzer for Hungarian In: Proceedings of the Tenth International Conference on Language Resources and Evaluation (LREC 2016). Portorož, pp. 1315–1322.

  * Novák Attila (2003): Milyen a jó Humor? [What is good Humor like?] In: Magyar Számítógépes Nyelvészeti Konferencia (MSZNY 2003). Szegedi Tudományegyetem, pp. 138–145

3. Please do share your adaptations of the morphology (vocabulary extensions etc.) using the same licenses.

