//
//  HabitReportImageCacher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/19.
//

import Foundation
import UIKit

/// 图片缓存键，用于唯一确定一张图片
struct HabitReportImageCacheKey: Hashable {
    let identifier: String
    let date: Date
    let size: CGSize
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(date.timeIntervalSince1970)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
    
    static func == (lhs: HabitReportImageCacheKey, rhs: HabitReportImageCacheKey) -> Bool {
        return lhs.identifier == rhs.identifier &&
               lhs.date == rhs.date &&
               lhs.size == rhs.size
    }
}

/// 图片缓存器（纯内存版本）
final class HabitReportImageCacher {
    
    private let cache = NSCache<NSString, UIImage>()
    
    var maxMemoryCount: Int = 100
    var maxMemoryCost: Int = 1024 * 1024 * 50 // 50MB
    
    /// 初始化图片缓存器
    /// - Parameters:
    ///   - maxMemoryCount: 最大缓存图片数量
    ///   - maxMemoryCost: 最大缓存内存成本（字节）
    init(maxMemoryCount: Int = 100, maxMemoryCost: Int = 1024 * 1024 * 50) {
        self.maxMemoryCount = maxMemoryCount
        self.maxMemoryCost = maxMemoryCost
        cache.countLimit = maxMemoryCount
        cache.totalCostLimit = maxMemoryCost
    }
    
    // MARK: - Public Methods
    
    /// 获取缓存的图片
    /// - Parameters:
    ///   - identifier: 图片标识符
    ///   - date: 日期
    ///   - size: 图片尺寸
    /// - Returns: 缓存的图片，如果未命中则返回 nil
    func getImage(identifier: String, date: Date, size: CGSize) -> UIImage? {
        let key = makeCacheKeyString(identifier: identifier, date: date, size: size)
        return cache.object(forKey: key as NSString)
    }
    
    /// 缓存图片
    /// - Parameters:
    ///   - image: 要缓存的图片
    ///   - identifier: 图片标识符
    ///   - date: 日期
    ///   - size: 图片尺寸
    func setImage(_ image: UIImage?, identifier: String, date: Date, size: CGSize) {
        guard let image = image else { return }
        
        let key = makeCacheKeyString(identifier: identifier, date: date, size: size)
        let cost = calculateMemoryCost(for: image)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    /// 移除特定缓存
    /// - Parameters:
    ///   - identifier: 图片标识符
    ///   - date: 日期
    ///   - size: 图片尺寸
    func removeImage(identifier: String, date: Date, size: CGSize) {
        let key = makeCacheKeyString(identifier: identifier, date: date, size: size)
        cache.removeObject(forKey: key as NSString)
    }
    
    /// 清空所有缓存
    func removeAllImages() {
        cache.removeAllObjects()
    }
    
    /// 检查是否存在缓存
    /// - Parameters:
    ///   - identifier: 图片标识符
    ///   - date: 日期
    ///   - size: 图片尺寸
    /// - Returns: 是否存在缓存
    func hasCachedImage(identifier: String, date: Date, size: CGSize) -> Bool {
        return getImage(identifier: identifier, date: date, size: size) != nil
    }
    
    // MARK: - Private Methods
    
    private func makeCacheKeyString(identifier: String, date: Date, size: CGSize) -> String {
        let timestamp = Int(date.timeIntervalSince1970)
        return "\(identifier)_\(timestamp)_\(Int(size.width))x\(Int(size.height))"
    }
    
    private func calculateMemoryCost(for image: UIImage) -> Int {
        let bytesPerPixel = 4
        let scale = UIScreen.main.scale
        let pixels = Int(image.size.width * image.size.height * scale * scale)
        return pixels * bytesPerPixel
    }
}
