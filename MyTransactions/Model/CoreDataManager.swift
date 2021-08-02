//
//  DataManager.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/30/21.
//

import Foundation
import CoreData
import Combine

class CoreDataManager {
    
    let persistantContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        persistantContainer.viewContext
    }
    
    static let shared = CoreDataManager()
    
    private init() {
        persistantContainer = NSPersistentContainer(name: "Transaction")
        persistantContainer.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading CORE DATA, \(error)")
            }
        }
    }
    
    func getAllTransactions(with request: NSFetchRequest<Transaction> = Transaction.fetchRequest()) -> [Transaction] {
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching transactions, \(error)")
            return []
        }
    }
    
    func getTransactionById(id: NSManagedObjectID) -> Transaction? {
        do {
            return try viewContext.existingObject(with: id) as? Transaction
        } catch {
            return nil
        }
        
    }
    
    func deleteTransaction(transaction: Transaction) {
        viewContext.delete(transaction)
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving, \(error)")
        }
    }
    
    
}
