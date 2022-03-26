let upstream =  https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.21-20220215/package-set.dhall
let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
let additions = [
    { name = "cap"
      , repo = "https://github.com/Psychedelic/cap-motoko-library"
      , version = "v1.0.3"
      , dependencies = [] : List Text
    },
    { name = "array"
    , repo = "https://github.com/aviate-labs/array.mo"
    , version = "v0.1.1"
    , dependencies = [ "base" ]
    },
    { name = "hash"
    , repo = "https://github.com/aviate-labs/hash.mo"
    , version = "v0.1.0"
    , dependencies = [ "array", "base" ]
    },
    { name = "encoding"
    , repo = "https://github.com/aviate-labs/encoding.mo"
    , version = "v0.3.1"
    , dependencies = [ "array", "base" ]
    },
    { name = "canistergeek"
      , repo = "https://github.com/usergeek/canistergeek-ic-motoko"
      , version = "v0.0.3"
      , dependencies = ["base"] : List Text
    }] : List Package
in upstream # additions