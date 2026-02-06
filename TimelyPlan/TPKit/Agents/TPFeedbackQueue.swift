//
//  TPFeedbackQueue.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/14.
//

import Foundation
import UIKit

class TPFeedback {
    
    enum Position {
        case top
        case middle
        case bottom
    }
    
    /// 反馈文本
    let text: String
    
    /// 反馈文本显示父视图
    var parentView: UIView?
    
    /// 超出范围是否省略文本
    var isOmission: Bool = false
    
    /// 位置
    var position: Position = .middle
    
    init(text: String,
         parentView: UIView?,
         isOmission: Bool = false,
         position: Position = .middle) {
        
        self.text = text
        self.parentView = parentView
        self.isOmission = isOmission
        self.position = position
    }
}

class TPFeedbackQueue: NSObject {
 
    static let common = TPFeedbackQueue()

    /// 当前是否有信息显示
    var isShowing: Bool {
        return feedbackView != nil
    }
    
    /// 反馈条目队列
    private var feedbacks: [TPFeedback] = []
    
    /// 反馈视图
    private var feedbackView: TFFeedbackView?
    
    // MARK: - Private Methods
    func postFeedback(text: String,
                      onView parentView: UIView? = nil,
                      position: TPFeedback.Position = .middle,
                      isOmission: Bool = false) {
        
        for feedback in feedbacks {
            if feedback.text == text {
                /// 暂时只对相同文字的排重，没有区分parentView
                return
            }
        }
        
        let feedback = TPFeedback(text: text,
                                parentView: parentView,
                                isOmission: isOmission,
                                position: position)
        feedbacks.append(feedback)
        beginShowing()
    }

    /// 开始显示
    private func beginShowing() {
        guard feedbacks.count > 0 else {
            return
        }
        
        let feedback = feedbacks.removeFirst()
        showUp(feedback)
    }
    
    private func showUp(_ feedback: TPFeedback) {
        
        if feedbackView != nil {
            feedbackView?.removeFromSuperview()
            feedbackView = nil
        }
        
        guard let parentView = feedback.parentView ?? UIWindow.keyWindow else {
            return
        }
        
        let feedbackView = TFFeedbackView(feedback: feedback)
        parentView.addSubview(feedbackView)
        self.feedbackView = feedbackView
        
        feedbackView.width = parentView.width - 40.0
        feedbackView.sizeToFit()
        
        switch feedback.position {
        case .top:
            feedbackView.top = parentView.safeAreaFrame().minY + 10.0
        case .middle:
            feedbackView.alignVerticalCenter()
        case .bottom:
            feedbackView.bottom = parentView.safeAreaFrame().maxY - 10.0
        }
        
        feedbackView.alignHorizontalCenter()
        
        feedbackView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        feedbackView.alpha = 0.0
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) {
            feedbackView.transform = .identity
            feedbackView.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 1.0, options: .curveEaseIn, animations: {
                feedbackView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                feedbackView.alpha = 0
            }) { _ in
                feedbackView.removeFromSuperview()
                self.feedbackView = nil
                
                self.beginShowing() /// 继续显示
            }
        }
    }
    
}

class TFFeedbackView: UIView {
    
    private lazy var textLabel: TPLabel = {
        let label = TPLabel()
        label.backgroundColor = UIColor.clear
        label.font = BOLD_SYSTEM_FONT
        label.textAlignment = .center
        label.textColor = UIColor(white: 1.0, alpha: 0.8)
        label.text = feedback.text
        if feedback.isOmission {
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingMiddle
        } else {
            label.numberOfLines = 0
        }
        
        return label
    }()
    
    let feedback: TPFeedback
    
    init(feedback: TPFeedback) {
        self.feedback = feedback
        super.init(frame: .zero)
        self.padding = UIEdgeInsets(horizontal: 15.0, vertical: 15.0)
        self.isUserInteractionEnabled = false
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 12.0
        self.backgroundColor = Color(0x000000, 0.9)
        textLabel.frame = layoutFrame()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let constraintSize = CGSize(width: size.width - padding.horizontalLength,
                                    height: size.height - padding.verticalLength)
        let fitSize = textLabel.sizeThatFits(constraintSize)
        return CGSize(width: fitSize.width + padding.horizontalLength,
                      height: fitSize.height + padding.verticalLength)
    }
}
