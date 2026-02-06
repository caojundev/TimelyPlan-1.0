//
//  FocusUserTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/5.
//

import Foundation
import UIKit

class FocusHomeViewController: TPContainerViewController,
                                UISearchBarDelegate {
    
    weak var pageController: TPPageController? {
        didSet {
            self.timersViewController.pageController = pageController
        }
    }
    
    let searchBarHeight = 60.0
    let searchBarEdgeMargin = 10.0
    let searchBarMaxWidth = kFocusHomeContentMaxWidth
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        bar.placeholder = resGetString("Search Timer")
        bar.barTintColor = .clear
        bar.tintColor = resGetColor(.title)
        bar.backgroundImage = UIImage()
        return bar
    }()
    
    /// 用户计时器视图控制器
    lazy var timersViewController: FocusHomeUserTimerViewController = {
        let vc = FocusHomeUserTimerViewController()
        vc.pageController = self.pageController
        return vc
    }()
    
    var searchResultsViewController: FocusHomeSearchResultViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(searchBar)
        self.setContentViewController(timersViewController)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let searchBarWidth = view.width - 2 * searchBarEdgeMargin
        self.searchBar.width = min(searchBarMaxWidth, searchBarWidth)
        self.searchBar.height = searchBarHeight
        self.searchBar.alignHorizontalCenter()
    }

    override func contentViewFrame() -> CGRect {
        let inset = UIEdgeInsets(top: searchBarHeight)
        return self.view.bounds.inset(by: inset)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func revealTimer(_ timer: FocusTimer) {
        searchBarCancelButtonClicked(searchBar)
        timersViewController.revealTimer(timer)
    }
    
    private func startFocus(with timer: FocusTimer) {
        searchBarCancelButtonClicked(searchBar)
        FocusPresenter.startFocus(with: timer)
    }
    
    // MARK: - UISearchBarDelegate

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    
        if self.searchResultsViewController == nil {
            let resultsViewController = FocusHomeSearchResultViewController()
            resultsViewController.didClickStart = { [weak self] timer in
                self?.startFocus(with: timer)
            }
            
            resultsViewController.didSelectTimer = { [weak self] timer in
                self?.revealTimer(timer)
            }
            
            self.searchResultsViewController = resultsViewController
            self.setContentViewController(resultsViewController)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchTextCount = searchBar.text?.count ?? 0
        if searchTextCount == 0 {
            searchBarCancelButtonClicked(searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        
        self.searchResultsViewController = nil
        self.setContentViewController(timersViewController)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResultsViewController?.updateSearchResults(with: searchText)
    }
    
}
