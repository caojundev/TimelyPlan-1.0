//
//  JSONValueTransformer.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/2.
//

import Foundation

class JSONValueTransformer<T>: ValueTransformer where T: Codable {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let value = value as? T, let data = try? encoder.encode(value) else {
            return nil
        }
        
        return data as NSData
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let obj = try decoder.decode(T.self, from: data as Data)
            return obj
        } catch {
            debugPrint("JSON 解析失败：\(error.localizedDescription)")
            return nil
        }
    }
}
 
