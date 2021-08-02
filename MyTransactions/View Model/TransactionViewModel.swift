//
//  TransactionViewModel.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/22/21.
//

import CoreData
import UIKit

struct TransactionViewModel {
    
    let transaction: Transaction
    
    var id: NSManagedObjectID {
        transaction.objectID
    }
    
    var merchant: String {
        transaction.merchant ?? ""
    }
    var amount: Double {
        transaction.amount
    }
    var date: Date {
        transaction.date ?? Date()
    }
    var note: String {
        transaction.note ?? ""
    }
    var isReturn: Bool {
        transaction.isReturn
    }
    

    var dateAsString: String {
        transaction.date!.toString
    }

    var amountAsString: String {
        transaction.isReturn ? "+\(transaction.amount.toUsDollars)" : transaction.amount.toUsDollars
    }

    var amountTextColor: UIColor {
        transaction.isReturn ? .systemGreen : .label
    }
}


