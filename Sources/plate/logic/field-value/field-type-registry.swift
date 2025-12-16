import Foundation

public actor FieldTypeRegistry<Value: Sendable> {
    public typealias Table = String
    public typealias Key   = String
    public typealias Map   = [Key: Value]

    private var mapping: [Table: Map] = [:]

    // Inits
    public init() { }
    public init(initial: [Table: Map]) {
        self.mapping = initial
    }

    // READ
    /// Returns the entire map for a table.
    public func table(named name: String) throws -> Map {
        if let m = mapping[name] { return m }
        throw Error.noMap(name)
    }

    /// Returns a single value for a given table/key.
    public func value(in table: Table, for key: Key) throws -> Value {
        guard let m = mapping[table] else { throw Error.noMap(table) }
        guard let v = m[key] else { throw Error.noKey(table, key) }
        return v
    }

    /// Snapshot of the whole registry.
    public func snapshot() -> [Table: Map] { mapping }

    /// Returns true if a table is registered.
    public func contains(table name: Table) -> Bool { mapping[name] != nil }

    /// Returns true if a key exists in a table.
    public func contains(table name: Table, key: Key) -> Bool {
        mapping[name]?[key] != nil
    }

    /// All table names.
    public func tables() -> [Table] { Array(mapping.keys) }

    /// All keys for a table.
    public func keys(in table: Table) -> [Key] {
        guard let m = mapping[table] else { return [] }
        return Array(m.keys)
    }

    // WRITE
    /// Set the full map for a table. Idempotent unless `overwrite` is true.
    public func set(table name: Table, to map: Map, overwrite: Bool = false) {
        if overwrite || mapping[name] == nil { mapping[name] = map }
    }

    /// Kept for compatibility with your previous API.
    public func register(table name: Table, types: Map, overwrite: Bool = false) {
        set(table: name, to: types, overwrite: overwrite)
    }

    /// Merge a patch map into a table (replaces on key collision).
    public func merge(table name: Table, patch: Map) {
        var base = mapping[name] ?? [:]
        for (k, v) in patch { base[k] = v }
        mapping[name] = base
    }

    /// Upsert a single key in a table. If the key exists, replaces it.
    public func upsert(table name: Table, key: Key, value: Value) {
        var base = mapping[name] ?? [:]
        base[key] = value
        mapping[name] = base
    }

    /// Upsert a single key with a custom combiner when the key already exists.
    public func upsert(
        table name: Table,
        key: Key,
        value: Value,
        combine: ((Value, Value) -> Value)?
    ) {
        var base = mapping[name] ?? [:]
        if let existing = base[key], let combine {
            base[key] = combine(existing, value)
        } else {
            base[key] = value
        }
        mapping[name] = base
    }

    /// Remove a whole table.
    public func remove(table name: Table) {
        mapping.removeValue(forKey: name)
    }

    /// Remove a single key from a table.
    public func remove(table name: Table, key: Key) {
        guard var base = mapping[name] else { return }
        base.removeValue(forKey: key)
        mapping[name] = base
    }

    // Errors
    public enum Error: Swift.Error, LocalizedError {
        case noMap(Table)
        case noKey(Table, Key)

        public var errorDescription: String? {
            switch self {
            case .noMap(let t): return "No field-type map registered for table: \(t)"
            case .noKey(let t, let k): return "No value for key '\(k)' in table: \(t)"
            }
        }
    }
}
