#!/bin/bash

git add data/RKI/working/*.zip
# git add \*.zip
# git add \*.xlsx
git add data/DIVI_Intensiv/working/DIVI*
git add data/RKI_Impf/working/\*.xlsx

git commit -m "Neue Daten"
git push -v

