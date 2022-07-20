//
//  DarwinNotification.swift
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
