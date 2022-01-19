import Array "mo:base/Array";
module {
    // Checks whether an array contains a given value.
    public func contains<T>(xs : [T], y : T, equal : (T, T) -> Bool) : Bool {
        for (x in xs.vals()) {
            if (equal(x, y)) return true;
        }; false;
    };
}