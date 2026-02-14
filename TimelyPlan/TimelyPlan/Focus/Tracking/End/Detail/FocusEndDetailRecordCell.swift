//
//  FocusEndDetailRecordCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/15.
//

import Foundation
import UIKit

class FocusEndDetailRecordCellItem: TPCollectionCellItem {

    let record: FocusRecord

    var timelineRowHeight = kDefaultTimelineRowHeight
    
    let headerViewHeight = 50.0
    
    let infoViewHeight = 100.0

    var timelineViewHeight: CGFloat {
        let rowsCount = self.record.timeline.recordDurations.count + 2 /// 加上开始结束日期
        return CGFloat(rowsCount) * timelineRowHeight
    }
    
    var noteViewHeight: CGFloat {
        let note = self.record.note
        guard let size = self.constraintSize,
              let note = note?.whitespacesAndNewlinesTrimmedString,
              note.count > 0 else {
            return kFocusEndRecordNotePlaceholderHeight
        }
       
        /// 计算备注高度
        let noteWidth = size.width - contentPadding.horizontalLength - kFocusEndRecordNotePadding.horizontalLength
        let maxSize = CGSize(width: noteWidth, height: .greatestFiniteMagnitude)
        let noteSize = note.size(with: kFocusEndRecordNoteFont, maxSize: maxSize)
        let noteHeight = noteSize.height + kFocusEndRecordNotePadding.verticalLength
        return noteHeight
    }
    
    init(record: FocusRecord) {
        self.record = record
        super.init()
        self.registerClass = FocusEndDetailRecordCell.self
        self.contentPadding = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 15.0, right: 15.0)
        self.canHighlight = false
    }
    
    override var size: CGSize? {
        get {
            var height = contentPadding.verticalLength + headerViewHeight
            height += infoViewHeight
            height += timelineViewHeight
            height += noteViewHeight
            return CGSize(width: .greatestFiniteMagnitude, height: height)
        }
        
        set { }
    }
}

protocol FocusEndDetailRecordCellDelegate: AnyObject {
    
    /// 点击绑定
    func focusEndDetailRecordCellDidClickBind(_ cell: FocusEndDetailRecordCell)
    
    /// 点击备注
    func focusEndDetailRecordCellDidClickNote(_ cell: FocusEndDetailRecordCell)
}

class FocusEndDetailRecordCell: TPCollectionCell {

    var record: FocusRecord?
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? FocusEndDetailRecordCellItem else {
                return
            }
            
            self.headerViewHeight = cellItem.headerViewHeight
            self.infoViewHeight = cellItem.infoViewHeight
            self.timelineRowHeight = cellItem.timelineRowHeight
            self.timelineViewHeight = cellItem.timelineViewHeight
            self.noteViewHeight = cellItem.noteViewHeight
            self.record = cellItem.record
            self.reloadData()
        }
    }

    /// 头视图
    var headerViewHeight: CGFloat = 50.0
    lazy var headerView: FocusEndDetailRecordCellHeader = {
        let view = FocusEndDetailRecordCellHeader()
        return view
    }()
    
    var infoViewHeight: CGFloat = 100.0
    lazy var infoView: TPInfoGalleryView = {
        let view = TPInfoGalleryView(frame: .zero, infoViewsCount: 3)
        view[0].titleConfig.textAlignment = .left
        view[0].subtitleConfig.textAlignment = .left
        view[0].subtitle = resGetString("Focus Duration")
        view[1].subtitle = resGetString("Pause Duration")
        view[2].subtitle = resGetString("Score")
        return view
    }()
    
    /// 时间线视图
    var timelineViewHeight: CGFloat = 0.0
    var timelineRowHeight: CGFloat = kDefaultTimelineRowHeight
    lazy var timelineView: FocusEndDetailTimelineView = {
        let view = FocusEndDetailTimelineView()
        return view
    }()
    
    /// 备注视图
    var noteViewHeight: CGFloat = 0.0
    lazy var noteView: FocusEndDetailRecordNoteView = {
        let view = FocusEndDetailRecordNoteView()
        view.didClickNote = { [weak self] in
            guard let self = self, let delegate = self.delegate as? FocusEndDetailRecordCellDelegate else {
                return
            }
            
            delegate.focusEndDetailRecordCellDidClickNote(self)
        }
        
        return view
    }()
    

    override func setupContentSubviews() {
        super.setupContentSubviews()
        headerView.bindButton.addTarget(self,
                                        action: #selector(clickBind(_:)),
                                        for: .touchUpInside)
        contentView.addSubview(headerView)
        contentView.addSubview(infoView)
        contentView.addSubview(timelineView)
        contentView.addSubview(noteView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        headerView.width = layoutFrame.width
        headerView.height = headerViewHeight
        headerView.origin = layoutFrame.origin
        
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.left = layoutFrame.minX
        infoView.top = headerView.bottom

        timelineView.width = contentView.width
        timelineView.height = timelineViewHeight
        timelineView.top = infoView.bottom
        
        noteView.width = layoutFrame.width
        noteView.height = noteViewHeight
        noteView.top = timelineView.bottom
        noteView.left = layoutFrame.minX
    }

    func reloadData() {
        /// 头信息
        headerView.color = record?.color ?? kFocusTimerDefaultColor
        if let attributedRangeText = record?.timeline.attributedDateRangeString() {
            headerView.title = attributedRangeText
        } else {
            headerView.title = "--"
        }
//        headerView.subtitle = resGetString("No task")
        
        /// 专注描述信息
        if let focusDuration = record?.timeline.focusInterval, focusDuration > 0 {
            infoView[0].title = Duration(focusDuration).attributedTitle
        } else {
            infoView[0].title = "--"
        }
        
        if let pauseDuration = record?.timeline.pauseInterval, pauseDuration > 0 {
            infoView[1].title = Duration(pauseDuration).attributedTitle
        } else {
            infoView[1].title = "--"
        }
        
        if let score = record?.score {
            infoView[2].title = "\(score)"
        } else {
            infoView[2].title = "--"
        }
        
        /// 时间线
        timelineView.rowHeight = timelineRowHeight
        timelineView.timeline = record?.timeline
        timelineView.reloadData()

        /// 备注
        noteView.note = record?.note
        setNeedsLayout()
    }
    
    /// 点击绑定
    @objc func clickBind(_ button: UIButton) {
        guard let delegate = self.delegate as? FocusEndDetailRecordCellDelegate else {
            return
        }
        
        delegate.focusEndDetailRecordCellDidClickBind(self)
    }
}

// MARK: - 头视图
class FocusEndDetailRecordCellHeader: TPInfoView {
    
    var color: UIColor? {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    /// 颜色视图
    private let colorView = UIView()
    
    /// 绑定按钮
    lazy var bindButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(horizontal: -20.0, vertical: -20.0)
        button.image = resGetImage("bind_24")
        return button
    }()
    
    let bindButtonSize = CGSize(width: 30.0, height: 30.0)
    let colorViewSize = CGSize(width: 6.0, height: 36.0)
    let colorViewRightMargin = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(left: 10.0)
        self.addSubview(colorView)
//        self.addSubview(bindButton)
        
        let textColor = resGetColor(.title)
        self.titleConfig.textColor = textColor
        self.titleConfig.font = BOLD_BODY_FONT
        self.subtitleConfig.textColor = textColor
        self.subtitleConfig.font = UIFont.systemFont(ofSize: 10.0)
        self.subtitleConfig.alpha = 0.6
        self.subtitleTopMargin = 5.0
        self.bindButton.imageConfig.color = textColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func labelLayoutFrame() -> CGRect {
        let frame = super.labelLayoutFrame()
        return frame.inset(by: UIEdgeInsets(left: colorViewSize.width + colorViewRightMargin,
                                            right: bindButtonSize.width))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        colorView.layer.cornerRadius = colorViewSize.width / 2.0
        colorView.size = colorViewSize
        colorView.left = layoutFrame.minX
        colorView.alignVerticalCenter()
        
        bindButton.size = bindButtonSize
        bindButton.right = layoutFrame.maxX
        bindButton.alignVerticalCenter()
    }
}


// MARK: - 备注视图
let kFocusEndRecordNotePlaceholderHeight = 60.0
let kFocusEndRecordNotePadding = UIEdgeInsets(value: 15.0)
let kFocusEndRecordNoteFont = BOLD_SMALL_SYSTEM_FONT

class FocusEndDetailRecordNoteView: UIView {
    
    /// 点击备注
    var didClickNote: (() -> Void)?
    
    /// 备注
    var note: String? {
        didSet {
            guard let note = note?.whitespacesAndNewlinesTrimmedString, note.count > 0 else {
                noteLabel.text = nil
                noteLabel.isHidden = true
                placeholderView.isHidden = false
                return
            }
            
            noteLabel.text = note
            noteLabel.isHidden = false
            placeholderView.isHidden = true
        }
    }
    
    /// 标签
    private lazy var noteLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = kFocusEndRecordNotePadding
        label.textAlignment = .left
        label.font = kFocusEndRecordNoteFont
        label.numberOfLines = 0
        label.textColor = resGetColor(.title)
        return label
    }()
    
    /// 无备注占位视图
    private lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.alpha = 0.6
        view.isUserInteractionEnabled = false
        view.isBorderHidden = false
        view.titleLabel.font = BOLD_SYSTEM_FONT
        view.titleLabel.textColor = resGetColor(.title)
        view.title = resGetString("Add Note")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = .zero
        self.addSubview(self.placeholderView)
        self.addSubview(self.noteLabel)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(recognizer)
        self.note = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        noteLabel.frame = bounds
        noteLabel.layer.backgroundColor = Color(0xbbbbbb, 0.1).cgColor
        noteLabel.layer.cornerRadius = 8.0
        placeholderView.frame = bounds.inset(by: UIEdgeInsets(horizontal: 10.0))
        placeholderView.layer.cornerRadius = 8.0
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickNote?()
    }
}
