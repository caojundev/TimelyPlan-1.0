//
//  FocusTimerStartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/5.
//

import Foundation

protocol FocusTimerStartCellDelegate: AnyObject {
    
    /// 点击开始
    func FocusTimerStartCellDidClickStart(_ cell: FocusTimerStartCell)
}

class FocusTimerStartCell: FocusUserTimerInfoCell {
    
    /// 开始按钮
    lazy var startButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(value: 10.0)
        button.image = resGetImage("triangle_right_32")
        button.imageConfig.color = .primary
        button.addTarget(self, action: #selector(clickStart(_:)), for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(startButton)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        startButton.sizeToFit()
        startButton.right = layoutFrame.maxX
        startButton.alignVerticalCenter()
        infoView.width = infoView.width - startButton.width
    }
    
    @objc func clickStart(_ button: UIButton) {
        if let delegate = delegate as? FocusTimerStartCellDelegate {
            delegate.FocusTimerStartCellDidClickStart(self)
        }
    }
    
}
