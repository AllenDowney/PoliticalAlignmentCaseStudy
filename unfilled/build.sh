#!/bin/bash

FILES="04_worldview"

# copy the chapter notebooks
for FILE in $FILES
do
    cp ../$FILE.ipynb .

    # run tests
    # pip install pytest nbmake
    # pytest --nbmake $FILE.ipynb

    python remove_soln.py $FILE.ipynb

    git add $FILE.ipynb

done
