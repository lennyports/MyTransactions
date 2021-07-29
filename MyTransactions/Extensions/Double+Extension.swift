//
//  Double+Extension.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/25/21.
//

import Foundation

extension Double {
    var toUsDollars: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        return formatter.string(from: NSNumber(value: self)) ?? "Invalid Number"
    }
}
