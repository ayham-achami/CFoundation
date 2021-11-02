//
//  TimersSource.swift
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

/// Объект источника таймеров
public class TimersSource {

    static let idKey = "CFoundation.TimersSource.idKey"

    /// Типы используемых таймеров
    public enum TimerType {

        /// таймер с использованием `DispatchSourceTimer`
        case dispatchSource
    }

    /// Источник по умолчанию
    public static var `default` = TimersSource(.dispatchSource)

    /// Тип используемого таймера
    private let timersType: TimerType
    /// Массив таймеров то, что было создано
    private var source: [SourceTimer] = []

    /// Инициализация
    /// - Parameter timersType: Тип используемого таймера
    public init(_ timersType: TimerType) {
        self.timersType = timersType
    }

    /// Создает и возвращает таймре по заданными параметрами
    /// - Parameter queue: Очередь где таймер будет выполняться
    /// - Returns: Объект таймера
    public func makeTimer(on queue: DispatchQueue = .main) -> Timer {
        switch timersType {
        case .dispatchSource:
            return dispatchSourceTimer(with: UUID(), on: queue)
        }
    }

    /// Получить таймер по его идентификатору
    /// - Parameter id: Идентификатор таймера
    /// - Returns: Объект таймера
    public func timer(at id: UUID) -> Timer? { source[id] }

    /// Создает и возвращает таймре по заданными параметрами типа `DispatchSourceTimer`
    /// - Parameters:
    ///   - id: Идентификатор таймера
    ///   - queue: Очередь где таймер будет выполняться
    /// - Returns: Объект таймера
    private func dispatchSourceTimer(with id: UUID, on queue: DispatchQueue) -> SourceTimer {
        let timer = SourceTimer(id, queue)
        timer.setCancel { [weak self] in
            self?.source.remove(with: id)
            NotificationCenter.default.post(name: .timersSourceDidReleaseTimer, object: nil, userInfo: [Self.idKey: id])
        }
        source[id] = timer
        return timer
    }
}

// MARK: - Array + SourceTimer
private extension Array where Element == SourceTimer {

    subscript(id: UUID) -> Element? {
        get {
            first(where: { $0.id == id })
        }
        set {
            if let newValue = newValue {
                if let index = firstIndex(where: { $0.id == id }) {
                    self[index] = newValue
                } else {
                    append(newValue)
                }
            } else {
                remove(with: id)
            }
        }
    }

    @discardableResult
    mutating func remove(with id: UUID) -> Element? {
        guard let index = firstIndex(where: { $0.id == id })  else { return nil }
        return remove(at: index)
    }
}

// MARK: - Notification.Name + TimersSource
public extension Notification.Name {

    /// Подписаться на уведомление о освобождении таймера
    static var timersSourceDidReleaseTimer = Notification.Name("CFoundation.TimersSource.timersSourceDidReleaseTimer")
}
