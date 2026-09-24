# Political Alignment Case Study Project Board

Numbered tasks for tracking work. Each task has a permanent number; add new
tasks at the end. Update status as work progresses.

Keep each task short here. When a task needs more than a few paragraphs (a
design, an inventory, a decision with options), write it up in a separate file
in `planning/` and link to it from the task.

Planning documents:

- [working_tree_triage.md](working_tree_triage.md): every untracked and
  modified path, and what to do with it

Related: the Elements of Data Science board
(`~/ElementsOfDataScience/planning/PROJECT_BOARD.md`). The printed EDS book
includes this case study as chapters 14–15, and EDS v2 plans to expand it
(`~/ElementsOfDataScience/planning/v2_plan.md`).

### Current focus (2026-09-24)

Same cleanup as EDS `v1`, before PACS is reworked for EDS v2.

- **Done:** **Task 1** (`v1` is the default; `master` fast-forwarded and
  protected; `v1.0.1` tagged)
- **Done:** **Task 3** (pandas 3 fixes; refactor verified against pandas 2),
  **Task 2** (CI green on all three OSes)
- **Done:** **Task 4** (working tree: 36 paths down to the `Makefile` and 7
  in limbo)
- **Done:** **Task 7** (`01_clean` pinned to GssExtract `1ac586b`; rebuilds
  now match the committed data, checked in CI)
- **Done:** **Task 5** (#1, #3, and PR #4 closed with comments; nothing open)
- **Done:** **Task 6** (`generation`, `resampling`, `resampling2` pinned and
  running under pandas 3)
- **Done:** **Task 8** (`environment.yml`, Makefile, `requirements-dev.txt`)
- **Next:** Task 9
- **Quick wins:** Task 5 (stale issues and PR)
- **Later:** Tasks 6–9

---

## Task 1: Decide the branch layout (`master` vs `v1`)

**Status:** Done 2026-09-24. Option A, with the one-time fast-forward.

- [x] Fast-forwarded `master` from `f3dd234` to `5404cac` (no force). This
      removed `gss_eds.hdf5`, `gss_eds.3.hdf5`, and `scrub_code.py` from
      `master`; nothing downloads them from `master` (EDS `archive/quizzes`
      and both `unfilled/04_worldview` copies use `raw/update2021/`).
- [x] Made `v1` the default branch on GitHub.
- [x] Ruleset `23951246` blocks deletion and non-fast-forward pushes on
      `master`, `v1`, and `update2021`, with no bypass actors, so it applies
      to the owner too. Normal pushes still work.
- [x] Tagged `v1.0.1` (annotated) on `898fe24` (2024-06-14), the last commit
      before EDS print 1.0.1 was finalized (Book `1ec3aca`, 2024-08-10),
      matching the EDS tag.
- [x] Checked: the eight printed `blob/master/` links for notebooks 1–4 and
      `raw/v1/gss_pacs_resampled.hdf` all return 200.
- [x] After Task 3, fast-forwarded `master` again to `1e5a15e`, so the
      printed links get the pandas 3 fixes. Repeat
      (`git push origin v1:master`) after later fixes worth printing.

Background, as written before the decision:

GitHub's default branch is `master` (last commit `f3dd234`, 2024-01-30), but
the work happens on `v1` (`0e490c5`, 2025-01-03). `v1` is 11 commits ahead of
`master` and 0 behind, so `master` could be fast-forwarded to it with no merge.
There is no `main` branch.

What links where:

- The printed EDS book (`ElementsOfDataScienceBook/latex/intro2.tex`) links to
  `blob/master/` for `01_clean`, `02_polviews`, `03_outlook`, and
  `04_worldview`, twice each.
- The notebooks download data and `utils.py` from `raw/v1/` (22 links). Four
  links still use `raw/master/`, in `generation`, `resampling`, and
  `resampling2`.
- The README links to `blob/master/` (8 links).

So both branches must keep existing. **Don't rename `master` to `main`.**
GitHub redirects web links after a rename, but printed links to Colab and to
`raw/master/...` are not guaranteed to follow a redirect, and they can't be
updated.

Options:

- **A. Make `v1` the default, as in EDS.** Keep `master` frozen at its
  current state, protected by a ruleset. The printed links then show the
  January 2024 notebooks (not yet tested under current libraries).
- **B. Fast-forward `master` to `v1`, then keep it in step.** The printed
  links show current notebooks. There are then two branches to keep equal;
  setting `master` as the default and retiring `v1` from new work would
  avoid that, but the notebooks' `raw/v1/` data links still need `v1` to
  exist.

Recommendation: **A**, for consistency with EDS. Fast-forward `master` once,
as in B, before freezing it, so the printed links get the fixes. Either way,
tag the release and protect the branches the printed book depends on.

## Task 2: Revive CI

**Status:** Done 2026-09-24. Run `36034145679` passed on Ubuntu, Windows,
and macOS, including `make tests-clean`.

GitHub disabled the `tests` workflow for inactivity (`disabled_inactivity`),
and it has no runs on record. It also triggers only on pushes to `master`,
uses `actions/checkout@v2` and `setup-python@v2` (Node 20, deprecated), and
tests Python 3.8.

- [x] Update `.github/workflows/tests.yml` to match EDS: actions v7, Python
      3.13, Ubuntu, Windows, and macOS, `fail-fast: false`, `PYTHONUTF8=1`,
      push on `v1`, monthly schedule
- [x] Re-enable the workflow on GitHub, and check the first run is green
- [x] Notebook 5 passes under statsmodels 0.15.0, so `make tests` now runs
      `0[2345]*.ipynb`. `01_clean` moved to `make tests-clean`, which runs a
      copy in `build/clean/` (gitignored), because running it in place
      rewrites both committed HDF files with data rebuilt from the changed
      GssExtract source (Task 7). CI runs both targets.
- [x] `05_alignment` writes `alignment1.jpg` to `alignment16.jpg` into the
      repo root; added them to `.gitignore`.

## Task 3: pandas 3 fixes

**Status:** Done 2026-09-24 (`1f8ba92`). Found 2026-09-24 by running the notebooks under
pandas 3.0.6 on a clean export of `origin/v1`: `02_polviews`,
`02_polviews_soln`, `03_outlook`, and `04_worldview` pass; `01_clean` and
`05_alignment` fail.

- [x] **Chained in-place calls do nothing under copy-on-write.** This covers
      both `df['col'].replace(..., inplace=True)` and the attribute form
      `df.col.replace(..., inplace=True)`: 98 calls in
      `utils.gss_replace_invalid`, one in `utils.fill_missing`, and 22 in
      `01_clean`. Checked: `df.age.replace([98, 99], np.nan, inplace=True)`
      leaves the values unchanged. Only `01_clean` calls
      `gss_replace_invalid`, so the published notebooks are unaffected,
      because they download the prebuilt `gss_pacs_resampled.hdf`. But
      rebuilding the data under pandas 3 would keep every missing-data code
      as a real answer. That happened to EDS's `clean_gss` (see EDS Task 19).
      Fix by assigning: `df['col'] = df['col'].replace(...)`.
- [x] **`to_hdf` key is keyword-only:** `01_clean` calls
      `gss.to_hdf("gss_pacs_clean.hdf", "gss", "w", complevel=6)`, which raises
      a `TypeError`.
- [x] **NaN into a bool column raises:** `05_alignment` builds `questions`
      from `isin` (bool), then sets `questions.loc[null, varname] = np.nan`.
      pandas 3 raises `TypeError: Invalid value 'nan' for dtype 'bool'`.
      Cast to float first.
- [x] After fixing `01_clean`, rebuild both HDF files in a scratch copy and
      check they are identical to the committed ones (the EDS method), rather
      than overwriting them.

Edit notebooks through jupytext (see `CLAUDE.md`).

Results:

- All 121 chained `inplace` calls now assign. `01_clean` also passes `key=`
  and `mode=` to `to_hdf` by keyword, and a cell that removed
  `gss_pacs_resampled.hdf` when it meant `gss_pacs_clean.hdf` is fixed.
  `05_alignment` casts the `isin` result to float.
- Refactor check: on the same `gss_pacs_2022.hdf`, the new `01_clean` under
  pandas 3.0.6 and the old one under pandas 2.3.3 produce identical
  `gss_pacs_clean.hdf` and identical `gss0`–`gss2`. The new
  `gss_replace_invalid` and `fill_missing` under pandas 3 match the old ones
  under pandas 2 on a synthetic frame (9,729 NaNs each; the old code under
  pandas 3 produces 0). No notebook calls either function, so this was
  checked directly.
- Neither rebuild matches the committed HDF files, because the GssExtract
  source has changed (Task 7). The committed files were not replaced.
- `pytest --nbmake` passes for 01, 02, 02_soln, 03, 04, and 05 under
  pandas 3.0.6 and Python 3.13. `01_clean` and `05_alignment` are committed
  without outputs, and they were left that way.

## Task 4: Triage the working tree

**Status:** Done 2026-09-24. Inventory and outcome in
[working_tree_triage.md](working_tree_triage.md). What is left: the
`Makefile` edits (Task 8), and the limbo files (`cover/`, two GIFs,
`gss_pacs.hdf`).

The uncommitted `gss_pacs_clean.hdf` turned out to be the file that the
committed `gss_pacs_resampled.hdf` came from, so it is now tracked
(`0a59c00`).

`git status` shows 36 paths: 7 modified tracked files and 29 untracked,
including a 477 MB raw GSS file (`gss7221_r2.dta`), 31 MB of website build
output, and the two scripts the build depends on (`build.sh`,
`remove_soln.py`), which have never been committed.

## Task 5: Close stale issues and the PR

**Status:** Done 2026-09-24. All three closed with a comment; the repo has no
open issues or PRs. All four typos in #1 were already fixed: the
codebook listing reads "Extremely conservative", the second PMF is
introduced as "And from 2022:", the repeated-title plot was rewritten, and
"helfulness" is gone.

- **#3** (2020-11-15, `GSS.dct` not found after a fresh clone) and **PR #4**
  (a fix for it): obsolete. `01_clean` stopped reading `GSS.dct` in 2022
  (`87a515d`); it now downloads a prebuilt extract from `GssExtract`. Close
  both with a note.
- **#1** (2020-02-05, assorted typos): the one typo quoted in the issue
  ("Extrmly conservative") is gone from `v1`. Check the rest of the list,
  then close.

## Task 6: Fix the notebooks that download deleted data

**Status:** Done 2026-09-24. All three run under pandas 3.0.6 and Python 3.13
with `pytest --nbmake`. They are not in `make tests`.

`generation.ipynb` downloads `raw/master/gss_eda.hdf5`, which was deleted from
this repo in 2022 (`5c5971c`), so it cannot run. EDS pinned its copy of the
same download to commit `34b22cb`, the last one that has the file. Check
`resampling` and `resampling2` too; they also use `raw/master/` links.

Results:

- `gss_eda.hdf5` has six versions. Each notebook is pinned (full hash) to
  the one its recorded `gss.shape` came from, not to `34b22cb`:
  `generation` and `resampling` to `c67527f` (2020-01-19, 165 columns),
  `resampling2` to `c97b1d3` (2020-08-05, 169 columns). `34b22cb` also has
  169 columns but differs from `c97b1d3` in `homosex`, `realinc`, and
  `avoidbuy`.
- `resampling` had a silent pandas 3 bug that Task 3 missed:
  `fill_missing_values(gss[varname])` filled a copy, so all 405 missing
  `age` and `educ` values stayed missing and statsmodels dropped those rows.
  The function now returns the filled Series and the callers assign it.
- `generation`: its `utils.py` link now uses `raw/v1/`. It called
  `resample_rows_weighted(df, df['wtssall'])`, written for a 2020 `utils.py`
  whose effective definition was `df.sample(..., weights=...)`; the current
  one takes a column name and fails on float32 weights ("probabilities do not
  sum to 1"). The cell now calls `df.sample` directly, which is what ran in
  2020. `results = None` was commented out, so a fresh run failed with a
  `NameError`.
- The nine `inplace=True` calls left in `generation` are in a markdown
  cell, so they never run.
- `generation` takes about 13 minutes. Running the three notebooks writes
  `gss_eda.hdf5` and eleven `generation*.png` figures; those are gitignored.
- Edits were made with nbformat, not a jupytext round trip, which added
  cell-metadata noise to these older notebooks. The recorded 2020 outputs are
  kept: they come from the pinned data.

## Task 7: Pin the `GssExtract` source

**Status:** Done 2026-09-24.

`01_clean` downloads `GssExtract/raw/main/data/interim/gss_pacs_2022.hdf`.
A `main` link changes whenever GssExtract does, so rebuilding PACS data is not
reproducible. Pin it to a commit or tag.

Confirmed 2026-09-24 (Task 3): a rebuild from today's `main` differs from the
committed `gss_pacs_clean.hdf` in 17 columns. (That file is now the
2024-04-03 rebuild that `gss_pacs_resampled.hdf` came from; see Task 4. The
2024-01-30 version it replaced differs in 31.) So the GssExtract version to
look for is the one from around 2024-04-03.

Result: GssExtract has nine commits of `gss_pacs_2022.hdf`. The one from
2024-04-02 (`1ac586b`) reproduces the committed `gss_pacs_clean.hdf` and all
three frames of `gss_pacs_resampled.hdf` exactly, under pandas 3.0.6. The
later one on `main` (`e954d99`, 2025-03-06, "2022 r4") is the changed data.

- [x] `01_clean` downloads from `raw/1ac586b64b42.../`, the full hash. That
      URL serves the same bytes as the local GssExtract object.
- [x] `make tests-clean` now also asserts that the rebuilt files equal the
      committed ones, so CI catches any change that moves the data. Checked
      that it fails when given the `main` source.
- [ ] Moving to the r4 data is a separate decision for EDS v2: it changes
      numbers in the printed chapters, so it gets its own commit and a
      rebuild of both files. The income columns are on a different
dollar basis, `reg16` code 9 is now 0, and `fund`, `hhrace`, and `reliten`
have values that were missing before. Find the GssExtract commit that
reproduces the committed files, and pin to it. Whether to move to the new
data is a separate decision, and it gets its own commit.

## Task 8: Refresh `environment.yml`, `requirements.txt`, and the Makefile

**Status:** Done 2026-09-24.

The repo has `requirements.txt` and `requirements-dev.txt`, and an untracked
`environment.yml~` (2019). Follow EDS Task 8: one `environment.yml` built
from what the notebooks import, Python 3.13, and Makefile targets that use it.

- [x] `environment.yml`: conda-forge, Python 3.13, the notebook libraries,
      pytest, nbmake, jupytext, `jupyter-book<2`, and `ghp-import`. It solves
      with mamba in under a minute (pandas 3.0.6, Jupyter Book 1.0.4), and
      `make tests` and `make tests-clean` pass in it. The site builds from a
      scratch copy (not published) with 4 warnings: `02_polviews`,
      `05_alignment`, and `divorce` are copied in but not in `_toc.yml`, and
      `confidence` has an empty cross-reference.
- [x] `requirements.txt` unchanged: it already lists what the notebooks
      import. `requirements-dev.txt` drops black and flake8 and adds jupytext.
- [x] Makefile: environment targets as in EDS (`create_environment`,
      `update_environment`, `delete_environment`, with `CONDA = mamba`),
      plus the uncommitted edits it had. Dropped `lint` and `format` (they
      pointed at a `pacs/` directory and a `pyproject.toml` that don't exist)
      and `add_notebooks` (it called the deleted `scrub_code.py`; `build.sh`
      does that job now).
- [ ] Not done: EDS split build from publish (`build.sh`/`publish.sh`,
      `make notebooks`/`make publish`). Here `build.sh` and `jb/build.sh`
      still build and publish in one step. Worth doing before EDS v2 work.

## Task 9: Reconcile the README with `jb/index.md`

**Status:** Not started.

The README still describes the 2020 PyData version and links to
`blob/master/`. It says "Uodate August 2022" (a typo), and notebook 5 is missing
from its list. `jb/index.md` has uncommitted changes.
