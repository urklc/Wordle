//
//  ListViewController.swift
//  Wordle
//
//  Created by Uğur Kılıç on 17.01.2022.
//

import Foundation
import UIKit

class ListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    private let database = GameRealmDatabase()

    private var items: [Game] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "background")

        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GameCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        items = database.retrieveGames()
        print(items)
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        proceedToGame(game: nil)
    }

    private func proceedToGame(game: Game?) {
        let model = GameViewModel(game: game)
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(
            withIdentifier: "GameViewController") as! GameViewController
        controller.model = model
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let game = items[indexPath.row]

        cell.textLabel?.textColor = .white
        switch game.state {
        case .pending(let remainingWords):
            cell.textLabel?.text = "Tap to guess the word: \(remainingWords) left!"
            cell.contentView.backgroundColor = UIColor(named: "yellow")
        case .completed(let isSuccess):
            cell.textLabel?.text = isSuccess ? "Success :)" : "Fail :("
            cell.contentView.backgroundColor = UIColor(named: isSuccess ? "green" : "red")
        }

        return cell
    }
}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = items[indexPath.row]
        proceedToGame(game: game)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
