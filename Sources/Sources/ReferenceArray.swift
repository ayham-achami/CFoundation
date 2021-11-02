//
//  ReferenceArray.swift
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

/// Массив ссылок на объектов, все ссылки слабые
public struct ReferenceArray<Element: AnyObject>: ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = Element

    /// Обложка ссылки
    struct Box<Element: AnyObject> {

        /// Слабая ссылка
        weak var element: Element?
    }

    /// Массив обложк ссылак
    private var references: [Box<Element>] = []

    /// Инициализация
    public init() {}

    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        references = elements.map(Box.init(element:))
    }

    /// Добваить ссылку
    /// - Parameter element: Ссылка
    public mutating func append(_ element: Element) {
        guard !references.contains(where: { $0.element === element }) else { return }
        references.append(Box(element: element))
    }

    /// Убрать ссылку по индиксу
    /// - Parameter index: Индекс ссылки
    @discardableResult
    public mutating func remove(_ index: Int) -> Element? {
        references.remove(at: index).element
    }

    /// Убрать ссылку
    /// - Parameter element: Ссылка для удаления
    public mutating func remove(_ element: Element) {
        references.removeAll { $0.element === element }
    }

    /// Удалит все nil значения
    @discardableResult
    public mutating func cleanup() -> ReferenceArray<Element> {
        references.removeAll { $0.element == nil }
        return self
    }
}

// MARK: - ReferenceArray + Collection
extension ReferenceArray: Collection {

    public typealias Index = Int

    public var startIndex: Int {
        references.startIndex
    }

    public var endIndex: Int {
        references.endIndex
    }

    public func index(after i: Int) -> Int {
        references.index(after: i)
    }

    public subscript(_ index: Index) -> Element? {
        references[index].element
    }
}
