//
//  QuadrantMatrixView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/22.
//

import Foundation
import UIKit

class QuadrantMatrixView: UIView {
    
    weak var delegate: QuadrantViewDelegate? {
        didSet {
            for quadrantView in quadrantViews {
                quadrantView.delegate = delegate
            }
        }
    }
    
    /// 象限视图数组
    private var quadrantViews: [QuadrantView] = []
    
    /// 象限之间的间隔
    private var spacing: CGFloat = 5.0
    
    /// 外边界间距
    private var margins: UIEdgeInsets = UIEdgeInsets(value: 5.0)
    
    init(interactors: [QuadrantHomeListInteractor]) {
        super.init(frame: .zero)
        assert(interactors.count == Quadrant.allCases.count)
        
        /// 初始化象限视图
        var views = [QuadrantView]()
        for interactor in interactors {
            let view = QuadrantView(interactor: interactor)
            views.append(view)
            addSubview(view)
        }
        
        self.quadrantViews = views
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutQuadrantViews()
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        endEditingQuadrantViews()
        return true
    }
    
    func endEditingQuadrantViews(except view: QuadrantView? = nil) {
        for quadrantView in quadrantViews {
            if quadrantView != view {
                let _ = quadrantView.endEditing(true)
            }
        }
    }
    
    /// 布局象限视图
    private func layoutQuadrantViews() {
        let layoutFrame = safeLayoutFrame().inset(by: margins)
        let width = (layoutFrame.width - spacing) / 2.0
        let height = (layoutFrame.height - spacing) / 2.0
        for (index, quadrantView) in quadrantViews.enumerated() {
            let row = index / 2
            let col = index % 2
            let x = layoutFrame.minX + CGFloat(col) * (width + spacing)
            let y = layoutFrame.minY + CGFloat(row) * (height + spacing)
            quadrantView.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    // MARK: - Public Methods
    func loadData() {
        for quadrantView in quadrantViews {
            quadrantView.loadData()
        }
    }
    
    // MARK: - 更新象限布局
    func updateLayout(animated: Bool = true) {
        updateQuadrantTitlePosition()
        updateQuadrantViewOrders(animated: animated)
    }
    
    private func updateQuadrantViewOrders(animated: Bool = false) {
        let layout = QuadrantSetting.shared.layout
        let quadrants = layout.getQuadrants()
        self.quadrantViews = quadrantViews.sorted(by: { lView, rView in
            let lIndex = quadrants.firstIndex(of: lView.quadrant) ?? 0
            let rIndex = quadrants.firstIndex(of: rView.quadrant) ?? 0
            return lIndex < rIndex
        })
        
        if animated {
            animateLayout(withDuration: 0.4)
        } else {
            setNeedsLayout()
        }
    }

    private func updateQuadrantTitlePosition() {
        let layout = QuadrantSetting.shared.layout
        let titlePosition = layout.getTitlePosition()
        for quadrantView in quadrantViews {
            quadrantView.titlePosition = titlePosition
        }
    }
    
    // MARK: -
    func quadrantView(at point: CGPoint) -> QuadrantView? {
        for quadrantView in quadrantViews {
            if quadrantView.frame.contains(point) {
                return quadrantView
            }
        }
        
        return nil
    }
    
    func quadrantView(for quadrant: Quadrant) -> QuadrantView? {
        let result = quadrantViews.first { view in
            return view.quadrant == quadrant
        }
        
        return result
    }
    
    func indexPathForItem(at point: CGPoint) -> QuadrantIndexPath? {
        guard let quadrantView = quadrantView(at: point) else {
            return nil
        }
        
        let convertedPoint = self.convert(point, toViewOrWindow: quadrantView)
        guard let indexPath = quadrantView.indexPathForItem(at: convertedPoint) else {
            return nil
        }
    
        return QuadrantIndexPath(quadrant: quadrantView.quadrant, indexPath: indexPath)
    }
    
    func cellForItem(at indexPath: QuadrantIndexPath) -> UITableViewCell? {
        guard let quadrantView = quadrantView(for: indexPath.quadrant) else {
            return nil
        }
        
        return quadrantView.cellForItem(at: indexPath.indexPath)
    }
    
    func task(at indexPath: QuadrantIndexPath) -> TodoTask? {
        guard let quadrantView = quadrantView(for: indexPath.quadrant) else {
            return nil
        }
        
        return quadrantView.task(at: indexPath.indexPath)
    }
}
