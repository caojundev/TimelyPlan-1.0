//
//  IAPUIKit.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/05.
//

#if canImport(UIKit)
import UIKit

// MARK: - UIKit 适配层
//
// 提供三个层次的用法，按需选择：
//   1. IAPViewController   —— 已经做好的付费页 UIViewController，零成本接入
//   2. IAPStorefront        —— 轻量状态订阅器，给它一个 UIViewController，自动帮你持有/释放订阅
//   3. observeEntitlement   —— 直接用回调订阅（见 IAPManager）

// MARK: - ① 轻量状态订阅器

/// 帮你管理订阅生命周期的辅助对象。
///
/// 典型用法（在 VC 里）：
/// ```swift
/// private let store = IAPStorefront(manager: .shared)
///
/// override func viewDidLoad() {
///     super.viewDidLoad()
///     store.onEntitlement = { [weak self] e in self?.updateUI(e) }
///     store.onProducts    = { [weak self] p in self?.reload(p) }
///     store.bind()   // VC 释放时 store 一并释放，订阅自动取消
/// }
/// ```
@MainActor
public final class IAPStorefront {

    public let manager: IAPManager

    /// 权益变化回调（已在主线程）
    public var onEntitlement: ((IAPEntitlement) -> Void)?
    /// 商品列表变化回调（已在主线程）
    public var onProducts: (([IAPStoreProduct]) -> Void)?

    private var entToken: IAPObservationToken?
    private var prodToken: IAPObservationToken?

    public init(manager: IAPManager? = nil) {
        self.manager = manager ?? .shared
    }

    /// 开始订阅。建议在 `viewDidLoad` 中调用。
    ///
    /// 注意：订阅的生命周期由 `IAPStorefront` 自身持有。
    /// 在 VC 中把它存为属性（`private let store = IAPStorefront(...)`），
    /// VC 释放时 `store` 一并释放，订阅自动取消，无需手动解绑。
    public func bind() {
        unbind()
        entToken = manager.observeEntitlement { [weak self] e in
            self?.onEntitlement?(e)
        }
        prodToken = manager.observeProducts { [weak self] p in
            self?.onProducts?(p)
        }
    }

    /// 主动退订
    public func unbind() {
        entToken?.cancel(); entToken = nil
        prodToken?.cancel(); prodToken = nil
    }
}

// MARK: - ② 现成的付费页 ViewController

/// 开箱即用的付费页。基于 `UITableView` 构建，无需 SwiftUI。
///
/// ```swift
/// let vc = IAPPaywallViewController(manager: iap)
/// vc.onFinish = { result in print(result.message) }
/// present(UINavigationController(rootViewController: vc), animated: true)
/// ```
@MainActor
public final class IAPPaywallViewController: UIViewController {

    public typealias FinishHandler = (IAPPurchaseResult) -> Void

    /// 购买/恢复结束后的回调
    public var onFinish: FinishHandler?

    /// 关闭按钮是否展示（作为子控制器时通常需要）
    public var showsCloseButton = true

    private let manager: IAPManager
    private let store: IAPStorefront
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingView = UIActivityIndicatorView(style: .medium)

    private var itemCellID = "IAPProductCell"

    public init(manager: IAPManager? = nil) {
        let resolved = manager ?? .shared
        self.manager = resolved
        self.store = IAPStorefront(manager: resolved)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "开通会员"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupBinding()
        Task { await manager.loadProducts() }
    }

    // MARK: - UI

    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        loadingView.hidesWhenStopped = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        if showsCloseButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closeTapped)
            )
        }
    }

    private func setupBinding() {
        store.bind()

        store.onProducts = { [weak self] _ in
            guard let self = self else { return }
            self.loadingView.stopAnimating()
            self.tableView.reloadData()
        }
        store.onEntitlement = { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: - 动作

    private func purchase(_ item: IAPStoreProduct, at indexPath: IndexPath) {
        loadingView.startAnimating()
        Task {
            let result = await manager.purchase(item)
            self.loadingView.stopAnimating()

            if case .success = result {} else {
                self.alert(result.message)
            }
            self.onFinish?(result)
        }
    }

    private func restore() {
        loadingView.startAnimating()
        Task {
            let snapshot = await manager.restore()
            self.loadingView.stopAnimating()
            if !snapshot.isActive {
                self.alert("未找到可恢复的购买记录。")
            }
            self.onFinish?(.success(entitlement: snapshot))
        }
    }

    private func alert(_ message: String) {
        let ac = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "好的", style: .cancel))
        present(ac, animated: true)
    }
}

// MARK: - 表格数据源

extension IAPPaywallViewController: UITableViewDataSource, UITableViewDelegate {

    public func numberOfSections(in tableView: UITableView) -> Int { 2 }

    private var products: [IAPStoreProduct] { manager.products }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? max(products.count, 1) : 1
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return manager.entitlement.isActive ? "会员已生效" : "会员方案"
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        section == 1
            ? "已购买过的用户请点击恢复。订阅可在系统「设置 → Apple ID → 订阅」中管理。"
            : nil
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: itemCellID)

        if indexPath.section == 0 {
            if products.isEmpty {
                cell.textLabel?.text = "暂无可用商品"
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            }
            let item = products[indexPath.row]
            cell.textLabel?.text = item.displayName
            cell.textLabel?.font = .preferredFont(forTextStyle: .body)
            cell.detailTextLabel?.text = detail(for: item)
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.accessoryView = priceLabel(item.displayPrice)

            // 已拥有则打勾
            if manager.entitlement.activeProductIDs.contains(item.id) {
                cell.accessoryType = .checkmark
                cell.accessoryView = nil
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.textLabel?.text = "恢复购买"
            cell.textLabel?.textColor = .systemBlue
            cell.textLabel?.font = .preferredFont(forTextStyle: .body)
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .default
            cell.accessoryView = nil
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            guard !products.isEmpty else { return }
            guard !manager.entitlement.activeProductIDs.contains(products[indexPath.row].id) else {
                alert("你已拥有该商品。")
                return
            }
            purchase(products[indexPath.row], at: indexPath)
        } else {
            restore()
        }
    }

    // MARK: - 辅助

    private func detail(for item: IAPStoreProduct) -> String {
        var parts: [String] = [item.subscriptionPeriodText ?? "永久"]
        if let trial = item.freeTrialText { parts.append(trial) }
        if !item.description.isEmpty { parts.append(item.description) }
        return parts.joined(separator: " · ")
    }

    private func priceLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .body)
        label.sizeToFit()
        return label
    }
}

// MARK: - ③ UIViewController 便捷扩展

public extension UIViewController {

    /// 以模态方式弹出内置付费页。
    ///
    /// - Parameters:
    ///   - manager: 默认使用 `IAPManager.shared`（需已 `configure`）
    ///   - onFinish: 购买/恢复结束回调
    func presentPaywall(
        manager: IAPManager? = nil,
        onFinish: IAPPaywallViewController.FinishHandler? = nil
    ) {
        let vc = IAPPaywallViewController(manager: manager ?? .shared)
        vc.onFinish = onFinish
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}
#endif
