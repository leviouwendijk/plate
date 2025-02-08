import Foundation

public enum VAT {
    case vat
    case revenue
}

public protocol ValueAddedTaxableDouble {
    func vat(_ vatRate: Int, _ calculatedValue: VAT) -> Double
}

public protocol ValueAddedTaxableInt {
    func vat(_ vatRate: Int, _ calculatedValue: VAT) -> Int
}

extension Double: ValueAddedTaxableDouble {
    public func vat(_ vatRate: Int = 21, _ calculatedValue: VAT) -> Double {
        let vatRateDouble = Double(vatRate)
        switch calculatedValue {
        case .vat:
            return (self / (100.0 + vatRateDouble)) * vatRateDouble
        case .revenue:
            return (self / (100.0 + vatRateDouble)) * 100.0
        }
    }
}

extension Int: ValueAddedTaxableInt {
    public func vat(_ vatRate: Int = 21, _ calculatedValue: VAT) -> Int {
        let doubleValue = Double(self)
        let vatRateDouble = Double(vatRate)
        let result: Double
        
        switch calculatedValue {
        case .vat:
            result = (doubleValue / (100.0 + vatRateDouble)) * vatRateDouble
        case .revenue:
            result = (doubleValue / (100.0 + vatRateDouble)) * 100.0
        }
        
        return Int(result.rounded())
    }
}
