# Root Makefile for the aware project
# Provides a unified interface for running linting, tests, and builds.

.DEFAULT_GOAL := help

# Detect OS for running flutter on non-linux if needed.
UNAME_S := $(shell uname -s)

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  backend        Install backend dependencies" 
	@echo "  backend-test   Run backend unit tests" 
	@echo "  backend-lint   Run backend lint" 
	@echo "  client         Install Flutter dependencies" 
	@echo "  client-analyze Run flutter analyze" 
	@echo "  client-test    Run flutter tests" 
	@echo "  ci            Run full CI suite (backend + client)"

# Backend targets
.PHONY: backend
backend:
	cd backend && npm install

.PHONY: backend-lint
backend-lint:
	cd backend && npm run lint

.PHONY: backend-test
backend-test:
	cd backend && npm test

# Client targets
.PHONY: client
client:
	cd client && flutter pub get

.PHONY: client-analyze
client-analyze:
	cd client && flutter analyze

.PHONY: client-test
client-test:
	cd client && flutter test

# Full CI suite
.PHONY: ci
ci: backend-lint backend-test client-analyze client-test
	@echo "CI suite completed."
