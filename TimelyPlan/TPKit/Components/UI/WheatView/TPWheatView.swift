//
//  TPWheatView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/18.
//

import Foundation
import UIKit

class TPWheatView: UIView {

    /// 图片尺寸
    var wheatSize = CGSize(width: 30.0, height: 60.0)
    
    /// 标题信息视图
    private(set) lazy var infoView: TPInfoView = {
        let infoView = TPInfoView()
        infoView.padding = UIEdgeInsets(horizontal: 10.0)
        infoView.subtitleTopMargin = 8.0
        return infoView
    }()
    
    /// 左端图片视图
    private lazy var leftImageView: UIImageView = {
        let images = wheatImages()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.animationImages = images
        imageView.image = images.last
        imageView.animationDuration = 1.2
        imageView.animationRepeatCount = 1
        return imageView
    }()
    
    /// 右端图片视图
    private lazy var rightImageView: UIImageView = {
        let images = wheatImages()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.animationImages = images
        imageView.image = images.last
        imageView.animationDuration = 1.2
        imageView.animationRepeatCount = 1
        imageView.layer.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        padding = UIEdgeInsets(value: 10.0)
        addSubview(leftImageView)
        addSubview(rightImageView)
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        leftImageView.size = wheatSize
        leftImageView.left = layoutFrame.minX
        leftImageView.centerY = layoutFrame.midY
        
        rightImageView.size = wheatSize
        rightImageView.right = layoutFrame.maxX
        rightImageView.centerY = layoutFrame.midY
        
        infoView.width = layoutFrame.width - wheatSize.width * 2.0
        infoView.height = layoutFrame.height
        infoView.centerY = layoutFrame.midY
        infoView.alignHorizontalCenter()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let infoSize = infoView.sizeThatFits(size)
        let width = infoSize.width + 2 * wheatSize.width + self.padding.horizontalLength
        let height = max(wheatSize.height, infoSize.height) + self.padding.verticalLength
        return CGSize(width: width, height: height)
    }
    
    private func wheatImages() -> [UIImage] {
        var images = [UIImage]()
        for i in 1...4 {
            let suffix = String(format: "%02ld", i)
            if let image = resGetImage("Wheat\(suffix)") {
                images.append(image)
            }
        }
        
        return images
    }
    
}
