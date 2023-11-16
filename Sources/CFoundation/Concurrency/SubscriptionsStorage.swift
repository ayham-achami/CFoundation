//
//  SubscriptionsStorage.swift
//

import Combine
import Foundation

/// Неизолированный хранилище для сохранения подписки
public final class SubscriptionsStorage {
    
    /// Количество элементов в хранилище
    public var count: Int {
        $subscriptions.read { $0.count }
    }
    
    /// Возвращает true, если хранилище пустое
    public var isEmpty: Bool {
        $subscriptions.read { $0.isEmpty }
    }
    
    /// Подписки
    @Protected private var subscriptions: Set<AnyCancellable>
    
    /// Защищенный
    /// - Parameter subscriptions: `Set<AnyCancellable>`
    public init(subscriptions: Set<AnyCancellable> = []) {
        self.subscriptions = subscriptions
    }
    
    /// Сохранить подписку
    /// - Parameter subscription: Подписка
    public func store(_ subscription: AnyCancellable) {
        $subscriptions.write { $0.insert(subscription) }
    }
    
    /// Возвращает true, если существует данный элемент в хранилище
    /// - Parameter member: `AnyCancellable`
    /// - Returns: true, если существует данный элемент в хранилище
    public func contains(_ member: AnyCancellable) -> Bool {
        $subscriptions.read { $0.contains(member) }
    }
    
    /// Удалит элемент из хранилищя
    /// - Parameter member: `AnyCancellable`
    /// - Returns: если элемента был найден и удалон успешно возвращает его
    @discardableResult
    public func remove(_ member: AnyCancellable) -> AnyCancellable? {
        $subscriptions.write { $0.remove(member) }
    }
    
    /// Отменить все подписки
    public func cancelAll() {
        $subscriptions.read { $0.forEach { subscription in subscription.cancel() } }
        $subscriptions.write { $0.removeAll() }
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
