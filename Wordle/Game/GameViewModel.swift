//
//  GameViewModel.swift
//  Wordle
//
//  Created by Uğur Kılıç on 13.01.2022.
//

import Foundation
import UserNotifications

enum WordleError: Error {
    case notValidCharacter
    case notInDictionary
    case inputAlreadyExists
}

final class GameViewModel {

    private enum Constant {

        static var alphabet: CharacterSet = {
            var characterSet = CharacterSet.lowercaseLetters
            characterSet.insert(charactersIn: "çğıöşü")
            return characterSet
        }()
    }

    var onInitialLoad: (([String], String) -> Void)? = nil {
        didSet {
            onInitialLoad?(inputWords, targetWord ?? "")
        }
    }
    var onCharacterSuccess: ((String) -> Void)? = nil
    var onInputComplete: ((InputComplete) -> Void)? = nil
    var onError: ((WordleError) -> Void)? = nil
    var onGameOver: ((Bool) -> Void)? = nil

    private(set) var inputWords: [String] = []

    // MARK: - Private Methods

    private var targetWord: String? {
        didSet {
            inputWords.removeAll()
            currentInput = ""
        }
    }

    private var currentInput: String = "" {
        didSet {
            onCharacterSuccess?(currentInput)

            if currentInput.count == 5 {
                provide(input: currentInput)
            }
        }
    }

    private let database = GameDatabase()
    private var currentGame: Game?

    // MARK: - Init

    init(game: Game?) {
        if let game = game {
            currentGame = game
            for word in game.words {
                inputWords.append(word)
            }
            targetWord = game.targetWord
        } else {
            targetWord = database.retrieveAndConsumeRandomWord()
            currentGame = database.initializeGame(targetWord: targetWord!)
        }
        print("target word: \(targetWord!)")
        let content = UNMutableNotificationContent()
        content.title = "Hello world"
        content.body = "Wordle"

        let date = Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 22
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: false)

        let request = UNNotificationRequest(identifier: "wordle",
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // MARK: - Public Methods

    func tryToProvide(input: String) {
        guard Constant.alphabet.isSuperset(of: CharacterSet(charactersIn: input)) else {
            onError?(.notValidCharacter)
            return
        }

        currentInput = input
    }

    // MARK: - Private Methods

    private func provide(input: String) {
        guard let targetWord = targetWord else {
            return
        }

        guard database.retrieveWords().contains(input) else {
            onError?(.notInDictionary)
            return
        }

        guard !inputWords.contains(input) else {
            onError?(.inputAlreadyExists)
            return
        }

        inputWords.append(input)



        if let game = currentGame {
            database.addWordToGame(game: game, word: input)
        }

        onInputComplete?(InputComplete(input: input, targetWord: targetWord))

        let isSuccess = inputWords.contains(targetWord)
        let isCompleted = inputWords.count == 6
        if isSuccess {
            onGameOver?(true)
            if let game = currentGame {
                database.updateGameStatus(game: game, isSuccess: true)
            }
        } else if isCompleted {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            onGameOver?(false)
            if let game = currentGame {
                database.updateGameStatus(game: game, isSuccess: false)
            }
        }
    }
}
