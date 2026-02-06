//
//  ExtensionSwizzler.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/14.
//

import Foundation
import UIKit

class ExtensionSwizzler {
    
    private static var swizzlingConfigured = false

    static func setup() {
        guard !swizzlingConfigured else {
          return
        }
        
        defer { swizzlingConfigured = true }
        UIView.swizzleUIViewMethods()
        UITableView.swizzleUITableViewMethods()
        UICollectionView.swizzleUICollectionViewMethods()
        UIViewController.swizzleUIViewControllerMethods()
    }
}
