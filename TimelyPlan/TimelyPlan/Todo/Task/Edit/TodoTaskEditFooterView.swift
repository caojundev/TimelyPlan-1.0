//
//  TodoTaskEditFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/9.
//

import Foundation

protocol TodoTaskEditFooterViewDelegate: AnyObject {
    
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

    /// 返回按钮
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
        addSubview(moreButton)
        addSubview(dateLabel)
        addSeparator(position: .top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.layoutFrame()
        moreButton.sizeToFit()
        moreButton.right = layoutFrame.maxX
        moreButton.alignVerticalCenter()
        
        let margin = moreButton.width
        dateLabel.width = layoutFrame.width - 2 * margin
        dateLabel.height = layoutFrame.height
        dateLabel.left = margin
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
    @objc func clickMore(_ button: UIButton) {
        delegate?.todoTaskEditFooterViewDidClickMore(self)
    }

}
