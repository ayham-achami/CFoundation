//
//  PhonePatternBuilder.swift
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

/// Создает паттерн регулярного выражения из маски номера телефона
public class PhonePatternBuilder {

    public typealias PhonePattern = String

    /// Символ пласходера в маске
    private let holder: Character
    /// Маска ввода номера телефона
    private var mask: String = ""
    /// Префикс маски
    private var prefix: String = ""

    /// Инициализация
    /// - Parameter holder: Символ пласходера в маске
    public init(holder: Character) {
        self.holder = holder
    }

    /// Добавить префикс маски
    /// - Parameter prefix: Префикс маски
    public func with(prefix: String) -> PhonePatternBuilder {
        self.prefix = prefix
        return self
    }

    /// Добавить маска ввода номера телефона
    /// - Parameter mask: Маска ввода номера телефона
    public func with(mask: String) -> PhonePatternBuilder {
        self.mask = mask
        return self
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
