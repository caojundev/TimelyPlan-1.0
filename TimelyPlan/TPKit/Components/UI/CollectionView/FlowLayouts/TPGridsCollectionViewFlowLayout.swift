//
//  TPGridsCollectionViewFlowLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/15.
//

import Foundation
import UIKit

class TPGridsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    /// 布局样式
    var layoutStyle: TPGridsLayoutStyle = TPGridsLayoutStyle()
    
    private let kDecorationViewKind = "DecorationViewKindGrids"

    override func prepare() {
        super.prepare()
        register(TFGridsCollectionReusableView.self, forDecorationViewOfKind: kDecorationViewKind)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect) ?? []
        
        var sections = Set<Int>()
        for attribute in attributes {
            sections.insert(attribute.indexPath.section)
        }
        
        var decorationAttributes: [TFGridsCollectionViewLayoutAttributes] = []
        for section in sections {
            let itemsCount = collectionView?.numberOfItems(inSection: section) ?? 0
            if itemsCount == 0 {
                continue
            }
            
            let firstItemIndexPath = IndexPath(item: 0, section: section)
            let lastItemIndexPath = IndexPath(item: itemsCount - 1, section: section)
            guard let firstItemAttribute = layoutAttributesForItem(at: firstItemIndexPath),
                  let lastItemAttribute = layoutAttributesForItem(at: lastItemIndexPath) else {
                continue
            }

            let attribute = TFGridsCollectionViewLayoutAttributes(forDecorationViewOfKind: kDecorationViewKind,
                                                                  with: firstItemIndexPath)
            attribute.zIndex = Int.max
            attribute.layoutStyle = layoutStyle
            
            let x = firstItemAttribute.frame.minX
            let width = lastItemAttribute.frame.maxX - firstItemAttribute.frame.minX
            let height = collectionView?.height ?? 0.0
            attribute.frame = CGRect(x: x, y: 0.0, width: width, height: height)
            decorationAttributes.append(attribute)
        }
    
        let allAttributes = attributes + decorationAttributes
        return allAttributes
    }
}

class TFGridsCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes {
    
    var layoutStyle: TPGridsLayoutStyle = TPGridsLayoutStyle()
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let newAttributes = super.copy(with: zone) as! TFGridsCollectionViewLayoutAttributes
        newAttributes.layoutStyle = layoutStyle
        return newAttributes
    }
}

class TFGridsCollectionReusableView : UICollectionReusableView {
    
    var gridsLayer: TPGridsLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        gridsLayer = TPGridsLayer()
        self.layer.addSublayer(gridsLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gridsLayer.frame = bounds
        gridsLayer.setNeedsLayout() /// 暗黑/明亮模式变化，layer不会重新布局子图层，需手动调用
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let attributes = layoutAttributes as! TFGridsCollectionViewLayoutAttributes
        gridsLayer.layoutStyle = attributes.layoutStyle
    }
}
