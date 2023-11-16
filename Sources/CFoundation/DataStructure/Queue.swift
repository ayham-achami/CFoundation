//
//  Queue.swift
//

import Foundation

/// Очередь
@frozen public struct Queue<Element> {
    
    /// Связный список
    fileprivate var list = LinkedList<Element>()
    
    /// Пустая ли очередь
    public var isEmpty: Bool {
        list.isEmpty
    }
    
    /// Количество элементов в списке
    public var count: Int {
        list.count
    }
    
    /// Инициализация
    public init() {}
    
    /// Добавить элемент к очереди
    /// - Parameter element: Элемент для добавления
    public mutating func enqueue(_ element: Element) {
        list.append(element)
    }
    
    /// Исключить элемент из очереди, если очередь пустая то возвращается nil
    /// - Returns: Исключенный элемент
    public mutating func dequeue() -> Element? {
        guard !list.isEmpty, let element = list.head else { return nil }
        list.remove(element)
        return element.value
    }
    
    public func peek() -> Element? {
        list.first
    }
}

// MARK: - Queue + Sequence
extension Queue: Sequence {
    
    public func makeIterator() -> some IteratorProtocol {
        list.makeIterator()
    }
}

// MARK: - LinkedList + Codable
extension Queue: Codable where Element: Codable {
    
    public init(from decoder: Decoder) throws {
        self.list = try .init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try list.encode(to: encoder)
    }
}

// MARK: - Queue + CustomStringConvertible
extension Queue: CustomStringConvertible {

    public var description: String {
        list.description
    }
}
