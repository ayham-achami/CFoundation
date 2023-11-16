//
//  DarwinNotification.swift
//

import Foundation

// Пространство имен `DarwinNotification`
public enum DarwinNotification {}

// MARK: - DarwinNotification + Name
public extension DarwinNotification {
    
    /// Имя нотификаций для общения между процессами
    struct Name: Hashable {
        
        /// Название нотификации
        let name: String
        
        /// Название нотификации в виде `CFString`
        var cfName: CFString {
            name as CFString
        }
        
        /// Инициализация
        /// - Parameter name: Название нотификации
        public init(rawValue: String) {
            self.name = "CFoundation.DarwinNotification.Name.\(rawValue)"
        }
    }
}

// MARK: - DarwinNotification + Observer
public extension DarwinNotification {
    
    /// Подписка на уведомление
    final class Subscription: NSObject {
        
        /// Замыкание, которое надо выполнять при получение уведомления
        var invocation: (() -> Void)?
        
        /// Замыкание, которое надо выполнять при получение уведомления
        var namedInvocation: ((_ notification: DarwinNotification.Name) -> Void)?
        
        /// Инициализация
        /// - Parameter namedInvocation: Замыкание, которое надо выполнять при получение уведомления
        init(namedInvocation: @escaping (_ notification: DarwinNotification.Name) -> Void) {
            self.namedInvocation = namedInvocation
            super.init()
        }
        
        /// Инициализация
        /// - Parameter invocation: Замыкание, которое надо выполнять при получение уведомления
        init(invocation: @escaping () -> Void) {
            self.invocation = invocation
            super.init()
        }
        
        deinit {
            invalidate()
        }
        
        func invoke(_ name: DarwinNotification.Name? = nil) {
            if let name = name {
                namedInvocation?(name)
            } else {
                invocation?()
            }
        }
        
        /// Отменить подписку на уведомление
        /// - Parameter center: Центр нотификации для общения между процессами
        public func invalidate(center: DarwinNotificationCenter = .default) {
            DarwinNotificationCenter
                .default
                .removeObserver(pointer: .init(Unmanaged.passUnretained(self).toOpaque()))
        }
    }
}
