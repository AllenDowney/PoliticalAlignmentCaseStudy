.PHONY: clean data lint format requirements create_environment

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = PoliticalAlignmentCaseStudy
PYTHON_VERSION = 3.8
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

tests:
	pytest --nbmake 0*.ipynb