//
//  DelaySearchPerformer.swift
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

/// Делегат объект реализующий логику поиска с задержкой
public protocol DelaySearchPerformerDelegate: AnyObject {

    /// Вызывается когда необходимо выполнять поиск
    /// - Parameters:
    ///   - performer: Объект вызывающий
    ///   - search: Объект поиска
    func delaySearchPerformer<Searched>(_ performer: DelaySearchPerformer<Searched>, didPerformSearch search: Searched)
}

/// Объект реализующий логику поиска с задержкой
public class DelaySearchPerformer<Searched> {

    /// Задержка поиска
    public let delay: DispatchTimeInterval
    /// Делегат поиска
    public weak var delegate: DelaySearchPerformerDelegate?

    /// Очередь поиска
    private let searchQueue: DispatchQueue
    /// Управление поиска
    private var searchItem: DispatchWorkItem?

    /// Инициализация
    /// - Parameters:
    ///   - initail: Начальное значение поиска
    ///   - delay: Задержка поиска
    ///   - delegate: Делегат поиска
    ///   - searchQueue: Очередь поиска
    public init(initial: Searched? = nil,
                delay: DispatchTimeInterval = .milliseconds(500),
                delegate: DelaySearchPerformerDelegate? = nil,
                searchQueue: DispatchQueue = .main) {
        self.delay = delay
        self.delegate = delegate
        self.searchQueue = searchQueue
        guard let initial = initial else { return }
        searchQueue.async { [weak self]  in self?.prepareSearch(initial) }
    }

    /// Выполнять поиск по заданному параметру
    /// - Parameter search: Объект поиска
    public func prepareSearch(_ search: Searched) {
        searchItem?.cancel()
        searchItem = searchQueue.asyncAfter(deadline: delay) { [weak self] in
            guard let self = self else { return }
            self.delegate?.delaySearchPerformer(self, didPerformSearch: search)
        }
    }
}
