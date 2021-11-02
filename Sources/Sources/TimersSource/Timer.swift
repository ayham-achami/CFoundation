//
//  Timer.swift
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

    /// Всстановить таймер
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
