//
//  UIViewController+Extension.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/29/21.
//

import UIKit

extension UIViewController {
    
    func dismissKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Invalid Input", message: "A valid transaction input must meet the requirements below: \n1. Ensure the merchant and amount fields must not be empty.\n2. The selected date is not in the future.\n3. The amount must be between $0.01 and $99.99", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { alertAction in }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
