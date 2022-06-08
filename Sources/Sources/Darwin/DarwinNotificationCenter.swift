//
//  DarwinNotificationCenter.swift
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

// MARK: - CFNotificationName + DarwinNotification
extension CFNotificationName {
    
    var stringName: DarwinNotification.Name {
        .init(name: rawValue as String)
    }
}

/// Центр нотификации для общения между процессами.
/// Отправлять можно только имя нотификации. Использует CFNotificationCenter.
public final class DarwinNotificationCenter {
    
    /// центр уведомлений по умолчанию
    public static let `default` = DarwinNotificationCenter()
    
    /// Cсылки на CFNotificationCenter.
    private let cfCenter: CFNotificationCenter
    
    /// Инициализация
    private init() {
        self.cfCenter = CFNotificationCenterGetDarwinNotifyCenter()
    }
    
    /// Отправить нотификацию с указанным именем
    /// - Parameter name: Имя нотификации
    public func postNotification(name: DarwinNotification.Name) {
        CFNotificationCenterPostNotification(cfCenter, CFNotificationName(rawValue: name.cfString), nil, nil, true)
    }
    
    /// Подписаться на получение нотификации с указанным названием
    /// - Parameters:
    ///   - name: Имя нотификации
    ///   - closure: Замыкание вызываемое при получении нотификации
    /// - Returns: `DarwinNotification.Observer`
    public func observeNotification(name: DarwinNotification.Name,
                                    _ closure: @escaping () -> Void) -> DarwinNotification.Subscription? {
        let token = DarwinNotification.Subscription(invocation: closure)
        let pointer = UnsafeRawPointer(Unmanaged.passUnretained(token).toOpaque())
        CFNotificationCenterAddObserver(cfCenter, pointer, { _, token, _, _, _ in
            guard let token = token else { return }
            Unmanaged<DarwinNotification.Subscription>.fromOpaque(token)
                .takeUnretainedValue()
                .invoke()
        }, name.cfString, nil, .deliverImmediately)
        return token
    }
    
    /// Подписаться на все нотификации
    /// - Parameter closure: Замыкание вызываемое при получении нотификации
    /// - Returns: `DarwinNotification.Observer`
    public func observeNotifications(_ closure: @escaping (_ notification: DarwinNotification.Name) -> Void) -> DarwinNotification.Subscription? {
        let token = DarwinNotification.Subscription(namedInvocation: closure)
        let pointer = UnsafeRawPointer(Unmanaged.passUnretained(token).toOpaque())
        CFNotificationCenterAddObserver(cfCenter, pointer, { _, token, notification, _, _ in
            guard
                let token = token,
                let notification = notification
            else { return }
            Unmanaged<DarwinNotification.Subscription>.fromOpaque(token)
                .takeUnretainedValue()
                .invoke(notification.stringName)
        }, nil, nil, .deliverImmediately)
        return token
    }
    
    /// Запрещает наблюдателю получать какие-либо уведомления от любого объекта
    /// - Parameter pointer: Ссылка на наблюдателя
    public func removeObserver(pointer: UnsafeRawPointer) {
        CFNotificationCenterRemoveEveryObserver(cfCenter, pointer)
    }
}
