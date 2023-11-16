//
//  SourceTimer.swift
//

import Foundation

/// Объект таймера
final class SourceTimer: Timer {

    /// Идентификатор таймера
    let id: UUID
    /// таймер
    let timer: DispatchSourceTimer

    /// Инициализация
    /// - Parameters:
    ///   - id: Идентификатор таймера
    ///   - queue: Очередь работы таймер
    init(_ id: UUID, _ queue: DispatchQueue) {
        self.id = id
        self.timer = DispatchSource.makeTimerSource(queue: queue)
    }

    /// Настроить замыкание отмены работы таймера
    /// - Parameter handler: Замыкание отмены работы таймера
    func setCancel(_ handler: TimerHandler?) {
        timer.setCancelHandler(handler: handler)
    }

    func schedule(deadline: DispatchTime, repeating interval: DispatchTimeInterval, leeway: DispatchTimeInterval) {
        timer.schedule(deadline: deadline, repeating: interval, leeway: leeway)
    }

    func setTick(_ handler: @escaping TimerHandler) {
        timer.setEventHandler(handler: handler)
    }

    func run() {
        timer.activate()
    }

    func cancel() {
        timer.cancel()
    }

    func resume() {
        timer.resume()
    }

    func suspend() {
        timer.suspend()
    }
}

// MARK: - SourceTimer + Equatable
extension SourceTimer: Equatable {
    
    static func == (lhs: SourceTimer, rhs: SourceTimer) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - SourceTimer + Hashable
extension SourceTimer: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
