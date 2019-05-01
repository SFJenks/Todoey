//
//  Item.swift
//  Todoey
//
//  Created by Stephen Jenks on 4/16/19.
//  Copyright © 2019 Stephen Jenks. All rights reserved.
//

import Foundation

class Item : Codable {
    var title : String
    var done = false

    init(name : String) {
        title = name
    }
}
