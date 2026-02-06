//
//  FocusPomodoroConfigCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/25.
//

import Foundation

class FocusPomodoroConfigCellItem: TPBaseTableCellItem {
    
    var config: FocusPomodoroConfig?
    
    /// 结束编辑番茄计时器
    var configDidChange: ((FocusPomodoroConfig) -> Void)?
    
    override init() {
        super.init()
        registerClass = FocusPomodoroConfigCell.self
        selectionStyle = .none
        height = 420.0
        contentPadding = UIEdgeInsets(value: 10.0)
    }
}

class FocusPomodoroConfigCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? FocusPomodoroConfigCellItem else {
                return
            }
            
            if let config = cellItem.config {
                timerView.setConfig(config, animated: true)
            }
        }
    }
    
    lazy var timerView: PomodoroTimerEditView = { [weak self] in
        let view = PomodoroTimerEditView()
        view.configDidChange = { config in
            self?.configDidChange(config)
        }
        
        view.margin = 10.0
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
    
    /// 计时器发生改变
    func configDidChange(_ config: FocusPomodoroConfig) {
        guard let cellItem = cellItem as? FocusPomodoroConfigCellItem else {
            return
        }
        
        cellItem.configDidChange?(config)
    }
}

