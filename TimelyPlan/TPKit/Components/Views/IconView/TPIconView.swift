//
//  IconView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/5/26.
//

import UIKit

class TPIconView: UIView {
    
    struct Configuration {
        
        /// 占位图
        var placeholderImage: UIImage?
        
        /// 图标背景色
        var backColor: UIColor? = .clear
        
        /// 图标颜色
        var foreColor: UIColor? = nil
        
        /// 图标圆角
        var cornerRadius: CGFloat = 0.0
        
        init(placeholderImage: UIImage? = nil) {
            self.placeholderImage = placeholderImage
        }
    }

    /// 图标
    var icon: TPIcon? {
        didSet {
            style = icon?.style ?? .image
            imageName = icon?.name
            character = icon?.text
        }
    }
    
    /// 样式
    private var style: TPIcon.Style = .image {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 判断图标是否为空
    var isEmpty: Bool {
        if style == .text {
            return character == nil
        } else {
            return image == nil
        }
    }
    
    // 前景颜色
    var foreColor: UIColor? {
        didSet { setNeedsLayout() }
    }

    // 背景颜色
    var backColor: UIColor? = .clear {
        didSet { setNeedsLayout() }
    }

    // 边框颜色
    var borderColor: UIColor? = UIColor.clear {
        didSet { setNeedsLayout() }
    }

    // 边框宽度
    var borderWidth: CGFloat = 0.0 {
        didSet { setNeedsLayout() }
    }

    // 圆角半径
    var cornerRadius: CGFloat = 0.0 {
        didSet { setNeedsLayout() }
    }

    // 点击事件闭包
    var didClick: (() -> Void)? {
        didSet {
            self.isUserInteractionEnabled = didClick != nil
        }
    }

    // MARK: - 图片
    // 图片视图
    private var imageView: UIImageView!

    // 图片名称
    var imageName: String? {
        didSet {
            if let name = imageName {
                image = resGetImage(name)
            } else {
                image = nil
            }
        }
    }
    
    // 图片
    var image: UIImage? {
        didSet {
            updateImageView()
        }
    }
    
    // 占位图片
    var placeholderImage: UIImage? {
        didSet {
            if imageView.image == nil {
                updateImageView()
            }
        }
    }
    
    // MARK: - 文本
    // 文本标签
    private var textLabel: UILabel!

    // 字符
    var character: String? {
        didSet {
            updateTextLabel()
        }
    }

    // 占位字符
    var placeholderCharacter: String = "文" {
        didSet {
            if textLabel.text == nil {
                updateTextLabel()
            }
        }
    }
    
    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // 设置子视图
    private func setupSubviews() {
        isUserInteractionEnabled = false
        
        textLabel = UILabel()
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.2
        textLabel.font = UIFont.boldSystemFont(ofSize: 40.0)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 1
        addSubview(textLabel)
        
        imageView = UIImageView()
        addSubview(imageView)
    }

    // 布局子视图
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.bounds.middleCircleInnerSquareRect
        
        let r = min(bounds.shortSideLength / 2.0, cornerRadius)
        layer.cornerRadius = r
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.backgroundColor = backColor?.cgColor
    
        textLabel.isHidden = style != .text
        textLabel.textColor = foreColor
        textLabel.frame = layoutFrame
        
        imageView.isHidden = style != .image
        imageView.frame = layoutFrame
        imageView.updateImage(withColor: foreColor)
        imageView.updateContentMode()
    }

    // MARK: - Update
    // 更新图片视图
    private func updateImageView() {
        var image = self.image
        if image == nil {
            image = placeholderImage
        }
        
        imageView.image = image
        setNeedsLayout()
    }
    
    // 更新文本标签
    private func updateTextLabel() {
        if let character = character?.whitespacesAndNewlinesTrimmedString, character.count > 0 {
            textLabel.text = character.capitalized
        } else {
            textLabel.text = placeholderCharacter
        }
        
        setNeedsLayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didClick?()
    }
    
    // MARK: - Public Methods
    /// 根据配置更新视图
    func update(with configuration: Configuration) {
        placeholderImage = configuration.placeholderImage
        backColor = configuration.backColor
        foreColor = configuration.foreColor
        cornerRadius = configuration.cornerRadius
    }
}
