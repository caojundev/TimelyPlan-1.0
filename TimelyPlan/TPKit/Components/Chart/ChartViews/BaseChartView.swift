//
//  BaseChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/28.
//

import Foundation
import UIKit

/// y轴坐标位置
enum ChartYAxisPosition: Int {
    case left
    case right
}

class BaseChartView: UIView, UIGestureRecognizerDelegate {
    
    /// 图表条目
    private(set) var chartItem = ChartItem()
    
    var xAxis: ChartAxis {
        return chartItem.xAxis
    }
    
    var stepWidth: CGFloat {
        return canvasFrame.width / CGFloat(xAxis.stepsCount)
    }
    
    var yAxis: ChartAxis {
        return chartItem.yAxis
    }
    
    /// 画布视图
    let canvasView = UIView()
    
    /// y轴标签视图
    private let yLabelsView = ChartYLabelsView()
    
    /// x轴标签视图
    private let xLabelsView = ChartXLabelsView()
    
    /// 辅助线视图
    private let guidelineView = ChartGuidelineView()

    /// 内容滚动视图
    private(set) lazy var contentView: UIScrollView = {
        let view = UIScrollView()
        view.clipsToBounds = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    // MARK: - 手势
    /// 平移手势
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handlePan(_:)))
        gesture.delaysTouchesBegan = true
        gesture.delegate = self
        return gesture
    }()
    
    /// 点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(handleTap(_:)))
        return gesture
    }()
    
    // MARK: - 占位视图
    /// 是否为空白图表
    var isEmpty: Bool = false {
        didSet {
            placeholderView.isHidden = !isEmpty
        }
    }
    
    /// 空白占位视图
    private lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView(frame: bounds)
        view.isUserInteractionEnabled = false
        view.isHidden = true
        view.titleLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        view.titleLabel.textColor = .secondaryLabel
        view.title = resGetString("NO DATA")
        return view
    }()
    
    let highlightView = ChartHighlightView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.clipsToBounds = false
        self.addSubview(self.yLabelsView)
        self.addSubview(self.contentView)
        self.addSubview(self.placeholderView)
        self.contentView.addSubview(self.guidelineView)
        self.contentView.addSubview(self.xLabelsView)
        self.contentView.addSubview(self.canvasView)
        self.contentView.addSubview(self.highlightView)
        self.addGestureRecognizer(self.panGesture)
        self.addGestureRecognizer(self.tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.padding = UIEdgeInsets(right: 10.0)
        let layoutFrame = self.layoutFrame()
        let yLabelsWidth = yLabelsView.widthThatFits(minWidth: chartItem.yAxisLabelMinWidth,
                                                     maxWidth: chartItem.yAxisLabelMaxWidth)
        yLabelsView.width = yLabelsWidth
        yLabelsView.height = layoutFrame.height - chartItem.xAxisLabelHeight
        yLabelsView.top = layoutFrame.minY
        
        contentView.width = layoutFrame.width - yLabelsWidth
        contentView.height = layoutFrame.height
        contentView.top = layoutFrame.minY
        
        if chartItem.yAxisPosition == .left {
            yLabelsView.left = layoutFrame.minX
            contentView.left = yLabelsView.right
        } else {
            yLabelsView.right = layoutFrame.maxX
            contentView.left = layoutFrame.minX
        }
        
        /// 更新内容尺寸
        self.updateContentSize()
        canvasView.frame = canvasFrame
        highlightView.frame = canvasView.frame
        guidelineView.frame = canvasView.frame
        placeholderView.frame = contentView.frame
        placeholderView.height = canvasView.height
        
        /// x轴标签
        xLabelsView.width = canvasView.width
        xLabelsView.height = chartItem.xAxisLabelHeight
        xLabelsView.top = canvasView.bottom
    }

    /// 更新内容尺寸
    func updateContentSize() {
        contentView.contentSize = CGSize(width: contentView.frame.width,
                                         height: contentView.frame.height)
    }
    
    /// 绘制画布区域
    var canvasFrame: CGRect {
        let w = max(contentView.contentSize.width, contentView.frame.width)
        let h = frame.height - chartItem.xAxisLabelHeight
        return CGRect(x: 0, y: 0, width: w, height: h)
    }

    // MARK: - 绘制图表
    func strokeChart(with chartItem: ChartItem) {
        self.chartItem = chartItem
        self.xLabelsView.axis = xAxis
        self.yLabelsView.axis = yAxis
        self.guidelineView.xGuideline = xAxis.guideline
        self.guidelineView.yGuideline = yAxis.guideline
        self.highlightView.hide() /// 隐藏高亮信息
    }
    
    // MARK: -
    /// 获取图表标记处对应的位置
    func positionForChartMark(_ mark: ChartMark) -> CGPoint {
        return position(xValue: mark.x, yValue: mark.y)
    }
    
    /// 获取图表标记处对应的位置
    func position(xValue: CGFloat, yValue: CGFloat) -> CGPoint {
        let frame = canvasFrame
        let x = frame.minX + frame.width * (xValue - xAxis.range.minValue) / xAxis.range.length
        let y = frame.maxY - frame.height * (yValue - yAxis.range.minValue) / yAxis.range.length
        return CGPoint(x: x, y: y)
    }
    
    // MARK: - 手势处理
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        didTapAtPoint(location)
    }
    
    var scrollSuperView: UIScrollView?
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            scrollSuperView = scrollViewSuperview()
            scrollSuperView?.panGestureRecognizer.isEnabled = false
            panDidBeganAtPoint(location)
            break
        case .changed:
            panDidChangedAtPoint(location)
            break
        default:
            scrollSuperView?.panGestureRecognizer.isEnabled = true
            scrollSuperView = nil
            panDidEndedAtPoint(location)
            break
        }
    }
    
    // MARK: - 子类重写
    func didTapAtPoint(_ location: CGPoint) {
        let point = self.convert(location, toViewOrWindow: canvasView)
        guard let element = element(at: point), !element.isEqual(highlightView.element) else {
            highlightView.hide()
            return
        }
        
        highlightElement(element)
    }
    
    /// 平移手势改变
    func panDidBeganAtPoint(_ point: CGPoint) {
        didChangeTouchPoint(point)
    }
    
    func panDidChangedAtPoint(_ point: CGPoint) {
        didChangeTouchPoint(point)
    }
    
    func panDidEndedAtPoint(_ point: CGPoint) {
        highlightView.hide()
    }
        
    func didChangeTouchPoint(_ location: CGPoint) {
        let point = self.convert(location, toViewOrWindow: canvasView)
        guard let element = element(at: point), !element.isEqual(highlightView.element) else {
            return
        }
        
        highlightElement(element)
    }
    
    private func highlightElement(_ element: ChartHighlightEelement) {
        if let text = element.highlightText, text.count > 0 {
            TPImpactFeedback.impactWithSoftStyle()
            highlightView.show(element: element)
        }
    }
    
    /// 获取触摸点处的元素
    func element(at point: CGPoint) -> ChartHighlightEelement? {
        return nil
    }
        
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UIScrollView {
            return true
        }
        
        return false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === self.panGesture else {
            return true
        }

        let translation = panGesture.translation(in: self)
        return abs(translation.x) > abs(translation.y)
    }
}

