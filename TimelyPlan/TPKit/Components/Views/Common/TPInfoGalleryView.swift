//
//  TPGalleryInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/20.
//

import Foundation
import UIKit

class TPInfoGalleryView: TPStackView {
    
    /// 分割线边界间距
    private let verticalSeparatorEdgeInset = UIEdgeInsets(top: 15.0, bottom: 10.0)

    private var infoViews: [TPInfoView] = []
    
    init(frame: CGRect, infoViewsCount: Int) {
        super.init(frame: frame)
        self.minimumItemWidth = 80.0
        guard infoViewsCount > 0 else {
            return
        }
        
        for i in 0..<infoViewsCount {
            let infoView = newInfoView()
            if i > 0 {
                infoView.separatorEdgeInset = verticalSeparatorEdgeInset
                infoView.addSeparator(position: .left)
            }
            
            self.infoViews.append(infoView)
        }
        
        self.views = self.infoViews
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.isUserInteractionEnabled = floor(contentView.contentSize.width) > ceil(contentView.frame.width)
    }
    
    
    // MARK: - Public Methods
    
    /// 重置标题
    func resetTitle(with title: String? = "--") {
        infoViews.forEach { view in
            view.title = title
        }
    }
    
    // MARK: - 下标访问视图
    subscript(index: Int) -> TPInfoView {
        get {
            return infoViews[index]
        }
        
        set {}
    }
    
    // 视图数组的个数
    var count: Int {
        return infoViews.count
    }
    
    // MARK: - Helpers
    private func newInfoView(subtitle: String? = nil) -> TPInfoView {
        let textColor = resGetColor(.title)
        let view = TPInfoView()
        view.padding = UIEdgeInsets(horizontal: 10.0)
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 24.0)
        view.titleConfig.textAlignment = .center
        view.titleConfig.textColor = textColor
        
        view.subtitleConfig.adjustsFontSizeToFitWidth = true
        view.subtitleConfig.textColor = textColor
        view.subtitleConfig.textAlignment = .center
        view.subtitleConfig.alpha = 0.5

        view.subtitleTopMargin = 10.0
        view.subtitle = subtitle
        return view
    }
    
}
