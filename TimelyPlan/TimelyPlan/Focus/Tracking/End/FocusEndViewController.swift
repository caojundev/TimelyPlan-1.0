//
//  FocusEndViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation
import UIKit

class FocusEndViewController: TPCollectionSectionsViewController {
    
    /// 底部视图
    lazy var bottomView: FocusEndBottomView =  { [weak self] in
        let view = FocusEndBottomView()
        view.didClickSave = {
            self?.clickSave()
        }
        
        view.didClickDiscard = {
            self?.clickDiscard()
        }
        
        return view
    }()

    /// 五彩纸屑视图
    lazy var confettiView: SAConfettiView =  {
        let view = SAConfettiView(frame: self.view.bounds)
        view.type = .confetti
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var summarySectionController: FocusEndSummarySectionController = {
        return FocusEndSummarySectionController(dataItem: self.dataItem)
    }()
    
    lazy var detailSectionController: FocusEndDetailSectionController = {
        return FocusEndDetailSectionController(dataItem: self.dataItem)
    }()
    
    var dataItem: FocusEndDataItem
    
    let cornerRadius = 16.0
    let bottomViewHeight = 120.0
    let collectionViewInsetBottom = 50.0
    let collectionViewBottomMargin = 60.0
    let confettiAnimateDuration = 3.0
    
    init(dataItem: FocusEndDataItem) {
        self.dataItem = dataItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(bottom: collectionViewInsetBottom)
        view.addSubview(bottomView)
        view.addSubview(confettiView)
        adapter.cellStyle.cornerRadius = cornerRadius
        adapter.cellStyle.backgroundColor = resGetColor(.insetGroupedTableCellBackgroundNormal)
        sectionControllers = [summarySectionController, detailSectionController]
        reloadData()
        startConfetti()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layoutFrame = self.view.safeLayoutFrame()
        bottomView.width = layoutFrame.width
        bottomView.height = bottomViewHeight
        bottomView.bottom = layoutFrame.maxY
        
        confettiView.frame = view.bounds
    }
    
    override func collectionViewFrame() -> CGRect {
        let layoutFrame = self.view.safeLayoutFrame()
        let height = layoutFrame.height - collectionViewBottomMargin
        return CGRect(x: 0.0, y: 0.0, width: view.width, height: height)
    }
    
    private func startConfetti() {
        /// 显示纸屑
        confettiView.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + confettiAnimateDuration) {
            self.confettiView.stopConfetti()
        }
    }
    
    // MARK: - Event Response
    func clickSave() {
        self.dismiss(animated: true, completion: nil)
        #warning("保存数据")
        FocusTracker.shared.clearEvent()
    }
    
    func clickDiscard() {
        let discardHandler = {
            FocusTracker.shared.clearEvent()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        guard let validFocusRecords = dataItem.validFocusRecords, validFocusRecords.count > 0 else {
            discardHandler()
            return
        }

        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let discardAction = TPAlertAction(type: .destructive,
                                          title: resGetString("Discard"),
                                          handleBeforeDismiss: false) { action in
            discardHandler()
        }
        
        let count = validFocusRecords.count
        let message: String
        if count > 1 {
            let format = resGetString("%ld focus records of this round will be discarded")
            message = String(format: format, count)
        } else {
            message = resGetString("The focus record of this round will be discarded")
        }

        let alertController = TPAlertController(title: resGetString("Discard Focus Data"),
                                                message: message,
                                                actions: [cancelAction, discardAction])
        alertController.show()
    }
    
}
