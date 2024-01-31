//
//  String.swift
//

import Foundation

// MARK: - String
public extension String {
 
    /// Проверить является ли строка действительным номером телефона
    ///
    /// - Parameters:
    ///   - prefix: код страны без + например 7
    ///   - holder: символ занимающий места цифры в маске например #
    ///   - mask: маска ввода на пример (###)###-##-##
    /// - Returns: true если строка действительным номером телефона иначе false
    func isValidPhoneNumber(holder: Character, prefix: String, mask: String) -> Bool {
        guard let pattern = try? PhonePatternBuilder(holder: holder)
            .with(prefix: prefix)
            .with(mask: mask)
            .build() else { return false }
        return range(of: pattern, options: .regularExpression) != nil
    }
}
