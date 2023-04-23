#!/bin/bash
# Desc: Compiles LaTeX report

# Process input 

pdflatex project_proposal_draft.tex
bibtex project_proposal_draft
pdflatex project_proposal_draft.tex
pdflatex project_proposal_draft.tex

# Cleanup of extra files
rm *.out
rm *.aux
rm *.log
rm *.bbl
rm *.blg
rm *.bcf
rm *.run.xml