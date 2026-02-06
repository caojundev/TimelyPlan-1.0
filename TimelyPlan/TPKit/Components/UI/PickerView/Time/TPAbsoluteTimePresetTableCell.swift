//
//  TPAbsoluteTimePresetTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/14.
//

import Foundation

class TPAbsoluteTimePresetTableCellItem: TPBaseTableCellItem {
    
    var didSelectOffset: ((Duration) -> Void)?
    
    /// 预设相对凌晨时间偏移数组
    var offsets: [Duration] = [6 * SECONDS_PER_HOUR,
                               9 * SECONDS_PER_HOUR,
                               12 * SECONDS_PER_HOUR,
                               13 * SECONDS_PER_HOUR,
                               18 * SECONDS_PER_HOUR,
                               19 * SECONDS_PER_HOUR,
                               22 * SECONDS_PER_HOUR]
    
    override init() {
        super.init()
        self.registerClass = TPTimePresetTableCell.self
        self.selectionStyle = .none
        self.contentPadding = UIEdgeInsets(horizontal: 10.0)
        self.height = 60.0
    }
}

class TPTimePresetTableCell: TPBaseTableCell {
    
    var offsets: [Int] = [] {
        didSet {
            var actions = [TPTextInfo]()
            for offset in offsets {
                let action = TPTextInfo()
                action.title = offset.timeString
                action.subtitle = offset.timePeriod.title
                actions.append(action)
            }
            
            presetView.actions = actions
            presetView.reloadData()
        }
    }
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPAbsoluteTimePresetTableCellItem else {
                return
            }
            
            offsets = cellItem.offsets
        }
    }
    
    private lazy var presetView: TPTextCarouselView = {
        let presetView = TPTextCarouselView()
        presetView.scrollDirection = .horizontal
        presetView.itemHeight = 40.0
        presetView.subtitleFont = UIFont.systemFont(ofSize: 10.0)
        presetView.didSelectItemAtIndex = { [weak self] index in
            self?.didSelectPresetMinutes(at: index)
        }
        
        let style = presetView.cellStyle
        style.borderWidth = 0.0
        style.cornerRadius = 8.0
        style.backgroundColor = .secondarySystemBackground
        return presetView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(presetView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        presetView.frame = contentView.layoutFrame()
    }
    
    private func didSelectPresetMinutes(at index: Int) {
        guard let cellItem = cellItem as? TPAbsoluteTimePresetTableCellItem else {
            return
        }
        
        cellItem.didSelectOffset?(offsets[index])
    }
}

