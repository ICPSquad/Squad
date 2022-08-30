let upstream =  https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.21-20220215/package-set.dhall
let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
let additions = [
    { name = "cap"
      , repo = "https://github.com/Psychedelic/cap-motoko-library"
      , version = "v1.0.4"
      , dependencies = [] : List Text
    },
    { name = "array"
    , repo = "https://github.com/aviate-labs/array.mo"
    , version = "v0.1.1"
    , dependencies = [ "base"]
    },
    { name = "hash"
    , repo = "https://github.com/aviate-labs/hash.mo"
    , version = "v0.1.0"
    , dependencies = [ "array", "base"]
    },
    { name = "encoding"
    , repo = "https://github.com/aviate-labs/encoding.mo"
    , version = "v0.3.1"
    , dependencies = [ "array", "base"]
    },
    { name = "canistergeek"
      , repo = "https://github.com/usergeek/canistergeek-ic-motoko"
      , version = "v0.0.3"
      , dependencies = ["base"] : List Text
    },
    { name = "ext"
      , repo = "https://github.com/aviate-labs/ext.std"
      , version = "v0.2.0"
      , dependencies = ["array", "base", "encoding", "principal"]
    },
    { name = "principal"
      , repo = "https://github.com/aviate-labs/principal.mo"
      , version = "v0.2.5"
      , dependencies = ["array", "crypto", "base", "encoding", "hash"]
    },
    { name = "crypto"
    , repo = "https://github.com/aviate-labs/crypto.mo"
    , version = "v0.1.1"
    , dependencies = ["base", "encoding"]
    },
    { name = "io"
    , repo = "https://github.com/aviate-labs/io.mo"
    , version = "v0.3.1"
    , dependencies = ["base"]
    },
    {
      name = "rand"
    , repo = "https://github.com/aviate-labs/rand.mo"
    , version = "v0.2.2"
    , dependencies = ["base", "encoding", "io"]
    },
    { name = "modsdk"
    , repo = "https://github.com/modclub-app/sdk"
    , version = "0.1.1"
    , dependencies = ["base"] : List Text
    }
    ] : List Package
in upstream # additions