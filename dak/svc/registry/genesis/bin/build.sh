#!/usr/bin/env bash

#npx esbuild --bundle --sourcemap --loader:.html=text --minify \
#  --loader:.ico=binary --outfile=dist/index.mjs --format=esm ./src/index.mjs

## no --sourcemap
#
npx esbuild --bundle --loader:.html=text --minify \
  --loader:.ico=binary --outfile=dist/index.mjs --format=esm ./src/index.mjs
