//
//  InputComplete.swift
//  Wordle
//
//  Created by Uğur Kılıç on 30.01.2022.
//

import Foundation

struct InputComplete {
    let word: String
    let matchedIndexes: [Int]
    let nearlyMatchedIndexes: [Int]

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
