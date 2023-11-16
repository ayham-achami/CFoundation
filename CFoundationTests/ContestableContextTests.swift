//
//  ContestableContextTests.swift
//

@testable import CFoundation
import Combine
import XCTest

final class ContestableContextTests: XCTestCase {
    
    private let range = (1...10)
    private lazy var values = range.map { value in AnyCancellable { print(value) } }
    
    @ContestableContext
    var subscriptions: SubscriptionsStorage = .init()
    
    func testContestableContext() {
        let group = DispatchGroup()
        let expect = expectation(description: "all async assertions are complete")
        for _ in range {
            let cancellable = values.removeFirst()
            DispatchQueue.global().async(group: group) { [weak self] in
                guard let self else { return }
                self.$subscriptions.store(cancellable)
                XCTAssertTrue(self.$subscriptions.contains(cancellable))
                DispatchQueue.global().async(group: group) { [weak self] in
                    guard let self else { return }
                    XCTAssertTrue(self.$subscriptions.contains(cancellable))
                    cancellable.cancel()
                    self.$subscriptions.remove(cancellable)
                    XCTAssertFalse(self.$subscriptions.contains(cancellable))
                }
            }
        }
        group.notify(queue: .main) {
            XCTAssertTrue(self.$subscriptions.isEmpty)
            expect.fulfill()
        }
         wait(for: [expect], timeout: 30)
    }
}
