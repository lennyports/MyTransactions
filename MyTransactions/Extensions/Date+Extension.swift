//
//  Date+Extension.swift
//  MyTransactions
//
//  Created by Lenny Ports on 7/25/21.
//

import Foundation

extension Date {
    
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        return dateFormatter.string(from: self)
    }
}
