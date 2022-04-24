#!/bin/bash
dfx generate avatar
dfx generate accessories
dfx generate hub 
dfx generate invoice
cp -r src/declarations node
pushd node/declarations
    rm **/index.js
    rm **/*.did
    for f in **/*.js; do
        sed -i '' -e '$ d' "$f"
        sed -i '' -e 's/export const idlFactory = ({ IDL }) => {/import { IDL } from \"@dfinity\/candid\";\nexport const idlFactory : IDL.InterfaceFactory = ({ IDL }) => {/g' "$f"
        mv -- "$f" "${f%.js}.ts"
    done
popd
