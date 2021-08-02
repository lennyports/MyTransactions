//
//  TransactionTableViewCell.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/22/21.
//

import Foundation
import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    func configureCell(transaction: TransactionViewModel) {
        merchantLabel.text = transaction.merchant
        amountLabel.text = transaction.amountAsString
        amountLabel.textColor = transaction.amountTextColor
        dateLabel.text = transaction.dateAsString
        noteLabel.text = transaction.note
    }
}
