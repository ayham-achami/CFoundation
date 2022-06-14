//
//  Queue.swift
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

/// Очередь
public struct Queue<Element> {
    
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
