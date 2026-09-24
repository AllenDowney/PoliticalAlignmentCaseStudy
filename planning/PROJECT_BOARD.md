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
- **Next:** Tasks 2 (CI), 3 (pandas 3), 4 (working tree)
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
- [ ] After Task 3, fast-forward `master` again (`git push origin v1:master`)
      so the printed links get the pandas 3 fixes.

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

**Status:** Not started.

GitHub disabled the `tests` workflow for inactivity (`disabled_inactivity`),
and it has no runs on record. It also triggers only on pushes to `master`,
uses `actions/checkout@v2` and `setup-python@v2` (Node 20, deprecated), and
tests Python 3.8.

- [ ] Update `.github/workflows/tests.yml` to match EDS: actions v7, Python
      3.13, Ubuntu, Windows, and macOS, `fail-fast: false`, `PYTHONUTF8=1`,
      push on the working branch (Task 1), monthly schedule
- [ ] Re-enable the workflow on GitHub
- [ ] `make tests` runs `0[1234]*.ipynb`, with a comment that notebook 5
      "won't run until Colab updates statsmodels". Recheck that after Task 3.

## Task 3: pandas 3 fixes

**Status:** Not started. Found 2026-09-24 by running the notebooks under
pandas 3.0.6 on a clean export of `origin/v1`: `02_polviews`,
`02_polviews_soln`, `03_outlook`, and `04_worldview` pass; `01_clean` and
`05_alignment` fail.

- [ ] **Chained in-place calls do nothing under copy-on-write.** This covers
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
- [ ] **`to_hdf` key is keyword-only:** `01_clean` calls
      `gss.to_hdf("gss_pacs_clean.hdf", "gss", "w", complevel=6)`, which raises
      a `TypeError`.
- [ ] **NaN into a bool column raises:** `05_alignment` builds `questions`
      from `isin` (bool), then sets `questions.loc[null, varname] = np.nan`.
      pandas 3 raises `TypeError: Invalid value 'nan' for dtype 'bool'`.
      Cast to float first.
- [ ] After fixing `01_clean`, rebuild both HDF files in a scratch copy and
      check they are identical to the committed ones (the EDS method), rather
      than overwriting them.

Edit notebooks through jupytext (see `CLAUDE.md`).

## Task 4: Triage the working tree

**Status:** Not started. Inventory in
[working_tree_triage.md](working_tree_triage.md).

`git status` shows 36 paths: 7 modified tracked files and 29 untracked,
including a 477 MB raw GSS file (`gss7221_r2.dta`), 31 MB of website build
output, and the two scripts the build depends on (`build.sh`,
`remove_soln.py`), which have never been committed.

## Task 5: Close stale issues and the PR

**Status:** Not started.

- **#3** (2020-11-15, `GSS.dct` not found after a fresh clone) and **PR #4**
  (a fix for it): obsolete. `01_clean` stopped reading `GSS.dct` in 2022
  (`87a515d`); it now downloads a prebuilt extract from `GssExtract`. Close
  both with a note.
- **#1** (2020-02-05, assorted typos): the one typo quoted in the issue
  ("Extrmly conservative") is gone from `v1`. Check the rest of the list,
  then close.

## Task 6: Fix the notebooks that download deleted data

**Status:** Not started.

`generation.ipynb` downloads `raw/master/gss_eda.hdf5`, which was deleted from
this repo in 2022 (`5c5971c`), so it cannot run. EDS pinned its copy of the
same download to commit `34b22cb`, the last one that has the file. Check
`resampling` and `resampling2` too; they also use `raw/master/` links.

## Task 7: Pin the `GssExtract` source

**Status:** Not started.

`01_clean` downloads `GssExtract/raw/main/data/interim/gss_pacs_2022.hdf`.
A `main` link changes whenever GssExtract does, so rebuilding PACS data is not
reproducible. Pin it to a commit or tag.

## Task 8: Refresh `environment.yml`, `requirements.txt`, and the Makefile

**Status:** Not started.

The repo has `requirements.txt` and `requirements-dev.txt`, and an untracked
`environment.yml~` (2019). Follow EDS Task 8: one `environment.yml` built
from what the notebooks import, Python 3.13, and Makefile targets that use it.

## Task 9: Reconcile the README with `jb/index.md`

**Status:** Not started.

The README still describes the 2020 PyData version and links to
`blob/master/`. It says "Uodate August 2022" (a typo), and notebook 5 is missing
from its list. `jb/index.md` has uncommitted changes.
