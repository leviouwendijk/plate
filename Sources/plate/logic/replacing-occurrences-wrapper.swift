extension String {
    public func replacing(
        _ instances: String,
        with replacement: String = ""
    ) -> String {
        return self.replacingOccurrences(
            of: instances,
            with: replacement
        )
    }
}
