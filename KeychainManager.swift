//
//  KeychainManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/16.
//

/*
 在 "Remember Me" 功能中，存儲用戶的電子郵件和密碼是有風險的，尤其是明文存儲密碼會帶來很大的安全隱患。為了確保用戶信息的安全，建議對密碼進行加密或使用更安全的方法來存儲敏感數據。

 1. 使用 Keychain 存儲敏感信息
 Keychain 是 iOS 中專門用來安全存儲敏感信息的框架。它提供了一個安全的方式來存儲用戶的認證信息。

 2. 確保數據安全
 確保密碼不以明文形式存儲在任何地方，即使是本地存儲。使用 Keychain 可以防止數據被未經授權的應用程序訪問。此外，還可以考慮使用生物識別技術（如 Touch ID 或 Face ID）來提高安全性。

 3. 總結
 使用 Keychain 存儲用戶的敏感數據是一種安全且推薦的做法。Keychain 提供了一個安全的存儲空間，防止數據洩露或被未經授權的應用程序訪問。在設計和實現 "Remember Me" 功能時，請務必考慮數據安全問題，使用合適的工具和方法來保護用戶的隱私。
 */

import Foundation
import Security

/// 管理 Keychain 操作，方便對 Keychain 進行存取、檢索和刪除操作。（存取電子郵件和密碼到 Keychain）
class KeychainManager {
    
    @discardableResult
    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    @discardableResult
    class func delete(key: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        return SecItemDelete(query as CFDictionary)
    }
}
