#!/bin/bash

# Generate declarations files using dfx

dfx generate avatar
dfx generate accessories
dfx generate hub 
dfx generate invoice
dfx generate ledger

# Change declarations from JS to TS
pushd src/declarations
    rm **/index.js
    rm **/*.did
    for f in **/*.js; do
        sed -i '' -e '$ d' "$f"
        sed -i '' -e 's/export const idlFactory = ({ IDL }) => {/import { IDL } from \"@dfinity\/candid\";\nexport const idlFactory : IDL.InterfaceFactory = ({ IDL }) => {/g' "$f"
        mv -- "$f" "${f%.js}.ts"
    done
    sed -i '' -e '$ d' hub/hub.did.ts
    sed -i '' -e '$ d' hub/hub.did.ts
popd

# Copy declarations to Node folder
cp -r src/declarations node
