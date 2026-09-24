# Working in this repo

A data science case study using the General Social Survey: how political alignment (liberal, moderate, conservative) relates to other attitudes, and how both change over time. It is part of the *Elements of Data Science* curriculum. The printed EDS book includes two of these notebooks as chapters 14 and 15 (`02_polviews_soln` and `03_outlook`), and EDS v2 plans to expand the case study. `planning/PROJECT_BOARD.md` holds the numbered tasks and is the place to record findings; `planning/` holds the longer write-ups.

## Branches: two of them matter, and neither can move

GitHub's default branch is `master`; the current work is on `v1`. Both are load-bearing:

- The printed EDS book links to `blob/master/` for notebooks 1–4 (`ElementsOfDataScienceBook/latex/intro2.tex`).
- The notebooks download `utils.py` and `gss_pacs_resampled.hdf` from `raw/v1/`.

So never delete, rename, or force-push either branch, and don't move `utils.py` or the committed HDF files on `v1`. Don't rename `master` to `main`: printed links can't be updated, and Colab and raw links aren't guaranteed to follow GitHub's rename redirect. Which branch should be the default is open; see Task 1.

## Layout

```
01_clean.ipynb            GssExtract extract -> gss_pacs_clean.hdf, gss_pacs_resampled.hdf
02_polviews_soln.ipynb    source for 02_polviews.ipynb (solutions removed by build.sh)
03_outlook.ipynb, 04_worldview.ipynb, 05_alignment.ipynb
generation.ipynb, margin.ipynb, resampling*.ipynb   extra notebooks
examples/                 confidence, divorce
unfilled/                 an older 04_worldview with 16 of 42 code cells empty
jb/                       Jupyter Book website: 01-04 (02 as the _soln version) and examples/confidence
utils.py                  helpers the notebooks download; not the same file as EDS's utils.py
planning/                 project board and write-ups
```

## Data flow

`01_clean` downloads `gss_pacs_2022.hdf` from the `GssExtract` repo (`raw/main/data/interim/`), cleans it with `utils.gss_replace_invalid` and other steps, and writes `gss_pacs_clean.hdf` and `gss_pacs_resampled.hdf`. Both are committed. Every other notebook downloads `gss_pacs_resampled.hdf` from `raw/v1/`, so readers don't need to run `01_clean`.

A change to `01_clean` or `gss_replace_invalid` could change the data every other notebook reads. Rebuild in a scratch copy and compare with the committed files before replacing them:

```python
import pandas as pd
new = pd.read_hdf("scratch/gss_pacs_resampled.hdf", "gss")
old = pd.read_hdf("gss_pacs_resampled.hdf", "gss")
pd.testing.assert_frame_equal(new, old)
```

A refactor must pass this unchanged. A change that is meant to move numbers gets its own commit.

## Notebooks: the `.ipynb` is the source

There is no jupytext pairing, and no `.md` copies are committed. For anything beyond a trivial edit, go through markdown and back:

```bash
jupytext --to md -o /tmp/X.md X.ipynb            # keep the .md out of the repo
# edit /tmp/X.md
jupytext --to ipynb --update -o X.ipynb /tmp/X.md
jupyter nbconvert --to notebook --execute --inplace X.ipynb
```

`--update` keeps the existing outputs and metadata; plain `jupytext --to ipynb` discards every output. After `nbconvert`, strip the per-cell `execution` timestamps it adds, or every run produces a noisy diff. Before committing executed outputs, check that no cell recorded a local path, such as the log from a `pip install` fallback cell.

Edit `02_polviews_soln.ipynb`, not `02_polviews.ipynb`; `build.sh` regenerates the latter.

## Traps

pandas 3 (copy-on-write) makes chained in-place calls silent no-ops. That includes the attribute form: `df.age.replace([98, 99], np.nan, inplace=True)` leaves `df` unchanged, exactly like `df['age'].replace(..., inplace=True)`. Nothing raises, so tests don't catch it. Task 3 removed them all; don't add new ones. Assign instead: `df['age'] = df['age'].replace(...)`.

pandas 3 also makes the `key` of `to_hdf` keyword-only (`to_hdf(path, key="gss")`), and refuses to write NaN into a bool column (`05_alignment`).

`build.sh` and `jb/build.sh` publish without asking. `build.sh` ends in `git commit` and `git push`, and `jb/build.sh` ends in `ghp-import -p`, which replaces the website. Don't run them as a way to test something.

`make tests` runs notebooks 2–5 against the committed data. `make tests-clean` runs `01_clean` in `build/clean/`. Don't run `01_clean` in the repo root: it rewrites both committed HDF files, and because the GssExtract source has changed since they were built (Task 7), a rebuild does not match them. `05_alignment` writes `alignment*.jpg` frames into the root; they are gitignored.

`generation.ipynb` downloads `raw/master/gss_eda.hdf5`, which was deleted in 2022, so it can't run (Task 6).

`examples/utils.py` is a runtime download of `utils.py`, not a second copy to maintain.

## Environment

For now, `requirements.txt` and `requirements-dev.txt`, installed with pip. Task 8 replaces them with an `environment.yml` like the one in `ElementsOfDataScience`.
