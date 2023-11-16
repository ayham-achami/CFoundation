//
//  DelaySearchPerformer.swift
//

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
