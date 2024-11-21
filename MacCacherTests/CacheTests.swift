//
//  CacheTests.swift
//  MacCacherTests
//
//  Created by Abdoelrahman Eaita on 20/11/2024.
//

//import XCTest
//@testable import MacCacher
//
//class CacheTests: XCTestCase {
//    var cache: Cache<String, String>!
//    var cacheWithInt: Cache<String, Int>!
//
//    override func setUp() {
//        super.setUp()
//        cache = Cache<String, String>()
//        cacheWithInt = Cache<String, Int>()
//    }
//    
//    override func tearDown() {
//        cache = nil
//        super.tearDown()
//    }
//    
//    func testBasicSetAndGet() {
//        cache.set("key1", value: "value1")
//        let value = cache.get("key1")
//        XCTAssertEqual(value, "value1", "The value retrieved should match the value set.")
//    }
//    
//    func testOverwriteValue() {
//        cache.set("key1", value: "value1")
//        cache.set("key1", value: "value2")
//        let value = cache.get("key1")
//        XCTAssertEqual(value, "value2", "The value should be updated to the new value.")
//    }
//    
//    func testNonExistentKey() {
//        let value = cache.get("nonexistent")
//        XCTAssertNil(value, "Retrieving a value for a non-existent key should return nil.")
//    }
//    
//    func testConcurrentReads() {
//        let expectation = XCTestExpectation(description: "Concurrent reads should work without crashing.")
//        
//        DispatchQueue.concurrentPerform(iterations: 10) { _ in
//            _ = self.cache.get("key1")
//        }
//        
//        expectation.fulfill()
//        wait(for: [expectation], timeout: 1)
//    }
//    
//    func testConcurrentWrites() {
//        let expectation = XCTestExpectation(description: "Concurrent writes should not crash or corrupt the cache.")
//        
//        DispatchQueue.concurrentPerform(iterations: 10) { index in
//            self.cache.set("key\(index)", value: "value\(index)")
//        }
//        
//        expectation.fulfill()
//        wait(for: [expectation], timeout: 1)
//    }
//    
//    func testConcurrentReadsAndWrites() {
//        let expectation = XCTestExpectation(description: "Concurrent reads and writes should work without crashing.")
//        
//        DispatchQueue.concurrentPerform(iterations: 20) { index in
//            if index % 2 == 0 {
//                _ = self.cache.get("key\(index)")
//            } else {
//                self.cache.set("key\(index)", value: "value\(index)")
//            }
//        }
//        
//        expectation.fulfill()
//        wait(for: [expectation], timeout: 1)
//    }
//    
//    func testConcurrentAccessRaceCondition() {
//        let cache = Cache<String, Int>()
//        let key = "testKey"
//        let iterations = 10000
//        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
//        let group = DispatchGroup()
//        
//        _ = false
//        
//        // Set initial value
//        cache.set(key, value: 0)
//        
//        // Create multiple concurrent read-modify-write operations
//        for _ in 0..<iterations {
//            group.enter()
//            queue.async(group: group) {
//                if let currentValue = cache.get(key) {
//                    // Introduce a small delay to increase chance of race condition
//                    Thread.sleep(forTimeInterval: 0.0001)
//                    cache.set(key, value: currentValue + 1)
//                }
//                group.leave()
//            }
//        }
//        
//        group.wait()
//        
//        // If there's no race condition, final value should equal iterations
//        let finalValue = cache.get(key)
//        XCTAssertNotEqual(finalValue, iterations, "Expected race condition to cause lost updates")
//        
//        // The test passes if finalValue is less than iterations,
//        // indicating lost updates due to race condition
//    }
//    
//    func testReadModifyWriteRaceCondition() {
//        let key = "testKey"
//        let iterations = 10000
//        
//        // Simulate a read-modify-write operation that requires external processing
//        func incrementWithDelay(_ currentValue: Int) -> Int {
//            // Simulate processing time where other threads could interfere
//            Thread.sleep(forTimeInterval: 0.001)
//            return currentValue + 1
//        }
//        
//        // Run concurrent increments without proper synchronization
//        cacheWithInt.set(key, value: 0)
//        
//        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
//            if let value = cacheWithInt.get(key) {
//                let newValue = incrementWithDelay(value)
//                // During this gap, other threads might have modified the value
//                cacheWithInt.set(key, value: newValue)
//            }
//        }
//        
//        // The final value should be less than iterations due to lost updates
//        let finalValue = cacheWithInt.get(key) ?? 0
//        XCTAssertLessThan(finalValue, iterations,
//                          "Expected race condition to cause lost updates, but got \(finalValue)")
//    }
//    
//    
//    func testConcurrentReadsAndWritesWithStress() {
//        let key = "testKey"
//        let iterations = 10_000
//        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
//        let group = DispatchGroup()
//        
//        // Initialize cache value
//        cacheWithInt.set(key, value: 0)
//        
//        for _ in 0..<iterations {
//            group.enter()
//            queue.async(group: group) {
//                // Writer
//                self.cacheWithInt.set(key, value: Int.random(in: 0...iterations))
//                group.leave()
//            }
//            
//            group.enter()
//            queue.async(group: group) {
//                // Reader
//                _ = self.cacheWithInt.get(key)
//                group.leave()
//            }
//        }
//        
//        group.wait()
//        XCTAssert(true, "Test completed successfully. Look for inconsistencies during debugging.")
//    }
//    
//    func testConcurrentDeletesAndReadsWithHighIteration() {
//        let key = "testKey"
//        let iterations = 5_000
//        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
//        let group = DispatchGroup()
//        
//        // Initialize cache value
//        cacheWithInt.set(key, value: 42)
//        
//        for _ in 0..<iterations {
//            group.enter()
//            queue.async(group: group) {
//                // Reader
//                _ = self.cacheWithInt.get(key)
//                group.leave()
//            }
//            
//            group.enter()
//            queue.async(group: group) {
//                // Deleter (simulate by setting nil)
//                self.cacheWithInt.set(key, value: 0)
//                group.leave()
//            }
//        }
//        
//        group.wait()
//        XCTAssert(true, "Test completed successfully. Look for inconsistencies during debugging.")
//    }
//
//
//    func testConcurrentAccessWithMultipleKeys() {
//        let keys = ["key1", "key2", "key3", "key4"]
//        let iterations = 10_000
//        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
//        let group = DispatchGroup()
//        
//        // Initialize keys
//        for key in keys {
//            cacheWithInt.set(key, value: 0)
//        }
//        
//        for _ in 0..<iterations {
//            for key in keys {
//                group.enter()
//                queue.async(group: group) {
//                    if let currentValue = self.cacheWithInt.get(key) {
//                        self.cacheWithInt.set(key, value: currentValue + 1)
//                    }
//                    group.leave()
//                }
//            }
//        }
//        
//        group.wait()
//        
//        for key in keys {
//            let finalValue = cacheWithInt.get(key)
//            XCTAssertLessThan(finalValue ?? 0, iterations, "Expected race condition to cause lost updates for \(key)")
//        }
//    }
//    
//    func testCacheThreadSafety() {
//        let cache = Cache<Int, Int>()
//        let expectation = XCTestExpectation(description: "Concurrent access")
//        let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
//        let group = DispatchGroup()
//        let iterations = 1000
//        
//        for i in 0..<iterations {
//            group.enter()
//            concurrentQueue.async(group: group) {
//                cache.set(i, value: i)
//                group.leave()
//            }
//        }
//        
//        group.notify(queue: .main) {
//            var failed = false
//            for i in 0..<iterations {
//                if cache.get(i) != i {
//                    failed = true
//                    XCTFail("Value for key \(i) is incorrect or missing")
//                    break
//                }
//            }
//            if !failed {
//                expectation.fulfill()
//            }
//        }
//        
//        wait(for: [expectation], timeout: 10.0)
//    }
//}
