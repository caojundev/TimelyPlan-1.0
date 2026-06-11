//
//  TodoHomeSearchView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/11.
//

import Foundation
import UIKit

class TodoHomeSearchView: UIView {
    
    static let height = 60.0
    
    var didClickSearch: (() -> Void)?
    
    private(set) lazy var searchButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Search")
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textAlignment = .center
        button.titleConfig.textColor = .secondaryLabel
        
        button.imageName = "search_24"
        button.imagePosition = .left
        button.imageConfig.size = .mini
        button.imageConfig.color = .secondaryLabel
        button.imageConfig.margins = UIEdgeInsets(right: 8.0)
        
        button.normalBackgroundColor = .secondarySystemBackground
        button.selectedBackgroundColor = .secondarySystemBackground
        button.cornerRadius = 12.0
        button.scaleMaxLength = 4.0
        
        button.addTarget(self, action: #selector(clickSearch(_:)), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        addSubview(searchButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchButton.frame = layoutFrame()
    }
    
    @objc private func clickSearch(_ button: UIButton) {
        didClickSearch?()
    }
}
