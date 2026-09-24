.PHONY: clean data lint format requirements create_environment

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = PoliticalAlignmentCaseStudy
PYTHON_VERSION = 3.10
PYTHON_INTERPRETER = python


#################################################################################
# COMMANDS                                                                      #
#################################################################################


## Set up python interpreter environment
create_environment:
	conda create -y --name $(PROJECT_NAME) python=$(PYTHON_VERSION)
	@echo ">>> conda env created. Activate with:\nconda activate $(PROJECT_NAME)"


## Install Python Dependencies
requirements:
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements-dev.txt


## Lint using flake8 and black (use `make format` to do formatting)
lint:
	flake8 pacs
	black --check --config pyproject.toml pacs


## Format source code with black
format:
	black --config pyproject.toml pacs


## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete


add_notebooks:
	python scrub_code.py 02_polviews_soln.ipynb
	git add 0*.ipynb
	git commit -m "Updating notebooks"

## The notebooks that read the committed gss_pacs_resampled.hdf
tests:
	pytest --nbmake 0[2345]*.ipynb

## 01_clean downloads the GssExtract source and writes gss_pacs_clean.hdf and
## gss_pacs_resampled.hdf into its working directory, so run it in a copy
## under build/ to keep it from replacing the committed files.
tests-clean:
	python -c "import os, shutil; os.makedirs('build/clean', exist_ok=True); shutil.copy('01_clean.ipynb', 'build/clean')"
	cd build/clean && pytest --nbmake 01_clean.ipynb
