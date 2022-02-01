//
//  GameViewModelTests.swift
//  WordleTests
//
//  Created by Uğur Kılıç on 1.02.2022.
//

import XCTest
@testable import Wordle

class GameViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModelTriggersNotValidCharacterErrorIfNotValidCharacterIsGiven() {
        let model = GameViewModel(game: nil)
        model.onError = { error in
            XCTAssertNotNil(error, "Model didn't throw error on failure!")
            switch error {
            case .notInDictionary,
                    .inputAlreadyExists:
                XCTFail()
            default:
                break
            }
        }

        model.tryToProvide(input: "a1bcd")
    }

    func testModelTriggersOnCharacterSuccess() {
        let testValue = "test"

        let model = GameViewModel(game: nil)
        model.onCharacterSuccess = { value in
            XCTAssertEqual(value, testValue, "Model didn't call on character success when input is updated!")
        }

        model.tryToProvide(input: testValue)
    }

    func testModelTriggersOnCompleteIfWordIsEnough() {
        let databaseSpy = GameDatabaseSpy()
        let targetWord = "kalem"
        databaseSpy.stubbedRandomWord = targetWord

        let model = GameViewModel(database: databaseSpy,
                                  game: nil)
        model.onWordComplete = { wordComplete in
            XCTAssertEqual(wordComplete,
                           WordComplete(word: "kitap", matchedIndexes: [0], nearlyMatchedIndexes: [3]))
        }

        model.tryToProvide(input: "kitap")
    }
}

class GameDatabaseSpy: GameDatabaseProtocol {
    var stubbedRandomWord = ""

    func retrieveAndConsumeRandomWord() -> String {
        return stubbedRandomWord
    }

    func initializeGame(targetWord: String) -> Game {
        return Game()
    }

    func addWordToGame(game: Game, word: String) {

    }

    func retrieveWords() -> [String] {
        return []
    }

    func updateGameStatus(game: Game, isSuccess: Bool) {

    }
}
