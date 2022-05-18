//
//  ListViewController.swift
//  Wordle
//
//  Created by Uğur Kılıç on 17.01.2022.
//

import Foundation
import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var emptyGameView: UIView!

    private let database = GameRealmDatabase()

    private var items: [Game] = [] {
        didSet {
            tableView.reloadData()
            tableView.isHidden = items.isEmpty
            emptyGameView.isHidden = !items.isEmpty
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGroupedBackground

        newGameLabel.textColor = .label
        newGameLabel.text = NSLocalizedString("empty_game_info", comment: "")

        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "GameCell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! ListTableViewCell
        let game = items[indexPath.row]
        cell.game = game
        return cell
    }
}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = items[indexPath.row]
        proceedToGame(game: game)
    }
}
