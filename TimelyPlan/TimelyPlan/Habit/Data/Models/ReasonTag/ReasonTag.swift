import Foundation

class ReasonTag: NSObject, Codable {
    
    /// 表情符号
    var emoji: String?
    
    /// 原因
    var reason: String?
    
    /// 表情 + 原因字符串
    var combinedString: String {
       return (emoji ?? "") + (reason ?? "")
    }
    
    convenience init(emoji: String?, reason: String?) {
        self.init()
        self.emoji = emoji
        self.reason = reason
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(emoji)
        hasher.combine(reason)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ReasonTag else { return false }
        if self === other { return true }
        return emoji == other.emoji && reason == other.reason
    }
    
    static func defaultTags() -> [ReasonTag] {
        let tagStrings = ["😴Ill",
                          "✈️Vacation",
                          "🚗Business trip",
                          "🌧️Rain",
                          "😓Exhausted",
                          "🎉Event",
                          "👥Social",
                          "🎮Game"]
        let tags = tagStrings.toReasonTags()
        for tag in tags {
            if let reason = tag.reason {
                tag.reason = resGetString(reason)
            }
        }
        
        return tags
    }
}

// MARK: - String Extension for ReasonTag

extension String {
    /// 将字符串转换为 ReasonTag
    /// - Returns: ReasonTag 实例
    func toReasonTag() -> ReasonTag {
        guard !isEmpty else {
            return ReasonTag(emoji: nil, reason: nil)
        }
        
        // 获取第一个字符
        let firstChar = String(self.first!)
        
        // 判断第一个字符是否为 emoji
        if firstChar.isEmoji {
            // 如果有剩余字符，作为 reason
            let remaining = dropFirst().isEmpty ? nil : String(dropFirst())
            return ReasonTag(emoji: firstChar, reason: remaining)
        } else {
            // 非 emoji，整个字符串作为 reason
            return ReasonTag(emoji: nil, reason: self)
        }
    }
}

// MARK: - Array Extension for ReasonTag

extension Array where Element == String {
    /// 将字符串数组转换为 ReasonTag 数组
    /// - Returns: ReasonTag 数组
    func toReasonTags() -> [ReasonTag] {
        return self.map { $0.toReasonTag() }
    }
}

// MARK: - Array Extension for ReasonTag to String

extension Array where Element == ReasonTag {
    /// 将 ReasonTag 数组转换为字符串数组
    /// - Returns: 字符串数组，每个元素为 emoji + reason 的组合
    func toStrings() -> [String] {
        return self.map { $0.combinedString }
    }
}

// MARK: - Character Extension for Emoji Detection

private extension String {
    /// 判断字符串是否为 emoji
    var isEmoji: Bool {
        // 检查是否包含 emoji 标量
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x1F1E0...0x1F1FF, // Regional indicator
                 0x2600...0x26FF,   // Miscellaneous symbols
                 0x2700...0x27BF,   // Dingbats
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1FA00...0x1FA6F, // Chess Symbols
                 0x1FA70...0x1FAFF, // Symbols and Pictographs Extended-A
                 0x200D,            // Zero-width joiner
                 0x20E3,            // Combining enclosing keycap
                 0xFE0F,            // Variation Selector-16
                 0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
}
