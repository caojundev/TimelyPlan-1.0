//
//  HabitTaskBindSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation

class HabitTaskBindSectionController: BaseTaskBindSectionController {
    
    override init() {
        super.init()
    }

    override func classForCell(at index: Int) -> AnyClass? {
        return HabitTaskBindCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        let cell = cell as! HabitTaskBindCell
        cell.habitTask = item(at: index) as? HabitTask
        cell.delegate = self
    }
}

class HabitTaskBindCell: HabitTaskListDefaultInfoCell {
    
    lazy var checkmarkImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = resGetImage("checkmark_24")
        imageView.updateImage(withColor: .primary)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.padding = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 8.0)
        self.coverView.isHidden = true
        self.shadowView.layer.shadowColor = Color(0x343434, 0.1).cgColor
        self.shadowView.layer.shadowOffset = CGSize(width:0, height: 0.0)
        let titleView = self.infoView.titleView
        titleView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        titleView.rightAccessoryView = checkmarkImageView
        titleView.rightAccessorySize = .mini
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldAddMoreButton() -> Bool {
        /// 不添加更多按钮
        return false
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        let titleColor = resGetColor(.title)
        let iconView = infoView.iconView
        iconView.foreColor = titleColor
        iconView.backColor = Color(0xcccccc, 0.1)

        let titleView = infoView.titleView
        titleView.titleConfig.textColor = titleColor
        titleView.subtitleConfig.textColor = .secondaryLabel
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        selectedBackgroundView?.backgroundColor = .secondarySystemGroupedBackground
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        self.checkmarkImageView.isHidden = !checked
    }
}
