//
//  TodoTaskEditFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/9.
//

import Foundation

protocol TodoTaskEditFooterViewDelegate: AnyObject {
    
    /// 点击专注
    func todoTaskEditFooterViewDidClickFocus(_ view: TodoTaskEditFooterView)
    
    /// 点击更多按钮
    func todoTaskEditFooterViewDidClickMore(_ view: TodoTaskEditFooterView)
}

class TodoTaskEditFooterView: UIView {
    /// 日期类型
    enum DateType: Int {
        case created
        case completed
    }

    /// 代理对象
    weak var delegate: TodoTaskEditFooterViewDelegate?
    
    /// 任务
    var task: TodoTask?
    
    /// 日期标签
    private lazy var dateLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    /// 专注按钮
    private(set) lazy var focusButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.image = resGetImage("focus_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self,
                         action: #selector(clickFocus(_:)),
                         for: .touchUpInside)
        return button
    }()

    /// 更多按钮
    private(set) lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.image = resGetImage("ellipsis_circle_fill_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()

    /// 日期信息
    private var dateInfo: (date: Date, type: DateType)? {
        guard let task = task else {
            return nil
        }

        if task.isCompleted, let completionDate = task.completionDate {
            return (completionDate, .completed)
        } else if let creationDate = task.creationDate {
            return (creationDate, .created)
        }
        
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.padding = UIEdgeInsets(horizontal: 16.0)
        addSubview(dateLabel)
        addSubview(focusButton)
        addSubview(moreButton)
        addSeparator(position: .top)
        moreButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.layoutFrame()
        focusButton.size = .size(8)
        focusButton.left = layoutFrame.minX
        focusButton.centerY = layoutFrame.midY
        
        moreButton.size = .size(8)
        moreButton.right = layoutFrame.maxX
        moreButton.centerY = layoutFrame.midY
        
        dateLabel.width = layoutFrame.width - focusButton.width - moreButton.width
        dateLabel.height = layoutFrame.height
        dateLabel.left = focusButton.right
        dateLabel.top = layoutFrame.minY
    }
    
    /// 更新日期文本
    func updateDateInfo() {
        guard let dateInfo = dateInfo else {
            dateLabel.text = nil
            setNeedsLayout()
            return
        }

        let format: String
        if dateInfo.type == .created {
            format = resGetString("Created %@")
        } else {
            format = resGetString("Completed %@")
        }

        let dateString = dateInfo.date.yearMonthDayTimeString(omitYear: true,
                                                              showRelativeDate: true)
        dateLabel.text = String(format: format, dateString)
        setNeedsLayout()
    }
    
    // MARK: - Event Response
    @objc func clickFocus(_ button: UIButton) {
        delegate?.todoTaskEditFooterViewDidClickFocus(self)
    }
    
    @objc func clickMore(_ button: UIButton) {
        delegate?.todoTaskEditFooterViewDidClickMore(self)
    }

}
