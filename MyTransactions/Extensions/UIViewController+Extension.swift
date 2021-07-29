//
//  UIViewController+Extension.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/29/21.
//

import Foundation
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
}
