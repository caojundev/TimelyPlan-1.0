//
//  MyDayMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/13.
//

import Foundation
import UIKit

enum TimelineItemType: Equatable {
    case point(icon: UIImage?)
    case short(icon: UIImage?)
    case long(icon: UIImage?)
    case gap
    
    // 手动实现 Equatable (忽略 icon 的比较)
    static func == (lhs: TimelineItemType, rhs: TimelineItemType) -> Bool {
        switch (lhs, rhs) {
        case (.point, .point), (.short, .short), (.long, .long), (.gap, .gap):
            return true
        default:
            return false
        }
    }
}

struct TimelineItem {
    let id = UUID()
    let timeStart: String
    let timeEnd: String?
    let title: String
    let subtitle: String?
    let type: TimelineItemType
    let isCompleted: Bool
    let durationText: String?
    
    let nodeColor: UIColor
}

struct TimelineLayoutManager {
    // 预设颜色
    static let blueColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0)
    static let yellowColor = UIColor.systemYellow
    static let greenColor = UIColor.systemGreen
    
    static func cellHeight(for item: TimelineItem) -> CGFloat {
        switch item.type {
        case .long: return 140
        case .point, .short: return 80
        case .gap: return 40
        }
    }
}


class TimelineDecorationAttributes: UICollectionViewLayoutAttributes {
    var topColor: UIColor?
    var bottomColor: UIColor?
    
    // 重要：必须重写 copy 方法，否则在 UICollectionView 内部复用 Attribute 时数据会丢失
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! TimelineDecorationAttributes
        copy.topColor = self.topColor
        copy.bottomColor = self.bottomColor
        return copy
    }
    
    // 重要：重写 isEqual，确保当颜色变化时，CollectionView 能够识别出需要重绘
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TimelineDecorationAttributes else { return false }
        guard super.isEqual(object) else { return false }
        return topColor == other.topColor && bottomColor == other.bottomColor
    }
}

class TimelineLayout: UICollectionViewFlowLayout {
    
    // 依赖外部传入的 DataSource
    var dataSource: [TimelineItem] = []
    
    // 缓存 Attributes
    private var cellAttributes: [UICollectionViewLayoutAttributes] = []
    private var decorationAttributes: [UICollectionViewLayoutAttributes] = []
    
    // 预设常量
    private let leftTimeWidth: CGFloat = 60
    private let padding: CGFloat = 16
    private let centerNodeWidth: CGFloat = 40
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView, !dataSource.isEmpty else { return }
        
        cellAttributes.removeAll()
        decorationAttributes.removeAll()
        
        let width = collectionView.bounds.width
        var currentY: CGFloat = 0
        var nodeCenterYs: [CGFloat] = [] // 缓存所有非Gap的节点中心Y
        
        // 1. 计算所有 Cell 的 Frame 和节点中心 Y
        for (index, item) in dataSource.enumerated() {
            let indexPath = IndexPath(item: index, section: 0)
            let height = TimelineLayoutManager.cellHeight(for: item)
            let frame = CGRect(x: 0, y: currentY, width: width, height: height)
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attrs.frame = frame
            cellAttributes.append(attrs)
            
            // 记录非 Gap 事项的中心 Y
            if item.type != .gap {
                let centerY = currentY + height / 2
                nodeCenterYs.append(centerY)
            }
            
            currentY += height
        }
        
        // 在 prepare() 方法中，找到生成 Decoration Attributes 的地方，替换为如下代码：

        // 2. 生成装饰视图的 Attributes
        let nonGapItems = dataSource.filter { $0.type != .gap }

        guard nodeCenterYs.count >= 2 else { return }

        for i in 0..<(nodeCenterYs.count - 1) {
            let topY = nodeCenterYs[i]
            let bottomY = nodeCenterYs[i+1]
            let height = bottomY - topY
            
            let centerX = leftTimeWidth + padding + 8 + centerNodeWidth / 2 - 1
            let kind = "TimelineConnection"
            let indexPath = IndexPath(item: i, section: 0)
            
            // 【修改点1】使用我们的子类进行初始化
            let decoAttrs = TimelineDecorationAttributes(forDecorationViewOfKind: kind, with: indexPath)
            
            decoAttrs.frame = CGRect(x: centerX, y: topY, width: 2, height: height)
            decoAttrs.zIndex = -1
            
            // 【修改点2】直接设置自定义属性
            decoAttrs.topColor = nonGapItems[i].nodeColor
            decoAttrs.bottomColor = nonGapItems[i+1].nodeColor
            
            decorationAttributes.append(decoAttrs)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var attrs: [UICollectionViewLayoutAttributes] = []
        attrs.append(contentsOf: cellAttributes.filter { rect.intersects($0.frame) })
        attrs.append(contentsOf: decorationAttributes.filter { rect.intersects($0.frame) })
        return attrs
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // 这里依然返回基类即可，因为我们的 decoAttrs 也是它的子类
        return decorationAttributes.first { $0.indexPath == indexPath }
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let totalHeight = dataSource.reduce(0) { $0 + TimelineLayoutManager.cellHeight(for: $1) }
        return CGSize(width: collectionView.bounds.width, height: totalHeight)
    }
}

import UIKit

class TimelineDecorationView: UICollectionReusableView {
    
    private let gradientLayer = CAGradientLayer()
    private let dashMaskLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradientLayer)
        
        dashMaskLayer.fillColor = UIColor.clear.cgColor
        dashMaskLayer.strokeColor = UIColor.white.cgColor
        dashMaskLayer.lineWidth = 2
        dashMaskLayer.lineDashPattern = [4, 4]
        gradientLayer.mask = dashMaskLayer
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // 【修改点】直接接收 Attributes，或者直接接收两个颜色
    func configure(with attributes: TimelineDecorationAttributes) {
        guard let top = attributes.topColor, let bottom = attributes.bottomColor else { return }
        gradientLayer.colors = [top.cgColor, bottom.cgColor]
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        // 在 apply 中安全地向下转型，并调用配置方法
        if let customAttrs = layoutAttributes as? TimelineDecorationAttributes {
            configure(with: customAttrs)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width / 2, y: 0))
        path.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height))
        dashMaskLayer.path = path.cgPath
    }
}

import UIKit

class TimelineCell: UICollectionViewCell {
    private let startTimeLabel = UILabel()
    private let endTimeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationLabel = UILabel()
    private let rightCircleView = UIView()
    private let centerIconContainer = UIView()
    private let centerIconImageView = UIImageView()
    
    private var currentItem: TimelineItem?
       
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        
        startTimeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        startTimeLabel.textColor = .lightGray
        startTimeLabel.textAlignment = .right
        
        endTimeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        endTimeLabel.textColor = .gray
        endTimeLabel.textAlignment = .right
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        durationLabel.font = .systemFont(ofSize: 11, weight: .regular)
        durationLabel.textColor = .lightGray
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = 4
        durationLabel.layer.masksToBounds = true
        durationLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        
        centerIconImageView.contentMode = .center
        centerIconContainer.addSubview(centerIconImageView)
        
        rightCircleView.layer.borderWidth = 2
        rightCircleView.backgroundColor = .clear
        
        [startTimeLabel, endTimeLabel, centerIconContainer, titleLabel, subtitleLabel, durationLabel, rightCircleView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func configure(with item: TimelineItem) {
        self.currentItem = item
        
        startTimeLabel.text = item.timeStart
        endTimeLabel.text = item.timeEnd
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        durationLabel.text = item.durationText
        durationLabel.isHidden = item.durationText == nil
        
        endTimeLabel.isHidden = (item.timeEnd == nil)
        
        // 配置圆点/胶囊
        centerIconContainer.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        centerIconImageView.image = nil
        
        switch item.type {
        case .point(let icon):
            centerIconContainer.backgroundColor = item.nodeColor
            centerIconContainer.layer.cornerRadius = 20
            centerIconImageView.image = icon
        case .short(let icon):
            centerIconContainer.backgroundColor = item.nodeColor
            centerIconContainer.layer.cornerRadius = 20
            centerIconImageView.image = icon
        case .long(let icon):
            centerIconContainer.backgroundColor = item.nodeColor
            centerIconContainer.layer.cornerRadius = 20
            centerIconImageView.image = icon
        case .gap:
            centerIconContainer.backgroundColor = .clear
        }
        
        rightCircleView.layer.borderColor = item.isCompleted ? item.nodeColor.cgColor : UIColor.gray.cgColor
        rightCircleView.layer.borderWidth = 2
        rightCircleView.layer.cornerRadius = 10
        rightCircleView.backgroundColor = item.isCompleted ? item.nodeColor.withAlphaComponent(0.2) : .clear
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let leftTimeWidth: CGFloat = 60
        let rightCircleSize: CGFloat = 20
        let centerNodeWidth: CGFloat = 40
        let padding: CGFloat = 16
        let verticalCenterY = bounds.height / 2
        let centerX = leftTimeWidth + padding + 8
        
        // 左侧时间
        startTimeLabel.sizeToFit()
        startTimeLabel.frame = CGRect(x: 0, y: verticalCenterY - startTimeLabel.bounds.height / 2, width: leftTimeWidth, height: startTimeLabel.bounds.height)
        
        if !endTimeLabel.isHidden {
            endTimeLabel.sizeToFit()
            endTimeLabel.frame = CGRect(x: 0, y: verticalCenterY + 20, width: leftTimeWidth, height: endTimeLabel.bounds.height)
        }
        
        // 中间节点
        switch currentItem?.type {
        case .long:
            let height = bounds.height - 20
            centerIconContainer.frame = CGRect(x: centerX, y: 10, width: centerNodeWidth, height: height)
            centerIconImageView.frame = CGRect(x: 0, y: (height - 24)/2, width: centerNodeWidth, height: 24)
        default:
            centerIconContainer.frame = CGRect(x: centerX, y: verticalCenterY - centerNodeWidth / 2, width: centerNodeWidth, height: centerNodeWidth)
            centerIconImageView.frame = centerIconContainer.bounds
        }
        
        // 右侧文字
        let textStartX = centerX + centerNodeWidth + 12
        let textMaxWidth = bounds.width - textStartX - padding - rightCircleSize - padding
        
        if !durationLabel.isHidden {
            durationLabel.sizeToFit()
            durationLabel.frame = CGRect(x: textStartX, y: verticalCenterY - 30, width: durationLabel.bounds.width + 12, height: durationLabel.bounds.height + 4)
        }
        
        let titleY = durationLabel.isHidden ? verticalCenterY - 10 : verticalCenterY - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(x: textStartX, y: titleY, width: min(titleSize.width, textMaxWidth), height: titleSize.height)
        
        if let _ = currentItem?.subtitle, !(currentItem?.subtitle?.isEmpty ?? true) {
            subtitleLabel.isHidden = false
            subtitleLabel.sizeToFit()
            subtitleLabel.frame = CGRect(x: textStartX, y: titleLabel.frame.maxY + 4, width: min(textMaxWidth, subtitleLabel.bounds.width), height: subtitleLabel.bounds.height)
        } else {
            subtitleLabel.isHidden = true
        }
        
        // 右侧圆圈
        rightCircleView.frame = CGRect(x: bounds.width - rightCircleSize - padding, y: verticalCenterY - rightCircleSize / 2, width: rightCircleSize, height: rightCircleSize)
    }
}


class MyDayMainViewController: TPViewController,
                               TPSidebarContent,
                               UICollectionViewDataSource {

    var sidebarController: SidebarController?
    
    private var collectionView: UICollectionView!
    private var dataSource: [TimelineItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("My Day")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        setupCollectionView()
        loadTestData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    private func setupCollectionView() {
        let layout = TimelineLayout()
        layout.scrollDirection = .vertical
        
        // 注册装饰视图类型
        layout.register(TimelineDecorationView.self, forDecorationViewOfKind: "TimelineConnection")
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: "TimelineCell")
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        view.addSubview(collectionView)
    }
    
    private func loadTestData() {
        // 生成图标
        let moonIcon = UIImage(systemName: "moon.zz.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let bagIcon = UIImage(systemName: "bag.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let alarmIcon = UIImage(systemName: "alarm.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        // 预设颜色（为了方便，直接复用 LayoutManager 里的颜色）
        let blue = TimelineLayoutManager.blueColor
        let yellow = TimelineLayoutManager.yellowColor
        let green = TimelineLayoutManager.greenColor
        
        // 1. 构建基础节点数据
        let item1 = TimelineItem(
            timeStart: "08:30", timeEnd: "08:45",
            title: "Wind Down", subtitle: nil,
            type: .point(icon: moonIcon), isCompleted: false, durationText: "15 min",
            nodeColor: blue
        )
        
        let item2 = TimelineItem(
            timeStart: "17:00", timeEnd: "17:30",
            title: "Go Shopping", subtitle: nil,
            type: .short(icon: bagIcon), isCompleted: false, durationText: "30 min",
            nodeColor: yellow
        )
        
        let item3 = TimelineItem(
            timeStart: "21:45", timeEnd: "23:15",
            title: "起床", subtitle: "0/2",
            type: .long(icon: alarmIcon), isCompleted: false, durationText: "1 hr, 30 min",
            nodeColor: green
        )
        
        // 2. 构建 Gap 数据 (注意：只有 type 是 .gap，其他内容可填空)
        let gapItem = TimelineItem(
            timeStart: "", timeEnd: nil,
            title: "A well-deserved break.", subtitle: nil,
            type: .gap, isCompleted: false, durationText: nil,
            nodeColor: .clear // Gap 没有节点颜色
        )
        
        // 3. 组装测试数组 (加入 gapItem)
        var rawItems: [TimelineItem] = []
        rawItems.append(item1)
        rawItems.append(gapItem) // 故意插入一个 Gap
        rawItems.append(item2)
        rawItems.append(item3)
        
        // 4. 给 Layout 赋值数据源并刷新
        self.dataSource = rawItems
        (collectionView.collectionViewLayout as? TimelineLayout)?.dataSource = dataSource
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
        cell.configure(with: dataSource[indexPath.item])
        return cell
    }
}
