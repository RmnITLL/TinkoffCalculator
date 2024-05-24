//
//  HistoryTableViewCell.swift
//  TinkoffCalculator
//
//  Created by R Kolos on 24.05.2024.
//

import Foundation
import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var expressionLabel: UILabel!
    @IBOutlet private weak var resultLabel: UILabel!
    
    func configure(with exression: String, result: String) {
        expressionLabel.text = exression
        resultLabel.text = result
    }
}
