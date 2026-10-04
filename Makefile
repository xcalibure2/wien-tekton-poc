.PHONY: build install deploy clean

build:
	@echo "=== SECURITY RESEARCH POC - Wien Tekton RCE ==="
	@sh scripts/build.sh

install: build

deploy: build
	@echo "[deploy] Deploying to server..."

clean:
	@echo "[clean] Cleaning build artifacts"
