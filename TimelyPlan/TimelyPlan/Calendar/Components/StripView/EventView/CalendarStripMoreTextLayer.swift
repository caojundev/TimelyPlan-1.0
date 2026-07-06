//
//  CalendarStripMoreTextLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/26.
//

import Foundation

class CalendarStripMoreTextLayer: CATextLayer {
    
    var column: Int

    init(column: Int) {
        self.column = column
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func layer(with column: Int, string: String?) -> CalendarStripMoreTextLayer {
        let textLayer = CalendarStripMoreTextLayer(column: column)
        textLayer.string = string
        textLayer.fontSize = 12.0
        textLayer.foregroundColor = UIColor.systemGray2.cgColor
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
}
