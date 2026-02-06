//
//  TPCollectionHeaderFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/28.
//

import Foundation
import UIKit

class TPCollectionHeaderFooterItem: NSObject {
    
    /// 区块头脚视图注册类
    var registerClass = TPCollectionHeaderFooterView.self
    
    /// 尺寸
    var size: CGSize = .zero
    
    /// 内间距
    var padding: UIEdgeInsets = UIEdgeInsets(horizontal: 16.0)
    
    /// 标题
    var title: TextRepresentable?
    
    /// 标题配置
    var titleConfig: TPLabelConfig = .titleConfig
    
    /// 图片内容
    var imageContent: TPImageContent?
    
    /// 图片配置
    var imageConfig: TPImageAccessoryConfig = TPImageAccessoryConfig()
}

protocol TPCollectionHeaderFooterViewDelegate: AnyObject {
    
    /// 获取布局边间距
    func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets
}

class TPCollectionHeaderFooterView: UICollectionReusableView {
    
    weak var delegate: AnyObject?
    
    var headerFooterItem: TPCollectionHeaderFooterItem? {
        didSet {
            guard let headerFooterItem = headerFooterItem else {
                return
            }

            contentPadding = headerFooterItem.padding
            infoView.imageContent = headerFooterItem.imageContent
            infoView.imageConfig = headerFooterItem.imageConfig
            infoView.title = headerFooterItem.title
            infoView.titleConfig = headerFooterItem.titleConfig
            setNeedsLayout()
        }
    }
    
    /// 内容内间距
    var contentPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 16.0, bottom: 0, right: 16.0) {
        didSet {
            setNeedsLayout()
        }
    }

    var title: TextRepresentable? {
        get {
            return infoView.title
        }
        
        set {
            infoView.title = newValue
        }
    }
    
    var titleConfig: TPLabelConfig {
        get {
            return infoView.titleConfig
        }
        
        set {
            infoView.titleConfig = newValue
        }
    }
    
    var infoView = TPImageInfoView()

    /// 内容视图
    private(set) var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       setupViews()
    }

    private func setupViews() {
        self.contentView = UIView()
        self.addSubview(contentView)
        self.contentView.addSubview(infoView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        var layoutMargins: UIEdgeInsets = .zero
        if let delegate = delegate as? TPCollectionHeaderFooterViewDelegate {
            layoutMargins = delegate.layoutMarginsForHeaderFooterView(self)
        }
    
        padding = layoutMargins
        contentView.frame = layoutFrame()
        
        contentView.padding = contentPadding
        infoView.frame = contentView.layoutFrame()
    }
}
