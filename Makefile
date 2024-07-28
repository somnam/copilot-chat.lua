root := ./lua
tests := ./tests
deps := ./deps
plenary := ${deps}/plenary.nvim

.ONESHELL:

.PHONY: lint
lint:
	@luacheck ${root} ${tests}

.PHONY: deps
deps:
	@mkdir -p ${deps}
	@[ -d ${plenary} ] || git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git ${plenary}

.PHONY: test
test:
	@bash ./scripts/run-tests

.PHONY: ci
ci: deps lint test
