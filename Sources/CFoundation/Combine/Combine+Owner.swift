//
//  Combine+Owner.swift
//

import Combine
import Foundation

// MARK: - Publisher + Owner + Never
extension Publisher where Failure == Never {

    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner, receiveValue: @escaping ((Owner?, Self.Output) -> Void)) -> AnyCancellable where Owner: AnyObject {
        sink { [weak owner] output in
            receiveValue(owner, output)
        }
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner, receiveValue: @escaping ((Owner?, Self.Output) async -> Void)) -> AnyCancellable where Owner: AnyObject {
        sink { [weak owner] output in
            Task { [weak owner] in
                await receiveValue(owner, output)
            }
        }
    }
}

// MARK: - Publisher + Owner
extension Publisher {
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     receiveCompletion: @escaping ((Owner?, Subscribers.Completion<Self.Failure>) -> Void),
                     receiveValue: @escaping ((Owner?, Self.Output) -> Void)) -> AnyCancellable where Owner: AnyObject {
        sink { [weak owner] completion in
            receiveCompletion(owner, completion)
        } receiveValue: { [weak owner] output in
            receiveValue(owner, output)
        }
    }
    
    /// Создает подписчика и немедленно запрашивает неограниченное количество
    /// значений перед возвратом подписчика.
    /// - Parameters:
    ///   - owner: Владелец вызова на него создается слабая ссылка и передается в замыкание получения знания
    ///   - receiveCompletion: Замыкание, выполняемое по завершении.
    ///   - receiveValue: Замыкание, выполняемое при получении значения.
    func sink<Owner>(_ owner: Owner,
                     receiveCompletion: @escaping ((Owner?, Subscribers.Completion<Self.Failure>) async -> Void),
                     receiveValue: @escaping ((Owner?, Self.Output) async -> Void)) -> AnyCancellable where Owner: AnyObject {
        sink { [weak owner] completion in
            Task { [weak owner] in
                await receiveCompletion(owner, completion)
            }
        } receiveValue: { [weak owner] output in
            Task { [weak owner] in
                await receiveValue(owner, output)
            }
        }
    }
}
