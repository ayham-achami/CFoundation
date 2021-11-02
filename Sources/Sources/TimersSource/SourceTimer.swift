//
//  SourceTimer.swift
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
class SourceTimer: Timer, Hashable {

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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SourceTimer, rhs: SourceTimer) -> Bool {
        lhs.id == rhs.id
    }
}
