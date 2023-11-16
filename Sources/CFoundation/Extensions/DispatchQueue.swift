//
//  DispatchQueue.swift
//

import Foundation

// MARK: - DispatchQueue
public extension DispatchQueue {

    /// Выполнять задачу отложено
    /// - Parameters:
    ///   - deadline: Задержка выполнения
    ///   - block: Задача
    func asyncAfter(deadline: DispatchTimeInterval,
                    _ block: @escaping @convention(block) () -> Void) -> DispatchWorkItem {
        let workItem = DispatchWorkItem(block: block)
        asyncAfter(deadline: .now() + deadline, execute: workItem)
        return workItem
    }
}
