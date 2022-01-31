//
//  GameDatabase.swift
//  Wordle
//
//  Created by Uğur Kılıç on 14.01.2022.
//

import Foundation
import RealmSwift

final class GameDatabase {

    var documentsFileURL: URL? {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent("words.realm")
        }
        return nil
    }

    private var realm: Realm? {
        guard let url = documentsFileURL else {
            return nil
        }
        return try? Realm(fileURL: url)
    }

    init() {
        if let documentsFileURL = documentsFileURL {
            if !FileManager.default.fileExists(atPath: documentsFileURL.path) {
                if let bundleURL = Bundle.main.url(forResource: "words", withExtension: "realm") {
                    try? FileManager.default.copyItem(at: bundleURL, to: documentsFileURL)
                }
            }
        }
    }

    func retrieveGames() -> [Game] {
        return realm?
            .objects(Game.self)
            .sorted(by: { game1, game2 in
                return game1.date > game2.date
            })
            .compactMap { $0 } ?? []
    }

    func initializeGame(targetWord: String) -> Game {
        let game = Game()
        game.targetWord = targetWord
        try? realm?.write {
            realm?.add(game)
        }
        return game
    }

    func addWordToGame(game: Game, word: String) {
        try? realm?.write {
            game.words.append(word)
        }
    }

    func updateGameStatus(game: Game, isSuccess: Bool) {
        try? realm?.write {
            game.isSuccess = isSuccess
        }
    }

    func retrieveAndConsumeRandomWord() -> String {
        let words = realm?
            .objects(Word.self)
            .filter { $0.item.count == Global.wordLength && !$0.skip }
        let wordsArray = words?.compactMap { $0.item } ?? []

        let randomWord = wordsArray.randomElement() ?? ""
        markAsSkip(word: randomWord)
        return randomWord
    }

    func retrieveWords() -> [String] {
        let words = realm?
            .objects(Word.self)
            .filter { $0.item.count == Global.wordLength }
        return words?.compactMap { $0.item } ?? []
    }

    func removeExpired() {
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let games = realm?
            .objects(Game.self)
            .filter {
                let components = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
                return components == todayComponents
            }
        if let games = games {
            try? realm?.write {
                realm?.delete(games)
            }
        }
    }

    private func markAsSkip(word: String) {
        let word = realm?
            .objects(Word.self)
            .filter { word == $0.item }
            .first
        try? realm?.write {
            word?.skip = true
        }
    }
}
