//
//  CFoundation.swift
//

import Foundation

/// Основой протокол любого объекта модели
public protocol Model {}

// MARK: - Bool + Model
extension Bool: Model {}

// MARK: - Int + Model
extension Int: Model {}

// MARK: - Double + Model
extension Double: Model {}

// MARK: - Float + Model
extension Float: Model {}

// MARK: - String + Model
extension String: Model {}

// MARK: - Array + Model
extension Array: Model {}

// MARK: - Dictionary + Model
extension Dictionary: Model {}

// MARK: - LinkedList + Model
extension LinkedList: Model {}

// MARK: - Queue: Model
extension Queue: Model {}

// MARK: - Data + Model
extension Data: Model {}

// MARK: - Date + Model
extension Date: Model {}
