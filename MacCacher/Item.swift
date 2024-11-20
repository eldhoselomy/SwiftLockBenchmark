//
//  Item.swift
//  MacCacher
//
//  Created by Abdoelrahman Eaita on 20/11/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
