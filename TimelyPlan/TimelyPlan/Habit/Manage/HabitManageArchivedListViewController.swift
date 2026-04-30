//
//  HabitManageArchivedListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/6.
//

import Foundation
import UIKit

class HabitManageArchivedListViewController: HabitManageBaseListViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = HabitArchivedTaskViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
