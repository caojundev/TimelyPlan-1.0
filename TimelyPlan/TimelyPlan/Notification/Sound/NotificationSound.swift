//
//  NotificationSoundManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/28.
//

import Foundation
import UserNotifications
import AVFoundation

// MARK: - 通知声音枚举
enum NotificationSound: String, Codable, CaseIterable {
    case happyAlert = "happy-alert"
    case gladNotice = "glad-notice"
    case lightHearted = "light-hearted"
    
    var displayName: String {
        switch self {
        case .happyAlert:
            return resGetString("Happy Alert")
        case .gladNotice:
            return resGetString("Glad Notice")
        case .lightHearted:
            return resGetString("Light Hearted")
        }
    }
    
    var fileName: String {
        return self.rawValue
    }
    
    var fileExtension: String {
        return "caf"
    }
    
    var fullFileName: String {
        return "\(fileName).\(fileExtension)"
    }
    
    var toUNNotificationSound: UNNotificationSound {
        let sound = NotificationSoundManager.shared.convertToUNNotificationSound(self)
        return sound ?? .default
    }
    
    static func displayName(of sound: NotificationSound?) -> String {
        guard let sound = sound else {
            return resGetString("System Default")
        }

        return sound.displayName
    }
}

// MARK: - 通知声音管理器
class NotificationSoundManager {
    
    // MARK: - 单例
    static let shared = NotificationSoundManager()
    
    private init() {
        for sound in NotificationSound.allCases {
            let notificationSound: UNNotificationSound
            if soundFileExists(sound) {
                let soundName = UNNotificationSoundName(rawValue: sound.fullFileName)
                notificationSound = UNNotificationSound(named: soundName)
                soundCache[sound] = notificationSound
            }
        }
    }
    
    // MARK: - 声音缓存
    private var soundCache: [NotificationSound: UNNotificationSound] = [:]
    
    // MARK: - 音频播放器引用（修复播放问题）
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - 转换为 UNNotificationSound
    
    func convertToUNNotificationSound(_ sound: NotificationSound) -> UNNotificationSound? {
        return soundCache[sound]
    }
    
    // MARK: - 检查声音文件是否存在
    func soundFileExists(_ sound: NotificationSound) -> Bool {
        // 首先检查主 Bundle
        if let _ = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) {
            return true
        }
        
        // 然后检查 Library/Sounds 目录
        if let soundsURL = soundsDirectoryURL() {
            let fileURL = soundsURL.appendingPathComponent(sound.fullFileName)
            return FileManager.default.fileExists(atPath: fileURL.path)
        }
        
        return false
    }
    
    // MARK: - 获取声音文件路径
    func soundFileURL(for sound: NotificationSound) -> URL? {
        // 先检查主 Bundle
        if let url = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) {
            return url
        }
        
        // 再检查 Library/Sounds 目录
        if let soundsURL = soundsDirectoryURL() {
            let fileURL = soundsURL.appendingPathComponent(sound.fullFileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
        }
        
        return nil
    }
    
    // MARK: - 导入自定义声音文件
    func importCustomSound(from sourceURL: URL, soundName: String) throws {
        guard let soundsURL = soundsDirectoryURL() else {
            throw SoundManagerError.directoryNotFound
        }
        
        // 创建目录（如果不存在）
        if !FileManager.default.fileExists(atPath: soundsURL.path) {
            try FileManager.default.createDirectory(at: soundsURL,
                                                  withIntermediateDirectories: true)
        }
        
        let destinationURL = soundsURL.appendingPathComponent("\(soundName).caf")
        
        // 如果文件已存在，先删除
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        // 复制文件
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        
        // 清除缓存以确保使用新文件
        clearCache()
        
        debugPrint("✅ 自定义声音导入成功: \(destinationURL.path)")
    }
    
    // MARK: - 删除自定义声音
    func removeCustomSound(_ sound: NotificationSound) throws {
        guard let url = soundFileURL(for: sound) else {
            throw SoundManagerError.fileNotFound
        }
        
        // 不要删除 bundle 中的声音文件
        if url.path.contains(Bundle.main.bundlePath) {
            throw SoundManagerError.cannotDeleteBundleResource
        }
        
        try FileManager.default.removeItem(at: url)
        clearCache()
        
        debugPrint("✅ 自定义声音删除成功: \(url.path)")
    }
    
    // MARK: - 获取所有可用的声音
    func getAvailableSounds() -> [NotificationSound] {
        return NotificationSound.allCases.filter { sound in
            return soundFileExists(sound)
        }
    }
    
    // MARK: - 清除缓存
    func clearCache() {
        soundCache.removeAll()
    }
    
    // MARK: - 播放预览声音
    func previewSound(_ sound: NotificationSound?) {
        guard let sound = sound, let url = soundFileURL(for: sound) else {
            // 播放系统默认声音（这个不会卡顿）
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(1007)
            }
            return
        }
        
        // 捕获 url 的副本，避免在闭包中引用
        let soundURL = url
        let soundName = sound.displayName
        
        // 在后台线程处理音频
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                // 配置音频会话（这个操作较重，放在后台）
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .default, options: [])
                try audioSession.setActive(true)
                
                // 创建音频播放器（文件读取也在后台）
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.prepareToPlay()
                
                // 回到主线程保存引用并播放
                DispatchQueue.main.async {
                    self?.audioPlayer = player
                    player.play()
                    debugPrint("✅ 正在预览声音: \(soundName) from \(soundURL.path)")
                }
            } catch {
                DispatchQueue.main.async {
                    debugPrint("❌ 播放预览失败: \(error.localizedDescription)")
                }
            }
        }
    }
    // MARK: - 停止预览声音
    func stopPreviewSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    // MARK: - 私有方法
    private func soundsDirectoryURL() -> URL? {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory,
                                                        in: .userDomainMask).first else {
            return nil
        }
        return libraryURL.appendingPathComponent("Sounds")
    }
}

// MARK: - 错误类型
enum SoundManagerError: LocalizedError {
    case directoryNotFound
    case fileNotFound
    case cannotDeleteBundleResource
    
    var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "声音目录未找到"
        case .fileNotFound:
            return "声音文件未找到"
        case .cannotDeleteBundleResource:
            return "不能删除Bundle中的资源文件"
        }
    }
}
