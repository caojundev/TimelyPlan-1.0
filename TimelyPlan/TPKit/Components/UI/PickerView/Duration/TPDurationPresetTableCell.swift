//
//  TPDurationPresetTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/14.
//

import Foundation
import UIKit

class TPDurationPresetTableCellItem: TPBaseTableCellItem {
    
    var didSelectMinute: ((Int) -> Void)?
    
    /// 预设分钟数组
    var presetMinutes: [Int] = [0, 5, 15, 30, 45, 60, 90, 120, 240]
    
    override init() {
        super.init()
        self.registerClass = TPDurationPresetTableCell.self
        self.contentPadding = UIEdgeInsets(horizontal: 15.0)
        self.selectionStyle = .none
        self.height = 60.0
    }
}

class TPDurationPresetTableCell: TPBaseTableCell {
    
    var minutes: [Int] = [] {
        didSet {
            var actions = [TPTextInfo]()
            for minute in minutes {
                let action = TPTextInfo()
                action.title = (minute * SECONDS_PER_MINUTE).localizedTitle
                actions.append(action)
            }
            
            presetView.actions = actions
            presetView.reloadData()
        }
    }
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPDurationPresetTableCellItem else {
                return
            }

            self.minutes = cellItem.presetMinutes
        }
    }
    
    private lazy var presetView: TPTextCarouselView = {
        let presetView = TPTextCarouselView()
        presetView.sectionInset = UIEdgeInsets(left: 0.0, right: 5.0)
        presetView.scrollDirection = .horizontal
        presetView.minimumItemWidth = 60.0
        presetView.itemHeight = 40.0
        presetView.cellStyle.borderWidth = 0.0
        presetView.cellStyle.cornerRadius = 8.0
        presetView.cellStyle.backgroundColor = .secondarySystemFill
        presetView.didSelectItemAtIndex = { [weak self] index in
            self?.didSelectPresetMinutes(at: index)
        }
        
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
        guard let cellItem = cellItem as? TPDurationPresetTableCellItem else {
            return
        }
        
        cellItem.didSelectMinute?(minutes[index])
    }
}
