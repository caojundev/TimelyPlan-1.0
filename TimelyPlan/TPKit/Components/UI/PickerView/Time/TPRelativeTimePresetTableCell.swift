//
//  TPRelativeTimePresetTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/10.
//

import Foundation

class TPRelativeTimePresetTableCellItem: TPBaseTableCellItem {
    
    var didSelectOffset: ((Int) -> Void)?
    
    /// 预设偏移分钟数组
    var presetOffsets: [Int] = [0, 1, 3, 5, 15, 30, 45, 60, 90, 120]
    
    override init() {
        super.init()
        self.registerClass = TPRelativeTimePresetTableCell.self
        self.contentPadding = UIEdgeInsets(horizontal: 15.0)
        self.selectionStyle = .none
        self.height = 60.0
    }
}

class TPRelativeTimePresetTableCell: TPBaseTableCell {
    
    var offsets: [Int] = [] {
        didSet {
            var actions = [TPTextInfo]()
            for offset in offsets {
                let action = TPTextInfo()
                action.title = title(for: offset)
                actions.append(action)
            }
            
            presetView.actions = actions
            presetView.reloadData()
        }
    }
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPRelativeTimePresetTableCellItem else {
                return
            }

            self.offsets = cellItem.presetOffsets
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
        presetView.cellStyle.backgroundColor = .secondarySystemBackground
        presetView.didSelectItemAtIndex = { [weak self] index in
            self?.didSelectPresetOffset(at: index)
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
    
    private func title(for offset: Int) -> String {
        if offset == 0 {
            return resGetString("Now")
        }
        
        let format: String
        if offset > 0 {
            format = resGetString("%@ later")
        } else {
            format = resGetString("%@ early")
        }
        
        let title = (Int(abs(offset)) * SECONDS_PER_MINUTE).localizedTitle
        return String(format: format, title)
    }
    
    private func didSelectPresetOffset(at index: Int) {
        guard let cellItem = cellItem as? TPRelativeTimePresetTableCellItem else {
            return
        }
        
        cellItem.didSelectOffset?(offsets[index])
    }
}
