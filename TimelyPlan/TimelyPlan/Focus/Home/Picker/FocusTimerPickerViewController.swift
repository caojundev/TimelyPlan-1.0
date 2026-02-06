//
//  FocusTimerPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class FocusTimerPickerViewController: TPContainerViewController,
                                      UISearchControllerDelegate  {
    
    /// 选中列表回调
    var didPickTimer: ((FocusTimerRepresentable?) -> Void)?

    /// 当前列表
    var selectedTimer: FocusTimerRepresentable?

    /// 列表搜索控制器
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search Timer")
        searchBar.tintColor = resGetColor(.title)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()

    var selectViewController: FocusTimerSelectViewController!
    
    init(timer: FocusTimerRepresentable? = nil) {
        self.selectedTimer = timer
        super.init(nibName: nil, bundle: nil)
        self.selectViewController = FocusTimerSelectViewController(timer: timer)
        self.selectViewController.didSelectTimer = { [weak self] timer in
            self?.selectTimer(timer)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Timer")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.setContentViewController(selectViewController, withAnimationStyle: .none)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    /// 选中列表
    private func selectTimer(_ timer: FocusTimerRepresentable?) {
        TPImpactFeedback.impactWithSoftStyle()
        self.selectedTimer = timer
        self.didPickTimer?(timer)
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        let selectedTimer = self.selectedTimer as? FocusTimer
        let resultVC = FocusTimerSearchResultViewController(timer: selectedTimer)
        /// 不限制单元格宽度
        resultVC.preferredItemWidth = .greatestFiniteMagnitude
        resultVC.didSelectTimer = { timer in
            self.selectTimer(timer)
        }

        searchController.searchResultsUpdater = resultVC
        setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchResultsUpdater = nil
        setContentViewController(selectViewController, withAnimationStyle: .none)
    }
    
    // MARK: - Class Methods
    class func show(with timer: FocusTimerRepresentable?, completion: ((FocusTimerRepresentable?) -> Void)?) {
        let vc = FocusTimerPickerViewController(timer: timer)
        vc.didPickTimer = { selectedTimer in
            if selectedTimer === timer {
                return
            }
            
            completion?(selectedTimer)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
}
