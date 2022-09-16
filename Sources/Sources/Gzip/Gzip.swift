//
//  Gzip.swift
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
import zlib

/// Уровень сжатия, значение rawValue которого основано на константах zlib.
/// Уровень сжатия в диапазоне от «0» (без сжатия) до «9» (максимальное сжатие).
public struct CompressionLevel: RawRepresentable {

    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}

// MARK: - CompressionLevel + Default
extension CompressionLevel {
    
    public static let bestSpeed = CompressionLevel(rawValue: Z_BEST_SPEED)
    public static let noCompression = CompressionLevel(rawValue: Z_NO_COMPRESSION)
    public static let bestCompression = CompressionLevel(rawValue: Z_BEST_COMPRESSION)
    public static let defaultCompression = CompressionLevel(rawValue: Z_DEFAULT_COMPRESSION)
}

/// Ошибки gzipping/gunzipping на основе кодов ошибок zlib.
/// http://www.zlib.net/manual.html
public struct GzipError: LocalizedError {
    
    public enum Kind: Equatable {
        /// Структура потока была непоследовательной
        /// - Базовая ошибка zlib: `Z_STREAM_ERROR`
        case stream
        /// Входные данные были повреждены
        /// (input stream not conforming to the zlib format or incorrect check value).
        /// - Базовая ошибка zlib: `Z_DATA_ERROR`
        case data
        /// Не хватило памяти
        /// - Базовая ошибка zlib: `Z_MEM_ERROR`
        case memory
        /// Прогресс невозможен или в выходном буфере недостаточно места
        /// - Базовая ошибка zlib: `Z_BUF_ERROR`
        case buffer
        /// Версия библиотеки zlib несовместима с версией, предполагаемой вызывающей стороной
        /// Базовая ошибка zlib: `Z_VERSION_ERROR`
        case version
        /// Произошла неизвестная ошибка
        /// - parameter code: Базовая ошибка zlib
        case unknown(code: Int)
        
        static func from(_ code: Int32) -> Self {
            switch code {
            case Z_STREAM_ERROR:
                return .stream
            case Z_DATA_ERROR:
                return .data
            case Z_MEM_ERROR:
                return .memory
            case Z_BUF_ERROR:
                return .buffer
            case Z_VERSION_ERROR:
                return .version
            default:
                return .unknown(code: Int(code))
            }
        }
    }
    
    /// Тип ошибки
    public let kind: Kind
    /// Ответное сообщение от zlib
    public let message: String
    
    public var errorDescription: String? { message }
    
    /// Инициализация
    /// - Parameters:
    ///   - code: Код из zlib
    ///   - message: Cообщение от zlib
    public init(code: Int32, message: UnsafePointer<CChar>) {
        self.message = String(validatingUTF8: message) ?? "Unknown gzip error"
        self.kind = .from(code)
    }
}

// MARK: - DataSize
enum DataSize {
    
    static let chunk = 1 << 14
    static let stream = MemoryLayout<z_stream>.size
}

extension Data {
    
    /// Whether the receiver is compressed in gzip format.
    public var isGzipped: Bool {
        starts(with: [0x1f, 0x8b])
    }
    
    /// Create a new `Data` object by compressing the receiver using zlib.
    /// Throws an error if compression failed.
    /// - Parameter level: Compression level.
    /// - Returns: Gzip-compressed `Data` object.
    /// - Throws: `GzipError`
    public func gzipped(level: CompressionLevel = .defaultCompression) throws -> Data {
        guard !self.isEmpty else { return .init() }
        var stream = z_stream()
        var status: Int32 = deflateInit2_(&stream,
                                          level.rawValue,
                                          Z_DEFLATED,
                                          MAX_WBITS + 16,
                                          MAX_MEM_LEVEL,
                                          Z_DEFAULT_STRATEGY,
                                          ZLIB_VERSION,
                                          Int32(DataSize.stream))
        guard
            status == Z_OK
        else { throw GzipError(code: status, message: stream.msg) }
        var data = Data(capacity: DataSize.chunk)
        repeat {
            if Int(stream.total_out) >= data.count {
                data.count += DataSize.chunk
            }
            let inputCount = count
            let outputCount = data.count
            withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!).advanced(by: Int(stream.total_in))
                stream.avail_in = uint(inputCount) - uInt(stream.total_in)
                data.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
                    stream.next_out = outputPointer.bindMemory(to: Bytef.self).baseAddress!.advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(outputCount) - uInt(stream.total_out)
                    status = deflate(&stream, Z_FINISH)
                    stream.next_out = nil
                }
                stream.next_in = nil
            }
        } while stream.avail_out == 0
        
        guard
            deflateEnd(&stream) == Z_OK, status == Z_STREAM_END
        else { throw GzipError(code: status, message: stream.msg) }
        data.count = Int(stream.total_out)
        return data
    }
    
    /// Create a new `Data` object by decompressing the receiver using zlib.
    /// Throws an error if decompression failed.
    ///
    /// - Returns: Gzip-decompressed `Data` object.
    /// - Throws: `GzipError`
    public func gunzipped() throws -> Data {
        guard !self.isEmpty else { return .init() }
        var stream = z_stream()
        var status: Int32
        status = inflateInit2_(&stream, MAX_WBITS + 32,
                               ZLIB_VERSION,
                               Int32(DataSize.stream))
        guard
            status == Z_OK
        else { throw GzipError(code: status, message: stream.msg) }
        var data = Data(capacity: count * 2)
        repeat {
            if Int(stream.total_out) >= data.count {
                data.count += count / 2
            }
            let inputCount = count
            let outputCount = data.count
            withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!).advanced(by: Int(stream.total_in))
                stream.avail_in = uint(inputCount) - uInt(stream.total_in)
                data.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
                    stream.next_out = outputPointer.bindMemory(to: Bytef.self).baseAddress!.advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(outputCount) - uInt(stream.total_out)
                    status = inflate(&stream, Z_SYNC_FLUSH)
                    stream.next_out = nil
                }
                stream.next_in = nil
            }
        } while status == Z_OK
        guard
            inflateEnd(&stream) == Z_OK, status == Z_STREAM_END
        else { throw GzipError(code: status, message: stream.msg) }
        data.count = Int(stream.total_out)
        return data
    }
}
