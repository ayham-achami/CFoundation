//
//  PhonePatternBuilder.swift
//

import Foundation

/// Создает паттерн регулярного выражения из маски номера телефона
@frozen public struct PhonePatternBuilder: Sendable {

    public typealias PhonePattern = String

    /// Символ пласходера в маске
    private let holder: Character
    /// Маска ввода номера телефона
    private let mask: String
    /// Префикс маски
    private let prefix: String

    /// Инициализация
    /// - Parameter holder: Символ пласходера в маске
    /// - Parameter mask: Маска ввода номера телефона
    /// - Parameter prefix: Префикс маски
    public init(holder: Character, mask: String, prefix: String) {
        self.holder = holder
        self.mask = mask
        self.prefix = prefix
    }

    /// Добавить префикс маски
    /// - Parameter prefix: Префикс маски
    public func with(prefix: String) -> PhonePatternBuilder {
        .init(holder: holder, mask: mask, prefix: prefix)
    }

    /// Добавить маска ввода номера телефона
    /// - Parameter mask: Маска ввода номера телефона
    public func with(mask: String) -> PhonePatternBuilder {
        .init(holder: holder, mask: mask, prefix: prefix)
    }

    /// Создает и возвращает паттерн регулярного выражения из маски номера телефона
    public func build() throws -> PhonePattern {
        var source = [String]()
        var index: Int = 0
        mask.forEach {
            if $0 == holder {
                index += 1
            } else if index == 0 && !$0.isNumber {
                source.append(String($0))
            } else if index > 0 {
                source.append(String(index))
                source.append(String($0))
                index = 0
            } else if $0 == " " {
                source.append(String($0))
            }
        }
        source.append(String(index))
        // ^(\+7)?[\s\-]?\([0-9]{3}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$
        // ^(\+7)?[\s\-]?\([0-9]{3}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$
        // ^(\\+7)?[\\s\\-]?\\([0-9]{3}\\)?[\\s\\-]?[0-9]{3}[\\s\\-]?[0-9]{2}[\\s\\-]?[0-9]{2}
        var patternBuffer = ""
        patternBuffer += #"^(\+"#
        patternBuffer += prefix
        patternBuffer += ")?"
        patternBuffer += #"[\s\-]?"#
        source.forEach {
            if $0.isOnlyIntegers {
                patternBuffer += "[0-9]{"
                patternBuffer += $0
                patternBuffer += "}"
            } else if $0 == "(" {
                patternBuffer += "\\\($0)"
            } else if $0 == ")" {
                patternBuffer += #"\"#
                patternBuffer += $0
                patternBuffer += #"?[\s\-]?"#
            } else if $0 == "-" {
                patternBuffer += #"[\s\"#
                patternBuffer += $0
                patternBuffer += "]?"
            }
        }
        return patternBuffer + "$"
    }
}

// MARK: - String + Integers
private extension String {

    /// только целые числа
    var isOnlyIntegers: Bool {
        let integerRegEx = "^[0-9]+$"
        let integerTest = NSPredicate(format: "SELF MATCHES %@", integerRegEx)
        return integerTest.evaluate(with: self)
    }
}
