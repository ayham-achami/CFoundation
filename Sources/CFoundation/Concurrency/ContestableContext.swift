//
//  ContestableContext.swift
//

import Combine
import Foundation

@propertyWrapper
@dynamicMemberLookup
public struct ContestableContext<T> {
    
    @Protected private var context: T
    
    public var wrappedValue: T {
        $context.read { $0 }
    }
    
    public var projectedValue: ContestableContext<T> {
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

// MARK: - ContestableContext + SubscriptionsStorage
public extension ContestableContext where T == SubscriptionsStorage {
    
    /// Количество элементов в хранилище.
    var count: Int {
        wrappedValue.count
    }
    
    /// Возвращает true, если хранилище пустое
    var isEmpty: Bool {
        wrappedValue.isEmpty
    }
    
    /// Сохранить подписку
    /// - Parameter subscription: Подписка
    func store(_ subscription: AnyCancellable) {
        wrappedValue.store(subscription)
    }
    
    /// Возвращает true, если существует данный элемент в хранилище
    /// - Parameter member: `AnyCancellable`
    /// - Returns: true, если существует данный элемент в хранилище
    func contains(_ member: AnyCancellable) -> Bool {
        wrappedValue.contains(member)
    }
    
    /// Удалит элемент из хранилищя
    /// - Parameter member: `AnyCancellable`
    /// - Returns: если элемента был найден и удалон успешно возвращает его
    @discardableResult
    func remove(_ member: AnyCancellable) -> AnyCancellable? {
        wrappedValue.remove(member)
    }
    
    /// Отменить все подписки
    func cancelAll() {
        wrappedValue.cancelAll()
    }
}
