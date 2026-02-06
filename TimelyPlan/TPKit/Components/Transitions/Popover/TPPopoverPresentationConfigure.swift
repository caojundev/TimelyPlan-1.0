//
//  TPPopoverPresentationConfigure.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation
import UIKit

class TPPopoverPresentationConfigure {
    
    /// 弹出源视图
    weak var sourceView: UIView?

    /// 相对源视图区域位置尺寸信息
    var sourceRect: CGRect = .zero
    
    /// 源视图是否被遮盖
    var isSourceViewCovered: Bool = false
    
    var cornerRadius: CGFloat = 16.0
    
    /// 边界间距
    var layoutMargins: UIEdgeInsets = UIEdgeInsets(value: 10.0)
    
    /// 首选弹出位置
    var preferredPosition: TPPopoverPosition = .center

    /// 当首选位置不适配时其它允许弹出位置
    var permittedPositions: [TPPopoverPosition] = TPPopoverPosition.allCases

    /// 是否需要遮盖源视图区域
    var shouldCoverSourceViewRect: Bool = true

    /// 遮罩颜色
    var maskColor: UIColor = Color(0x000000, 0.2)

    /// 点击遮罩是否 dismiss 视图控制器
    var shouldDismissWhenTapOnMask = true
}
