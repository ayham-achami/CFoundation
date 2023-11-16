//
//  ContestableContext.swift
//

import Combine
import Foundation

@propertyWrapper
@dynamicMemberLookup
public final class ContestableContext<T> {
    
    @Protected private var context: T
    
    public var wrappedValue: T {
        $context.read { $0 }
    }
    
    nonisolated public var projectedValue: ContestableContext<T> {
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
