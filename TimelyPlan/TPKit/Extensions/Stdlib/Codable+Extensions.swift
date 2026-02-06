//
//  Codable+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/7.
//

import Foundation

extension Encodable {
    
    /// 日期编码策略
    static func dateEncodingStrategy() -> JSONEncoder.DateEncodingStrategy {
        return .iso8601
    }
    
    /// 返回 JSON 数据对象
    public func jsonData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = Self.dateEncodingStrategy()
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        
        return data
    }
    
    /// 返回 JSON 字符串
    public func jsonString() -> String? {
        if let data = jsonData() {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
}

extension Decodable {
    
    /// 日期编码策略
    static func dateDecodingStrategy() -> JSONDecoder.DateDecodingStrategy {
        return .iso8601
    }
    
    static func model(with jsonData: Data) -> Self? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = Self.dateDecodingStrategy()
        if let model = try? decoder.decode(Self.self, from: jsonData) {
            return model
        }
        
        return nil
    }
    
    static func model(with jsonString: String) -> Self? {
        if let _ = Self.self as? String.Type {
            return jsonString as? Self
        }
        
        if let data = jsonString.data(using: .utf8) {
            return model(with: data)
        }
        
        return nil
    }
}
