//
//  Item.swift
//  SlavicWallpapers
//
//  Created by Василий Буланов on 04.02.2025.
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
