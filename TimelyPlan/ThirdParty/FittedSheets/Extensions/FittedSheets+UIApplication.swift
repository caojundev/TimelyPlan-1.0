//
//  FittedSheets+UIApplication.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/20.
//

import Foundation

extension UIApplication {
    var activeWindow: UIWindow? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            .flatMap { $0.windows.first }
    }
}
