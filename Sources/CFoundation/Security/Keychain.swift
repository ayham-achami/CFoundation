//
//  Keychain.swift
//

import Foundation
import LocalAuthentication

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
public enum KeychainAccessOption: Sendable {

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

// MARK: - Service
public protocol KeychainService: Sendable {}

/// Тип сохраняемого элемента в Keychain
typealias KeychainItem = Codable

// MARK: - Configuration
@frozen public struct KeychainConfiguration: Sendable {

    public typealias Service = KeychainService & RawRepresentable
    
    public struct SecureAccess: @unchecked Sendable {
        
        public static var `default`: SecureAccess {
            .init(context: nil,
                  operationPrompt: nil,
                  accessFlags: .biometryCurrentSet)
        }
        
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
    
    public struct Identity: @unchecked Sendable {
        
        public enum KeyType: @unchecked Sendable {
            
            case ec
            case rsa
            
            var rawValue: CFString {
                switch self {
                case .rsa:
                    kSecAttrKeyTypeRSA
                case .ec:
                    kSecAttrKeyTypeEC
                }
            }
        }
        
        public let tag: Data
        public let label: String
        public let keyType: KeyType
        
        public init(tag: Data,
                    label: String,
                    keyType: KeyType) {
            self.tag = tag
            self.label = label
            self.keyType = keyType
        }
    }
    
    public let service: String
    public let account: String
    public let secureAccess: SecureAccess?
    public let thisDeviceOnly: Bool
    public let accessGroup: String?
    public let access: KeychainAccessOption
    public let identity: Identity?

    public init<Service>(service: Service,
                         account: String,
                         secureAccess: SecureAccess? = nil,
                         thisDeviceOnly: Bool = false,
                         accessGroup: String? = nil,
                         access: KeychainAccessOption = .whenUnlocked,
                         identity: Identity? = nil) where Service: Self.Service {
        self.access = access
        self.account = account
        self.identity = identity
        self.secureAccess = secureAccess
        self.accessGroup = accessGroup
        self.thisDeviceOnly = thisDeviceOnly
        self.service = String(describing: service.rawValue)
    }
}

/// Keychain
@frozen public struct Keychain: Sendable {

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
        try deleteItem(with: query)
    }
    
    /// Получить комбинацию сертификата и приватного ключа
    /// - Returns: `SecIdentity`
    public func readIdentity() throws -> SecIdentity {
        var query: [String: Any] = [
            kSecReturnRef as String: true,
            kSecClass as String: kSecClassIdentity,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        if let identity = configuration.identity {
            query[kSecAttrLabel as String] = identity.label
            query[kSecAttrApplicationTag as String] = identity.tag
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess || status == noErr else {
            throw KeychainError.unhandledError(status: status)
        }
        switch status {
        case errSecUserCanceled:
            throw KeychainError.biometryUserCanceled
        case errSecItemNotFound:
            throw KeychainError.noData
        case errSecAuthFailed:
            throw KeychainError.authFailed
        case noErr, errSecSuccess:
            guard let item else { throw KeychainError.noData }
            return unsafeBitCast(item, to: SecIdentity.self)
        default:
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    /// Сохранить приватный ключ
    /// - Parameters:
    ///   - key: `SecKey`
    ///   - throwIfExists: Кидать ли ошибку если данные по указанному ключу уже существуют
    /// - Throws: `KeychainError`
    public func save(_ key: SecKey, throwIfExists: Bool) throws {
        var baseQuery: [String: Any] = [
            kSecClass as String: kSecClassKey
        ]
        var attributes: [String: Any] = baseWriteQuery()
        attributes[kSecValueRef as String] = key
        if let identity = configuration.identity {
            baseQuery[kSecAttrLabel as String] = identity.label
            baseQuery[kSecAttrApplicationTag as String] = identity.tag
            baseQuery[kSecAttrKeyType as String] = identity.keyType.rawValue
        }
        var addQuery = baseQuery
        attributes.forEach { addQuery[$0.key] = $0.value }
        
        var status = SecItemAdd(addQuery as CFDictionary, nil)
        if !throwIfExists && status == errSecDuplicateItem {
            var updateQuery = baseQuery
            if let secureAccess = configuration.secureAccess {
                if let context = secureAccess.context {
                    updateQuery[kSecUseAuthenticationContext as String] = context
                }
                if let operationPrompt = secureAccess.operationPrompt {
                    updateQuery[kSecUseOperationPrompt as String] = operationPrompt
                }
            }
            status = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
        }
        guard status == errSecSuccess || status == noErr else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    /// Сохранить сертификат
    /// - Parameters:
    ///   - certificate: `SecCertificate`
    ///   - throwIfExists: Кидать ли ошибку если данные по указанному ключу уже существуют
    /// - Throws: `KeychainError`
    public func save(_ certificate: SecCertificate, throwIfExists: Bool) throws {
        var baseQuery: [String: Any] = [
            kSecClass as String: kSecClassCertificate
        ]
        var attributes: [String: Any] = baseWriteQuery()
        attributes[kSecValueRef as String] = certificate
        if let identity = configuration.identity {
            baseQuery[kSecAttrLabel as String] = identity.label
        }
        var addQuery = baseQuery
        attributes.forEach { addQuery[$0.key] = $0.value }
        
        var status = SecItemAdd(addQuery as CFDictionary, nil)
        if !throwIfExists && status == errSecDuplicateItem {
            var updateQuery = baseQuery
            if let secureAccess = configuration.secureAccess {
                if let context = secureAccess.context {
                    updateQuery[kSecUseAuthenticationContext as String] = context
                }
                if let operationPrompt = secureAccess.operationPrompt {
                    updateQuery[kSecUseOperationPrompt as String] = operationPrompt
                }
            }
            status = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
        }
        guard status == errSecSuccess || status == noErr else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    /// Удалить приватный ключ
    public func deleteKey() throws {
        guard let identity = configuration.identity else { return }
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrLabel as String: identity.label,
            kSecAttrApplicationTag as String: identity.tag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        if let accessGroup = configuration.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        try deleteItem(with: query)
    }
    
    /// Удалить сертификат
    public func deleteCerificate() throws {
        guard let identity = configuration.identity else { return }
        var query: [String: Any] = [
            kSecAttrLabel as String: identity.label,
            kSecClass as String: kSecClassCertificate,
            kSecAttrApplicationTag as String: identity.tag
        ]
        if let accessGroup = configuration.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        query[kSecClass as String] = kSecClassCertificate
        try deleteItem(with: query)
    }
    
    private func deleteItem(with query: [String: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound || status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    private func baseWriteQuery() -> [String: Any] {
        var query: [String: Any] = [:]
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
        return query
    }
}
