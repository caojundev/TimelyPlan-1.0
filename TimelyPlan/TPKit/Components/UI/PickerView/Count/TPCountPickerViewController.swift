//
//  TPCountPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation
import UIKit

class TPCountPickerViewController: TPViewController {
    
    /// 最小数目
    var minimumCount: Int = 1
    
    /// 最大数目
    var maximumCount: Int = 100
    
    /// 步长数目
    var stepCount: Int = 1
    
    /// 当前数目
    var count: Int = 1
    
    /// 选中数目回调
    var didPickCount: ((Int) -> Void)?
    
    /// 内容尺寸
    var contentSize: CGSize = CGSize(width: kPopoverPreferredContentWidth, height: 260.0)
    
    /// 获取特定数目对应的尾文本
    var tailingTextForCount: ((Int) -> String?)? {
        get {
            return pickerView.tailingTextForCount
        }
        
        set {
            pickerView.tailingTextForCount = newValue
        }
    }
    
    private lazy var pickerView: TPCountPickerView = {
        let view = TPCountPickerView()
        return view
    }()

    private var contentView: UIView {
        let view = view as! UIVisualEffectView
        return view.contentView
    }
    
    override func loadView() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        self.view = UIVisualEffectView(effect: blurEffect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.padding = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 0.0, right: 10.0)
        contentView.addSubview(pickerView)
        setupActionsBar(actions: [doneAction])
        actionsBar?.padding = UIEdgeInsets(vertical: 10.0)
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        pickerView.frame = layoutFrame
        pickerView.height = layoutFrame.height - actionsBarHeight
        updatePopoverContentSize()
    }
    
    override var popoverContentSize: CGSize {
        return contentSize
    }
    
    func reloadData() {
        pickerView.stepCount = stepCount
        pickerView.minimumCount = minimumCount
        pickerView.maximumCount = maximumCount
        pickerView.count = count
        pickerView.reloadData()
    }
    
    override func clickDone() {
        didPickCount?(pickerView.count)
        dismiss(animated: true, completion: nil)
    }
}
