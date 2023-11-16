//
//  DarwinNotificationCenter.swift
//

import Foundation

// MARK: - CFNotificationName + DarwinNotification
extension CFNotificationName {
    
    /// Название уведомления
    var name: DarwinNotification.Name {
        .init(rawValue: rawValue as String)
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
        CFNotificationCenterPostNotification(cfCenter, CFNotificationName(rawValue: name.cfName), nil, nil, true)
    }
    
    /// Подписаться на получение нотификации с указанным названием
    /// - Parameters:
    ///   - name: Имя нотификации
    ///   - closure: Замыкание вызываемое при получении нотификации
    /// - Returns: `DarwinNotification.Observer`
    public func observeNotification(name: DarwinNotification.Name,
                                    behavior: CFNotificationSuspensionBehavior = .deliverImmediately,
                                    _ closure: @escaping () -> Void) -> DarwinNotification.Subscription {
        let subscription = DarwinNotification.Subscription(invocation: closure)
        let pointer = UnsafeRawPointer(Unmanaged.passUnretained(subscription).toOpaque())
        let observation: CFNotificationCallback = { _, subscription, _, _, _ in
            guard let subscription = subscription else { return }
            Unmanaged<DarwinNotification.Subscription>
                .fromOpaque(subscription)
                .takeUnretainedValue()
                .invoke()
        }
        CFNotificationCenterAddObserver(cfCenter, pointer, observation, name.cfName, nil, behavior)
        return subscription
    }
    
    /// Подписаться на все нотификации
    /// - Parameter closure: Замыкание вызываемое при получении нотификации
    /// - Returns: `DarwinNotification.Observer`
    public func observeNotifications(behavior: CFNotificationSuspensionBehavior = .deliverImmediately,
                                     _ closure: @escaping (_ notification: DarwinNotification.Name) -> Void) -> DarwinNotification.Subscription {
        let subscription = DarwinNotification.Subscription(namedInvocation: closure)
        let pointer = UnsafeRawPointer(Unmanaged.passUnretained(subscription).toOpaque())
        let observation: CFNotificationCallback = { _, subscription, notification, _, _ in
            guard
                let subscription = subscription,
                let notification = notification
            else { return }
            Unmanaged<DarwinNotification.Subscription>.fromOpaque(subscription)
                .takeUnretainedValue()
                .invoke(notification.name)
        }
        CFNotificationCenterAddObserver(cfCenter, pointer, observation, nil, nil, .deliverImmediately)
        return subscription
    }

    /// Возвращает Publisher, который генерирует события при широковещательной рассылке уведомлений.
    /// - Parameters:
    ///   - name: Имя нотификации
    ///   - behavior: Флаги приостановки
    /// - Returns: `DarwinNotificationCenter.Publisher`
    public func publisher(for name: DarwinNotification.Name,
                          behavior: CFNotificationSuspensionBehavior = .deliverImmediately) -> DarwinNotificationCenter.Publisher {
        .init(name.cfName, cfCenter, behavior)
    }
    
    /// Запрещает наблюдателю получать какие-либо уведомления от любого объекта
    /// - Parameter pointer: Ссылка на наблюдателя
    public func removeObserver(pointer: UnsafeRawPointer) {
        CFNotificationCenterRemoveEveryObserver(cfCenter, pointer)
    }
}
