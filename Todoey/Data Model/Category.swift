//
//  Category.swift
//  Todoey
//
//  Created by Stephen Jenks on 5/14/19.
//  Copyright © 2019 Stephen Jenks. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
