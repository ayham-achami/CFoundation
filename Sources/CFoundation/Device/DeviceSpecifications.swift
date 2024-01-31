//
//  DeviceSpecifications.swift
//

#if canImport(UIKit)
import UIKit

/// Если `UIViewController` наследует этот протокол то, разрешается поворот экрана типа `allButUpsideDown` для iPhone
public protocol Autorotatebale {}

/// Ориентация устройства
public enum DeviceOrientation {

    /// Портрет
    case portrait
    /// Пейзаж
    case landscape
}

/// Характеристики устройства
public protocol Specifications {

    /// является ли текущее устройство iPad
    var isPad: Bool { get }

    /// Ориентация устройства
    var orientation: DeviceOrientation { get }
}

// MARK: - Specifications + Default
public extension Specifications {

    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

// MARK: - Specifications + Default
@available(iOSApplicationExtension, unavailable)
public extension Specifications {
    
    var orientation: DeviceOrientation {
        let orientation = UIApplication
            .shared
            .windows
            .first?
            .windowScene?
            .interfaceOrientation ?? .portrait
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            return .landscape
        case .portrait, .portraitUpsideDown, .unknown:
            return .portrait
        @unknown default:
            return .portrait
        }
    }
}
#endif
