//
//  Word.swift
//  Wordle
//
//  Created by Uğur Kılıç on 13.01.2022.
//

import Foundation
import RealmSwift

@objcMembers class Word: Object {

    dynamic var item: String = ""
    dynamic var skip: Bool = false

    convenience init(item: String, skip: Bool = false) {
        self.init()
        self.item = item
        self.skip = false
    }
}
