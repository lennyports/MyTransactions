//
//  ViewController.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/22/21.
//

import UIKit
import Combine

class TransactionsViewController: UITableViewController {
    
    var transactionListVM = TransactionListViewModel()
    var cancellable: AnyCancellable?
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        setupTransactionListSubscriber()
    }
    
    private func setupTransactionListSubscriber() {
        cancellable = transactionListVM.transactions.sink { _ in
            self.tableView.reloadData()
            self.totalLabel.text = self.transactionListVM.transactionsTotalString
        }
    }
    
    
    // MARK: - UI actions received
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToNewTransaction", sender: self)
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        transactionListVM.getAllTransactions()
    }
    
    @IBAction func sortSegmentSelected(_ sender: UISegmentedControl) {
        transactionListVM.configureSortCriteria(selectedSegmentIndex: sender.selectedSegmentIndex)
    }
    
}



extension TransactionsViewController {
    // MARK: - Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactionListVM.transactions.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        let transaction = transactionListVM.transactions.value[indexPath.row]
        cell.configureCell(transaction: transaction)
        
        return cell
    }
    
    
    // MARK: - Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTransactionDetail", sender: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05){
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as! UINavigationController
        let transactionInputVC = navVC.topViewController as! TransactionInputViewController
        
        if segue.identifier == "goToTransactionDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                transactionInputVC.isNewTransaction = false
                transactionInputVC.selectedIndex = indexPath.row
            }
        }
        transactionInputVC.transactionListVM = transactionListVM
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let transactionToDelete = transactionListVM.transactions.value[indexPath.row]
            transactionListVM.deleteTransaction(transactionToDelete)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}


// MARK: - Search bar methods
extension TransactionsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getFilteredList(searchBarText: searchBar.text!)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count >= 3 {
            getFilteredList(searchBarText: searchBar.text!)
        }
        
        if searchBar.text?.count == 0 {
            transactionListVM.getAllTransactions()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.sortSegmentedControl.isEnabled = true
            }
        }
    }
    
    private func getFilteredList(searchBarText: String) {
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "merchant CONTAINS[cd] %@", searchBarText), NSPredicate(format: "amount CONTAINS[cd] %@", searchBarText), NSPredicate(format: "note CONTAINS[cd] %@", searchBarText)])
        transactionListVM.getAllTransactions(predicates: compoundPredicate)
        sortSegmentedControl.isEnabled = false
    }
    
}
