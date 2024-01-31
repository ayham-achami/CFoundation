//
//  Logger.swift
//

import Foundation
import os

/// Объект логирования
public final class Logger {

    /// контроль уровня логирования
    ///
    /// - debug:   логирование рзаршено
    /// - release: логирование запрещено
    public enum Level: String {

        case debug
        case release
    }

    /// уровня логирования
    ///
    /// - debug: дебаг
    /// - error: ошибка
    /// - warning: предупреждение
    /// - info: информационный
    public enum LogLevel: String {

        case debug = " ✅ "
        case error = " ⛔️ "
        case warning = " ⚠️ "
        case info = " ℹ️ "

        fileprivate var name: String {
            "\(self)".uppercased()
        }

        fileprivate var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .error:
                return .error
            case .info:
                return .info
            case .warning:
                return .default
            }
        }
    }
    
    /// Формирование файла логов
    ///
    /// - url: URL - ссылка на файл, куда записываются логи
    /// - levels: LogLevel - массив уровней логирования
    public struct LogFile {
        
        public let url: URL
        public let levels: [LogLevel]
        
        public init(url: URL, levels: [LogLevel] = [.error]) {
            self.url = url
            self.levels = levels
        }
    }
    
    /// регулирует название уровня лога использовать прямое название или эмоции (*_*)
    private let useEmoji: Bool
    
    /// уровень логирования
    private let level: Level
    
    /// формирование файла логов
    private let logFile: LogFile?
    
    /// Объектно-ориентированная оболочка для файлового дескриптора.
    private let fileHandler: FileHandle?
    
    /// 50 Mb free space
    private let maxFreeSpace: UInt64 = 50 * 1024 * 1024
    
    /// максимальный размер файла лога
    private let maxFileLogSize: UInt64 = 50 * 1024 * 1024
    
    /// минмальный размер файла лога
    private let minFileLogSize: UInt64 = 1024
    
    /// Очередь для записи в файл
    private let logFileQueue = DispatchQueue(label: "CFoundation.Async.FileLog.Queue")
    
    /// инициализирует объект логирования
    ///
    /// - returns: инстенс `Logger`
    public init(level: Level = .debug, useEmoji: Bool = true, logFile: LogFile? = nil) {
        self.level = level
        self.useEmoji = useEmoji
        self.logFile = logFile
        
        if let logFile = logFile {
            if !FileManager.default.fileExists(atPath: logFile.url.path) {
                FileManager.default.createFile(atPath: logFile.url.path, contents: nil)
            }
            self.fileHandler = FileHandle(forWritingAtPath: logFile.url.path)
        } else {
            fileHandler = nil
        }
    }
    
    deinit {
        fileHandler?.closeFile()
    }
    
    /// Вывод сообщения уровня дибаг
    ///
    /// - Parameters:
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func debug(_ message: @autoclosure () -> Any,
                      _ file: StaticString = #file,
                      _ function: StaticString = #function,
                      _ line: Int = #line) {
        log(.debug, "Logger", message(), file, function, line)
    }

    /// Вывод сообщения уровня дибаг
    ///
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func debug(with tag: String = "Debug",
                      _ message: @autoclosure () -> Any,
                      _ file: StaticString = #file,
                      _ function: StaticString = #function,
                      _ line: Int = #line) {
        log(.debug, tag, message(), file, function, line)
    }

    /// Вывод сообщения уровня ошбики
    ///
    /// - Parameters:
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func error(_ message: @autoclosure () -> Any,
                      _ file: StaticString = #file,
                      _ function: StaticString = #function,
                      _ line: Int = #line) {
        log(.error, "Logger", message(), file, function, line)
    }
    
    /// Вывод сообщения уровня ошбики
    ///
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func error(with tag: String = "Error",
                      _ message: @autoclosure () -> Any,
                      _ file: StaticString = #file,
                      _ function: StaticString = #function,
                      _ line: Int = #line) {
        log(.error, tag, message(), file, function, line)
    }

    /// Вывод сообщения уровня предупреждение
    ///
    /// - Parameters:
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func warning(_ message: @autoclosure () -> Any,
                        _ file: StaticString = #file,
                        _ function: StaticString = #function,
                        _ line: Int = #line) {
        log(.warning, "Logger", message(), file, function, line)
    }

    /// Вывод сообщения уровня предупреждение
    ///
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func warning(with tag: String = "Warning",
                        _ message: @autoclosure () -> Any,
                        _ file: StaticString = #file,
                        _ function: StaticString = #function,
                        _ line: Int = #line) {
        log(.warning, tag, message(), file, function, line)
    }

    /// Вывод сообщения уровня информации
    ///
    /// - Parameters:
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func info(_ message: @autoclosure () -> Any,
                     _ file: StaticString = #file,
                     _ function: StaticString = #function,
                     _ line: Int = #line) {
        log(.info, "Logger", message(), file, function, line)
    }
    
    /// Вывод сообщения уровня информации
    ///
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func info(with tag: String = "info",
                     _ message: @autoclosure () -> Any,
                     _ file: StaticString = #file,
                     _ function: StaticString = #function,
                     _ line: Int = #line) {
        log(.info, tag, message(), file, function, line)
    }
    
    /// Вывод JSON уровня информации дибаг
    /// - Parameters:
    ///   - data: `Data` JSON
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func json(_ data: Data,
                     _ file: StaticString = #file,
                     _ function: StaticString = #function,
                     _ line: Int = #line) {
        guard level == .debug else { return }
        log(.debug, "Logger", data.prettyPrintedJSONString, file, function, line)
    }

    /// Вывод JSON уровня информации дибаг
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - data: `Data` JSON
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    public func json(with tag: String = "JSONDebug",
                     _ data: Data,
                     _ file: StaticString = #file,
                     _ function: StaticString = #function,
                     _ line: Int = #line) {
        guard level == .debug else { return }
        log(.debug, tag, data.prettyPrintedJSONString, file, function, line)
    }
    
    /// returns the filename of a path
    private func fileNameFromPath(_ path: StaticString) -> String {
        guard let lastPart = path.description.components(separatedBy: "/").last else { return "" }
        return lastPart
    }

    /// Вывод любого сообщение любого уровня
    ///
    /// - Parameters:
    ///   - tag: таг сообщения для фильтрации
    ///   - message: сообщение для вывода в консоле
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    private func log(_ level: LogLevel,
                     _ tag: String,
                     _ message: @autoclosure () -> Any,
                     _ file: StaticString,
                     _ function: StaticString,
                     _ line: Int) {
        guard let messageArg = message() as? CVarArg  else { return }
        let messageString = "\(messageArg)"
        let fileName = self.fileNameFromPath(file)
        let levelName = self.useEmoji ? level.rawValue : level.name
        
        logFileQueue.sync { [weak self] in
            let reportFile: String = .init(format: "%@ %@ - [%@:%d %@]: {\n\t %@ \n}\n",
                                           tag,
                                           levelName,
                                           fileName,
                                           line,
                                           function.description,
                                           messageString)
            self?.logToFileIfPresent(log: reportFile, level: level)
        }
        
        guard self.level == .debug else { return }
        let log = OSLog(subsystem: String(describing: type(of: self)), category: tag)
        os_log("%{public}s - [%{public}s:%d %{public}s]: {\n\t %{public}@ \n}",
               log: log,
               type: level.osLogType,
               levelName, fileName, line, function.description, messageString)
    }
    
    private func logToFileIfPresent(log: String, level: LogLevel) {
        guard let fileHandler = self.fileHandler,
              let logFile = self.logFile, logFile.levels.contains(level),
              var reportFile = log.data(using: .utf8)
        else { return }
        
        let printError: (String) -> Void = { str in
            if level == .debug {
                let log = OSLog(subsystem: String(describing: type(of: self)), category: "Logger")
                let levelName = self.useEmoji ? level.rawValue : level.name
                os_log("%{public}s - [%{public}s:%d %{public}s]: {\n\t %{public}@ \n}",
                       log: log,
                       type: level.osLogType,
                       levelName, str)
            }
        }
    
        let fileOffset = fileHandler.seekToEndOfFile()
        // проверяем есть ли вообще место для  записи
        let keys = Set<URLResourceKey>([.volumeAvailableCapacityForImportantUsageKey])
        let home = URL(fileURLWithPath: NSHomeDirectory() as String)
        guard
            let space = try? home.resourceValues(forKeys: keys).volumeAvailableCapacityForImportantUsage
        else  { printError("Error in record to log file: cant calculate free disk space"); return }
        if fileOffset < minFileLogSize, space < maxFreeSpace + minFileLogSize {
            printError("Not enough disk space for logs")
            return
        }
        let uSpace = UInt64(space)
        // можем писать.
        // не хватает размера файла, поэтому отсекаем  от него часть.
        // контент больше чем размер записываемого файла, поэтому берем только часть данных
        // при этом учитываем, что выделяемого под лог может быть меньше
        
        // вычисляем максимальный размер файла который может быть доступен.
        let maxFileSize = fileOffset + min(UInt64(max(0, Int64(maxFileLogSize) - Int64(fileOffset))), uSpace - maxFreeSpace)

        // если число записываемых данных больше чем макс размер лога, то оффсет в 0 и обрезаем записываемые данные
        if reportFile.count > maxFileSize {
            reportFile = reportFile.dropLast(Int(Int64(reportFile.count) - Int64(maxFileSize)))
            fileHandler.truncateFile(atOffset: 0)
            fileHandler.seek(toFileOffset: 0)
        } else if UInt64(reportFile.count) + fileOffset > maxFileSize {
            // если не влезаем в ограничения по размеру файла, то усекаем файл в начале
            fileHandler.truncateFile(atOffset: max(0, maxFileSize - UInt64(reportFile.count)))
            fileHandler.seekToEndOfFile()
        }
        fileHandler.write(reportFile)
    }
}

/// тип с настраиваемым текстовым представлением для логирования
public protocol CustomLogStringConvertible {

    /// преобразование в строку для логирования
    var logDescription: String { get }
}

// MARK: - Logger
extension Logger {

    /// Вывод сообщения уровня дибаг
    ///
    /// - Parameters:
    ///   - convertible: текст для логирования
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    func debug(convertible: CustomLogStringConvertible,
               _ file: StaticString = #file,
               _ function: StaticString = #function,
               _ line: Int = #line) {
        debug(convertible.logDescription, file, function, line)
    }

    /// Вывод сообщения уровня ошибки
    ///
    /// - Parameters:
    ///   - convertible: текст для логирования
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    func error(convertible: CustomLogStringConvertible,
               _ file: StaticString = #file,
               _ function: StaticString = #function,
               _ line: Int = #line) {
        error(convertible.logDescription, file, function, line)
    }

    /// Вывод сообщения уровня информации
    ///
    /// - Parameters:
    ///   - convertible: текст для логирования
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    func info(convertible: CustomLogStringConvertible,
              _ file: StaticString = #file,
              _ function: StaticString = #function,
              _ line: Int = #line) {
        info(convertible.logDescription, file, function, line)
    }

    /// Вывод сообщения уровня предупреждение
    ///
    /// - Parameters:
    ///   - convertible: текст для логирования
    ///   - file: название файла
    ///   - function: название функции или метода
    ///   - line: номер строки
    func warning(convertible: CustomLogStringConvertible,
                 _ file: StaticString = #file,
                 _ function: StaticString = #function,
                 _ line: Int = #line) {
        warning(convertible.logDescription, file, function, line)
    }
}

// MARK: - Data + PrettyPrinted
private extension Data {
    
    /// Преобразует `Data` в JSON
    var prettyPrintedJSONString: String {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return "" }
        return prettyPrintedString
    }
}
