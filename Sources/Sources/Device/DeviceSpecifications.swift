//
//  DeviceSpecifications.swift
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
