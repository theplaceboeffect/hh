jq -c '.activity[] | { "id":.id, "label":.label}' config.json
