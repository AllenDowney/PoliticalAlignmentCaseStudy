cp 02_polviews_soln.ipynb 02_polviews.ipynb

# this version of remove_soln only modifies 02_polviews.ipynb 
python remove_soln.py

git add 0*.ipynb
git commit -m "Updating notebooks"
git push
