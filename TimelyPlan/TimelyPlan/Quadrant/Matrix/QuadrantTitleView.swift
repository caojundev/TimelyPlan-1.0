//
//  QuadrantTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/26.
//

import Foundation
import UIKit

/// 标题位置
enum QuadrantTitlePosition: Int, Codable, Equatable {
    case top = 0
    case bottom

    var title: String {
        switch self {
        case .top:
            return resGetString("Top")
        case .bottom:
            return resGetString("Bottom")
        }
    }
}

protocol QuadrantTitleViewDelegate: AnyObject {
    
    /// 点击添加按钮
    func quadrantTitleViewDidClickAdd(_ titleView: QuadrantTitleView)
}

class QuadrantTitleView: UIView {
    
    /// 代理对象
    weak var delegate: QuadrantTitleViewDelegate?

    var quadrant: Quadrant {
        didSet {
            if quadrant != oldValue {
                updateContent()
            }
        }
    }
    
    var position: QuadrantTitlePosition {
        didSet {
            if position != oldValue {
                updateSeparatorPosition()
            }
        }
    }
    
    /// 信息视图
    private let infoView = TPImageInfoView()
    
    /// 更多按钮
    private(set) lazy var addButton: TPDefaultButton = {
        let image = resGetImage("plus_24")
        let button = TPDefaultButton.button(with: image)
        button.didClickHandler = { [weak self] in
            self?.clickMore()
        }
        
        return button
    }()
    
    init(quadrant: Quadrant, position: QuadrantTitlePosition = .top) {
        self.quadrant = quadrant
        self.position = position
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        padding = UIEdgeInsets(horizontal: 10.0)
        infoView.imageConfig.shouldRenderImageWithColor = true
        infoView.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        infoView.rightAccessoryView = addButton
        infoView.rightAccessorySize = .mini
        updateContent()
        addSubview(infoView)
        addSeparator()
        updateSeparatorPosition()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = layoutFrame()
    }

    private func updateContent() {
        let color = quadrant.color
        backgroundColor = color.withAlphaComponent(0.1)
        separatorColor = color.withAlphaComponent(0.2)
        infoView.imageContent = .withName(quadrant.iconName)
        infoView.imageConfig.color = color
        infoView.titleConfig.textColor = color
        infoView.title = quadrant.title
        addButton.imageConfig.color = color
    }
    
    private func updateSeparatorPosition() {
        if position == .top {
            separatorPosition = .bottom
        } else {
            separatorPosition = .top
        }
    }
    
    // MARK: - Event Response
    /// 点击更多
    func clickMore() {
        delegate?.quadrantTitleViewDidClickAdd(self)
    }
}
