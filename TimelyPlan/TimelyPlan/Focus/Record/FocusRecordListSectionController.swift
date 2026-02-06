//
//  FocusRecordListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/7.
//

import Foundation

class FocusRecordListSectionController: TPCollectionBaseSectionController,
                                            FocusRecordListCellDelegate {
    
    let date: Date
    
    let sessions: [FocusSession]
    
    /// 区块布局对象
    let sectionLayout = TPCollectionSectionLayout()
    
    init(date: Date, sessions: [FocusSession]) {
        self.date = date
        self.sessions = sessions
        super.init()
        self.identifier = date.yearMonthDayString
        self.sectionLayout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.sectionLayout.preferredItemWidth = .greatestFiniteMagnitude
        self.sectionLayout.preferredItemHeight = .greatestFiniteMagnitude
    }
    
    override var items: [ListDiffable]? {
        return self.sessions
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return sectionLayout.sectionInset
    }
    
    override func interitemSpacing() -> CGFloat {
        return sectionLayout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return sectionLayout.lineSpacing
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let session = item(at: index) as? FocusSession else {
            return .zero
        }
    
        sectionLayout.collectionViewSize = adapter?.collectionViewSize() ?? .zero
        let constraintCellSize = sectionLayout.constraintCellSize ?? .zero
        let cellLayout = FocusRecordListCellLayout(session: session)
        cellLayout.width = constraintCellSize.width
        return cellLayout.cellSize
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusRecordListCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        guard let cell = cell as? FocusRecordListCell else {
            return
        }
        
        cell.delegate = self
        cell.cellStyle = styleForItem(at: index)
        cell.session = item(at: index) as? FocusSession
    }
    
    override func didSelectItem(at index: Int) {
        guard let session = item(at: index) as? FocusSession else {
            return
        }
        
        self.editRecord(for: session)
    }
    
    // MARK: - Header
    override func sizeForHeader() -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    override func classForHeader() -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    override func didDequeHeader(_ headerView: UICollectionReusableView) {
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.padding = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 0, right: 16.0)
            headerView.titleConfig.font = .boldSystemFont(ofSize: 16.0)
            headerView.titleConfig.textColor = resGetColor(.title)
            headerView.title = date.monthDayWeekdaySymbolString
        }
    }
    
    // MARK: - FocusRecordListCellDelegate
    func focusRecordListCell(_ cell: FocusRecordListCell, didClickMore button: UIButton) {
        guard let session = cell.session else {
            return
        }
        
        let menuController = FocusRecordMenuController()
        menuController.didSelectMenuActionType = { type in
            switch type {
            case .edit:
                self.editRecord(for: session)
            case .delete:
                self.deleteRecord(for: session)
            }
        }

        let sourceRect = button.bounds.insetBy(dx: -10.0, dy: -10.0)
        menuController.showMenu(from: button,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    func editRecord(for session: FocusSession) {
        let record = session.editingRecord
        let vc = FocusRecordEditViewController(record: record, editType: .modify)
        vc.didEndEditing = { record in
            focus.updateSession(session, with: record)
        }
        
        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    func deleteRecord(for session: FocusSession) {
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            focus.deleteSession(session)
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let message = resGetString("Sure to delete this focus record?")
        let alertController = TPAlertController(title: resGetString("Delete Record"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
}
