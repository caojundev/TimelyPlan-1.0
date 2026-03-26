//
//  FocusStopwatchConfigCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/25.
//

import Foundation

class FocusStopwatchConfigCellItem: TPBaseTableCellItem {
    
    override init() {
        super.init()
        registerClass = FocusStopwatchConfigCell.self
        selectionStyle = .none
        height = 320.0
        contentPadding = UIEdgeInsets(value: 10.0)
    }
}

class FocusStopwatchConfigCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            timerView.progressView.commitStrokeAnimation()
        }
    }
    
    lazy var timerView: StopwatchProgressInfoView = {
        let view = StopwatchProgressInfoView()
        view.infoView.subtitleLabel.text = resGetString("Counting from zero")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(timerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timerView.frame = contentView.layoutFrame()
    }
}

