//
//  QuadrantDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/14.
//

import Foundation

class QuadrantDetailViewController: TPViewController {
    
    /// 标题视图
    private lazy var titleView: TPImageInfoView = {
        let view = TPImageInfoView()
        view.padding = .zero
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.titleConfig.textAlignment = .center
        return view
    }()
    
    private(set) var quadrant: Quadrant
    
    init(quadrant: Quadrant) {
        self.quadrant = quadrant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        titleView.imageName = quadrant.iconName
        titleView.imageConfig.color = quadrant.color
        titleView.title = quadrant.title
        titleView.sizeToFit()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .secondarySystemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .secondarySystemGroupedBackground
    }
    
    override var themeNavigationBarTintColor: UIColor? {
        return resGetColor(.title)
    }
}
