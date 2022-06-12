#!/bin/bash

# Generate declarations files using dfx

dfx generate avatar
dfx generate accessories
dfx generate hub
dfx generate invoice

# Change declarations from JS to TS
pushd src/declarations
    rm **/index.js
    rm **/*.did
    for f in **/*.js; do
        mv -- "$f" "${f%.js}.ts"
    done
popd

# Copy declarations to Node folder
cp -r src/declarations node
