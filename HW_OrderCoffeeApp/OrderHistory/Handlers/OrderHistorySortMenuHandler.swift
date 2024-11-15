//
//  OrderHistorySortMenuHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/8.
//

// MARK: - OrderHistorySortMenuHandler 重點筆記
/**
 ## OrderHistorySortMenuHandler 重點筆記

 `* 概述`
 - `功能`：`OrderHistorySortMenuHandler` 用於創建和管理排序選單，並在用戶選擇排序方式時，將選擇結果通知給代理。
 - `用途`：此類別專注於管理排序選單的邏輯，負責創建排序選單並處理選擇行為。

 `* 結構`
 
 `1. Properties：`
 - `delegate`：遵循 `OrderHistorySortMenuDelegate` 協定的代理，透過該代理來通知排序選擇。

 `2. Initialization：`
 - `init(delegate:)`：接受一個 `OrderHistorySortMenuDelegate` 的代理，用於初始化處理排序選單的邏輯。

 `3. Methods：`
 - `createSortMenu()`：創建並返回一個 `UIMenu`，包含不同的排序選項。每個選項在被選中時，都會透過代理通知回 `ViewController` 進行處理。

 `* 重點設計`
 - `資料分離設計`：透過將排序選單的邏輯獨立到 `OrderHistorySortMenuHandler`，可以使 `ViewController` 保持簡潔，專注於管理視圖和展示資料。
 - `弱引用代理`：使用 `weak var delegate`，防止循環引用，避免內存洩漏。
 */


import UIKit

/// `OrderHistorySortMenuHandler` 用於管理和處理排序選單的類別。
///
/// - 創建排序選單，並且當使用者選擇某個選項時，透過 `OrderHistorySortMenuDelegate` 通知對應的處理。
class OrderHistorySortMenuHandler {
    
    // MARK: - Properties

    /// 代理，用於提供排序選項的回調
    weak var delegate: OrderHistorySortMenuDelegate?
    
    // MARK: - Initialization

    /// 初始化方法，接受一個 `OrderHistorySortMenuDelegate` 代理
    /// - Parameter delegate: 傳入的代理，用於回傳排序選擇
    init(delegate: OrderHistorySortMenuDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - Methods

    /// 創建排序選項的下拉菜單
    /// - Returns: 包含不同排序選項的 `UIMenu`，提供給使用者選擇
    func createSortMenu() -> UIMenu {
        let byDateDescending = UIAction(title: "依時間由新到舊", image: UIImage(systemName: "calendar.badge.clock")) { _ in
            self.delegate?.didSelectSortOption(.byDateDescending)
        }
        
        let byDateAscending = UIAction(title: "依時間由舊到新", image: UIImage(systemName: "calendar")) { _ in
            self.delegate?.didSelectSortOption(.byDateAscending)
        }
        
        let byAmountDescending = UIAction(title: "依金額從高到低", image: UIImage(systemName: "arrow.down.circle")) { _ in
            self.delegate?.didSelectSortOption(.byAmountDescending)
        }
        
        let byAmountAscending = UIAction(title: "依金額從低到高", image: UIImage(systemName: "arrow.up.circle")) { _ in
            self.delegate?.didSelectSortOption(.byAmountAscending)
        }
        
        let byPickupMethod = UIAction(title: "依取件方式", image: UIImage(systemName: "shippingbox")) { _ in
            self.delegate?.didSelectSortOption(.byPickupMethod)
        }
        
        return UIMenu(title: "選擇排序方式", children: [byDateDescending, byDateAscending, byAmountDescending, byAmountAscending, byPickupMethod])
    }
    
}
