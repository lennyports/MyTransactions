//
//  NewTransactionViewController.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/22/21.
//

import UIKit

class TransactionInputViewController: UIViewController {
    
    var transactionListVM: TransactionListViewModel?
    var isNewTransaction = true
    var selectedIndex: Int?
    var inputAmount: Int = 0
    var amount: Double = 0.0
    
    @IBOutlet weak var merchantTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var merchantStackView: UIStackView!
    @IBOutlet weak var amountStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var notesStackView: UIStackView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var purchaseReturnSegmentedControl: UISegmentedControl!
    @IBOutlet weak var headingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        dismissKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isNewTransaction {
            loadTransaction()
            headingLabel.text = "Update Transaction"
        }
    }
    
    
    // MARK: - UI actions received
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        guard isValidInput() else { showAlert(); return }
        
        transactionListVM?.merchant = merchantTextField.text!
        transactionListVM?.amount = amount
        transactionListVM?.date = datePicker.date
        transactionListVM?.note = notesTextField.text!
        transactionListVM?.isReturn = (purchaseReturnSegmentedControl.selectedSegmentIndex == 1)
        
        if isNewTransaction {
            transactionListVM?.addTransaction()
        } else {
            guard let transactionToUpdate = transactionListVM?.transactions.value[selectedIndex!] else { return }
            transactionListVM?.updateTransaction(transactionToUpdate)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadTransaction() {
        let transaction = (transactionListVM?.transactions.value[selectedIndex!])!
        merchantTextField?.text = transaction.merchant
        amountTextField?.text = transaction.amount.toUsDollars
        purchaseReturnSegmentedControl.selectedSegmentIndex = transaction.isReturn ? 1 : 0
        datePicker?.date = transaction.date
        notesTextField?.text = transaction.note
        amount = transaction.amount
    }
    
    
    // MARK: - Helper functions
    
    private func configureUI() {
        merchantStackView.layer.cornerRadius = 6
        amountStackView.layer.cornerRadius = 6
        dateStackView.layer.cornerRadius = 6
        notesStackView.layer.cornerRadius = 6
        containerStackView.layer.cornerRadius = 8
    }
    
    private func isValidInput() -> Bool {
        if merchantTextField.text!.count < 1 || amountTextField.text!.count < 1 || datePicker.date > Date() || amount > 99.99 || amount < 0.01 {
            return false
        }
        return true
    }
}


// MARK: - Textfield delegate methods

extension TransactionInputViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            inputAmount = (inputAmount * 10) + digit
        }

        if string == "" {
            inputAmount = inputAmount / 10
        }
        updateAmount()
        return false
    }

    private func updateAmount() {
        amount = Double(inputAmount)/100
        amountTextField.text = amount.toUsDollars
    }
}
