//
//  PieRankingListView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/27.
//

import Foundation

class PieRankListView: TPCollectionWrapperView,
                       TPCollectionSectionControllersList {
    
    var visual: PieVisual? {
        didSet {
            pieSlices = visual?.slices
        }
    }
    
    var pieSlices: [PieSlice]?
    
    var sectionControllers: [TPCollectionBaseSectionController]?
    
    var rowHeight: CGFloat = 60.0 {
        didSet {
            sectionController.layout.preferredItemHeight = rowHeight
        }
    }
    
    lazy var sectionController: TPCollectionItemSectionController = {
        let sectionController = TPCollectionItemSectionController()
        let layout = sectionController.layout
        layout.interitemSpacing = 0.0
        layout.lineSpacing = 0.0
        layout.edgeMargins = .zero
        layout.minimumItemsCountPerRow = 2
        layout.maximumItemsCountPerRow = 2
        layout.preferredItemHeight = rowHeight
        return sectionController
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sectionControllers = [self.sectionController]
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        adapter.cellStyle.cornerRadius = 0.0
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        guard let visual = visual, let slices = visual.slices else {
            self.sectionController.cellItems = []
            self.adapter.reloadData()
            return
        }
        
        var cellItems = [TPCollectionCellItem]()
        for (index, slice) in slices.enumerated() {
            let color = visual.color(of: index)
            let cellItem = PieRankListCellItem(pieSlice: slice, color: color)
            cellItems.append(cellItem)
        }
        
        self.sectionController.cellItems = cellItems
        self.adapter.reloadData()
    }
}
