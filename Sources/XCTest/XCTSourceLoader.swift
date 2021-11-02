//
//  XCTSourceLoader.swift
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

/// Протокол используется исключительно для написания тестов
public protocol XCTSourceLoader {

    /// Функция, использующаяся для декодирования объектов при написании тестов
    /// - Parameters:
    ///   - resource: Локальные данные от ресурса, требующего декодирование
    ///   - bundle: Объект хранилища
    static func XCTResource<Resource>(by resource: AnyResourceType,
                                      bundle: Bundle, decoder: JSONDecoder) -> Resource where Resource: Decodable
}

/// Структура загрузки/декодирования из локального ресурса
struct Loader: SourceLoader {}

public extension XCTSourceLoader {
    /// Стандартная имплементация протокольной функции
    static func XCTResource<Resource>(by resource: AnyResourceType, bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) -> Resource where Resource: Decodable {
        do {
            return try Loader().resource(by: resource, bundle: bundle, decoder: decoder)
        } catch {
            preconditionFailure("Could not load resource error: \(error)")
        }
    }
}
