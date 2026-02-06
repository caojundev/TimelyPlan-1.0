//
//  TodoTaskEditDetailView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/13.
//

import Foundation
import UIKit

class TodoTaskEditDetailView: UIView {
    
    /// 富文本信息
    var attributedInfo: ASAttributedString? {
        didSet {
            self.infoLabel.attributed.text = attributedInfo
            self.setNeedsLayout()
        }
    }
    
    /// 内容高度
    var contentHeight: CGFloat {
        layout.width = width
        layout.padding = padding
        layout.attributedInfo = attributedInfo
        layout.font = infoLabel.font
        return layout.height
    }
    
    /// 布局对象
    private let layout = TodoTaskEditDetailLayout()
    
    private(set) lazy var infoLabel: TPLabel = {
        let label = TPLabel()
        label.font = UIFont.boldSystemFont(ofSize: 10.0)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        padding = UIEdgeInsets(top: 5.0, left: 55.0, bottom: 5.0, right: 10.0)
        addSubview(infoLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoLabel.frame = layoutFrame()
    }
}

private class TodoTaskEditDetailLayout {
    
    /// 富文本信息
    var attributedInfo: ASAttributedString? {
        didSet {
            if attributedInfo != oldValue {
                needsLayout = true
            }
        }
    }
    
    /// 字体
    var font: UIFont = BOLD_BODY_FONT {
        didSet {
            if font != oldValue {
                needsLayout = true
            }
        }
    }
    
    /// 内容内间距
    var padding: UIEdgeInsets = .zero {
        didSet {
            if padding != oldValue {
                needsLayout = true
            }
        }
    }
    
    /// 最大高度
    var maximumHeight: CGFloat = .greatestFiniteMagnitude {
        didSet {
            if maximumHeight != oldValue {
                needsLayout = true
            }
        }
    }

    /// 内容宽度
    var width: CGFloat? {
        didSet {
            if width != oldValue {
                needsLayout = true
            }
        }
    }
    
    /// 高度
    var height: CGFloat {
        guard needsLayout else {
            return validatedHeight(_height)
        }
        
        guard let width = width, let attributedInfo = attributedInfo else {
            _height = validatedHeight(0.0)
            needsLayout = false
            return _height
        }

        needsLayout = false
        let maxWidth = width - padding.horizontalLength
        let maxSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let size = attributedInfo.value.size(with: font, maxSize: maxSize)
        let contentHeight = ceil(size.height) + padding.verticalLength
        _height = validatedHeight(contentHeight)
        return _height
    }
    
    /// 最小高度
    var minimumHeight: CGFloat = 0.0
    
    private var needsLayout: Bool = true
    
    private var _height: CGFloat = 0.0
    
    private func validatedHeight(_ height: CGFloat) -> CGFloat {
        return min(maximumHeight, max(height, minimumHeight))
    }
}
