.PHONY: fmt lint test validate

TFLINT ?= tflint
TFSEC ?= tfsec
TFLINT_CONFIG := $(CURDIR)/tests/tflint.hcl

fmt:
	terraform fmt -recursive

validate:
	./tests/test_hcl.sh

lint:
	terraform fmt -check -recursive
	terraform init -backend=false -input=false
	$(TFLINT) --init --config $(TFLINT_CONFIG)
	$(TFLINT) --recursive --config $(TFLINT_CONFIG)
	$(TFSEC) --config-file tests/tfsec.yaml --minimum-severity HIGH .

test: lint validate
