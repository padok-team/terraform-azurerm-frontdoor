DIR_GIT=$(shell sh -c "git rev-parse --show-toplevel")

all: help

##@ Docs Generation
doc: README.md ## Generates Terraform docs for modules
	$(call info_colors,blue,📄 Terraform docs)
	@terraform-docs .

##@ Checks
precommit: ## Runs precommit on all files
	$(call info_colors,green,👍 Pre-commit checks)
	@pre-commit run --all-files && echo "Pre-commit checks passed" || echo "Pre-commit checks failed"

##@ Formating
format: ## Runs Terraform fmt and Validate
	terraform fmt
	terraform validate

##@ Commit
commit: ## Commits all files
	$(call info_colors,purple,🛍 Commits Changed files)
	@echo "Modified files:"
	@git status -s
	@cz

cz: doc precommit commit  ## Runs Docs, precommit and commits

##@ Version
dry-run: ## Dry run the version
	$(call info_colors,green,👏 Generate Version Dry Run)
	@npm run dry-run

version: ## Generate the version
	$(call info_colors,green,👏 Generate Version)
	@npm run version

release: ## Generate a draft for the release using Github Cli
	$(call info_colors,green,👏 Generate Release)
	@gh release create -d -F CHANGELOG.md

include $(DIR_GIT)/prettier.mk

.PHONY: all doc format precommit commit cz dry-run version
