//
//  WorkspaceTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/18.
//

import Foundation
import UIKit

/// 工作台导航栏标题视图。
///
/// 显示当前面板名称，点击后由外部弹出面板管理界面。
class WorkspaceTitleView: UIView {
    
    /// 点击标题回调
    var didClickTitle: (() -> Void)?
    
    /// 当前面板
    var dashboard: WSDashboard? {
        didSet {
            updateTitle()
        }
    }
    
    /// 标题颜色
    var titleColor: UIColor = resGetColor(.navigationBar, .title)
    
    /// 标题按钮
    private lazy var titleButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.imagePosition = .right
        button.imageConfig.size = .size(4)
        button.imageConfig.shouldRenderImageWithColor = true
        button.imageConfig.color = titleColor
        button.imageName = "chevron_upDown_16"
        button.titleConfig.textColor = titleColor
        button.titleConfig.font = .boldSystemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(clickTitle(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleButton)
        updateTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleButton.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return titleButton.sizeThatFits(size)
    }
    
    /// 更新标题显示
    func updateTitle() {
        titleButton.title = dashboard?.name ?? WSDashboard.defaultName
        sizeToFit()
    }
    
    // MARK: - Event Response
    /// 点击标题
    @objc func clickTitle(_ button: UIButton) {
        didClickTitle?()
    }
}
