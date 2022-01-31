//
//  WordleError.swift
//  Wordle
//
//  Created by Uğur Kılıç on 31.01.2022.
//

import Foundation

enum WordleError: Error, CustomStringConvertible {
    case notValidCharacter
    case notInDictionary
    case inputAlreadyExists

    var description: String {
        switch self {
        case .notValidCharacter:
            return "not valid character"
        case .notInDictionary:
            return "not in dictionary"
        case .inputAlreadyExists:
            return "input already exists"
        }
    }
}
