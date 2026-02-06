//
//  FocusRecordListCellLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/29.
//

import Foundation
import UIKit

class FocusRecordListCellLayout {
    
    /// 内容内间距
    static var contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
    
    /// 头视图高度
    static var headerViewHeight = 70.0
    
    /// 信息视图高度
    static var infoViewHeight = 90.0
    
    static var noteLabelPadding = UIEdgeInsets(horizontal: 10.0, vertical: 10.0)
    
    static var noteLabelFont = BOLD_SMALL_SYSTEM_FONT
    
    var width: CGFloat = 0.0
    
    var noteLabelHeight: CGFloat {
        guard let note = session.note?.whitespacesAndNewlinesTrimmedString, note.count > 0 else {
            return 0.0
        }
       
        /// 计算备注高度
        let noteWidth = width - Self.contentPadding.horizontalLength - Self.noteLabelPadding.horizontalLength
        let maxSize = CGSize(width: noteWidth, height: .greatestFiniteMagnitude)
        let noteSize = note.size(with: Self.noteLabelFont, maxSize: maxSize)
        let noteHeight = noteSize.height + Self.noteLabelPadding.verticalLength
        return noteHeight
    }
    
    let session: FocusSession
    
    init(session: FocusSession) {
        self.session = session
    }
    
    var cellSize: CGSize {
        var height = Self.contentPadding.verticalLength + Self.headerViewHeight + Self.infoViewHeight
        height += noteLabelHeight
        return CGSize(width: width, height: height)
    }
    
}
