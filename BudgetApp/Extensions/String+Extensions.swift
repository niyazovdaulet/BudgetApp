import Foundation

extension String {
    var isNumeric: Bool {
        return Double(self) != nil
    }
    
    func isGreaterThan(_ value: Double) -> Bool {
        guard let number = Double(self) else {
            return false
        }
        return number > value
    }
}
