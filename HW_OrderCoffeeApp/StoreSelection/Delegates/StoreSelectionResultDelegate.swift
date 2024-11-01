//
//  StoreSelectionResultDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/31.
//

// MARK: - StoreSelectionResultDelegate 重點筆記

/**
## StoreSelectionResultDelegate 重點筆記
 
 * `功能`：
    - `StoreSelectionResultDelegate` 用於實現「`店鋪選擇畫面(StoreSelectionViewController)`」和其他需要選擇結果的控制器之間的溝通。
    - 通知當用戶完成店鋪選擇後的結果，使得主畫面可以根據用戶選擇的店鋪及時更新顯示。

 * `主要組成部分`：
 
    - `storeSelectionDidComplete(with:)` 方法
            - 在用戶完成店鋪選擇後被呼叫，並將選擇的店鋪名稱作為參數傳遞給實現該代理的控制器。
            - 透過該方法，委託控制器可以即時更新顯示，提升使用者體驗。

 * `設計考量`：
 
    - 使用代理（Delegate）模式來通知選擇結果，確保「店鋪選擇畫面」與主控制器之間保持鬆耦合。
        - 這種方式能提高模組的重用性，使得 `StoreSelectionViewController` 可以被不同場景的控制器使用，而不需要緊密依賴特定控制器。
 
    - 確保當選擇結果回傳時，主控制器能及時更新相應的 UI，保持顯示資料與實際選擇的一致性。

 * `使用方式`：
        
    - 例如，在訂單流程中，當用戶進行取件門市選擇後，`OrderCustomerDetailsViewController` 會透過實現 `StoreSelectionResultDelegate` 接收選擇結果，並將選擇的店鋪名稱更新到顯示區域。

 * `未來改進`：
    
    - 可以考慮在店鋪選擇完成時，除了店鋪名稱之外，傳回更多關於店鋪的詳細資料（例如地址、營業時間等），以便於更全面的顯示。
    - 如果未來需要支持多個店鋪選擇，可能需要擴展 `storeSelectionDidComplete(with:)` 的參數，支持多店鋪的選擇結果。
*/


import Foundation

/// StoreSelectionResultDelegate 用於通知選擇店鋪的結果
///
/// 當使用者從「店鋪選擇畫面（StoreSelectionViewController）」中選擇完店鋪後，會呼叫此代理方法來通知結果，通常用於更新訂單相關的顧客資料。
///
/// ### 主要用途
/// - `StoreSelectionResultDelegate` 允許實現該協議的控制器收到來自 `StoreSelectionViewController` 的結果通知。
/// - 透過代理模式，實現了「店鋪選擇畫面」和主訂單畫面之間的鬆耦合關係，使得不同的視圖控制器之間可以共享資訊。
///
/// ### 使用情境
/// - 當用戶選擇取件門市時，將結果回傳給主訂單畫面（如 `OrderCustomerDetailsViewController`），從而使選擇的店鋪名稱能即時顯示在主畫面中。
protocol StoreSelectionResultDelegate: AnyObject {
    
    /// 店鋪選擇完成後調用此方法
    ///
    /// - Parameter storeName: 被選擇的店鋪名稱，用於更新顧客訂單中的取件門市資訊。
    ///
    /// ### 行為描述
    /// - 當用戶在 `StoreSelectionViewController` 中選擇了一個店鋪，完成選擇後會調用此方法，將選擇的店鋪名稱回傳給委託者。
    /// - 通常，該方法會觸發主畫面更新，將新的店鋪名稱顯示於相應的 UI 元素上。
    func storeSelectionDidComplete(with storeName: String)
    
}
