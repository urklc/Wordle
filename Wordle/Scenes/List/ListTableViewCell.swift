//
//  ListTableViewCell.swift
//  Wordle
//
//  Created by Uğur Kılıç on 18.05.2022.
//

import Foundation
import UIKit

final class ListTableViewCell: UITableViewCell {

    var game: Game? {
        didSet {
            if let game = game {
                switch game.state {
                case .pending(let remainingWords):
                    infoLabel.text = String(format: NSLocalizedString("in_progress_game_info", comment: ""),
                                                  remainingWords)
                    statusView.backgroundColor = UIColor(named: "yellow")
                case .completed(let isSuccess):
                    let failMessage = isSuccess ? NSLocalizedString("success_title", comment: "") : NSLocalizedString("fail_title", comment: "")
                    infoLabel.text = "\(failMessage) - \(game.targetWord)"

                    statusView.backgroundColor = UIColor(named: isSuccess ? "green" : "red")
                }
            } else {
                infoLabel.text = nil
                statusView.backgroundColor = .clear
            }
        }
    }

    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var statusView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .systemGroupedBackground
        contentView.backgroundColor = .systemGroupedBackground
        selectionStyle = .none

        statusView.superview?.layer.cornerRadius = 20.0
        statusView.layer.cornerRadius = statusView.frame.width / 2
    }
}
