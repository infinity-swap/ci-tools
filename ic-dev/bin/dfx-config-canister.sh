#!/usr/bin/env sh
# Add canister info into dfx.json
# Usage: dfx-config-canister pair_factory pair.wasm pair-factory.did
#
# Expecting that wasm and did files are stored in proper directories
# Arguments:
# - canister name
# - name of the wasm module (not URI)
# - name of the candid  (not URI)

name=$1
wasm=$2
did=$3
dfx_json_lines_limit=13
dfx_file="$WORK_DIR/dfx.json"

# Trick to do not have trailing comma
lines=$(wc -l < $dfx_file)
if [ $lines -gt $dfx_json_lines_limit ]; then coma=","; else coma=""; fi

tmpfile=$( mktemp /tmp/dfx-add.XXXXXX )
tee -a "$tmpfile" <<   END
"$name": {
    "type": "custom",
    "wasm": "$DFX_WASMS_DIR/$wasm",
    "candid": "$DFX_DID_DIR/$did"
}$coma
END

sed -i "/\"canisters\": {/r $tmpfile" $dfx_file

rm $tmpfile
