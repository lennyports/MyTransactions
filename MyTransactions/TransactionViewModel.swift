//
//  TransactionViewModel.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/22/21.
//

import Foundation
import CoreData
import Combine
import UIKit

class TransactionViewModel: ObservableObject {
    
    var transactions = CurrentValueSubject<[Transaction], Never>([Transaction]())
    
    let container = NSPersistentContainer(name: "Transaction")
    
    init() {
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading CORE DATA, \(error)")
            } else {
                self.loadTransactions()
            }
        }
    }
    
    
    var transactionTotal: Double {
        var amounts: [Double] = []
        _ = transactions.value.map { amounts.append($0.isReturn ? -$0.amount : $0.amount) }
        return amounts.reduce(0.0, +)
    }
    
    var transactionsTotalString: String {
        transactionTotal.toUsDollars
    }
    
    func dateAsString(index: Int) -> String {
        transactions.value[index].date!.toString
    }
    
    func amountAsString(index: Int) -> String {
        let transaction = transactions.value[index]
        return transaction.isReturn ? "+\(transaction.amount.toUsDollars)" : transaction.amount.toUsDollars
    }
    
    func getAmountTextColor(index: Int) -> UIColor {
        return transactions.value[index].isReturn ? .systemGreen : .label
    }
    
    var sortCriteria: SortCriteria = .date {
        didSet { loadTransactions() }
    }
    
    
    
    //MARK - Model manipulation methods
    
    func addTransaction(merchant: String, amount: Double, date: Date, note: String, isReturn: Bool) {
        let newTransaction = Transaction(context: container.viewContext)
        newTransaction.merchant = merchant
        newTransaction.amount = amount
        newTransaction.date = date
        newTransaction.note = note
        newTransaction.isReturn = isReturn
        
        saveData()
    }
    
    func loadTransactions(predicates: NSCompoundPredicate? = nil) {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        if let safePredicates = predicates {
            request.predicate = safePredicates
        }
        
        let isAscending = sortCriteria == .merchant ? true : false
        let sort = NSSortDescriptor(key: sortCriteria.rawValue, ascending: isAscending)
        request.sortDescriptors = [sort]
        
        do {
            transactions.value = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
    }
    
    func updateTransactions(index: Int, merchant: String, amount: Double, date: Date, note: String, isReturn: Bool) {
        transactions.value[index].merchant = merchant
        transactions.value[index].amount = amount
        transactions.value[index].date = date
        transactions.value[index].note = note
        transactions.value[index].isReturn = isReturn
        saveData()
    }
    
    func deleteTransaction(index: Int) {
        let transactionToDelete = transactions.value[index]
        container.viewContext.delete(transactionToDelete)
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            loadTransactions()
        } catch {
            print("Error saving, \(error)")
        }
    }
    
}


