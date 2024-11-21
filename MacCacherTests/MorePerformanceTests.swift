//
//  MorePerformanceTests.swift
//  MacCacherTests
//
//  Created by Abdoelrahman Eaita on 20/11/2024.
//

import XCTest

@testable import MacCacher

class MorePerformanceTests: XCTestCase {
    
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
    
    private func measureAsyncTest<T>(name: String, block: @escaping () async -> T) async -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        results[name] = timeElapsed
        return result
    }
    
    private func printResults() {
        print("\n=== Performance Test Results ===")
        print("Iterations per test: \(iterations)")
        print("-------------------------------")
        
        let sortedResults = results.sorted { $0.value < $1.value }
        
        if let fastestTime = sortedResults.first?.value {
            for (implementation, time) in sortedResults {
                let relative = (time / fastestTime - 1) * 100
                print(String(format: "%@ : %.4f seconds (%.1f%% slower than fastest)",
                             implementation.padding(toLength: 30, withPad: " ", startingAt: 0),
                             time,
                             relative))
            }
        }
    }
    
    // Test 1: Write-Heavy Workload (75% writes, 25% reads)
    func testWriteHeavyWorkload() async {
        print("\n=== Testing Write-Heavy Workload ===")
        
        measureTest(name: "NSLock - Write Heavy") {
            let cache = CacheNSLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 { // 25% reads
                    _ = cache.get(i % 1000)
                } else { // 75% writes
                    cache.set(i % 1000, value: i)
                }
            }
        }
        
        await measureAsyncTest(name: "Actor - Write Heavy") {
            let cache = CacheActor<Int, Int>()
            
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<self.iterations {
                    group.addTask {
                        if i % 4 == 0 { // 25% reads
                            _ = await cache.get(i % 1000)
                        } else { // 75% writes
                            await cache.set(i % 1000, value: i)
                        }
                    }
                }
                // Wait for all operations to complete
                await group.waitForAll()
            }
        }
        
        measureTest(name: "NSLockWithBlock - Write Heavy") {
            let cache = CacheNSLockWithBlock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 { // 25% reads
                    _ = cache.get(i % 1000)
                } else { // 75% writes
                    cache.set(i % 1000, value: i)
                }
            }
        }
        
        measureTest(name: "Serial Queue - Write Heavy") {
            let cache = CacheSerialQueue<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    _ = cache.get(i % 1000)
                } else {
                    cache.set(i % 1000, value: i)
                }
            }
        }
        
        measureTest(name: "Concurrent Queue - Write Heavy") {
            let cache = CacheConcurrentQueue<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    _ = cache.get(i % 1000)
                } else {
                    cache.set(i % 1000, value: i)
                }
            }
        }
        
        measureTest(name: "Unfair Lock - Write Heavy") {
            let cache = CacheUnfairLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    _ = cache.get(i % 1000)
                } else {
                    cache.set(i % 1000, value: i)
                }
            }
        }
        
        measureTest(name: "Unfair Lock OOP - Write Heavy") {
            let cache = CacheUnfairLockOOP<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    _ = cache.get(i % 1000)
                } else {
                    cache.set(i % 1000, value: i)
                }
            }
        }
        
        measureTest(name: "RW Lock - Write Heavy") {
            let cache = CacheRWLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    _ = cache.get(i % 1000)
                } else {
                    cache.set(i % 1000, value: i)
                }
            }
        }
    }
    
    // Test 2: Read-Heavy Workload (25% writes, 75% reads)
    func testReadHeavyWorkload() async {
        print("\n=== Testing Read-Heavy Workload ===")
        // Read-heavy workload
        await measureAsyncTest(name: "Actor - Read Heavy") {
            let cache = CacheActor<Int, Int>()
            
            // Pre-populate cache
            for i in 0..<1000 {
                await cache.set(i, value: i)
            }
            
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<self.iterations {
                    group.addTask {
                        if i % 4 == 0 { // 25% writes
                            await cache.set(i % 1000, value: i)
                        } else { // 75% reads
                            _ = await cache.get(i % 1000)
                        }
                    }
                }
                await group.waitForAll()
            }
        }
        
        measureTest(name: "NSLock - Read Heavy") {
            let cache = CacheNSLock<Int, Int>()
            // Pre-populate cache
            for i in 0..<1000 {
                cache.set(i, value: i)
            }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 { // 25% writes
                    cache.set(i % 1000, value: i)
                } else { // 75% reads
                    _ = cache.get(i % 1000)
                }
            }
        }
        
        measureTest(name: "NSLockWithBlock - Read Heavy") {
            let cache = CacheNSLockWithBlock<Int, Int>()
            // Pre-populate cache
            for i in 0..<1000 {
                cache.set(i, value: i)
            }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 { // 25% writes
                    cache.set(i % 1000, value: i)
                } else { // 75% reads
                    _ = cache.get(i % 1000)
                }
            }
        }
        
        // Repeat for other implementations...
        measureTest(name: "Serial Queue - Read Heavy") {
            let cache = CacheSerialQueue<Int, Int>()
            for i in 0..<1000 { cache.set(i, value: i) }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    cache.set(i % 1000, value: i)
                } else {
                    _ = cache.get(i % 1000)
                }
            }
        }
        
        measureTest(name: "Concurrent Queue - Read Heavy") {
            let cache = CacheConcurrentQueue<Int, Int>()
            for i in 0..<1000 { cache.set(i, value: i) }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    cache.set(i % 1000, value: i)
                } else {
                    _ = cache.get(i % 1000)
                }
            }
        }
        
        measureTest(name: "Unfair Lock - Read Heavy") {
            let cache = CacheUnfairLock<Int, Int>()
            for i in 0..<1000 { cache.set(i, value: i) }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    cache.set(i % 1000, value: i)
                } else {
                    _ = cache.get(i % 1000)
                }
            }
        }
        
        measureTest(name: "Unfair Lock OOP - Read Heavy") {
            let cache = CacheUnfairLockOOP<Int, Int>()
            for i in 0..<1000 { cache.set(i, value: i) }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    cache.set(i % 1000, value: i)
                } else {
                    _ = cache.get(i % 1000)
                }
            }
        }
        
        measureTest(name: "RW Lock - Read Heavy") {
            let cache = CacheRWLock<Int, Int>()
            for i in 0..<1000 { cache.set(i, value: i) }
            
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                if i % 4 == 0 {
                    cache.set(i % 1000, value: i)
                } else {
                    _ = cache.get(i % 1000)
                }
            }
        }
    }
    
    // Test 3: High-Contention Workload (50% reads/writes on same keys)
    func testContentionWorkload() async {
        print("\n=== Testing High-Contention Workload ===")
        await measureAsyncTest(name: "Actor - Contention") {
            let cache = CacheActor<Int, Int>()
            
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<self.iterations {
                    group.addTask {
                        let key = i % 10  // Use only 10 keys to create high contention
                        if i % 2 == 0 {
                            await cache.set(key, value: i)
                        } else {
                            _ = await cache.get(key)
                        }
                    }
                }
                await group.waitForAll()
            }
        }
        
        measureTest(name: "NSLock - Contention") {
            let cache = CacheNSLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let key = i % 10  // Use only 10 keys to create high contention
                if i % 2 == 0 {
                    cache.set(key, value: i)
                } else {
                    _ = cache.get(key)
                }
            }
        }
        
        measureTest(name: "NSLockWithBlock - Contention") {
            let cache = CacheNSLockWithBlock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let key = i % 10  // Use only 10 keys to create high contention
                if i % 2 == 0 {
                    cache.set(key, value: i)
                } else {
                    _ = cache.get(key)
                }
            }
        }
        
        // Repeat for other implementations...
        measureTest(name: "Serial Queue - Contention") {
            let cache = CacheSerialQueue<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let key = i % 10
                if i % 2 == 0 {
                    cache.set(key, value: i)
                } else {
                    _ = cache.get(key)
                }
            }
        }
        
        measureTest(name: "Concurrent Queue - Contention") {
            let cache = CacheConcurrentQueue<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let key = i % 10
                if i % 2 == 0 {
                    cache.set(key, value: i)
                } else {
                    _ = cache.get(key)
                }
            }
        }
        
        measureTest(name: "Unfair Lock - Contention") {
            let cache = CacheUnfairLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let key = i % 10
                if i % 2 == 0 {
                    cache.set(key, value: i)
                } else {
                    _ = cache.get(key)
                }
            }
        }
        
        measureTest(name: "Unfair Lock OOP - Contention") {
            let cache = CacheUnfairLockOOP<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let key = i % 10
                if i % 2 == 0 {
                    cache.set(key, value: i)
                } else {
                    _ = cache.get(key)
                }
            }
        }
        
        measureTest(name: "RW Lock - Contention") {
            let cache = CacheRWLock<Int, Int>()
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let key = i % 10
                if i % 2 == 0 {
                    cache.set(key, value: i)
                } else {
                    _ = cache.get(key)
                }
            }
        }
    }
    
    func testAllScenarios() async {
        await testWriteHeavyWorkload()
        await testReadHeavyWorkload()
        await testContentionWorkload()
    }
}
