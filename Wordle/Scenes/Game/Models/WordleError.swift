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
            return NSLocalizedString("error_not_valid_character", comment: "")
        case .notInDictionary:
            return NSLocalizedString("error_not_in_dictionary", comment: "")
        case .inputAlreadyExists:
            return NSLocalizedString("error_input_exists", comment: "")
        }
    }
}
