//
//  TodoSearchResultOptionsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/26.
//

import Foundation
import UIKit

class TodoSearchResultOptionsView: UIView,
                                   TPCollectionSectionControllersList {
    
    var optionsChanged: ((TodoSearchOptions) -> Void)? {
        get {
            return menuSectionController.optionsChanged
        }
        
        set {
            menuSectionController.optionsChanged = newValue
        }
    }

    var sectionControllers: [TPCollectionBaseSectionController]?

    /// 集合视图适配器
    private let adapter: TPCollectionViewAdapter = TPCollectionViewAdapter()
    
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds,
                                              collectionViewLayout: collectionViewLayout)
        collectionView.isPrefetchingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let menuSectionController: TodoSearchOptionsSectionController
    
    init(frame: CGRect, options:TodoSearchOptions) {
        self.menuSectionController = TodoSearchOptionsSectionController(options: options)
        super.init(frame: frame)
        addSubview(collectionView)
        
        self.adapter.collectionView = collectionView
        self.adapter.sectionInset = .zero
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.sectionControllers = [menuSectionController]
        self.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame = bounds
        CATransaction.commit()
    }

    func reloadData() {
        adapter.reloadData()
    }
    
}
