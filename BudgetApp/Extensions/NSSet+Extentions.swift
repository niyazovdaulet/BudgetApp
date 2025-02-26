import Foundation

extension NSSet {
    func toArray<T>() -> [T] {
        return compactMap { $0 as? T }
    }
}
