//
//  CameraPermissionsError.swift
//

import Foundation

/// Ошибка доступа к камере
@frozen public struct CameraPermissionsError: LocalizedError {

    public var errorDescription: String {
        NSLocalizedString("Turn on camera permissions", comment: "Turn on camera permissions")
    }
}
