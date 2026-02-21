//
//  FocusRecordListBasicCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/21.
//

import Foundation
import UIKit

protocol FocusRecordListBasicCellDelegate: AnyObject {
    
    /// 点击更多按钮
    func focusRecordListBasicCell(_ cell: FocusRecordListBasicCell, didClickMore button: UIButton)
}

class FocusRecordListBasicCell: TPCollectionCell {

    var session: FocusSession? {
        didSet {
            update(with: session)
        }
    }
    
    /// 头视图
    lazy var infoView: FocusRecordListCellBasicInfoView = {
        let view = FocusRecordListCellBasicInfoView()
        view.didClickMore = { [weak self] button in
            if let self = self,  let delegate = self.delegate as? FocusRecordListBasicCellDelegate {
                delegate.focusRecordListBasicCell(self, didClickMore: button)
            }
        }
        
        return view
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.padding = FocusRecordListBasicCellLayout.contentPadding
        infoView.frame = contentView.layoutFrame()
    }
    
    private func update(with session: FocusSession?) {
        guard let session = session else {
            return
        }

        infoView.session = session
        setNeedsLayout()
    }
}
