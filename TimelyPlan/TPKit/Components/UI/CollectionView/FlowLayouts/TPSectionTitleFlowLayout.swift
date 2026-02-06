//
//  TPSectionTitleFlowLayout.swift
//  SCSectionBackground
//
//  Created by Catherine Schwartz on 12/02/2016.
//  Copyright © 2016 StrawberryCode. All rights reserved.
//

import UIKit

protocol TFSectionTitleFlowLayoutTitleProvider: AnyObject {
    func sectionTitleFlowLayout(_ layout: TPSectionTitleFlowLayout, titleForSection section: Int) -> String?
}

class TPSectionTitleFlowLayout: UICollectionViewFlowLayout {

    let kDecorationViewKind = "SectionTitle"
    
    /// 标题供应者
    weak var titleProvider: TFSectionTitleFlowLayoutTitleProvider?
    
    var titleHeight: CGFloat = 30.0
    
    /// 标题配置
    lazy var titleConfig: TPLabelConfig = {
        var config = TPLabelConfig.titleConfig
        config.textColor = Color(light: 0x888888, dark: 0xABABAB)
        config.textAlignment = .center
        return config
    }()
    
    override func prepare() {
        super.prepare()
        register(TPSectionTitleReusableView.self, forDecorationViewOfKind: kDecorationViewKind)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect) ?? []
        
        var sections = Set<Int>()
        for attribute in attributes {
            sections.insert(attribute.indexPath.section)
        }
        
        var decorationAttributes: [TPSectionTitleLayoutAttributes] = []
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

            let attribute = TPSectionTitleLayoutAttributes(forDecorationViewOfKind: kDecorationViewKind, with: firstItemIndexPath)
            attribute.zIndex = -Int.max
            attribute.titleConfig = titleConfig
            attribute.titleHeight = titleHeight
            attribute.title = titleProvider?.sectionTitleFlowLayout(self, titleForSection: section)
            
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

class TPSectionTitleLayoutAttributes : UICollectionViewLayoutAttributes {
    
    /// 标题
    var title: String?
    
    /// 标题高度
    var titleHeight: CGFloat?

    /// 标题配置
    var titleConfig: TPLabelConfig = .titleConfig
    
    /// 标题字体
    var titleFont = BOLD_SYSTEM_FONT
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let newAttributes = super.copy(with: zone) as! TPSectionTitleLayoutAttributes
        newAttributes.titleConfig = titleConfig.copy() as! TPLabelConfig
        newAttributes.titleHeight = titleHeight
        newAttributes.title = title
        return newAttributes
    }
}

class TPSectionTitleReusableView: UICollectionReusableView {
    
    /// 文本标签高度
    var textLabelHeight: CGFloat?
    
    /// 文本标签
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel = UILabel()
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5
        addSubview(textLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.width = width
        if let height = textLabelHeight {
            textLabel.height = height
        } else {
            textLabel.sizeToFit()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let attributes = layoutAttributes as! TPSectionTitleLayoutAttributes
        textLabelHeight = attributes.titleHeight
        textLabel.text = attributes.title
        textLabel.font = attributes.titleConfig.font
        textLabel.textColor = attributes.titleConfig.textColor
        textLabel.textAlignment = attributes.titleConfig.textAlignment
        setNeedsLayout()
    }
}
