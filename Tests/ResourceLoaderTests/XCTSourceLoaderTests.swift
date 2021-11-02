//
//  XCTSourceLoader.swift
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

import XCTest
@testable import CFoundation

class XCTSourceLoaderTests: XCTestCase, XCTSourceLoader {
    
    /// Модель
    struct Model: Decodable {
        
        var id: String
        var title: String
    }
    
    /// Enum, содержащий название файла, где лежит необходимы JSON
    enum JSON: String, JSONResource {
        
        case modeldata
        case modelfail
    }
    
    static let bundle = Bundle(for: XCTSourceLoaderTests.self)
    let successData: [Model] = [Model(id: "1", title: "First Title"), Model(id: "2", title: "Second Title"), Model(id: "3", title: "Third Title")]
    let failureData: [Model] = []
    let models: [Model] = XCTSourceLoaderTests.XCTResource(by: JSON.modeldata, bundle: bundle)
    
    func testModelsSuccess() {
        /// Проверяет равно ли кол-во элементов из JSON массиву из XCTSourceLoader
        XCTAssertEqual(models.count, 3)
        XCTAssertTrue(successData.count == models.count)
        /// Проверяет совпадают ли объекты массива из JSON массиву из XCTSourceLoader
        models.enumerated().forEach { index, item in
            XCTAssertTrue(item.id == successData[index].id)
        }
        /// Проверяет наличие объектов в массиве из XCTSourceLoader
        XCTAssertNotNil(models)
    }
    
    func testModelsFailure() {
        /// Проверяет равно ли кол-во элементов из JSON массиву из XCTSourceLoader
        XCTAssertNotEqual(models.count, 4)
        XCTAssertFalse(failureData.count == models.count)
    }
}
