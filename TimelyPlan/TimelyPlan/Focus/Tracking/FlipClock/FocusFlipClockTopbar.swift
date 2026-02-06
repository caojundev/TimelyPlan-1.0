//
//  FocusFlipClockTopbar.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/17.
//

import Foundation
import UIKit

class FocusFlipClockTopbar: UIView {
    
    var didClickClose: (() -> Void)?
    
    /// 标题
    var title: String? {
        didSet {
            titleView.title = title
        }
    }
    
    /// 副标题
    var subtitle: String? {
        didSet {
            titleView.subtitle = subtitle
        }
    }
    
    /// 关闭按钮
    private lazy var closeButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.image = resGetImage("xmark_circle_fill_24")
        button.imageConfig.color = Color(0xFFFFFF, 0.6)
        button.addTarget(self, action: #selector(clickClose), for: .touchUpInside)
        return button
    }()
    
    /// 标题视图
    private lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.textColor = .white
        view.titleConfig.textAlignment = .center
        view.subtitleConfig.textColor = Color(0xFFFFFF, 0.6)
        view.subtitleConfig.textAlignment = .center
        view.padding = UIEdgeInsets(horizontal: 10.0)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 20.0, vertical: 5.0)
        addSubview(titleView)
        addSubview(closeButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        closeButton.sizeToFit()
        closeButton.alignVerticalCenter()
        closeButton.left = layoutFrame.minX
        
        titleView.width = layoutFrame.width - 2.0 * closeButton.width
        titleView.height = layoutFrame.height
        titleView.left = closeButton.right
        titleView.top = layoutFrame.minY
    }
    
    @objc func clickClose() {
        didClickClose?()
    }
}
