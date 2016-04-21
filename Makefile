.PHONY: clean-pyc clean-build docs clean

clean: clean-build clean-pyc clean-test-all

clean-build:
	@rm -rf build/
	@rm -rf dist/
	@rm -rf *.egg-info

clean-pyc:
	-@find . -name '*.pyc' -follow -print0 | xargs -0 rm -f &> /dev/null
	-@find . -name '*.pyo' -follow -print0 | xargs -0 rm -f &> /dev/null
	-@find . -name '__pycache__' -type d -follow -print0 | xargs -0 rm -rf &> /dev/null

clean-test:
	rm -rf .coverage coverage*
	rm -rf tests/.coverage test/coverage*
	rm -rf htmlcov/

clean-test-all: clean-test
	rm -rf .tox/

lint:
	flake8 users

test:  ## Run test suite against current Python path
	python runtests.py

test-coverage: clean-test
	-py.test ${COVER_FLAGS} ${TEST_FLAGS}
	@exit_code=$?
	@-coverage html
	@exit ${exit_code}

test-all:  ## Run all tox test environments, parallelized
	detox

check: clean-build clean-pyc clean-test lint test-coverage

release: clean  ## Uploads new source and wheel distributions (cleans first)
	python setup.py sdist upload
	python setup.py bdist_wheel upload

dist: clean  ## Creates new source and wheel distributions (cleans first)
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

api-docs:  ## Build autodocs from docstrings
	sphinx-apidoc -f -o docs users

manual-docs:  ## Build written docs
	$(MAKE) -C docs clean
	$(MAKE) -C docs html

docs:  api-docs manual-docs ## Builds and open docs
	open docs/_build/html/index.html

help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
