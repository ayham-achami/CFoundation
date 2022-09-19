//
//  ViewController.swift
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

import UIKit
import Combine
import CFoundation

extension DarwinNotification.Name {
    
    static let someNotification = Self(rawValue: "someNotification")
}

class ViewController: UIViewController {

    var subscription1: AnyCancellable?
    var subscription2: AnyCancellable?
    var subscription3: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscription1 = Timer.publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .scan(0) { counter, _ in
                counter + 1
            }.sink { [weak self] value in
                DarwinNotificationCenter.default.postNotification(name: .someNotification)
                print("Post notification [\(value)]")
                if value > 10 {
                    self?.subscription3?.cancel()
                    self?.subscription3 = nil
                }
                if value > 20 {
                    self?.subscription2?.cancel()
                    self?.subscription2 = nil
                }
                if value > 30 {
                    self?.subscription1?.cancel()
                    self?.subscription1 = nil
                }
            }
        subscription2 = DarwinNotificationCenter.default.publisher(for: .someNotification).sink {
            print("Receive notification 1")
        }
        
        subscription3 = DarwinNotificationCenter.default.publisher(for: .someNotification).sink { 
            print("Receive notification 2")
        }
    }
}
