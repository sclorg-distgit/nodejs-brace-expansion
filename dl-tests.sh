#!/bin/bash

tag=$(sed -n 's/^Version:\s\(.*\)$/\1/p' ./*.spec | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
url=$(sed -n 's/^URL:\s\(.*\)$/\1/p' ./*.spec | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
pkgdir=$(basename $url | sed -s 's/\.git$//')

echo "tag: $tag"
echo "URL: $url"
echo "pkgdir: $pkgdir"

set -e

tmp=$(mktemp -d)

trap cleanup EXIT
cleanup() {
    echo Cleaning up...
    set +e
    [ -z "$tmp" -o ! -d "$tmp" ] || rm -rf "$tmp"
}

unset CDPATH
pwd=$(pwd)

pushd "$tmp"
git clone $url
cd $pkgdir
echo Finding git tag
gittag=$(git show-ref --tags | cut -d' ' -f2 | grep '${tag}$'||git show-ref --tags | cut -d' ' -f2 | sort -nr | head -n1)
echo "Git Tag: $gittag"
if [ -z $gittag ]; then
	gittag=tags/$tag
fi
git archive --prefix='test/' --format=tar ${gittag}:test/ \
    | bzip2 > "$pwd"/tests-${tag}.tar.bz2
popd
