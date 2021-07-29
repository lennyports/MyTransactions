//
//  ViewController.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/22/21.
//

import UIKit
import Combine

class TransactionsViewController: UITableViewController {
    
    var transactionVM = TransactionViewModel()
    var cancellable: AnyCancellable?
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        cancellable = transactionVM.transactions.sink { _ in
            self.tableView.reloadData()
            self.totalLabel.text = self.transactionVM.transactionsTotalString
        }
    }
    
    // MARK: - Button actions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToNewTransaction", sender: self)
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        transactionVM.loadTransactions()
    }
    @IBAction func sortSegmentSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            transactionVM.sortCriteria = .date
        case 1:
            transactionVM.sortCriteria = .merchant
        case 2:
            transactionVM.sortCriteria = .amount
        default:
            return
        }
    }
    
    // MARK: - Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactionVM.transactions.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        cell.merchantLabel.text = transactionVM.transactions.value[indexPath.row].merchant
        cell.amountLabel.text = transactionVM.amountAsString(index: indexPath.row)
        cell.amountLabel.textColor = transactionVM.getAmountTextColor(index: indexPath.row)
        cell.dateLabel.text = transactionVM.dateAsString(index: indexPath.row)
        cell.noteLabel.text = transactionVM.transactions.value[indexPath.row].note
        
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
        transactionInputVC.transactionVM = transactionVM
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            transactionVM.deleteTransaction(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.endUpdates()
        }
    }
    
    
    
}


// MARK: - Search bar methods
extension TransactionsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "merchant CONTAINS[cd] %@", searchBar.text!), NSPredicate(format: "amount CONTAINS[cd] %@", searchBar.text!), NSPredicate(format: "note CONTAINS[cd] %@", searchBar.text!)])
        transactionVM.loadTransactions(predicates: compoundPredicate)
        sortSegmentedControl.isEnabled = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            transactionVM.loadTransactions()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.sortSegmentedControl.isEnabled = true
            }
        }
        
        if searchBar.text!.count >= 3 {
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "merchant CONTAINS[cd] %@", searchBar.text!), NSPredicate(format: "amount CONTAINS[cd] %@", searchBar.text!), NSPredicate(format: "note CONTAINS[cd] %@", searchBar.text!)])
            transactionVM.loadTransactions(predicates: compoundPredicate)
            sortSegmentedControl.isEnabled = false
        }
    }
    
}
