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

    private let database = GameDatabase()

    private var items: [Game] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Game")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Game", for: indexPath)
        let game = items[indexPath.row]
        cell.textLabel?.text = "\(game.words.count) - \(game.date)"
        cell.textLabel?.textColor = game.isSuccess ? .systemGreen : (game.words.count == Global.totalTryCount ? .red : .darkGray)
        return cell
    }
}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = items[indexPath.row]
        proceedToGame(game: game)
    }
}
