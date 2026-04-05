//
//  TodoTagSearchResultsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation
import UIKit

protocol TodoTagSearchResultsViewControllerDelegate: AnyObject {
    /// 创建新标签
    func todoTagSearchResultsViewController(_ vc: TodoTagSearchResultsViewController,
                                            createTagWithName name: String,
                                            color: UIColor)
}

class TodoTagSearchResultsViewController: TPTableSectionsViewController,
                                            UISearchResultsUpdating {
    
    weak var delegate: TodoTagSearchResultsViewControllerDelegate?
    
    private let resultsSectionController: TodoTagSearchResultsSectionController
  
    /// 占位视图
    private lazy var placeholderView: TodoTagSearchResultsPlaceholderView = {
        let placeholderView = TodoTagSearchResultsPlaceholderView()
        placeholderView.didClickCreate = { [weak self] name, color in
            self?.createTag(name: name, color: color)
        }
        
        return placeholderView
    }()

    let selection: TPMultipleItemSelection<TodoTag>
    
    init(selection: TPMultipleItemSelection<TodoTag>) {
        self.selection = selection
        self.resultsSectionController = TodoTagSearchResultsSectionController(selection: selection)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        tableView.placeholderView = placeholderView
        sectionControllers = [resultsSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func createTag(name: String?, color: UIColor) {
        guard let name = name, name.count > 0 else {
            return
        }
        
        delegate?.todoTagSearchResultsViewController(self,
                                                     createTagWithName: name,
                                                     color: color)
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.whitespacesAndNewlinesTrimmedString
        placeholderView.tagName = searchText
        resultsSectionController.updateSearchResults(for: searchController)
    }
}

fileprivate class TodoTagSearchResultsPlaceholderView: UIView {

    var tagName: String? {
        didSet {
            createView.tagName = tagName
            if let tagName = tagName, tagName.count > 0 {
                createView.isHidden = false
            } else {
                createView.isHidden = true
            }
        }
    }
    
    /// 点击创建按钮
    var didClickCreate: ((_ name: String?, _ color: UIColor) -> Void)? {
        get {
            return createView.didClickCreate
        }
        
        set {
            createView.didClickCreate = newValue
        }
    }
    
    private let createView = TodoTagSearchResultsCreateTagView()
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        padding = UIEdgeInsets(value: 10.0)
        imageView.image = resGetImage("placeholder_hashTag_80")
        imageView.isUserInteractionEnabled = false
        imageView.size = .size(20)
        imageView.alpha = 0.6
        addSubview(imageView)
    
        createView.isHidden = true
        addSubview(createView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        createView.width = layoutFrame.width
        createView.height = 45.0
        createView.origin = layoutFrame.origin
        
        imageView.alignCenter()
        imageView.updateContentMode()
    }
}


fileprivate class TodoTagSearchResultsCreateTagView: UIView {
    
    /// 点击创建按钮
    var didClickCreate: ((_ name: String?, _ color: UIColor) -> Void)?
    
    var tagName: String? {
        get {
            return createButton.tagName
        }
        
        set {
            createButton.tagName = newValue
        }
    }
    
    var tagColor: UIColor = TodoTag.defaultColor {
        didSet {
            colorButton.normalBackgroundColor = tagColor
        }
    }
    
    let createButton = TodoTagSearchResultsCreateTagButton()
    
    let colorButton = TPBaseButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        createButton.addTarget(self,
                               action: #selector(clickCreate(_:)),
                               for: .touchUpInside)
        addSubview(createButton)
        
        colorButton.hitTestEdgeInsets = UIEdgeInsets(value: -15.0)
        colorButton.cornerRadius = .greatestFiniteMagnitude
        colorButton.borderWidth = 2.0
        colorButton.normalBorderColor = Color(0x888888, 0.1)
        colorButton.normalBackgroundColor = tagColor
        colorButton.addTarget(self,
                              action: #selector(clickColor(_:)),
                              for: .touchUpInside)
        addSubview(colorButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createButton.padding = UIEdgeInsets(left: 5.0, right: 40.0)
        createButton.frame = bounds
        
        let layoutFrame = createButton.layoutFrame()
        colorButton.size = .mini
        colorButton.left = layoutFrame.maxX
        colorButton.centerY = layoutFrame.midY
    }
    
    @objc private func clickCreate(_ button: TodoTagSearchResultsCreateTagButton) {
        didClickCreate?(tagName, tagColor)
    }
    
    @objc private func clickColor(_ button: UIButton) {
        let selectView = TPColorSelectPopoverView()
        selectView.colors = TodoTag.colors
        selectView.selectedColor = tagColor
        selectView.didSelectColor = { color in
            self.tagColor = color
        }
        
        selectView.reloadData()
        selectView.show(from: button,
                        sourceRect: button.bounds,
                        isCovered: false,
                        preferredPosition: .bottomLeft,
                        permittedPositions: [.bottomLeft],
                        animated: true)
    }
}
    
fileprivate class TodoTagSearchResultsCreateTagButton: TPBaseButton {
    
    var tagName: String? {
        didSet {
            nameLabel.text = tagName
        }
    }
    
    private let createLabel = TPLabel()
    
    private let nameLabel = TPLabel()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.borderWidth = 2.0
        self.normalBorderColor = .primary
        self.cornerRadius = 12.0
        self.normalBackgroundColor = .clear
        self.selectedBackgroundColor = .clear
        self.preferredTappedScale = 1.0
        
        createLabel.edgeInsets = UIEdgeInsets(horizontal: 5.0)
        createLabel.textAlignment = .center
        createLabel.textColor = .primary
        createLabel.font = BOLD_SMALL_SYSTEM_FONT
        createLabel.text = resGetString("Create Tag")
        contentView.addSubview(createLabel)
        
        nameLabel.edgeInsets = UIEdgeInsets(horizontal: 5.0)
        nameLabel.textAlignment = .left
        nameLabel.textColor = resGetColor(.title)
        nameLabel.font = BOLD_SMALL_SYSTEM_FONT
        contentView.addSubview(nameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        createLabel.sizeToFit()
        createLabel.height = layoutFrame.height
        createLabel.left = layoutFrame.minX
        createLabel.top = layoutFrame.minY
        
        nameLabel.width = layoutFrame.maxX - createLabel.right
        nameLabel.height = layoutFrame.height
        nameLabel.left = createLabel.right
        nameLabel.top = layoutFrame.minY
    }
    
}
