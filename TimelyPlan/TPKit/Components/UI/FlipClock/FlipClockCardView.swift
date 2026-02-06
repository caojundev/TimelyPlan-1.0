//
//  FlipCard.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/2.
//

import UIKit

class FlipClockCardView: UIView {
    
    /// 圆角半径
    var cornerRadius: CGFloat = 0.0
    
    /// 文本字体
    var font: UIFont? = .robotoMonoBoldFont(size: 300.0)
//        .barlowCondensedFont(size: 300.0)
    
    /// 文本颜色
    var textColor: UIColor = Color(0xFFFFFF, 0.8)
    
    /// 背景颜色
    var backColor: UIColor? = Color(0x232323)
    
    /// 分割线颜色
    var separatorLineColor: UIColor? = Color(0x232323)
    
    /// 分割线高度
    var separatorLineHeight: CGFloat = 2.0
   
    /// 分割区域空白高度
    var separatorSpacing: CGFloat = 8.0
    
    /// 阴影半径
    var shadowRadius: CGFloat = 16.0
    
    /// 阴影颜色
    var shadowColor: UIColor = Color(0x000000, 0.6)
    
    /// 内容间距
    var contentPadding: UIEdgeInsets = .zero
    
    /// 当前文本
    private var text: String?
    
    /// 内容视图
    private let contentView = UIView()
    
    /// 分割线
    private let separator = UIView()
    
    /// 卡片数组
    private var elementViews: [FlipClockCardElementView]

    private var reuseableViews: [FlipClockCardElementView] = []
    
    override init(frame: CGRect) {
        self.elementViews = [FlipClockCardElementView()]
        super.init(frame: frame)
        self.clipsToBounds = false
        self.addSubview(self.contentView)
        self.addSubview(self.separator)
        self.contentView.clipsToBounds = false
        for cardView in elementViews {
            contentView.addSubview(cardView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentView.frame = bounds
        for elementView in elementViews {
            elementView.frame = contentView.bounds
            updateStyle(for: elementView)
        }
        
        separator.backgroundColor = separatorLineColor
        separator.width = width
        separator.height = separatorLineHeight
        separator.alignCenter()
        CATransaction.commit()
    }
    
    private func updateStyle(for elementView: FlipClockCardElementView) {
        elementView.contentPadding = contentPadding
        elementView.cornerRadius = cornerRadius
        elementView.spacing = separatorSpacing
        elementView.font = font
        elementView.textColor = textColor
        elementView.backColor = backColor
        elementView.shadowRadius = shadowRadius
        elementView.shadowColor = shadowColor
        elementView.setNeedsLayout()
        elementView.layoutIfNeeded()
    }

    /// 设置文本
    func setText(_ text: String?, animated: Bool) {
        guard self.text != text else {
            return
        }
        
        if !animated {
            elementViews.last?.text = text
            return
        }
        
        let currentElementView = getElementView()
        currentElementView.text = text
        contentView.insertSubview(currentElementView, at: 0)
        elementViews.insert(currentElementView, at: 0)
    
        let previousView = elementViews.last!
        let _ = elementViews.remove(previousView)
        
        currentElementView.topView.alpha = 0.0
        previousView.rotateTopHalfToMiddle(duration: 0.3) {
            currentElementView.topView.alpha = 1.0
        } completion: { finished in
            self.contentView.bringSubviewToFront(currentElementView)
            currentElementView.rotateBottomHalfFromMiddle(duration: 0.4) {
                previousView.bottomView.alpha = 0.0
            } completion: { finished in
                previousView.removeFromSuperview()
                self.reuseableViews.append(previousView)
            }
        }
    }
    
    private func getElementView() -> FlipClockCardElementView {
        let view: FlipClockCardElementView
        if reuseableViews.count > 0 {
            view = reuseableViews.removeFirst()
        } else {
            view = FlipClockCardElementView()
        }
        
        view.frame = contentView.bounds
        view.reset()
        updateStyle(for: view)
        return view
    }
}
