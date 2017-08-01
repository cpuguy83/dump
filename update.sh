#!/bin/sh

BRANCH="moby-split-test-17.06" # would be branches like 17.06 etc.
# branch that needs docker/docker be rewritten to moby/moby-core. Following was used on docker-ce:
# 
# git grep -l "github.com/docker/docker" | xargs sed -i '' -E 's,github.com/docker/docker(["/ ]|$),github.com/moby/moby-core\1,g' && git status -s | cut -d' ' -f3- | grep '.*\.go$' | xargs gofmt -w -s

dir=$(pwd)
tmp=$(mktemp -d)
(
	cd "$tmp"
	git clone --depth 1 -b "$BRANCH" https://github.com/tiborvass/docker-ce
	rm -rf "$dir"/go/mobycore
	mkdir -p "$dir"/go
	cp -r docker-ce/components/engine/client "$dir"/go/mobycore
	find "$dir"/go -name '*.go' -print | xargs sed -i '' -E 's,\bpackage client\b,package mobycore,g'
	#for rule in \
	#	'"github.com/docker/docker/client" -> "github.com/tiborvass/devkit/go/mobycore"' \
	#	; do
	#	gofmt -w -r "$rule" "$dir"/go/mobycore/*.go
	#done
)
rm -rf "$tmp"
