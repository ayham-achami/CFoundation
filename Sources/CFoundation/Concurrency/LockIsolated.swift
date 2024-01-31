//
//  LockIsolated.swift
//

import Combine
import Foundation

@propertyWrapper
@dynamicMemberLookup
public struct LockIsolated<T>: @unchecked Sendable {
    
    @Protected private var context: T
    
    public var wrappedValue: T {
        $context.read { $0 }
    }
    
    public var projectedValue: LockIsolated<T> {
        self
    }
    
    public subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        $context.read { $0[keyPath: keyPath] }
    }
    
    /// Инициализация
    /// - Parameter context: Защищенный контекст
    public init(_ context: T) {
        self.context = context
    }
    
    /// Инициализация
    /// - Parameter wrappedValue: Защищенный контекст
    public init(wrappedValue: T) {
        self.context = wrappedValue
    }
}
