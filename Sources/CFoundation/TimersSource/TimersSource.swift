//
//  TimersSource.swift
//

import Combine
import Foundation

/// Объект источника таймеров
public final class TimersSource {

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
    
    /// Субъект отмены таймера
    private let cancelSubject = PassthroughSubject<UUID, Never>()

    /// Инициализация
    /// - Parameter timersType: Тип используемого таймера
    public init(_ timersType: TimerType) {
        self.timersType = timersType
    }

    /// Создает и возвращает таймер по заданными параметрами
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
    public func timer(at id: UUID) -> Timer? {
        source[id]
    }
    
    /// Подписаться на освобождении (отмена) таймера
    /// - Parameter id: Идентификатор таймера
    /// - Returns: `AnyPublisher<UUID, Never>`
    public func subscribeTimeCanceled(with id: UUID) -> AnyPublisher<UUID, Never> {
        cancelSubject.filter { $0 == id }.eraseToAnyPublisher()
    }

    /// Создает и возвращает таймер по заданными параметрами типа `DispatchSourceTimer`
    /// - Parameters:
    ///   - id: Идентификатор таймера
    ///   - queue: Очередь где таймер будет выполняться
    /// - Returns: Объект таймера
    private func dispatchSourceTimer(with id: UUID, on queue: DispatchQueue) -> SourceTimer {
        let timer = SourceTimer(id, queue)
        timer.setCancel { [weak self] in
            self?.source.remove(with: id)
            self?.cancelSubject.send(id)
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
        guard
            let index = firstIndex(where: { $0.id == id })
        else { return nil }
        return remove(at: index)
    }
}

// MARK: - Notification.Name + TimersSource
public extension Notification.Name {

    /// Подписаться на уведомление о освобождении таймера
    static var timersSourceDidReleaseTimer = Notification.Name("CFoundation.TimersSource.timersSourceDidReleaseTimer")
}
