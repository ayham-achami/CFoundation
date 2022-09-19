//
//  Keychain.swift
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
import LocalAuthentication

// MARK: - Service
public protocol KeychainService {}

/// Тип сохраняемого элемента в Keychain
typealias KeychainItem = Codable

// MARK: - Error
public enum KeychainError: LocalizedError {

    case noData
    case authFailed
    case unexpectedData
    case unexpectedItemData
    case biometryUserCanceled
    case unhandledError(status: OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case let .unhandledError(status):
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        default:
            return "\(String(describing: Self.self)).\(String(describing: self))"
        }
    }
}

// MARK: - AccessOption
public enum KeychainAccessOption {

    /// Доступ к данным в `Keychain` возможен только в том случае, если
    /// устройство разблокировано пользователем. Это рекомендуется для элементов, которые
    /// должны быть доступны только тогда, когда приложение находится на переднем плане.
    /// Элементы с этим атрибутом переносятся на новое устройство при использовании
    /// зашифрованных резервных копий.
    case whenUnlocked
    /// Доступ к данным в `Keychain` возможен только в том случае, если
    /// устройство разблокировано пользователем. Это рекомендуется для элементов, которые
    /// должны быть доступны только тогда, когда приложение находится на переднем плане.
    /// Элементы с этим атрибутом не переносятся на новое устройство. Таким образом, после
    /// восстановления из резервной копии другого устройства эти элементы не будут присутствовать.
    case whenUnlockedThisDeviceOnly
    /// Данные в элементе `Keychain` не могут быть доступны после перезапуска, пока пользователь
    /// не разблокирует устройство один раз. После первой разблокировки данные остаются доступными до следующего
    /// перезапуска. Это рекомендуется для элементов, к которым должны обращаться фоновые приложения.
    /// Элементы с этим атрибутом переносятся на новое устройство при использовании зашифрованных резервных копий.
    case afterFirstUnlock
    /// Данные в элементе `Keychain` не могут быть доступны после перезапуска, пока пользователь не разблокирует
    /// устройство один раз. После первой разблокировки данные остаются доступными до следующего перезапуска.
    /// Это рекомендуется для элементов, к которым должны обращаться фоновые приложения. Элементы с этим атрибутом не переносятся
    /// на новое устройство. Таким образом, после восстановления из резервной копии другого устройства эти элементы не будут присутствовать.
    case afterFirstUnlockThisDeviceOnly
    /// Доступ к данным `Keychain` возможен только при разблокированном устройстве.
    /// Доступно, только если на устройстве установлен пароль. Это рекомендуется для элементов,
    /// которые должны быть доступны только тогда, когда приложение находится на переднем плане.
    /// Элементы с этим атрибутом никогда не переносятся на новое устройство.
    /// После восстановления резервной копии на новом устройстве эти элементы отсутствуют.
    /// В этом классе нельзя хранить элементы на устройствах без пароля.
    /// Отключение пароля устройства приводит к удалению всех элементов этого класса.
    case whenPasscodeSetThisDeviceOnly

    internal var rawValue: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}

// MARK: - Configuration
public struct KeychainConfiguration {

    public typealias Service = KeychainService & RawRepresentable
    
    public struct SecureAccess {
        
        public static var `default`: SecureAccess { .init(context: nil,
                                                          operationPrompt: nil,
                                                          accessFlags: .biometryCurrentSet) }
        
        public let context: LAContext?
        public let operationPrompt: String?
        public let accessFlags: SecAccessControlCreateFlags
        
        public init(context: LAContext?,
                    operationPrompt: String?,
                    accessFlags: SecAccessControlCreateFlags) {
            self.context = context
            self.operationPrompt = operationPrompt
            self.accessFlags = accessFlags
        }
    }
    
    public let service: String
    public let account: String
    public let secureAccess: SecureAccess?
    public let thisDeviceOnly: Bool
    public let accessGroup: String?
    public let access: KeychainAccessOption

    public init<Service>(service: Service,
                         account: String,
                         secureAccess: SecureAccess? = nil,
                         thisDeviceOnly: Bool = false,
                         accessGroup: String? = nil,
                         access: KeychainAccessOption = .whenUnlocked) where Service: Self.Service {
        self.access = access
        self.account = account
        self.secureAccess = secureAccess
        self.accessGroup = accessGroup
        self.thisDeviceOnly = thisDeviceOnly
        self.service = String(describing: service.rawValue)
    }
}

/// Keychain
public struct Keychain {

    /// Конфигурации
    public let configuration: KeychainConfiguration
    
    /// Инициализация
    /// - Parameter configuration: Конфигурации `Keychain`
    public init(_ configuration: KeychainConfiguration) {
        self.configuration = configuration
    }
    
    /// Сохранить ключ
    /// - Parameters:
    ///   - data: данные
    /// - Throws: `KeychainError`
    public func save(_ data: Data) throws {
        try save(data, throwIfExists: false)
    }
    
    /// Загрузить данные из keychain по ключу
    ///
    /// - Parameter key: ключ
    /// - Returns: данные для этого ключа
    public func read() throws -> Data {
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: configuration.account,
                                    kSecAttrServer as String: configuration.service,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        if let accessGroup = configuration.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        if let secureAccess = configuration.secureAccess {
            if let context = secureAccess.context {
                query[kSecUseAuthenticationContext as String] = context
            }
            if let operationPrompt = secureAccess.operationPrompt {
                query[kSecUseOperationPrompt as String] = operationPrompt
            }
        } else {
            query[kSecAttrAccessible as String] = configuration.access.rawValue
        }
        var queryResult: AnyObject?
        let status: OSStatus = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        switch status {
        case errSecUserCanceled:
            throw KeychainError.biometryUserCanceled
        case errSecItemNotFound:
            throw KeychainError.noData
        case errSecAuthFailed:
            throw KeychainError.authFailed
        case noErr, errSecSuccess:
            guard let existingItem = queryResult as? [String: AnyObject],
                  let data = existingItem[kSecValueData as String] as? Data else {
                throw KeychainError.unexpectedData
            }
            return data
        default:
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    /// Сохранить ключ
    /// - Parameters:
    ///   - data: данные
    ///   - throwIfExists: Кидать ли ошибку если данные по указанному ключу уже существуют
    /// - Throws: `KeychainError`
    public func save(_ data: Data, throwIfExists: Bool) throws {
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: configuration.account,
                                    kSecAttrServer as String: configuration.service,
                                    kSecValueData as String: data]
        if let secureAccess = configuration.secureAccess {
            let access = SecAccessControlCreateWithFlags(nil,
                                                         configuration.access.rawValue,
                                                         secureAccess.accessFlags,
                                                         nil)
            query[kSecAttrAccessControl as String] = access
            if let context = secureAccess.context {
                query[kSecUseAuthenticationContext as String] = context
            }
            if let operationPrompt = secureAccess.operationPrompt {
                query[kSecUseOperationPrompt as String] = operationPrompt
            }
        } else {
            query[kSecAttrAccessible as String] = configuration.access.rawValue
        }
        if let accessGroup = configuration.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        var status = SecItemAdd(query as CFDictionary, nil)
        if !throwIfExists && status == errSecDuplicateItem {
            let attributes: [String: Any] = [kSecValueData as String: data]
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        }
        guard status != errSecUserCanceled else {
            throw KeychainError.biometryUserCanceled
        }
        guard status == noErr || status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    /// Удалить данные из `Keychain`
    public func delete() throws {
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: configuration.account,
                                    kSecAttrServer as String: configuration.service,
                                    kSecAttrAccessible as String: configuration.access.rawValue]
        if let accessGroup = configuration.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound || status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
