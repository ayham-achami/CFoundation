//
//  CombineContestableContextTests.swift
//

@testable import CFoundation
import XCTest

final class CombineContestableContextTests: XCTestCase {

    @ContestableContext
    var subscriptions: SubscriptionsStorage = .init()
    
    func testContestableSink() {
        let expect = expectation(description: "all async assertions are complete")
        (1...10).publisher.sink($subscriptions) { completion in
            guard completion == .finished else { return }
            expect.fulfill()
        } receiveValue: { element in
            print(element)
        }
        wait(for: [expect], timeout: 30)
    }
}
