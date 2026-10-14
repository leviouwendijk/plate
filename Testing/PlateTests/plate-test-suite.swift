import Testing

enum PlateTestSuite {
    static let suite = TestSuite("plate", title: "plate regressions") {
        pklRegressionSuite
        versionRegressionSuite
        casingRegressionSuite
    }
}
