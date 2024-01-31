//
//  Publisher+SubscriptionsStorage.swift
//

import Combine
import Foundation

// MARK: - Publisher + SubscriptionsStorage
public extension Publisher where Self.Failure == Never {
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ subscriptions: SubscriptionsStorage,
              receiveValue: @escaping ((Self.Output) -> Void)) {
        subscriptions.store(sink(receiveValue: receiveValue))
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ subscriptions: SubscriptionsStorage,
              receiveValue: @escaping ((Self.Output) async -> Void)) {
        let subscription = sink { output in
            Task {
                await receiveValue(output)
            }
        }
        subscriptions.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ subscriptions: SubscriptionsStorage,
                     receiveValue: @escaping ((Owner?, Self.Output) -> Void)) where Owner: AnyObject {
        let subscription = sink { [weak owner] output in
            receiveValue(owner, output)
        }
        subscriptions.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ subscriptions: SubscriptionsStorage,
                     receiveValue: @escaping ((Owner?, Self.Output) async -> Void)) where Owner: AnyObject {
        let subscription = sink { [weak owner] output in
            Task { [weak owner] in
                await receiveValue(owner, output)
            }
        }
        subscriptions.store(subscription)
    }
}

// MARK: - Publisher + SubscriptionsStorage
public extension Publisher {
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ subscriptions: SubscriptionsStorage,
              receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
              receiveValue: @escaping ((Self.Output) -> Void)) {
        subscriptions.store(sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue))
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ subscriptions: SubscriptionsStorage,
                     receiveCompletion: @escaping ((Owner?, Subscribers.Completion<Self.Failure>) -> Void),
                     receiveValue: @escaping ((Owner?, Self.Output) -> Void)) where Owner: AnyObject {
        let subscription = sink { [weak owner] completion in
            receiveCompletion(owner, completion)
        } receiveValue: { [weak owner] output in
            receiveValue(owner, output)
        }
        subscriptions.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ subscriptions: SubscriptionsStorage,
              receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) async -> Void),
              receiveValue: @escaping ((Self.Output) async -> Void)) {
        let subscription = sink { completion in
            Task {
                await receiveCompletion(completion)
            }
        } receiveValue: { output in
            Task {
                await receiveValue(output)
            }
        }
        subscriptions.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - subscriptions: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ subscriptions: SubscriptionsStorage,
                     receiveCompletion: @escaping ((Owner?, Subscribers.Completion<Self.Failure>) async -> Void),
                     receiveValue: @escaping ((Owner?, Self.Output) async -> Void)) where Owner: AnyObject {
        let subscription = sink { [weak owner] completion in
            Task { [weak owner] in
                await receiveCompletion(owner, completion)
            }
        } receiveValue: { [weak owner] output in
            Task { [weak owner] in
                await receiveValue(owner, output)
            }
        }
        subscriptions.store(subscription)
    }
}
