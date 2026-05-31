//
//  CalendarEventListHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/31.
//

import Foundation
import UIKit

class CalendarEventListHeaderView: UIView {
  
    /// 点击添加
    var didClickAdd: (() -> Void)?
    
    var date: Date? {
        didSet {
            updateDateInfo()
        }
    }
    
    /// 日期标签
    private lazy var dateInfoView: TPInfoView = {
        let view = TPInfoView()
        view.padding = UIEdgeInsets(vertical: 2.0)
        view.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        view.titleConfig.textColor = resGetColor(.title)
        view.titleConfig.textAlignment = .left
        
        view.subtitleConfig.font = .boldSystemFont(ofSize: 10.0)
        view.subtitleConfig.textColor = .secondaryLabel
        view.subtitleConfig.textAlignment = .left
        return view
    }()

    /// 添加按钮
    private(set) lazy var addButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.image = resGetImage("plus_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self,
                         action: #selector(clickAdd(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.padding = UIEdgeInsets(horizontal: 16.0)
        addSubview(dateInfoView)
        addSubview(addButton)
        addSeparator(position: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.layoutFrame()
        dateInfoView.width = layoutFrame.width / 2.0
        dateInfoView.height = layoutFrame.height
        dateInfoView.left = layoutFrame.minX
        dateInfoView.top = layoutFrame.minY
        
        addButton.size = .size(8)
        addButton.right = layoutFrame.maxX
        addButton.centerY = layoutFrame.midY
    }
    
    @objc func clickAdd(_ button: UIButton) {
        didClickAdd?()
    }

    func updateDateInfo() {
        dateInfoView.title = date?.yearMonthDayString(omitYear: true, showRelativeDate: false)
        dateInfoView.subtitle = date?.weekdaySymbol(style: .full)
    }
}
