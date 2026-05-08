//
//  QuadrantDetailListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/8.
//

import Foundation

class QuadrantDetailListInteractor: QuadrantListInteractor {

    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        
        self.placeholderProvider.emptyImage = quadrant.placeholderImage
        self.placeholderProvider.emptyTitle = resGetString("No Tasks")
        self.placeholderProvider.emptyTitleColor = .systemGray3
        self.placeholderProvider.emptyTitleFont = BOLD_BODY_FONT
    }

    override func title() -> TextRepresentable? {
        if let iconName = quadrant.iconName, let image = resGetImage(iconName) {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: quadrant.color,
                            trailingText: quadrant.title,
                            separator: " ")
            return title
        }
        
        return super.title()
    }
}
