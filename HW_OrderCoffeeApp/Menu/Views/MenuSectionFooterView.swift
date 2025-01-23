//
//  MenuSectionFooterView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/22.
//


// MARK: - MenuSectionFooterView 筆記
/**
 
 ## MenuSectionFooterView 筆記


 `* What`

 - `MenuSectionFooterView` 是一個自訂的 `UICollectionReusableView`，專門用於在 `MenuViewController` 的 `UICollectionView` 中作為 section 的底部分隔線。
 - 它主要由一條簡單的分隔線（`MenuSeparatorView`）構成，提供視覺上的區隔效果。

 - 功能：
 
   1. 顯示於每個 section 的底部。
   2. 提供一致的分隔線樣式（如顏色和高度）。
   3. 支援自訂間距和對齊方式。

 ---

 `* Why`

 1. 提升視覺結構：
 
    - 在不同的 section 之間添加分隔線，能夠幫助用戶清晰地辨別內容區域。
    - 增強頁面設計的層次感，改善用戶體驗。

 2. 統一樣式管理：
 
    - 使用自訂的 `MenuSeparatorView` 統一控制分隔線的樣式與屬性，確保整體風格一致。

 3. 提高可維護性：
 
    - 集中處理 footer 的邏輯，未來若需要調整分隔線的樣式或功能，只需修改 `MenuSectionFooterView` 或其內部組件。

 4. 解耦頁面結構：
 
    - 將 footer 的設計與其他 UI 元件分離，避免不同模組之間的耦合，符合單一職責原則。

 ---

 `* How`

 1. 分隔線設計：
 
    - 使用 `MenuSeparatorView` 作為分隔線，定義其背景顏色與高度（例如淺灰色和 2.0pt）。
    - 支援透過初始化參數調整樣式。

 2. Auto Layout 實現：
 
    - 分隔線的寬度設置為視圖的內部範圍（左右各保留 16pt 間距）。
    - 分隔線緊貼 footer 的底部，並保留 8pt 的底部間距，提升視覺效果。

 3. 在 `setupViews` 方法中完成配置：
 
    - 添加 `separatorView` 到 `MenuSectionFooterView`，並通過約束確保其布局正確。

 4. 與 `UICollectionView` 集成：
 
    - 在 `MenuCollectionHandler` 的 `viewForSupplementaryElementOfKind` 方法中，註冊並配置 `MenuSectionFooterView` 作為 section footer。

 ---

 `* 具體例子`

    - 以下為使用 `MenuSectionFooterView` 的完整示例：

     ```swift
     if kind == UICollectionView.elementKindSectionFooter {
         guard let footerView = collectionView.dequeueReusableSupplementaryView(
             ofKind: kind,
             withReuseIdentifier: MenuSectionFooterView.footerIdentifier,
             for: indexPath
         ) as? MenuSectionFooterView else {
             fatalError("Invalid footer configuration")
         }
         return footerView
     }
     ```
 
 */



// MARK: - (v)

import UIKit

/// 自訂的 Footer View，用於區隔 `UICollectionView` 的 section 底部。
///
/// 此類專為 `MenuViewController` 的 `UICollectionView` 設計，
/// 主要用於在每個 section 的底部添加一條分隔線，
/// 提升視覺區隔效果，增強界面結構的清晰度。
///
/// - 功能特色:
///   1. 提供統一的分隔線樣式，增強 section 間的視覺分離效果。
///   2. 使用自訂的 `MenuSeparatorView`，輕鬆配置分隔線的顏色與高度。
///   3. 支援動態布局，通過 Auto Layout 設置間距與位置。
///
/// - 使用場景:
///   適用於 `MenuViewController` 的 `UICollectionView`，
///   作為每個 section 的 footer，區隔不同區域的內容。
class MenuSectionFooterView: UICollectionReusableView {
    
    /// footer view 的重用識別符。
    static let footerIdentifier = "MenuSectionFooterView"
    
    // MARK: - UI Elements
    
    /// 分隔線視圖
    private let separatorView = MenuSeparatorView(backgroundColor: .lightWhiteGray, height: 2.0)
    
    // MARK: - Initialization
    
    /// 初始化 footer view。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 footer view 的子視圖與佈局。
    ///
    /// - 將 `separatorView` 添加到視圖中。
    /// - 設置約束，確保分隔線具有適當的間距與對齊。
    private func setupViews() {
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
}
