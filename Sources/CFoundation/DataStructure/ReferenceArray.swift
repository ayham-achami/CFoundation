//
//  ReferenceArray.swift
//

import Foundation

/// Массив ссылок на объектов, все ссылки слабые
public struct ReferenceArray<Element: AnyObject>: ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = Element

    /// Обложка ссылки
    struct Box<Value: AnyObject> {

        /// Слабая ссылка
        weak var value: Value?
    }

    /// Массив ссылок
    private var references: [Box<Element>] = []

    /// Инициализация
    public init() {}

    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        references = elements.map(Box.init(value:))
    }

    /// Добавить ссылку
    /// - Parameter element: Ссылка
    public mutating func append(_ element: Element) {
        guard
            !references.contains(where: { $0.value === element })
        else { return }
        references.append(.init(value: element))
    }

    /// Убрать ссылку по индексу
    /// - Parameter index: Индекс ссылки
    @discardableResult
    public mutating func remove(_ index: Int) -> Element? {
        references.remove(at: index).value
    }

    /// Убрать ссылку
    /// - Parameter element: Ссылка для удаления
    public mutating func remove(_ element: Element) {
        references.removeAll { $0.value === element }
    }

    /// Удалит все nil значения
    @discardableResult
    public mutating func cleanup() -> ReferenceArray<Element> {
        references.removeAll { $0.value == nil }
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

    public subscript(_ index: Index) -> Element? {
        references[index].value
    }
    
    public func index(after i: Int) -> Int {
        references.index(after: i)
    }
}
