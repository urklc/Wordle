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
    private weak var currentCharacterStackView: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "background")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(back))

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
                self?.apply(WordComplete(input: word, targetWord: targetWord))
            }
            if words.count != Global.totalTryCount && !words.contains(targetWord) {
                self?.wordTextField.becomeFirstResponder()
            }
        }
        model.onCharacterSuccess = { [weak self] word in
            self?.addCharacterBox(word: word)
        }
        model.onWordComplete = { [weak self] wordComplete in
            self?.apply(wordComplete)
        }
        model.onError = { [weak self] error in
            self?.presentAlert(title: NSLocalizedString("error_title", comment: ""), message: error.description)
        }
        model.onGameOver = { [weak self] isSuccess in
            self?.wordTextField.resignFirstResponder()

            self?.presentAlert(
                title: NSLocalizedString("game_over", comment: "Title of alert when game is over!"),
                message: isSuccess ? NSLocalizedString("success_title", comment: "") : NSLocalizedString("fail_title", comment: ""))
        }
    }

    private func addCharacterBox(word: String) {
        guard let currentCharacterStackView = currentCharacterStackView else {
            return
        }
        currentCharacterStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for i in 0..<Global.wordLength {
            let labelContainerView = UIView()

            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 44)
            label.textColor = .white
            label.textAlignment = .center
            if word.count > i {
                label.text = String(word[word.index(word.startIndex, offsetBy: i)])
                    .uppercased(with: Locale(identifier: "tr-TR"))
            } else {
                label.text = " "
            }

            labelContainerView.layer.borderWidth = 2.0
            labelContainerView.layer.borderColor = UIColor(named: "border")?.cgColor
            labelContainerView.backgroundColor = UIColor(named: "border")
            labelContainerView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: labelContainerView.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: labelContainerView.trailingAnchor, constant: -8),
                label.topAnchor.constraint(equalTo: labelContainerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: labelContainerView.bottomAnchor, constant: -8),
                labelContainerView.widthAnchor.constraint(equalTo: labelContainerView.heightAnchor)
            ])
            currentCharacterStackView.addArrangedSubview(labelContainerView)
        }
    }

    private func addStackViewForNewWord() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        baseStackView.addArrangedSubview(stackView)

        currentCharacterStackView = stackView
        wordTextField.text = ""
        addCharacterBox(word: "")
    }

    private func apply(_ wordComplete: WordComplete) {
        guard let currentCharacterStackView = currentCharacterStackView else {
            return
        }
        for i in 0..<currentCharacterStackView.arrangedSubviews.count {
            let view = currentCharacterStackView.arrangedSubviews[i]
            if wordComplete.matchedIndexes.contains(i) {
                let color = UIColor(named: "green")
                view.layer.borderColor = color?.cgColor
                view.backgroundColor = color
            } else if wordComplete.nearlyMatchedIndexes.contains(i) {
                let color = UIColor(named: "yellow")
                view.layer.borderColor = color?.cgColor
                view.backgroundColor = color
            }
        }

        if baseStackView.arrangedSubviews.count != Global.totalTryCount &&
           wordComplete.matchedIndexes.count != Global.wordLength {
            addStackViewForNewWord()
        }
    }

    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc func textDidChange(_ sender: UITextField) {
        model.currentInput = sender.text!
    }
}

extension GameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return model.canProvide(input: updatedText)
        }
        return true
    }
}
