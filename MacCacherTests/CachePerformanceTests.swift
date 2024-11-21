//
//  CachePerformanceTests.swift
//  MacCacherTests
//
//  Created by Abdoelrahman Eaita on 20/11/2024.
//

import XCTest
@testable import MacCacher

//class CachePerformanceTests: XCTestCase {
//    var cache: Cache<String, String>!
//    
//    override func setUp() {
//        super.setUp()
//        cache = Cache<String, String>()
//        
//        // Pre-fill the cache with some data for realistic testing
//        for i in 0..<1_000 {
//            cache.set("key\(i)", value: "value\(i)")
//        }
//    }
//    
//    override func tearDown() {
//        cache = nil
//        super.tearDown()
//    }
//    
//    func testSingleThreadedSetPerformance() {
//        measure {
//            for i in 0..<1_000 {
//                cache.set("newKey\(i)", value: "newValue\(i)")
//            }
//        }
//    }
//    
//    func testSingleThreadedGetPerformance() {
//        measure {
//            for i in 0..<1_000 {
//                _ = cache.get("key\(i % 1_000)") // Random access to existing keys
//            }
//        }
//    }
//    
//    func testConcurrentSetPerformance() {
//        measure {
//            DispatchQueue.concurrentPerform(iterations: 1_000) { i in
//                cache.set("concurrentKey\(i)", value: "concurrentValue\(i)")
//            }
//        }
//    }
//    
//    func testConcurrentGetPerformance() {
//        measure {
//            DispatchQueue.concurrentPerform(iterations: 1_000) { i in
//                _ = cache.get("key\(i % 1_000)")
//            }
//        }
//    }
//    
//    func testConcurrentReadWritePerformance() {
//        measure {
//            DispatchQueue.concurrentPerform(iterations: 2_000) { i in
//                if i % 2 == 0 {
//                    _ = cache.get("key\(i % 1_000)") // Reads
//                } else {
//                    cache.set("key\(i)", value: "value\(i)") // Writes
//                }
//            }
//        }
//    }
//}
//
