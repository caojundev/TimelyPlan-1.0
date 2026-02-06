//
//  FocusEndScoreCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/20.
//

import Foundation
import UIKit

class FocusEndScoreCellItem: TPCollectionCellItem {
    
    /// 评分
    var score: CGFloat = 0.0
    
    override init() {
        super.init()
        self.registerClass = FocusEndScoreCell.self
        self.canHighlight = false
        self.height = 300.0
        self.contentPadding = UIEdgeInsets(value: 10.0)
    }
}

class FocusEndScoreCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! FocusEndScoreCellItem
            let score = cellItem.score
            self.scoreView.setValue(0, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.scoreView.setValue(score, animated: true)
            }
            
            scoreInfoView.title = "\(Int(score))"
        }
    }
    
    /// 标题信息视图
    private(set) lazy var scoreInfoView: TPInfoView = {
        let infoView = TPInfoView()
        infoView.subtitleTopMargin = 8.0
        infoView.titleConfig.adjustsFontSizeToFitWidth = true
        infoView.titleConfig.font = UIFont.boldSystemFont(ofSize: 36.0)
        infoView.subtitle = resGetString("Focus Score")
        return infoView
    }()
    
    private var scoreView = OpenCircleSlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scoreView.valueView.isHidden = true
        scoreView.isUserInteractionEnabled = false
        scoreView.addSubview(scoreInfoView)
        scoreView.value = 0.0
        contentView.addSubview(scoreView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        
        scoreView.padding = UIEdgeInsets(value: 5.0)
        scoreView.frame = layoutFrame.middleCircleRect
        scoreInfoView.frame = scoreView.progressInnerLayoutFrame
    }
}
