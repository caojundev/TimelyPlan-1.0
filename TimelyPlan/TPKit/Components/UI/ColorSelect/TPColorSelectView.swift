//
//  TPColorSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/26.
//

import Foundation
import UIKit

class TPColorSelectView: TPCollectionWrapperView,
                         TPCollectionSingleSectionListDataSource,
                         TPCollectionViewAdapterDelegate {
    
    /// 当前选中颜色
    var selectedColor: UIColor?
    
    /// 可选颜色数组
    lazy var colors: [UIColor] = {
        let values: [UInt64] = [
            0xFD2504, 0xE84F01, 0xFF9300, 0xFCB100, 0x306B16,
            0x26B450, 0x09AFFF, 0x8C36FF, 0xBA1910, 0x00786C,
            0x0096A7, 0x0087D3, 0x2E3BA3, 0x301A94, 0x7E22A3, 0x6534FF]
        return values.map { Color($0) }
    }()

    /// 选中颜色回调
    var didSelectColor: ((UIColor) -> Void)?

    /// 条目间距
    var itemMargin: CGFloat = 10.0
    
    /// 条目尺寸
    var itemSize: CGSize = CGSize(40.0, 40.0)
    
    /// 指示器外环边宽度
    var indicatorBorderWidth = 3.0
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(colors: [UIColor]) {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionConfiguration = { collectionView in
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
        }
        
        scrollDirection = .horizontal
        adapter.sectionInset = UIEdgeInsets(horizontal: itemMargin)
        adapter.interitemSpacing = itemMargin
        adapter.lineSpacing = itemMargin
        
        adapter.cellClass = TPColorSelectCell.self
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - TPCollectionViewAdapterDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return colors
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! TPColorSelectCell
        cell.cellStyle = adapter.cellStyle
        cell.color = adapter.item(at: indexPath) as? UIColor
        cell.indicatorBorderWidth = indicatorBorderWidth
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let color = adapter.item(at: indexPath) as! UIColor
        if !color.isEqual(selectedColor) {
            selectedColor = color
            didSelectColor?(color)
            adapter.updateCheckmarks()
            scrollToSelectedColor()
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        let color = adapter.item(at: indexPath) as! UIColor
        guard let selectedColor = selectedColor else {
            return false
        }
        
        return color == selectedColor
    }
    
    /// 将选中颜色滚动到可视位置
    func scrollToSelectedColor(animated: Bool = true) {
        if let selectedColor = selectedColor {
            self.adapter.scrollToItem(selectedColor, at: .centeredHorizontally,
                                 animated: animated)
        }
    }
}

class TPColorSelectCell: TPCollectionCell {
    
    var indicatorBorderWidth: CGFloat {
        get {
            return indicatorLayer.borderWidth
        }
        
        set {
            indicatorLayer.borderWidth = newValue
            setNeedsLayout()
        }
    }

    private let indicatorLayer = CALayer()
    private let dotLayer = CALayer()
    
    var color: UIColor? {
        didSet {
            dotLayer.backgroundColor = color?.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scaleWhenHighlighted = false
        dotLayer.borderWidth = 0.0
        contentView.layer.addSublayer(dotLayer)
        
        indicatorLayer.isHidden = true
        indicatorLayer.backgroundColor = UIColor.clear.cgColor
        dotLayer.addSublayer(indicatorLayer)
        indicatorBorderWidth = 3.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let dotSize = CGSize(value: bounds.shortSideLength)
        var dotRect = CGRect.zero
        dotRect.size = dotSize
        dotRect.origin.x = (bounds.width - dotSize.width) / 2.0
        dotRect.origin.y = (bounds.height - dotSize.height) / 2.0
        dotLayer.frame = dotRect
        dotLayer.cornerRadius = dotSize.width / 2.0
        
        let indicatorRect = dotLayer.bounds.inset(by: UIEdgeInsets(value: indicatorBorderWidth))
        indicatorLayer.frame = indicatorRect
        indicatorLayer.cornerRadius = indicatorRect.width / 2.0
        indicatorLayer.borderColor = UIColor.secondarySystemBackground.cgColor
        
        CATransaction.commit()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        indicatorLayer.isHidden = !checked
    }
}
