//
//  FocusRecordListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/7.
//

import Foundation

class FocusRecordListSectionController: TPCollectionBaseSectionController,
                                            FocusRecordListDetailCellDelegate,
                                            FocusRecordListBasicCellDelegate {
    
    let date: Date
    
    let sessions: [FocusSession]
    
    /// 显示模式
    let mode: FocusRecordListMode
    
    /// 区块布局对象
    let sectionLayout = TPCollectionSectionLayout()
    
    init(date: Date, sessions: [FocusSession], mode: FocusRecordListMode) {
        self.date = date
        self.sessions = sessions
        self.mode = mode
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
        
        switch mode {
        case .detail:
            let cellLayout = FocusRecordListDetailCellLayout(session: session)
            cellLayout.width = constraintCellSize.width
            return cellLayout.cellSize
        case .basic:
            let cellLayout = FocusRecordListBasicCellLayout(session: session)
            cellLayout.width = constraintCellSize.width
            return cellLayout.cellSize
        }
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        switch mode {
        case .detail:
            return FocusRecordListDetailCell.self
        case .basic:
            return FocusRecordListBasicCell.self
        }
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        switch mode {
        case .detail:
            guard let cell = cell as? FocusRecordListDetailCell else {
                return
            }
            
            cell.delegate = self
            cell.cellStyle = styleForItem(at: index)
            cell.session = item(at: index) as? FocusSession
        case .basic:
            guard let cell = cell as? FocusRecordListBasicCell else {
                return
            }
            cell.delegate = self
            cell.cellStyle = styleForItem(at: index)
            cell.session = item(at: index) as? FocusSession
        }
    }
    
    override func didSelectItem(at index: Int) {
        guard let session = item(at: index) as? FocusSession else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
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
            headerView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
            headerView.titleConfig.textColor = resGetColor(.title)
            headerView.title = date.monthDayWeekdaySymbolString
        }
    }
    
    // MARK: - FocusRecordListDetailCellDelegate
    func focusRecordListDetailCell(_ cell: FocusRecordListDetailCell, didClickMore button: UIButton) {
        guard let session = cell.session else { return }
        handleMoreButtonClick(button, session: session)
    }
    
    // MARK: - FocusRecordListBasicCellDelegate
    func focusRecordListBasicCell(_ cell: FocusRecordListBasicCell, didClickMore button: UIButton) {
        guard let session = cell.session else { return }
        handleMoreButtonClick(button, session: session)
    }
    
    // MARK: - Private Methods
    private func handleMoreButtonClick(_ button: UIButton, session: FocusSession) {
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
        FocusPresenter.editRecord(for: session)
    }
    
    func deleteRecord(for session: FocusSession) {
        FocusPresenter.confirmRecordDeletion { confirmed in
            if confirmed {
                focus.deleteSession(session)
            }
        }
    }
}
