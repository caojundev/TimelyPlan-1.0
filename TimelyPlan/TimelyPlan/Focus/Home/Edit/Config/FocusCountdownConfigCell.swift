//
//  FoucsCountdownConfigCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/25.
//

import Foundation

class FocusCountdownConfigCellItem: TPBaseTableCellItem {

    var config: FocusCountdownConfig?
    
    var configDidChange: ((FocusCountdownConfig) -> Void)?
    
    override init() {
        super.init()
        registerClass = FocusCountdownConfigCell.self
        selectionStyle = .none
        height = 320.0
        contentPadding = UIEdgeInsets(value: 10.0)
    }
}

class FocusCountdownConfigCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? FocusCountdownConfigCellItem else {
                return
            }

            let duration = cellItem.config?.duration ?? FocusCountdownConfig.defaultDuration
            timerView.setDurationWithAnimationFromZero(duration)
        }
    }
    
    lazy var timerView: CountdownTimerEditView = {
        let view = CountdownTimerEditView()
        view.didEndEditing = { [weak self] duration in
            self?.didSelectDuration(duration)
        }
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.timerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timerView.frame = contentView.layoutFrame()
    }
    
    func didSelectDuration(_ duration: TimeInterval) {
        guard let cellItem = cellItem as? FocusCountdownConfigCellItem else {
            return
        }
        
        let config = FocusCountdownConfig(duration: duration)
        cellItem.config = config
        cellItem.configDidChange?(config)
    }
}

