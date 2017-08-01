#!/bin/bash

BRANCH="moby-split-test-17.06" # would be branches like 17.06 etc.
# branch that needs docker/docker be rewritten to moby/moby-core. Following was used on docker-ce:
# 
# git grep -l "github.com/docker/docker" | xargs sed -i '' -E 's,github.com/docker/docker(["/ ]|$),github.com/moby/moby-core\1,g' && git status -s | cut -d' ' -f3- | grep '.*\.go$' | xargs gofmt -w -s


mobycorePrefix='github.com/moby/moby-core/'

sed=$(which gsed) || sed=$(which sed)
dir=$(pwd)
tmp=$(mktemp -d)

importMobyDep() {
    local base=${1}
    local dep="${2}"


    scopedImportPath="${dep:${#mobycorePrefix}}"
    dest="vendor/${mobycorePrefix}${scopedImportPath}"
    mkdir -p $(dirname "$dest")
    cp -r "${base}/docker-ce/components/engine/${scopedImportPath}" "$dest"

    deps=$(goList "./${dest}")
    for dep in $deps; do
        if isMobyDep "$dep"; then
            importMobyDep "$base" "$dep"
        fi
    done
}

goList() {
    local path="$1"
    go list -json $path | jq -r '[.Imports[],.TestImports[]][]' | sort -u | grep -E '^[^/]+\.[^/]+'
}

isMobyDep() {
    local dep=$1
    echo "$dep" | grep -q "^$mobycorePrefix";
}

(
	cd "$tmp"
	git clone --depth 1 -b "$BRANCH" https://github.com/tiborvass/docker-ce
	rm -rf "$dir"/go/mobycore
	mkdir -p "$dir"/go
	cp -r docker-ce/components/engine/client "$dir"/go/mobycore
	cd "$dir"/go/mobycore

	find . -name '*.go' -print | xargs $sed -i'' -E 's,\b([pP])ackage client\b,\1ackage mobycore,g'

    deps="$(goList ./...)"
    for dep in $deps; do
        if isMobyDep "$dep"; then
            importMobyDep "$tmp" "$dep"
        else
            dest="vendor/$dep"
            mkdir -p $(dirname "$dest")
            cp -r "$tmp/docker-ce/components/engine/vendor/$dep" "$dest"
        fi
    done
)

rm -rf "$tmp"
