//
//  WSQuadrantDetailPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 象限详情

/// 象限详情展示。
///
/// 与四象限主页面点击象限标题一致：按象限配置创建详情页，并推入当前导航栈。
enum WSQuadrantDetailPresenter {
    
    static func showDetail(for quadrant: Quadrant, from view: UIView?) {
        guard let navigationController = view?.parentViewController?.navigationController else {
            return
        }
        
        let filterRule = QuadrantSetting.shared.filterRule(for: quadrant)
        let configuration = QuadrantListConfiguration(quadrant: quadrant, filterRule: filterRule)
        let interactor = QuadrantDetailListInteractor(configuration: configuration)
        let viewController = configuration.makeContent(with: interactor)
        
        /// 进入详情后左上角只显示返回箭头
        navigationController.topViewController?.navigationItem.backButtonDisplayMode = .minimal
        navigationController.pushViewController(viewController, animated: true)
    }
}
