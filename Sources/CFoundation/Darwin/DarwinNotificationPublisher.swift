//
//  DarwinNotificationPublisher.swift
//

import Combine
import Foundation

/// Любой подписчик `DarwinNotificationCenter`
protocol AnyDarwinNotificationSubscriber: AnyObject {
    
    /// Сообщает подписчику, что Publisher готов принимать дальнейшие запросы
    func receive()
}

// MARK: - DarwinNotificationCenter + Publisher
extension DarwinNotificationCenter {
    
    /// Обертка надо Subscriber
    private class SubscriberBox<SubscriberType: Subscriber>: AnyDarwinNotificationSubscriber where SubscriberType.Input == Void,
                                                                                                   SubscriberType.Failure == Never {
        
        /// Подписчик
        var subscriber: SubscriberType
        
        /// Инициализация
        /// - Parameter subscriber: Подписчик
        init(_ subscriber: SubscriberType) {
            self.subscriber = subscriber
        }
        
        func receive() {
            _ = subscriber.receive()
        }
    }
    
    /// Publisher доставляет элементы одному или нескольким экземплярам подписчика.
    public struct Publisher: Combine.Publisher {
        
        public typealias Failure = Never
        public typealias Output = Void
        
        /// Название события на которое идет подписка
        private let name: CFString
        
        /// Центр нотификации для общения между процессами.
        private let center: CFNotificationCenter
        
        /// Флаги приостановки, которые указывают, как должны
        /// обрабатываться распределенные уведомления, когда принимающее
        /// приложение находится в фоновом режиме.
        private let behavior: CFNotificationSuspensionBehavior
        
        /// Инициализация
        /// - Parameters:
        ///   - name: Название уведомления
        ///   - center: Центр уведомление межпроцессорный
        ///   - behavior: Флаги приостановки
        init(_ name: CFString,
             _ center: CFNotificationCenter,
             _ behavior: CFNotificationSuspensionBehavior) {
            self.name = name
            self.center = center
            self.behavior = behavior
        }

        public func receive<SubscriberType>(subscriber: SubscriberType) where SubscriberType: Subscriber,
                                                                              SubscriberType.Input == Void,
                                                                              SubscriberType.Failure == Never {
            subscriber.receive(subscription: DarwinNotificationCenter
                .Publisher
                .Subscription(name, center, SubscriberBox(subscriber), behavior))
        }
    }
 }

// MARK: - DarwinNotificationCenter.Publisher + Subscription
extension DarwinNotificationCenter.Publisher {
    
    /// Объект представляющий подключение подписчики к `DarwinNotificationCenter.Publisher`
    final class Subscription: Combine.Subscription {
        
        /// Название события на которое идет подписка
        private let name: CFString
        
        /// Центр нотификации для общения между процессами.
        private let center: CFNotificationCenter
        
        /// Флаги приостановки, которые указывают, как должны
        /// обрабатываться распределенные уведомления, когда принимающее
        /// приложение находится в фоновом режиме.
        private let behavior: CFNotificationSuspensionBehavior
        
        /// Подписчик
        private var subscriber: AnyDarwinNotificationSubscriber?
        
        /// Инициализация
        /// - Parameters:
        ///   - name: Название уведомления
        ///   - center: Центр уведомление межпроцессорный
        ///   - subscriber: Подписчик
        ///   - behavior: Флаги приостановки
        init(_ name: CFString,
             _ center: CFNotificationCenter,
             _ subscriber: AnyDarwinNotificationSubscriber,
             _ behavior: CFNotificationSuspensionBehavior) {
            self.name = name
            self.center = center
            self.behavior = behavior
            self.subscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            let pointer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
            let observation: CFNotificationCallback = { _, subscription, _, _, _ in
                guard let subscription = subscription else { return }
                Unmanaged<DarwinNotificationCenter.Publisher.Subscription>
                    .fromOpaque(subscription)
                    .takeUnretainedValue()
                    .subscriber?
                    .receive()
            }
            CFNotificationCenterAddObserver(center, pointer, observation, name, nil, behavior)
        }
        
        func cancel() {
            let pointer = Unmanaged.passUnretained(self).toOpaque()
            CFNotificationCenterRemoveEveryObserver(center, pointer)
            subscriber = nil
        }
    }
}
