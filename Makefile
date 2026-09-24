PROJECT_NAME = PoliticalAlignmentCaseStudy
PYTHON_INTERPRETER = python

## mamba solves this environment much faster than conda; use conda if that is
## what you have
CONDA = mamba

.PHONY: default create_environment update_environment delete_environment requirements clean tests tests-clean

default:
	@echo "No command specified. Please specify a target."

create_environment:
	$(CONDA) env create -f environment.yml
	@echo ">>> conda env created. Activate with:\nconda activate $(PROJECT_NAME)"

update_environment:
	$(CONDA) env update -f environment.yml --prune

delete_environment:
	conda env remove --name $(PROJECT_NAME)

requirements:
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## The notebooks that read the committed gss_pacs_resampled.hdf
tests:
	pytest --nbmake 0[2345]*.ipynb

## 01_clean downloads the GssExtract source and writes gss_pacs_clean.hdf and
## gss_pacs_resampled.hdf into its working directory, so run it in a copy
## under build/ to keep it from replacing the committed files. Then check that
## the rebuilt files match the committed ones.
tests-clean:
	python -c "import os, shutil; os.makedirs('build/clean', exist_ok=True); shutil.copy('01_clean.ipynb', 'build/clean')"
	cd build/clean && pytest --nbmake 01_clean.ipynb
	python -c "import pandas as pd; [pd.testing.assert_frame_equal(pd.read_hdf('build/clean/' + f, k), pd.read_hdf(f, k)) for f, ks in [('gss_pacs_clean.hdf', ['gss']), ('gss_pacs_resampled.hdf', ['gss0', 'gss1', 'gss2'])] for k in ks]; print('rebuilt data match the committed files')"
