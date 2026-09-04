//
//  TPMultiColumnEmptyDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/29.
//

import Foundation
import UIKit

class TPMultiColumnEmptyDetailViewController: TPMultiColumnDetailViewController {

    var placeholderTitle: String? {
        get { return emptyView.title }
        set { emptyView.title = newValue }
    }
    
    var placeholderImage: UIImage? {
        get { return emptyView.image }
        set { emptyView.image = newValue }
    }

    private let emptyView = TPDefaultPlaceholderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView.backgroundColor = .systemGroupedBackground
        emptyView.titleColor = .placeholderText
        view.addSubview(emptyView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emptyView.frame = view.bounds
    }
}
