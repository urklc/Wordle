//
//  GameViewController.swift
//  Wordle
//
//  Created by Uğur Kılıç on 13.01.2022.
//

import UIKit

class GameViewController: UIViewController {

    var model: GameViewModel!

    @IBOutlet private weak var baseStackView: UIStackView!
    @IBOutlet private weak var wordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        wordTextField.addTarget(self,
                                action: #selector(textDidChange(_:)),
                                for: .editingChanged)
        subscribeToModel()
    }

    private func subscribeToModel() {
        model.onInitialLoad = { [weak self] words, targetWord in
            self?.addStackViewForNewWord()
            for word in words {
                self?.addCharacterBox(word: word)
                self?.apply(InputComplete(input: word, targetWord: targetWord))
            }
        }
        model.onCharacterSuccess = { [weak self] word in
            self?.addCharacterBox(word: word)
        }
        model.onInputComplete = { [weak self] inputComplete in
            self?.apply(inputComplete)
        }
        model.onError = { [weak self] error in
            let message: String
            switch error {
            case .notValidCharacter:
                message = "not valid character"
            case .notInDictionary:
                message = "not in dictionary"
            case .inputAlreadyExists:
                message = "input already exists"
            }

            let alertController = UIAlertController(
                title: "hata",
                message: message,
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }
        model.onGameOver = { [weak self] isSuccess in
            let alertController = UIAlertController(
                title: "oyun bitti",
                message: isSuccess ? "basarili :)" : "basarisiz :(",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self?.present(alertController, animated: true, completion: nil)
        }
    }

    private func addCharacterBox(word: String) {
        guard let lastStackView = baseStackView.arrangedSubviews.last as? UIStackView else {
            return
        }
        lastStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for character in Array(word) {
            let label = UILabel()
            label.font = .systemFont(ofSize: 32)
            label.text = String(character)
            lastStackView.addArrangedSubview(label)
        }
    }

    private func addStackViewForNewWord() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 32
        stackView.distribution = .fillEqually
        baseStackView.addArrangedSubview(stackView)

        wordTextField.text = ""
    }

    private func apply(_ inputComplete: InputComplete) {
        guard let lastStackView = baseStackView.arrangedSubviews.last as? UIStackView else {
            return
        }
        for i in 0..<lastStackView.arrangedSubviews.count {
            let label = lastStackView.arrangedSubviews[i] as? UILabel
            if inputComplete.matchedIndexes.contains(i) {
                label?.textColor = .systemGreen
            } else if inputComplete.nearlyMatchedIndexes.contains(i) {
                label?.textColor = .systemYellow
            }
        }
        addStackViewForNewWord()
    }

    @objc func textDidChange(_ sender: UITextField) {
        model.tryToProvide(input: sender.text!)
    }
}
