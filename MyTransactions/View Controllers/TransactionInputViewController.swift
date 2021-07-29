//
//  NewTransactionViewController.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/22/21.
//

import Foundation
import UIKit

class TransactionInputViewController: UIViewController {
    
    var transactionVM: TransactionViewModel?
    var isNewTransaction = true
    var selectedIndex: Int?
    var merchant: String = ""
    var inputAmount: Int = 0
    var amount: Double = 0.0
    var date = Date()
    var note: String = ""
    var isReturn = false
    
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
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        merchant = merchantTextField.text!
        date = datePicker.date
        note = notesTextField.text!
        isReturn = (purchaseReturnSegmentedControl.selectedSegmentIndex == 1)
        
        guard isValidInput() else {
            showAlert(alertDescription: "A valid transaction input must meet the requirements below: \n1. Ensure the merchant and amount fields must not be empty.\n2. The selected date is not in the future.\n3. The amount must be between $0.01 and $99.99")
            return
        }
        
        if isNewTransaction {
            transactionVM?.addTransaction(merchant: merchant, amount: amount, date: date, note: note, isReturn: isReturn)
        } else {
            transactionVM?.updateTransactions(index: selectedIndex!, merchant: merchant, amount: amount, date: date, note: note, isReturn: isReturn)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadTransaction() {
        let transaction = (transactionVM?.transactions.value[selectedIndex!])!
        merchantTextField?.text = transaction.merchant
        amountTextField?.text = transaction.amount.toUsDollars
        purchaseReturnSegmentedControl.selectedSegmentIndex = transaction.isReturn ? 1 : 0
        datePicker?.date = transaction.date!
        notesTextField?.text = transaction.note
        amount = transaction.amount
    }
    
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
    
    private func showAlert(alertDescription: String) {
        let alertController = UIAlertController(title: "Invalid Input", message: alertDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { alertAction in }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
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
