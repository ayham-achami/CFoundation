//
//  LinkedList.swift
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

/// Связный двунаправленный список
public struct LinkedList<Element> {
    
    /// Узел между элементами
    public class Node<Element> {
        
        /// Значение узла
        public private(set) var value: Element
        
        /// Следующий узел
        fileprivate var next: Node<Element>?
        
        /// Предыдущий узел
        fileprivate var previous: Node<Element>?
        
        /// Инициализация
        /// - Parameter value: Значение узла
        public init(value: Element) {
            self.value = value
        }
    }
    
    /// Тип, который выдает значения последовательности по одному.
    public struct Iterator: IteratorProtocol {
        
        private var node: Node<Element>?
        
        /// Инициализация
        /// - Parameter list: Звязный список
        public init(head: Node<Element>?) {
            self.node = head
        }
        
        public mutating func next() -> Element? {
            defer { node = node?.next }
            return node?.value
        }
    }
    
    /// Самый первый элемент списка
    public private(set) var head: Node<Element>?
    
    /// Самый крайний элемент списка
    public private(set) var tail: Node<Element>?
    
    /// Количество элементов в списке
    public private(set) var count: Int = 0
    
    /// Пустой ли список
    public var isEmpty: Bool {
        head == nil
    }
    
    /// Первый элемент списка
    public var first: Element? {
        head?.value
    }
    
    /// Последный элемент списка
    public var last: Element? {
        tail?.value
    }
    
    /// Инициализация
    public init() {}
    
    /// Добавить элемент к списку
    /// - Parameter value: Элемент для добавления
    public mutating func append(_ value: Element) {
        let newNode = Node(value: value)
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
        count += 1
    }
    
    /// Удалить элемент из списка
    /// - Parameter node: Узел элемента
    /// - Returns: Удаленный элемент
    @discardableResult public mutating func remove(_ node: Node<Element>) -> Element {
        let prev = node.previous
        let next = node.next
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        if next == nil {
            tail = prev
        }
        node.previous = nil
        node.next = nil
        if count > .zero {
            count -= 1
        }
        return node.value
    }
}

// MARK: - LinkedList + Sequence
extension LinkedList: Sequence {
        
    public func makeIterator() -> Iterator {
        Iterator(head: self.head)
    }
}

// MARK: - LinkedList + Codable
extension LinkedList: Codable where Element: Codable {
    
    @inlinable public init(from decoder: Decoder) throws {
        self.init()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let element = try container.decode(Element.self)
            self.append(element)
        }
    }
    
    @inlinable public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element)
        }
    }
}

// MARK: - LinkedList + CustomStringConvertible
extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        map { $0 }.description
    }
}
