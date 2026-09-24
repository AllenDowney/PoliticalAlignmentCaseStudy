# Working tree triage (Task 4)

Snapshot 2026-09-24, on branch `v1`: `git status` lists 36 paths, of which 7
are modified tracked files and 29 are untracked. This file proposes what to do
with each one.

**Done 2026-09-24.** Everything below was carried out as proposed, except as
noted in the Outcome section at the end. What is left in `git status`: the
`Makefile` (Task 8) and the seven limbo paths. It follows the EDS triage
(`~/ElementsOfDataScience/planning/working_tree_triage.md`).

Actions: **track** (commit it), **ignore** (add to `.gitignore`), **delete**,
**restore** (`git restore`, discarding the local change), **limbo** (leave it
for now, and say why).

"Runtime download" means a notebook fetches the file into its working
directory when it runs.

## Modified tracked files

| Path | What changed | Action |
|---|---|---|
| `jb/_toc.yml` | `jb-article` → `jb-book`, adds the Examples part with `confidence` | track |
| `jb/build.sh` | Also copies `examples/*.ipynb` | track |
| `jb/index.md` | NBViewer and Colab links updated | review, then track |
| `examples/confidence.ipynb` | Title wording ("'hardly any'") | track |
| `02_polviews_soln.ipynb` | Two blank lines removed | track, or restore |
| `Makefile` | 34 lines removed, including `lint`, `format`, and env targets | review with Task 8 |
| `gss_pacs_clean.hdf` | Rebuilt 2024-04-03; binary | compare with the committed version first (Task 3). Restore if it is not a deliberate update. **Outcome: tracked** (`0a59c00`); see below |

## Untracked: the build

| Path | Action | Why |
|---|---|---|
| `build.sh`, `remove_soln.py` | **track** | `build.sh` makes `02_polviews.ipynb` from `02_polviews_soln.ipynb` using `remove_soln.py`. Neither has been committed |
| `unfilled/build.sh`, `unfilled/remove_soln.py` | track | Go with the tracked `unfilled/04_worldview.ipynb` |
| `jb/_build/` (31 MB) | ignore | Build output |
| `jb/0*.ipynb`, `jb/confidence.ipynb`, `jb/divorce.ipynb` | ignore | Copied in by `jb/build.sh` |

## Untracked: data

| Path | Action | Why |
|---|---|---|
| `gss7221_r2.dta` (477 MB) | ignore | Raw GSS cumulative file (Stata) |
| `gss_pacs_2022.hdf` (10 MB) | ignore | Runtime download: `01_clean` fetches it from `GssExtract` |
| `examples/gss_pacs_resampled.hdf` (31 MB), `examples/utils.py` | ignore | Runtime downloads; `examples/utils.py` is identical to `utils.py` |
| `gss_pacs.hdf` (7.3 MB, 2022) | limbo, then delete | Older extract; nothing on `v1` reads it |
| `gss_docs/` (NORC methodological primer and release notes), `GSS2024_Ballot1_English.pdf` | ignore, or track the small ones | NORC documentation, 1.2 MB and 2 MB |

## Untracked: other

| Path | Action | Why |
|---|---|---|
| `examples/divorce1.png`, `examples/divorce2.png` | ignore | Figures written by `examples/divorce.ipynb` |
| `cover/cover_figure.svg`, `cover/eds_cover.{jpg,pdf,svg}` | limbo | 2021 cover files, next to the tracked `cover/cover.ipynb`. The EDS cover lives in `~/ElementsOfDataScienceBook/cover/` |
| `gss_alignment.gif` (2.2 MB), `mygif.gif` | limbo | 2022 animations |
| `environment.yml~` | delete | Editor backup from 2019 (Task 8) |
| `planning/` | **track** | This folder |

## Proposed `.gitignore` additions

```gitignore
# website build: output, and notebooks copied in by jb/build.sh
jb/_build/
jb/*.ipynb

# raw and downloaded data; the committed HDF files stay tracked
*.dta
/gss_pacs_2022.hdf
examples/*.hdf
examples/utils.py
examples/*.png

# NORC documentation kept locally
gss_docs/
GSS2024_*.pdf

# editor backups
*~
```

## Outcome

- `gss_pacs_clean.hdf`: tracked, not restored (`0a59c00`). The 2024-04-03
  rebuild (`37c15b0`) committed `gss_pacs_resampled.hdf` but not the matching
  clean file. Resampling the uncommitted file with `01_clean`'s
  `resample_by_year` and seeds 0–2 reproduces all three committed frames
  exactly, under pandas 2.3.3 and 3.0.6. The 2024-01-30 file does not.
- Build scripts tracked (`1a45ad3`). The `jb/`, `examples/confidence`, and
  `02_polviews_soln` edits tracked (`d015d64`). `jb/build.sh` now copies
  `examples/divorce.ipynb` too, although `_toc.yml` does not list it.
- `environment.yml~` deleted; the proposed `.gitignore` additions made.
- `05_alignment` also writes `alignment1.jpg`–`alignment16.jpg` into the root;
  those were ignored under Task 2.
- Still in limbo: `cover/` (4 files), `gss_alignment.gif`, `mygif.gif`,
  `gss_pacs.hdf`.
