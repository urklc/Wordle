//
//  Game.swift
//  Wordle
//
//  Created by Uğur Kılıç on 17.01.2022.
//

import Foundation
import RealmSwift

enum GameState {
    case pending(Int)
    case completed(Bool)
}

@objcMembers class Game: Object {

    dynamic var id: String = UUID().uuidString
    dynamic var date: Date = Date()
    dynamic var targetWord: String = ""
    dynamic var words: List<String> = List<String>()
    dynamic var isSuccess: Bool = false

    convenience init(id: String,
                     date: Date,
                     targetWord: String,
                     words: List<String>,
                     isSuccess: Bool) {
        self.init()
        self.date = date
        self.targetWord = targetWord
        self.words = words
        self.isSuccess = isSuccess
    }

    var state: GameState {
        if isSuccess {
            return .completed(true)
        } else {
            let remainingWords = Global.totalTryCount - words.count
            if remainingWords == 0 {
                return .completed(false)
            } else {
                return .pending(remainingWords)
            }
        }
    }
}
