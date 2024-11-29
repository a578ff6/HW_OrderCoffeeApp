//
//  KeychainManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/16.
//

// MARK: - KeychainManager 重點筆記
/**

 ### KeychainManager 重點筆記

 `* What - 什麼是 KeychainManager？`

 - `KeychainManager` 是一個簡化的工具類，用於對 `Keychain` 進行基本操作，如 `保存、加載和刪除數據`。
 - 它主要用於處理應用程序中的敏感信息，例如用戶的電子郵件和密碼，確保這些數據的安全性。

 `* Why - 為什麼需要使用 KeychainManager？`

 `1. 安全存儲敏感數據：`
 
    - 在 "Remember Me" 功能中，存儲用戶的電子郵件和密碼是有風險的，尤其是明文存儲密碼會帶來很大的安全隱患。
    - `Keychain` 是蘋果提供的安全存儲解決方案，適合用來存儲需要持久保存且高度敏感的用戶數據，例如帳號和密碼。它提供了一個安全的方式來存儲用戶的認證信息。
    - 使用 `KeychainManager` 可以將常見的 Keychain 存取操作進行封裝，減少重複代碼，提高代碼的可讀性和可維護性。

 `2. 確保數據安全：`
 
    - `Keychain` 可以防止數據被未經授權的應用程序訪問。確保密碼不以明文形式存儲在任何地方，即使是本地存儲。
    - 除此之外，還可以考慮使用生物識別技術（如 Touch ID 或 Face ID）來提高敏感數據的安全性。

 `* How - 如何使用 KeychainManager？`

 `1. 保存數據：`
    - 使用 `save(key:data:)` 方法將數據保存到 Keychain。
    - 例如：`KeychainManager.save(key: "userEmail", data: Data(email.utf8))`。

 `2. 加載數據：`
    - 使用 `load(key:)` 方法從 Keychain 中讀取數據。
    - 例如：`if let emailData = KeychainManager.load(key: "userEmail") { ... }`。

 `3. 刪除數據：`
    - 使用 `delete(key:)` 方法從 Keychain 中刪除某個鍵值對應的數據。
    - 例如：`KeychainManager.delete(key: "userEmail")`。

 `* 總結`

 - `使用 KeychainManager 保存用戶的敏感數據`是一種安全且推薦的做法。Keychain 提供了一個安全的存儲空間，防止數據洩露或被未經授權的應用程序訪問。
 - 在設計和實現 "`Remember Me`" 功能時，請務必考慮數據安全問題，使用合適的工具和方法來保護用戶的隱私。
 - `KeychainManager` 提供了一個封裝的介面，簡化了 Keychain 的使用，讓保存、加載和刪除敏感信息變得更加方便和安全。
 */


import Foundation
import Security

/// 管理 Keychain 操作，方便對 Keychain 進行存取、檢索和刪除操作（`存取電子郵件和密碼到 Keychain`）
class KeychainManager {
    
    // MARK: - Save Data to Keychain
    
    /// 將數據保存到 Keychain 中
    /// - Parameters:
    ///   - key: 要保存的鍵值，用於識別這條數據
    ///   - data: 要保存的數據（Data 格式）
    /// - Returns: 操作的狀態 (`OSStatus`)，可以用來檢查是否成功
    @discardableResult
    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        // 刪除現有的條目，防止重複
        SecItemDelete(query as CFDictionary)
        // 添加新的條目
        let status = SecItemAdd(query as CFDictionary, nil)
        print("Saving to Keychain: \(key), Status: \(status)")
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    // MARK: - Load Data from Keychain
    
    /// 從 Keychain 中加載數據
    /// - Parameter key: 用於識別數據的鍵值
    /// - Returns: 如果找到，則返回數據（Data 格式），否則返回 nil
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
            print("Loaded data from Keychain for key: \(key)")
            return dataTypeRef as! Data?
        } else {
            print("Failed to load data from Keychain for key: \(key), Status: \(status)")
            return nil
        }
    }
    
    // MARK: - Delete Data from Keychain
    
    /// 從 Keychain 中刪除數據
    /// - Parameter key: 要刪除的數據的鍵值
    /// - Returns: 操作的狀態 (`OSStatus`)，可以用來檢查是否成功
    @discardableResult
    class func delete(key: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        print("Deleting from Keychain: \(key), Status: \(status)")
        return SecItemDelete(query as CFDictionary)
    }
    
}
