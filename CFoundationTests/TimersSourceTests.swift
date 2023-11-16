//
//  TimersSourceTests.swift
//

@testable import CFoundation
import XCTest

final class TimersSourceTests: XCTestCase {
    
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
