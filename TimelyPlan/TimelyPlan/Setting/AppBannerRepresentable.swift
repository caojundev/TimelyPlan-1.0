//
//  AppBannerRepresentable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/12.
//

import Foundation
import UIKit

// MARK: - 会员横幅协议
/// 设置页会员横幅协议：提供指定宽度下的横幅整体高度
protocol AppBannerRepresentable: UIView {
    
    /// 指定宽度下横幅的整体高度
    func bannerHeight(forWidth width: CGFloat) -> CGFloat
}

extension MemberBannerView: AppBannerRepresentable {
    
    func bannerHeight(forWidth width: CGFloat) -> CGFloat {
        return recommendedHeight(forWidth: width)
    }
}

extension AppProUpgradeBannerView: AppBannerRepresentable {
    
    func bannerHeight(forWidth width: CGFloat) -> CGFloat {
        return cardHeight + contentPadding.verticalLength
    }
}
