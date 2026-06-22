//
//  LocalNotificationPreviewViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/22.
//

import Foundation
import UIKit
import UserNotifications

// MARK: - Notification Preview View Controller

final class LocalNotificationPreviewViewController: UITableViewController {
    
    private var notifications: [UNNotificationRequest] = []
    private let emptyLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        title = "本地通知预览"
        setupTableView()
        setupEmptyState()
        setupRefreshControl()
        
        Task { await loadNotifications() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次进入页面自动刷新，保证数据最新
        Task { await loadNotifications() }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupEmptyState() {
        emptyLabel.text = "暂无待触发的本地通知"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        Task { await loadNotifications() }
    }
    
    // MARK: - Data Loading
    
    @MainActor
    private func loadNotifications() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        
        // 按触发时间正序排序
        self.notifications = requests.sorted { lhs, rhs in
            let lhsDate = triggerDate(from: lhs.trigger) ?? .distantFuture
            let rhsDate = triggerDate(from: rhs.trigger) ?? .distantFuture
            return lhsDate < rhsDate
        }
        
        emptyLabel.isHidden = !notifications.isEmpty
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    /// 从任意 Trigger 类型中提取可读的触发时间
    private func triggerDate(from trigger: UNNotificationTrigger?) -> Date? {
        guard let trigger = trigger else { return nil }
        
        if let calendar = trigger as? UNCalendarNotificationTrigger {
            return Calendar.current.nextDate(after: Date(), matching: calendar.dateComponents, matchingPolicy: .strict)
        } else if let timeInterval = trigger as? UNTimeIntervalNotificationTrigger {
            return Date(timeIntervalSinceNow: timeInterval.timeInterval)
        } else if let location = trigger as? UNLocationNotificationTrigger {
            // 地理围栏触发无固定时间，返回 nil 排到最后
            _ = location
            return nil
        }
        return nil
    }
}

// MARK: - UITableViewDataSource & Delegate

extension LocalNotificationPreviewViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseId, for: indexPath) as! NotificationCell
        cell.configure(with: notifications[indexPath.row])
        return cell
    }
    
    // 点击复制完整信息
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let request = notifications[indexPath.row]
        let detail = formatNotificationDetail(request)
        
        UIPasteboard.general.string = detail
        
        let alert = UIAlertController(title: "已复制", message: "通知详情已复制到剪贴板", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // 左滑删除
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "取消") { [weak self] _, _, completion in
            guard let self = self else { return completion(false) }
            let request = self.notifications[indexPath.row]
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
            
            self.notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.emptyLabel.isHidden = !self.notifications.isEmpty
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    /// 格式化完整的调试信息
    private func formatNotificationDetail(_ request: UNNotificationRequest) -> String {
        let content = request.content
        var lines: [String] = []
        lines.append("🆔 Identifier: \(request.identifier)")
        lines.append("📌 Title: \(content.title)")
        lines.append("📝 Subtitle: \(content.subtitle)")
        lines.append("💬 Body: \(content.body)")
        lines.append("🔊 Sound: \(content.sound?.description ?? "none")")
        lines.append("🔢 Badge: \(content.badge?.intValue ?? 0)")
        lines.append("🏷️ Category: \(content.categoryIdentifier)")
        lines.append("📅 Trigger: \(request.trigger?.description ?? "none")")
        lines.append("📦 UserInfo: \(content.userInfo)")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Custom Cell

final class NotificationCell: UITableViewCell {
    
    static let reuseId = "NotificationCell"
    
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let timeLabel = UILabel()
    private let idLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        // Time badge
        timeLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        timeLabel.textColor = .systemBackground
        timeLabel.backgroundColor = .systemBlue
        timeLabel.layer.cornerRadius = 4
        timeLabel.clipsToBounds = true
        timeLabel.textAlignment = .center
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)

        // Title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 1
        
        // Body
        bodyLabel.font = .preferredFont(forTextStyle: .subheadline)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 3
        
        // ID
        idLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        idLabel.textColor = .tertiaryLabel
        idLabel.numberOfLines = 1
        
        // Top row: time + title
        let topRow = UIStackView(arrangedSubviews: [timeLabel, titleLabel])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.addArrangedSubview(topRow)
        stackView.addArrangedSubview(bodyLabel)
        stackView.addArrangedSubview(idLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with request: UNNotificationRequest) {
        let content = request.content
        titleLabel.text = content.title.isEmpty ? "(无标题)" : content.title
        bodyLabel.text = content.body.isEmpty ? "(无内容)" : content.body
        idLabel.text = "ID: \(request.identifier)"
        
        // 解析触发时间
        if let date = Self.extractTriggerDate(from: request.trigger) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm:ss"
            timeLabel.text = formatter.string(from: date)
            timeLabel.backgroundColor = date < Date() ? .systemRed : .systemBlue
        } else {
            timeLabel.text = "GEOFENCE"
            timeLabel.backgroundColor = .systemOrange
        }
    }
    
    private static func extractTriggerDate(from trigger: UNNotificationTrigger?) -> Date? {
        guard let trigger = trigger else { return nil }
        if let cal = trigger as? UNCalendarNotificationTrigger {
            return Calendar.current.nextDate(after: Date(), matching: cal.dateComponents, matchingPolicy: .strict)
        } else if let ti = trigger as? UNTimeIntervalNotificationTrigger {
            return Date(timeIntervalSinceNow: ti.timeInterval)
        }
        return nil
    }
}
