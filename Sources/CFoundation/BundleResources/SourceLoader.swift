//
//  SourceLoader.swift
//

import Foundation

/// Протокол описывающий структуру локальных данных
public protocol AnyResourceType {

    /// Название ресурса
    var name: String { get }
    /// Тип ресурса
    var type: String { get }
}

// MARK: - AnyResourceType + RawRepresentable
public extension AnyResourceType where Self: RawRepresentable, RawValue == String {

    var name: String {
        rawValue.prefix(1).capitalized + rawValue.dropFirst()
    }
}

/// Протокол для создания enum, содержащем в себе имя json модели
public protocol JSONResource: AnyResourceType {}

// MARK: - JSONResource + Default
public extension JSONResource {

    /// Расширение файла, требующего декодирования
    var type: String { "json" }
}

/// Объект, содержащий ошибки
public struct SourceLoadingError: LocalizedError {

    /// Ошибка загрузки JSON файла
    public var errorDescription: String {
        NSLocalizedString("Could not to load a local data from resources", comment: "Could not to load a local data from resources")
    }
}

// MARK: - Bundle + LocalData
public extension Bundle {

    /// Возвращает путь к ресурсу в локальном хранилище
    /// - Parameter Resource: Локальные данны
    /// - Throws: `LocalDataLoadingError`
    /// - Returns: Путь к ресурсу
    func path(for resource: AnyResourceType) throws -> URL {
        guard
            let path = path(forResource: resource.name, ofType: resource.type)
        else { throw SourceLoadingError() }
        return URL(fileURLWithPath: path)
    }
}

/// Протокол загрузки/декодирования из локального ресурса
public protocol SourceLoader {

    /// Функция возвращает дату по локальному ресурсу
    /// - Parameters:
    ///   - ofResource: Название и расширение файла, требующего декодирования
    ///   - bundle: Хранилище
    /// - Returns: Возвращает объект типа 'Data'
    func data(ofResource: AnyResourceType, bundle: Bundle) throws -> Data

    /// Функция декодирования модели из JSON
    /// - Parameters:
    ///   - resource: Название и расширение файла, требующего декодирования
    ///   - bundle: Хранилище
    /// - Returns: Generic объект
    func resource<Resource>(by resource: AnyResourceType, bundle: Bundle, decoder: JSONDecoder) throws -> Resource where Resource: Decodable
}

// MARK: - SourceLoader + Default
public extension SourceLoader {

    func data(ofResource: AnyResourceType, bundle: Bundle = .main) throws -> Data {
        try Data(contentsOf: try bundle.path(for: ofResource), options: .mappedIfSafe)
    }

    func resource<Resource>(by resource: AnyResourceType, bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) throws -> Resource where Resource: Decodable {
        try decoder.decode(Resource.self, from: try data(ofResource: resource, bundle: bundle))
    }
}
