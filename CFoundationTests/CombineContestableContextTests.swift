//
//  CombineContestableContextTests.swift
//

@testable import CFoundation
import Combine
import XCTest

@globalActor public actor SomeActor {
    
    public static var shared = SomeActor()
    
    private init() {}
}

final class CombineContestableContextTests: XCTestCase {

    actor Service {
        
        private let group = DispatchGroup()
        private let subject = PassthroughSubject<Int, Never>()
        
        nonisolated func subscribe() -> AnyPublisher<Int, Never> {
            subject.eraseToAnyPublisher()
        }
        
        func run() async {
            await withTaskGroup(of: Void.self) { group in
                (1...10).forEach { int in
                    group.addTask {
                        self.subject.send(int)
                    }
                }
            }
        }
    }

    actor ActorObject {
        
        private let service: Service
        private let subscriptions = SubscriptionsStorage()
        private let subject = PassthroughSubject<Int, Never>()
        
        init(service: Service) {
            self.service = service
            self.service.subscribe().sink(subscriptions) { [weak self] int in
                print(int)
                self?.subject.send(int)
            }
            self.service.subscribe().sink(subscriptions) { int in
                print(int)
            }
        }
        
        nonisolated func subscribe() -> AnyPublisher<Int, Never> {
            subject.eraseToAnyPublisher()
        }
        
        func assert() {
            XCTAssertEqual(subscriptions.count, 2)
        }
    }
    
    @SomeActor
    final class ClassObject {
        
        private let actorObject: ActorObject
        private var subscriptions: SubscriptionsStorage = .init()
        
        nonisolated init(actorObject: ActorObject) {
            self.actorObject = actorObject
            self.actorObject.subscribe().sink(subscriptions) { int in
                print(int)
            }
            self.actorObject.subscribe().sink(subscriptions) { int in
                print(int)
            }
        }
        
        func assert() {
            XCTAssertEqual(subscriptions.count, 2)
        }
    }
    
    func testActorObject() async {
        let service = Service()
        let objcet = ActorObject(service: service)
        await service.run()
        await objcet.assert()
    }
    
    func testClassActorObject() async {
        let service = Service()
        let actorObjcet = ActorObject(service: service)
        let classObject = ClassObject(actorObject: actorObjcet)
        await service.run()
        await actorObjcet.assert()
        await classObject.assert()
    }
}
