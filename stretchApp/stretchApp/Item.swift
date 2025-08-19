//
//  Item.swift
//  stretchApp
//
//  Created by Abdalla Abdelmagid on 8/19/25.
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
