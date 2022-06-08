//
//  SourceLoader.swift
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

/// Протокол описывающий структуру локальных данных
public protocol AnyResourceType {

    /// Название ресурса
    var name: String { get }
    /// Тип ресурса
    var type: String { get }
}

// MARK: - AnyResourceType + RawRepresentable
public extension AnyResourceType where Self: RawRepresentable, RawValue == String {

    var name: String { rawValue.prefix(1).capitalized + rawValue.dropFirst() }
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
        "Could not to load a local data from resources".localized
    }
}

// MARK: - Bundle + LocalData
public extension Bundle {

    /// Возвращает путь к ресурсу в локальном хранилище
    /// - Parameter Resource: Локальные данны
    /// - Throws: `LocalDataLoadingError`
    /// - Returns: Путь к ресурсу
    func path(for resource: AnyResourceType) throws -> URL {
        if let path = path(forResource: resource.name, ofType: resource.type) {
            return URL(fileURLWithPath: path)
        }
        throw SourceLoadingError()
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

/// Стандартная имплементация
public extension SourceLoader {

    func data(ofResource: AnyResourceType, bundle: Bundle = .main) throws -> Data {
        try Data(contentsOf: try bundle.path(for: ofResource), options: .mappedIfSafe)
    }

    func resource<Resource>(by resource: AnyResourceType, bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) throws -> Resource where Resource: Decodable {
        try decoder.decode(Resource.self, from: try data(ofResource: resource, bundle: bundle))
    }
}
