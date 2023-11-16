//
//  Publisher+ContestableContext.swift
//

import Combine
import Foundation

// MARK: - Publisher + ContestableContext
extension Publisher where Self.Failure == Never {
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ context: ContestableContext<SubscriptionsStorage>,
              receiveValue: @escaping ((Self.Output) -> Void)) {
        context.store(sink(receiveValue: receiveValue))
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ context: ContestableContext<SubscriptionsStorage>,
              receiveValue: @escaping ((Self.Output) async -> Void)) {
        let subscription = sink { output in
            Task {
                await receiveValue(output)
            }
        }
        context.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ context: ContestableContext<SubscriptionsStorage>,
                     receiveValue: @escaping ((Owner?, Self.Output) -> Void)) where Owner: AnyObject {
        let subscription = sink { [weak owner] output in
            receiveValue(owner, output)
        }
        context.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ context: ContestableContext<SubscriptionsStorage>,
                     receiveValue: @escaping ((Owner?, Self.Output) async -> Void)) where Owner: AnyObject {
        let subscription = sink { [weak owner] output in
            Task { [weak owner] in
                await receiveValue(owner, output)
            }
        }
        context.store(subscription)
    }
}

// MARK: - Publisher + ContestableContext
extension Publisher {
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ context: ContestableContext<SubscriptionsStorage>,
              receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
              receiveValue: @escaping ((Self.Output) -> Void)) {
        context.store(sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue))
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ context: ContestableContext<SubscriptionsStorage>,
                     receiveCompletion: @escaping ((Owner?, Subscribers.Completion<Self.Failure>) -> Void),
                     receiveValue: @escaping ((Owner?, Self.Output) -> Void)) where Owner: AnyObject {
        let subscription = sink { [weak owner] completion in
            receiveCompletion(owner, completion)
        } receiveValue: { [weak owner] output in
            receiveValue(owner, output)
        }
        context.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink(_ context: ContestableContext<SubscriptionsStorage>,
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
        context.store(subscription)
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - context: Неизолированный контекст для сохранения подписки
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     _ context: ContestableContext<SubscriptionsStorage>,
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
        context.store(subscription)
    }
}
