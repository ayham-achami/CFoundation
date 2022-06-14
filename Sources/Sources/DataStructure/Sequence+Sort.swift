//
//  Sequence+Sort.swift
//
//  The MIT License (MIT)
//
//  Copyright (c) 2019 Community Arch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

/// Дескриптор сортировки
public struct SortDescriptor<Value> {
    
    /// Порядок сортировки
    public enum Order {
        
        /// По возрастанию
        case ascending
        /// По убыванию
        case descending
    }
    
    /// Замыкание сравнения
    public var comparator: (Value, Value) -> ComparisonResult
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
