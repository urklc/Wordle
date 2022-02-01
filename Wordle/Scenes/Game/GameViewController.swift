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

        view.backgroundColor = UIColor(named: "background")

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
            if words.count != Global.totalTryCount && !words.contains(targetWord) {
                self?.wordTextField.becomeFirstResponder()
            }
        }
        model.onCharacterSuccess = { [weak self] word in
            self?.addCharacterBox(word: word)
        }
        model.onInputComplete = { [weak self] inputComplete in
            self?.apply(inputComplete)
        }
        model.onError = { [weak self] error in
            self?.presentAlert(title: "hata", message: error.description)
        }
        model.onGameOver = { [weak self] isSuccess in
            self?.wordTextField.resignFirstResponder()
            self?.presentAlert(title: "oyun bitti", message: isSuccess ? "basarili :)" : "basarisiz :(")
        }
    }

    private func addCharacterBox(word: String) {
        guard let lastStackView = baseStackView.arrangedSubviews.last as? UIStackView else {
            return
        }
        lastStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

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
            lastStackView.addArrangedSubview(labelContainerView)
        }
    }

    private func addStackViewForNewWord() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        baseStackView.addArrangedSubview(stackView)

        wordTextField.text = ""
    }

    private func apply(_ inputComplete: InputComplete) {
        guard let lastStackView = baseStackView.arrangedSubviews.last as? UIStackView else {
            return
        }
        for i in 0..<lastStackView.arrangedSubviews.count {
            let view = lastStackView.arrangedSubviews[i]
            if inputComplete.matchedIndexes.contains(i) {
                let color = UIColor(named: "green")
                view.layer.borderColor = color?.cgColor
                view.backgroundColor = color
            } else if inputComplete.nearlyMatchedIndexes.contains(i) {
                let color = UIColor(named: "yellow")
                view.layer.borderColor = color?.cgColor
                view.backgroundColor = color
            }
        }
        addStackViewForNewWord()
    }

    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @objc func textDidChange(_ sender: UITextField) {
        model.tryToProvide(input: sender.text!)
    }
}
