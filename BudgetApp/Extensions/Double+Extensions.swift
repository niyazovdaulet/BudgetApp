import Foundation

extension Double {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    func formatAsCurrency() -> String {
        return Double.currencyFormatter.string(from: NSNumber(value: self)) ?? "0.00"
    }
}
