//
//  PerformanceTests.swift
//  MacCacherTests
//
//  Created by Abdoelrahman Eaita on 20/11/2024.
//

import XCTest
@testable import MacCacher


class CacheComparisonPerformanceTests: XCTestCase {
    
    let iterations = 100_000
    var results: [String: TimeInterval] = [:]
    
    override func setUp() {
        super.setUp()
        results.removeAll()
    }
    
    override func tearDown() {
        super.tearDown()
        printResults()
    }
    
    private func measureTest(name: String, block: () -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        results[name] = timeElapsed
    }
    
    private func printResults() {
        print("\n=== Performance Test Results ===")
        print("Iterations per test: \(iterations)")
        print("-------------------------------")
        
        // Sort results by execution time
        let sortedResults = results.sorted { $0.value < $1.value }
        
        // Find the fastest implementation for relative comparison
        if let fastestTime = sortedResults.first?.value {
            for (implementation, time) in sortedResults {
                let relative = (time / fastestTime - 1) * 100
                print(String(format: "%@ : %.4f seconds (%.1f%% slower than fastest)",
                             implementation.padding(toLength: 20, withPad: " ", startingAt: 0),
                             time,
                             relative))
            }
        }
    }
    
    func testAllCacheImplementations() {
        // Test NSLock implementation
        measureTest(name: "NSLock") {
            let cache = CacheNSLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cache.set(i, value: i)
                _ = cache.get(i)
            }
        }
        measureTest(name: "NSLockWithBlock") {
            let cache = CacheNSLockWithBlock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cache.set(i, value: i)
                _ = cache.get(i)
            }
        }
        
        // Test Serial Queue implementation
        measureTest(name: "Serial Queue") {
            let cache = CacheSerialQueue<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cache.set(i, value: i)
                _ = cache.get(i)
            }
        }
        
        // Test Concurrent Queue implementation
        measureTest(name: "Concurrent Queue") {
            let cache = CacheConcurrentQueue<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cache.set(i, value: i)
                _ = cache.get(i)
            }
        }
        
        // Test Unfair Lock implementation
        measureTest(name: "Unfair Lock") {
            let cache = CacheUnfairLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cache.set(i, value: i)
                _ = cache.get(i)
            }
        }
        
        // Test Unfair Lock OOP implementation
        measureTest(name: "Unfair Lock OOP") {
            let cache = CacheUnfairLockOOP<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cache.set(i, value: i)
                _ = cache.get(i)
            }
        }
        
        // Test RW Lock implementation
        measureTest(name: "RW Lock") {
            let cache = CacheRWLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cache.set(i, value: i)
                _ = cache.get(i)
            }
        }
    }
}


//
//class CacheComparisonPerformanceTests: XCTestCase {
//    
//    let iterations = 100_000
//    
//    func testPerformanceCacheNSLock() {
//        let cache = CacheNSLock<Int, Int>()
//        measure {
//            DispatchQueue.concurrentPerform(iterations: iterations) { i in
//                cache.set(i, value: i)
//                _ = cache.get(i)
//            }
//        }
//    }
//    
//    func testPerformanceCacheSerialQueue() {
//        let cache = CacheSerialQueue<Int, Int>()
//        measure {
//            DispatchQueue.concurrentPerform(iterations: iterations) { i in
//                cache.set(i, value: i)
//                _ = cache.get(i)
//            }
//        }
//    }
//    
//    func testPerformanceCacheConcurrentQueue() {
//        let cache = CacheConcurrentQueue<Int, Int>()
//        measure {
//            DispatchQueue.concurrentPerform(iterations: iterations) { i in
//                cache.set(i, value: i)
//                _ = cache.get(i)
//            }
//        }
//    }
//    
//    func testPerformanceCacheUnfairLock() {
//        let cache = CacheUnfairLock<Int, Int>()
//        measure {
//            DispatchQueue.concurrentPerform(iterations: iterations) { i in
//                cache.set(i, value: i)
//                _ = cache.get(i)
//            }
//        }
//    }
//    
//    func testPerformanceCacheUnfairLockOOP() {
//        let cache = CacheUnfairLockOOP<Int, Int>()
//        measure {
//            DispatchQueue.concurrentPerform(iterations: iterations) { i in
//                cache.set(i, value: i)
//                _ = cache.get(i)
//            }
//        }
//    }
//    
//    
//    
//    func testPerformanceCacheRWLock() {
//        let cache = CacheRWLock<Int, Int>()
//        measure {
//            DispatchQueue.concurrentPerform(iterations: iterations) { i in
//                cache.set(i, value: i)
//                _ = cache.get(i)
//            }
//        }
//    }
//}
//
