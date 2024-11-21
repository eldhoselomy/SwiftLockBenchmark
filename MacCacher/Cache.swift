import Foundation
import os.lock

protocol Cache: AnyObject {
    associatedtype Key: Hashable
    associatedtype Value
    func get(_ key: Key) -> Value?
    func set(_ key: Key, value: Value)
}

class CacheUnfairLockOOP<Key: Hashable, Value>: Cache {
    private var _cache: [Key: Value] = [:]
    private var lock = OSAllocatedUnfairLock()
    
    func get(_ key: Key) -> Value? {
        lock.withLock { _ in
            return _cache[key]
        }
    }
    
    func set(_ key: Key, value: Value) {
        lock.withLock { _ in
            _cache[key] = value
        }
    }
}

class CacheNSLockWithBlock<Key: Hashable, Value>: Cache {
    private var cache: [Key: Value] = [:]
    private let lock = NSLock()
    
    func get(_ key: Key) -> Value? {
        lock.withLock {
            return cache[key]
        }
    }
    
    func set(_ key: Key, value: Value) {
        lock.withLock {
            cache[key] = value
        }
    }
}

class CacheNSLock<Key: Hashable, Value>: Cache {
    private var cache: [Key: Value] = [:]
    private let lock = NSLock()
    
    func get(_ key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }
    
    func set(_ key: Key, value: Value) {
        lock.lock()
        defer { lock.unlock() }
        cache[key] = value
    }
}


class CacheSerialQueue<Key: Hashable, Value>: Cache {
    private var cache: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.cache.serialQueue")
    
    func get(_ key: Key) -> Value? {
        return queue.sync {
            cache[key]
        }
    }
    
    func set(_ key: Key, value: Value) {
        queue.sync {
            cache[key] = value
        }
    }
}


class CacheConcurrentQueue<Key: Hashable, Value>: Cache {
    private var cache: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.cache.concurrentQueue", attributes: .concurrent)
    
    func get(_ key: Key) -> Value? {
        return queue.sync {
            cache[key]
        }
    }
    
    func set(_ key: Key, value: Value) {
        queue.async(flags: .barrier) {
            self.cache[key] = value
        }
    }
}

class CacheUnfairLock<Key: Hashable, Value>: Cache {
    private var cache: [Key: Value] = [:]
    private var lock = os_unfair_lock_s()
    
    func get(_ key: Key) -> Value? {
        os_unfair_lock_lock(&lock)
        let value = cache[key]
        os_unfair_lock_unlock(&lock)
        return value
    }
    
    func set(_ key: Key, value: Value) {
        os_unfair_lock_lock(&lock)
        cache[key] = value
        os_unfair_lock_unlock(&lock)
    }
}


class CacheNSCache<Key: AnyObject, Value: AnyObject> {
    private let cache = NSCache<Key, Value>()
    
    func get(_ key: Key) -> Value? {
        return cache.object(forKey: key)
    }
    
    func set(_ key: Key, value: Value) {
        cache.setObject(value, forKey: key)
    }
}

class CacheRWLock<Key: Hashable, Value>: Cache {
    private var cache: [Key: Value] = [:]
    private var lock = pthread_rwlock_t()
    
    init() {
        pthread_rwlock_init(&lock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    func get(_ key: Key) -> Value? {
        pthread_rwlock_rdlock(&lock)
        let value = cache[key]
        pthread_rwlock_unlock(&lock)
        return value
    }
    
    func set(_ key: Key, value: Value) {
        pthread_rwlock_wrlock(&lock)
        cache[key] = value
        pthread_rwlock_unlock(&lock)
    }
}

actor CacheActor<Key: Hashable, Value> {
    private var cache: [Key: Value] = [:]
    
    func get(_ key: Key) async -> Value? {
        cache[key]
    }
    
    func set(_ key: Key, value: Value) async {
        cache[key] = value
    }
}
