//
//  TPRequestManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

class TPRequestManager {
    
    private(set) var currentRequestID: UUID?
    
    @discardableResult
    func executeRequest() -> UUID {
        let requestID = UUID()
        currentRequestID = requestID
        return requestID
    }
    
    func shouldProceed(with requestID: UUID) -> Bool {
        return requestID == currentRequestID
    }
}
