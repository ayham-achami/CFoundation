//
//  Sequence+Sort.swift
//

import Foundation

/// Дескриптор сортировки
@frozen public struct SortDescriptor<Value> {
    
    /// Порядок сортировки
    public enum Order {
        
        /// По возрастанию
        case ascending
        /// По убыванию
        case descending
    }
    
    /// Замыкание сравнения
    public let comparator: (Value, Value) -> ComparisonResult
    
    /// Инициализация
    /// - Parameter comparator: Замыкание сравнения
    public init(_ comparator: @escaping (Value, Value) -> ComparisonResult) {
        self.comparator = comparator
    }
}

// MARK: - SortDescriptor + Value
extension SortDescriptor {
    
    /// Возвращает `SortDescriptor` для заданного `KeyPath`
    /// - Parameter keyPath: `KeyPath` значения
    /// - Returns: `SortDescriptor`
    public static func value<T>(_ keyPath: KeyPath<Value, T>) -> Self where T: Comparable {
        .init { lRoot, rRoot in
            let lhs = lRoot[keyPath: keyPath]
            let rhs = rRoot[keyPath: keyPath]
            guard lhs != rhs else { return .orderedSame }
            return lhs < rhs ? .orderedAscending : .orderedDescending
        }
    }
    
    /// Возвращает `SortDescriptor` для заданного `KeyPath`. Работает с опциональными значениями
    /// - Parameter keyPath: `KeyPath` значения
    /// - Returns: `SortDescriptor`
    public static func value<T>(_ keyPath: KeyPath<Value, T?>) -> Self where T: Comparable {
        .init { lRoot, rRoot in
            let lhs = lRoot[keyPath: keyPath]
            let rhs = rRoot[keyPath: keyPath]
            switch (lhs, rhs) {
            case (.none, .none):
                return .orderedSame
            case (_, .none):
                return .orderedAscending
            case (.none, _):
                return .orderedDescending
            case let (.some(lhs), .some(rhs)):
                guard lhs != rhs else { return .orderedSame }
                return lhs < rhs ? .orderedAscending : .orderedDescending
            }
        }
    }
}

// MARK: - Sequence + Sort with KeyPath
public extension Sequence {
    
    /// Сортирует последовательность по значению заданного `KeyPath`
    /// - Parameter keyPath: `KeyPath` значения
    /// - Returns: Отсортированная последовательность
    func sorted<T>(by keyPath: KeyPath<Element, T>) -> [Element] where T: Comparable {
        sorted { lhs, rhs in
            lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        }
    }
    
    /// Сортирует последовательность по значению заданного `KeyPath` и указанные условия сортировки в замыкании
    /// - Parameters:
    ///   - keyPath: `KeyPath` значения
    ///   - comparator: Замыкание сравнения
    /// - Returns: Отсортированная последовательность
    func sorted<T>(by keyPath: KeyPath<Element, T>, using comparator: (T, T) -> Bool = (<)) -> [Element] where T: Comparable {
         sorted { lhs, rhs in
             comparator(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
         }
     }
    
    /// Сортирует последовательность по значениям заданных `KeyPath`
    /// порядок сортировки определяется с помощью порядка в аргументах вызова метода
    /// - Parameters:
    ///   - descriptors: `KeyPath` значений
    ///   - order: Порядок сортировки
    /// - Returns: Отсортированная последовательность
    func sorted(using descriptors: SortDescriptor<Element>..., order: SortDescriptor<Element>.Order = .ascending) -> [Element] {
        sorted { lhs, rhs in
            compare: for descriptor in descriptors {
                let result = descriptor.comparator(lhs, rhs)
                switch result {
                case .orderedSame:
                    continue compare
                case .orderedAscending:
                    return order == .ascending
                case .orderedDescending:
                    return order == .descending
                }
            }
            return false
        }
    }
}

// MARK: - Bool + Comparable
extension Bool: Comparable {
    
    // Всегда считаем что true больше false, то есть если
    // отсортировать массив bool значений то сначала идут true потом false
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        lhs && !rhs
    }
}
