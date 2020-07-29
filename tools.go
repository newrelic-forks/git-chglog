// +build tools

package main

import (
	// build/test.mk
	_ "github.com/stretchr/testify/assert"

	// build/document.mk
	_ "github.com/git-chglog/newrelic-forks/cmd/git-chglog"
	_ "golang.org/x/tools/cmd/godoc"

	// build/release.mk
	_ "github.com/goreleaser/goreleaser"
)
