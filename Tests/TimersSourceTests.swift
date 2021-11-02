//
//  TimersSourceTests.swift
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

import XCTest
@testable import CFoundation

class TimersSourceTests: XCTestCase {
    
    var timerExpectation: XCTestExpectation?
    
    func testTimerRelease() throws {
        // given
        timerExpectation = expectation(description: "TimerTick")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReleaseTime(_:)),
                                               name: .timersSourceDidReleaseTimer,
                                               object: nil)
        let tickCount = 5
        var currentTickCount = 0
        let queue = DispatchQueue(label: "CFoundation.test.timer.queue")
        let timer = TimersSource.default.makeTimer(on: queue)
        
        // then
        print("Create timer with id: \(timer.id)")
        timer.schedule(deadline: .now(), repeating: .milliseconds(500), leeway: .never)
        timer.setTick { [weak timer] in
            currentTickCount += 1
            print("This is a timer \(currentTickCount) tick")
            if let timer = timer {
                XCTAssertNotNil(TimersSource.default.timer(at: timer.id))
            } else {
                XCTFail("The timer is nil in tick")
            }
            if currentTickCount >= tickCount { timer?.cancel() }
        }
        timer.run()
        XCTAssertNotNil(TimersSource.default.timer(at: timer.id))
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    @objc func didReleaseTime(_ notification: Notification) {
        guard let id = notification.userInfo?[TimersSource.idKey] as? UUID else {
            XCTFail("TimersSourceDidReleaseTimer userinfo not contents timer id")
            return
        }
        let timer = TimersSource.default.timer(at: id)
        XCTAssertNil(timer)
        print("Timer with id \(id) has released")
        timerExpectation?.fulfill()
    }
}
