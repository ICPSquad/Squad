import Array "mo:base/Array";
import HashMap "mo:base/HashMap";

// MapHelper contains helper function to interact with hash maps.
module {
    // Returns a function that checks whether the given value is equal to a previously defined value `w`.
    // e.g. textEqual("foo")
    //    = func (v : Text) : Bool { v == "foo"}
    public func textEqual   (w : Text) : (v : Text) -> Bool = func(v : Text) { v == w; };
    public func textNotEqual(w : Text) : (v : Text) -> Bool = func(v : Text) { v != w; };

    public func principalEqual (w : Principal) : (v : Principal) -> Bool = func(v : Principal) { v == w; };

    // Adds the given value to the value array of the hash map if it does not already exists.
    public func add<K, V>(
        // Hash map to add to.
        map : HashMap.HashMap<K, [V]>,
        // Key of the array to add to.
        k : K,
        // Value to add to the targeted array.
        v : V,
        // Search function to check whether the value matches an element of the array.
        f : V -> Bool,
    ) {
        ignore _addIfNotLimit(map, k, v, null, f);
    };

    // Adds the given value to the value array of the hash map if it does not already exists.
    // Returns `true` if the value was added and thus whether the array did not exceed its limits.
    public func addIfNotLimit<K, V>(
        // Hash map to add to.
        map : HashMap.HashMap<K, [V]>,
        // Key of the array to add to.
        k : K,
        // Value to add to the targeted array.
        v : V,
        // Limit on the number of elements in the array.
        limit : Nat,
        // Search function to check whether the value matches an element of the array.
        f : V -> Bool,
    ) : Bool {
        _addIfNotLimit(map, k, v, ?limit, f);
    };

    private func _addIfNotLimit<K, V>(
        map : HashMap.HashMap<K, [V]>,
        k : K,
        v : V,
        limit : ?Nat,
        f : V -> Bool,
    ) : Bool {
        switch(map.get(k)) {
            // Add key iof it does not exist.
            case null {
                map.put(k, [v]);
            };
            // Key already exists.
            case (? vs) {
                // Checks whether the array reached/exceeded the limit.
                switch (limit) {
                    case null  {};
                    case (? l) {
                        if (vs.size() >= l) {
                            return false;
                        };
                    };
                };

                switch(Array.find<V>(vs, f)) {
                    // Add value of it does not exist.
                    case null {
                        map.put(k, Array.append(vs, [v]));
                    };
                     // Value already exists.
                    case (? v) {};
                };
            };
        };
        return true;
    };

    // Filters out all elements based on the given seach function `f`.
    // If no elements match, the entry is removed from the hash map.
    public func filter<K, V>(
        // Hash map to add to.
        map : HashMap.HashMap<K, [V]>,
        // Key of the array to add to.
        k : K,
        // Value to add to the targeted array.
        v : V,
        // Search function to check whether the value matches an element of the array.
        f : V -> Bool,
    ) {
        switch(map.get(k)) {
            // Key does not exist.
            case null {};
            // Key exists.
            case (? vs) {
                // Filter out all the elements that do not match `f`.
                let new = Array.filter<V>(vs, f);
                if (new.size() > 0) {
                    // Overwrite previous array.
                    map.put(k, new);
                } else {
                    // Delete array of no elements match.
                    map.delete(k);
                }
            };
        };
    };
};
