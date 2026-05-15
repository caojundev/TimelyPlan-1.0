//
//  TPMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/15.
//

import Foundation
import UIKit

class TPMoreBarButtonItem: UIBarButtonItem {
    
    var didClickMore: (() -> Void)?
    
    private(set) lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.image = resGetImage("ellipsis_24")
        button.imageConfig.color = resGetColor(.title)
        return button
    }()
    
    override init() {
        super.init()
        moreButton.addTarget(self, action: #selector(clickMore), for: .touchUpInside)
        self.customView = moreButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickMore() {
        didClickMore?()
    }
    
}

