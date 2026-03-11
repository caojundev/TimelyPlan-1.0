//
//  ReasonTagSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/18.
//

import Foundation

class ReasonTagSelectViewController: HabitReasonTagEditViewController {
    
    /// 选中标签回调
    var didSelectTag: ((ReasonTag) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Tag")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.preferredContentSize = CGSize(width: 400.0, height: 380.0)
        self.isEditingEnabled = false
        self.adapter.cellStyle.backgroundColor = .clear
    }
    
    override func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        let tag = adapter.item(at: indexPath) as! ReasonTag
        dismiss(animated: true, completion: {
            self.didSelectTag?(tag)
        })
    }
}
