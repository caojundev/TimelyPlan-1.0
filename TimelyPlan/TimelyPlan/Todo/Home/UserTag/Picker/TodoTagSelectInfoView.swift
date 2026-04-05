//
//  TodoTagSelectInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/5.
//

import Foundation
import UIKit

class TodoTagSelectInfoView: UIView {
    
    var tags: Set<TodoTag>? {
        didSet {
            let format: String
            let selectedCount = tags?.count ?? 0
            if selectedCount > 1 {
                format = resGetString("%ld tags selected")
            } else {
                format = resGetString("%ld tag selected")
            }
            
            self.textLabel.text = String(format: format, selectedCount)
            self.tagInfoView.attributedInfo = tags?.attributedOrderedTagsInfo()
        }
    }
    
    let descriptionHeight = 20.0
    
    let maxHeight = 60.0
    
    private let textLabel = TPLabel()
    
    private let tagInfoView = TodoTaskEditDetailView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.backgroundColor = .systemBackground
        self.padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        textLabel.textAlignment = .center
        textLabel.font = SMALL_SYSTEM_FONT
        textLabel.textColor = resGetColor(.title)
        addSubview(textLabel)
        
        tagInfoView.infoLabel.textAlignment = .center
        tagInfoView.padding = .zero
        addSubview(tagInfoView)
        addSeparator(position: .top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        self.textLabel.width = layoutFrame.width
        self.textLabel.height = descriptionHeight
        self.textLabel.origin = layoutFrame.origin
        
        self.tagInfoView.width = layoutFrame.width
        self.tagInfoView.height = layoutFrame.height - descriptionHeight
        self.tagInfoView.left = layoutFrame.minX
        self.tagInfoView.top = self.textLabel.bottom
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height = self.padding.verticalLength + descriptionHeight
        tagInfoView.width = size.width - padding.horizontalLength
        height += tagInfoView.contentHeight
        return CGSize(width: size.width, height: min(height, maxHeight))
    }
}
