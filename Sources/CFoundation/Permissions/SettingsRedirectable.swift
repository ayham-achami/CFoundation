//
//  SettingsRedirectable.swift
//

#if canImport(UIKit)
import UIKit

/// Открыть настройки приложения
public protocol SettingsRedirectable: AnyObject {

    /// Открыть настройки приложения
    /// - Parameter completionHandler: Замыкание вызывается после перехода на экран настройки приложения
    func openAppPermissions(completionHandler: ((Bool) -> Void)?)
}
#endif
