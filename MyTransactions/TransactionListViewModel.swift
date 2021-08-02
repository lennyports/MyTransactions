//
//  TransactionListViewModel.swift
//  MyTransactions
//
//  Created by Lenny Ports on 8/1/21.
//

import CoreData
import Combine

class TransactionListViewModel: ObservableObject {
    
    var merchant: String = ""
    var amount: Double = 0.00
    var date: Date = Date()
    var note: String = ""
    var isReturn: Bool = false
    var sortCriteria: SortCriteria = .date
    
    // Publisher
    var transactions = CurrentValueSubject<[TransactionViewModel], Never>([TransactionViewModel]())
    
    init() {
        getAllTransactions()
    }
    
    // MARK: - Computed properties
    var transactionTotal: Double {
        var amounts: [Double] = []
        _ = transactions.value.map { amounts.append($0.isReturn ? -$0.amount : $0.amount) }
        return amounts.reduce(0.0, +)
    }

    var transactionsTotalString: String {
        transactionTotal.toUsDollars
    }
    
    // MARK: - Helper functions
    func configureSortCriteria(selectedSegmentIndex: Int) {
        switch selectedSegmentIndex {
        case 0:
            sortCriteria = .date
        case 1:
            sortCriteria = .merchant
        case 2:
            sortCriteria = .amount
        default:
            return
        }
        getAllTransactions()
    }
        
    
    // MARK: - Model manipulation methods (calls to the CoreDataManager methods)
    func getAllTransactions(predicates: NSCompoundPredicate? = nil) {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        if let safePredicates = predicates {
            request.predicate = safePredicates
        }
        
        let isAscending = sortCriteria == .merchant ? true : false
        let sort = NSSortDescriptor(key: sortCriteria.rawValue, ascending: isAscending)
        request.sortDescriptors = [sort]
        
        transactions.value = CoreDataManager.shared.getAllTransactions(with: request).map(TransactionViewModel.init)
    }
    
    func save() {
        CoreDataManager.shared.save()
        getAllTransactions()
    }
    
    func addTransaction() {
        let transaction = Transaction(context: CoreDataManager.shared.viewContext)
        transaction.merchant = merchant
        transaction.amount = amount
        transaction.date = date
        transaction.note = note
        transaction.isReturn = isReturn
        save()
    }
    
    func deleteTransaction(_ transaction: TransactionViewModel) {
        guard let transactionToDelete = CoreDataManager.shared.getTransactionById(id: transaction.id) else { return }
        CoreDataManager.shared.deleteTransaction(transaction: transactionToDelete)
        save()
    }
    
    func updateTransaction(_ transaction: TransactionViewModel) {
        guard let transactionToUpdate = CoreDataManager.shared.getTransactionById(id: transaction.id) else { return }
        transactionToUpdate.merchant = merchant
        transactionToUpdate.amount = amount
        transactionToUpdate.date = date
        transactionToUpdate.note = note
        transactionToUpdate.isReturn = isReturn
        save()
    }
    
}
