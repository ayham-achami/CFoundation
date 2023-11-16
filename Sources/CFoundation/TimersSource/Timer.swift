//
//  Timer.swift
//

import Foundation

/// Объект таймера
public protocol Timer: AnyObject {

    typealias TimerHandler = @convention(block) () -> Void

    /// Идентификатор таймера
    var id: UUID { get }

    /// Запранровать таймер
    /// - Parameters:
    ///   - deadline: Когда начать
    ///   - interval: Период тика
    ///   - leeway: Максимальный период времени после deadline, на который система может отложить доставку события таймера.
    func schedule(deadline: DispatchTime, repeating interval: DispatchTimeInterval, leeway: DispatchTimeInterval)

    /// Что делать при тике
    /// - Parameter handler: Замыкание тика
    func setTick(_ handler: @escaping Self.TimerHandler)

    /// Запустить таймер
    func run()

    /// Отменить таймер
    func cancel()

    /// Восстановить таймер
    func resume()

    /// Остановить таймер
    func suspend()
}

// MARK: Timer + Default
public extension Timer {

    /// Запранровать таймер
    /// - Parameters:
    ///   - deadline: Когда начать
    ///   - interval: Период тика
    ///   - leeway: Максимальный период времени после deadline, на который система может отложить доставку события таймера.
    func scheduleTick(deadline: DispatchTime,
                      repeating interval: DispatchTimeInterval = .never,
                      leeway: DispatchTimeInterval = .nanoseconds(0)) {
        schedule(deadline: deadline, repeating: interval, leeway: leeway)
    }
}
