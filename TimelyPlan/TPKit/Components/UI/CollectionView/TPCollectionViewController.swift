//
//  TPCollectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/8.
//

import Foundation
import UIKit

class TPCollectionViewController: TPViewController {

    var adapter: TPCollectionViewAdapter {
        return wrapperView.adapter
    }
    
    var collectionView: UICollectionView {
        return wrapperView.collectionView
    }
    
    /// 布局对象
    lazy var collectionViewLayout: UICollectionViewLayout = {
        return UICollectionViewFlowLayout()
    }()
    
    /// 集合视图
    let wrapperView = TPCollectionWrapperView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(wrapperView)
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.wrapperView.frame = collectionViewFrame()
    }
    
    func collectionViewFrame() -> CGRect {
        return view.bounds
    }
    
    func reloadData() {
        wrapperView.reloadData()
    }
}

class TPCollectionSectionsViewController: TPCollectionViewController,
                                          TPCollectionSectionControllersList {

    var sectionControllers: [TPCollectionBaseSectionController]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adapter.dataSource = self
        self.adapter.delegate = self
    }
}
