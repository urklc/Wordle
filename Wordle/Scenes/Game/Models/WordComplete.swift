//
//  WordComplete.swift
//  Wordle
//
//  Created by Uğur Kılıç on 30.01.2022.
//

import Foundation

struct WordComplete {
    let word: String
    let matchedIndexes: [Int]
    let nearlyMatchedIndexes: [Int]

    init(word: String, matchedIndexes: [Int], nearlyMatchedIndexes: [Int]) {
        self.word = word
        self.matchedIndexes = matchedIndexes
        self.nearlyMatchedIndexes = nearlyMatchedIndexes
    }

    init(input: String, targetWord: String) {
        var matchedIndexes: [Int] = []
        var nearlyMatchedIndexes: [Int] = []

        for i in 0..<Global.wordLength {
            let inputCharacter = input[input.index(input.startIndex, offsetBy: i)]
            let targetCharacter = targetWord[targetWord.index(targetWord.startIndex, offsetBy: i)]

            if inputCharacter == targetCharacter {
                matchedIndexes.append(i)
            } else if (targetWord.contains(inputCharacter)) {
                nearlyMatchedIndexes.append(i)
            }
        }
        self.matchedIndexes = matchedIndexes
        self.nearlyMatchedIndexes = nearlyMatchedIndexes
        self.word = input
    }
}

extension WordComplete: Equatable {

    static func ==(lhs: WordComplete, rhs: WordComplete) -> Bool {
        return lhs.word == rhs.word
        && lhs.matchedIndexes == rhs.matchedIndexes
        && lhs.nearlyMatchedIndexes == rhs.nearlyMatchedIndexes
    }
}
