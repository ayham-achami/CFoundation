//
//  Protected.swift
//

import Foundation

/// Протокол блокировки доступа (Синхронизации значения)
public protocol Lock: Sendable {
    
    /// Блокировка
    func lock()
    
    /// Разблокировка
    func unlock()
}

public extension Lock {
    
    /// Выполняет замыкание, возвращая значение и синхронизировать обращение.
    /// - Parameter closure: Замыкание
    /// - Returns: Нужное значение
    func around<T>(_ closure: @Sendable () -> T) -> T {
        lock()
        defer { unlock() }
        return closure()
    }
}

/// `os_unfair_lock` Wrapper
public final class UnfairLock: Lock {

    private let unfairLock: os_unfair_lock_t

    public init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}

/// Потокобезопасная оболочка значения.
@propertyWrapper
@dynamicMemberLookup
public final class Protected<T>: @unchecked Sendable {

    private var value: T
    private let lock = UnfairLock()

    /// The contained value. Unsafe for anything more than direct read or write.
    public var wrappedValue: T {
        get {
            lock.around { value }
        }
        set {
            lock.around { value = newValue }
        }
    }

    public var projectedValue: Protected<T> { self }

    public subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get {
            lock.around { value[keyPath: keyPath] }
        }
        set {
            lock.around { value[keyPath: keyPath] = newValue }
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public init(wrappedValue: T) {
        value = wrappedValue
    }

    /// Синхронно прочитать или преобразовать содержащееся значение.
    /// - Parameter closure: Замыкание
    /// - Returns: Нужное значение
    public func read<U>(_ closure: @Sendable (T) -> U) -> U {
        lock.around { closure(self.value) }
    }
    
    /// Синхронно изменить защищенное значение.
    /// - Parameter closure: Замыкание
    /// - Returns: Нужное значение
    @discardableResult
    public func write<U>(_ closure: @Sendable (inout T) -> U) -> U {
        lock.around { closure(&self.value) }
    }
}

// MARK: - Protected + RangeReplaceableCollection
public extension Protected where T: RangeReplaceableCollection {
    
    /// Добавляет новый элемент в конец этой защищенной коллекции.
    /// - Parameter newElement: Новый элемент
    func append(_ newElement: T.Element) {
        write { (ward: inout T) in
            ward.append(newElement)
        }
    }

    /// Добавляет элементы последовательности в конец этой защищенной коллекции.
    /// - Parameter newElements: Новые элементы
    func append<S>(contentsOf newElements: S) where S: Sequence, S.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }

    /// Добавьте элементы коллекции в конец защищенной коллекции.
    /// - Parameter newElements: Новые элементы
    func append<C>(contentsOf newElements: C) where C: Collection, C.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }
}

// MARK: - Protected + Data
public extension Protected where T == Data? {
    
    /// Добавляет содержимое значения Data в конец защищенных Data.
    /// - Parameter data: Новые данные
    func append(_ data: Data) {
        write { (ward: inout T) in
            ward?.append(data)
        }
    }
}
