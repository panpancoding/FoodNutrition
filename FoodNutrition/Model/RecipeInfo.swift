//
//  RecipeInfo.swift
//  FoodNutrition
//
//  Created by Carolyn Pan on 12/8/21.
//

import Foundation
import RealmSwift

class RecipeInfo : Object {
    @objc dynamic var key: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var imageType: String = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
