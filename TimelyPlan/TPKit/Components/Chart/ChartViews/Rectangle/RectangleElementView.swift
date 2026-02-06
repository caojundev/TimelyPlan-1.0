//
//  RectangleElementView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/4.
//

import Foundation
import UIKit

class RectangleElementView: UIView, ChartHighlightEelement {
    
    /// 标记
    var mark: RectangleChartMark

    var highlightText: String? {
        return mark.highlightText
    }

    convenience init(mark: RectangleChartMark) {
        self.init(frame: .zero, mark: mark)
    }
    
    init(frame: CGRect, mark: RectangleChartMark) {
        self.mark = mark
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = .primary
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
