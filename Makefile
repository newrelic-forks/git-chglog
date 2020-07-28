.PHONY: clean
clean:
	rm -rf ./dist/
	rm -rf ./git-chglog
	rm -rf $(GOPATH)/bin/git-chglog
	rm -rf cover.out

.PHONY: build
build:
	go build -i -o git-chglog ./cmd/git-chglog

.PHONY: test
test:
	go test -covermode atomic -coverprofile cover.out -v ./...

.PHONY: install
install:
	go install ./cmd/git-chglog

.PHONY: changelog
changelog:
	@git-chglog --next-tag $(tag) $(tag)


.PHONY: compile
compile:
	@echo "=== $(PROJECT_NAME) === [ compile          ]: building commands:"
	@mkdir -p $(BUILD_DIR)/$(GOOS)
	@for b in $(BINS); do \
		echo "=== $(PROJECT_NAME) === [ compile          ]:     $(BUILD_DIR)$(GOOS)/$$b"; \
		BUILD_FILES=`find $(SRCDIR)/cmd/$$b -type f -name "*.go"` ; \
		CGO_ENABLED=0 GOOS=$(GOOS) $(GO) build -ldflags=$(LDFLAGS) -o $(BUILD_DIR)/$(GOOS)/$$b $$BUILD_FILES ; \
	done

compile-all:
	@echo "=== $(PROJECT_NAME) === [ compile          ]: building commands:"
	@mkdir -p $(BUILD_DIR)/$(GOOS)
	@for b in $(BINS); do \
		for os in $(COMPILE_OS); do \
			echo "=== $(PROJECT_NAME) === [ compile          ]:     $(BUILD_DIR)$$os/$$b"; \
			BUILD_FILES=`find $(SRCDIR)/cmd/$$b -type f -name "*.go"` ; \
			CGO_ENABLED=0 GOOS=$$os $(GO) build -ldflags=$(LDFLAGS) -o $(BUILD_DIR)/$$os/$$b $$BUILD_FILES ; \
		done \
	done

# Override GOOS for these specific targets
compile-darwin: GOOS=darwin
compile-darwin: compile

compile-linux: GOOS=linux
compile-linux: compile

compile-windows: GOOS=windows
compile-windows: compile
