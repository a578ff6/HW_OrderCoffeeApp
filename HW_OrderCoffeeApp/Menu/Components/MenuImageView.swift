//
//  MenuImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/22.
//

// MARK: - MenuImageView 筆記
/**
 
 ## MenuImageView 筆記

 * What
 
 - `MenuImageView` 是一個自訂的 `UIImageView`，專為菜單模組設計，提供統一的圖片顯示樣式與屬性。

 - 功能
 
 1. 統一圖片樣式：
 
    - 預設內容模式（`contentMode`）為 `.scaleAspectFill`，確保圖片完整顯示且不會變形。
    - 支援圖片圓角設置（`cornerRadius`），提升視覺效果。

 2. 可重用性：
 
    - 作為基礎圖片視圖，可用於菜單模組的多個場景，如橫幅圖片、分類圖片等。

 3. 簡化配置：
 
    - 集中管理圖片視圖的共用屬性，避免在多個元件中重複設置。

 ---------

 `* Why`

 - 問題
 
 1. 程式碼重複：
 
    - 在多個元件中重複設置 `UIImageView` 的屬性（如內容模式、圓角等）會導致程式碼冗餘。

 2. 缺乏一致性：
 
    - 如果每個元件手動設置 `UIImageView` 屬性，容易出現樣式不一致的問題，降低使用者體驗。

 3. 不利於擴展：
 
    - 當需要統一新增屬性（如陰影或邊框）時，若沒有集中管理，需逐一修改所有使用的 `UIImageView`。

 ---
 
 - 解決方式
 
 1. 集中管理屬性：
 
    - 將常見的圖片視圖屬性抽取到 `MenuImageView` 中，統一設置，減少重複程式碼。

 2. 提升可讀性與可維護性：
 
    - 簡化元件的圖片視圖配置，讓開發者專注於其他業務邏輯。

 3. 支援未來擴展：
 
    - 若需新增樣式（如陰影），只需在 `MenuImageView` 中調整即可，所有元件自動應用。

 ---------

 `* How`

 1. 初始化 `MenuImageView`
 
    - 使用初始化方法，直接生成統一樣式的圖片視圖：

     ```swift
     let menuImageView = MenuImageView(contentMode: .scaleAspectFill, cornerRadius: 12)
     ```

 ---

 2. 替換原有的 `UIImageView`
 
    - 將元件中的 `UIImageView` 替換為 `MenuImageView`，例如在 `MenuWebsiteBannerImageCell` 中：

     ```swift
     class MenuWebsiteBannerImageCell: UICollectionViewCell {
         let imageView = MenuImageView(contentMode: .scaleAspectFill, cornerRadius: 10)
     }
     ```

 ---

 3. 支援樣式統一
 
    - 如果未來需要新增陰影，只需修改 `MenuImageView` 的實現：

     ```swift
     private func setupImageView(contentMode: UIView.ContentMode, cornerRadius: CGFloat) {
         self.contentMode = contentMode
         self.layer.cornerRadius = cornerRadius
         self.clipsToBounds = true
         self.translatesAutoresizingMaskIntoConstraints = false
         
         // 新增陰影樣式
         self.layer.shadowColor = UIColor.black.cgColor
         self.layer.shadowOpacity = 0.2
         self.layer.shadowOffset = CGSize(width: 0, height: 2)
         self.layer.shadowRadius = 4
     }
     ```

 所有使用 `MenuImageView` 的元件將自動應用該樣式。

 ---------

` * 總結`

 - What：
 
    - `MenuImageView` 是專為菜單模組設計的自訂圖片視圖，提供統一的樣式與屬性。
 
 - Why：
 
   - 減少重複程式碼，統一圖片樣式，提升可讀性與擴展性。
 
 - How：
 
   - 使用初始化方法生成視圖，替換元件中的 `UIImageView`，統一管理與應用樣式，便於未來擴展與維護。
 */




// MARK:  - (v)

import UIKit

/// 自訂的圖片視圖，專為菜單模組設計，提供統一的圖片顯示樣式與屬性。
///
/// 此類旨在簡化並統一管理菜單頁面中常見的圖片顯示邏輯，
/// 如設定圖片的內容模式（`contentMode`）與圓角（`cornerRadius`）等屬性。
///
/// - 功能特色:
///   1. 預設圖片內容模式為 `.scaleAspectFill`，確保圖片完整顯示且不會變形。
///   2. 預設支援圖片圓角設置，提升視覺效果。
///   3. 適用於菜單模組的多個場景，例如橫幅圖片、分類圖片等。
class MenuImageView: UIImageView {
    
    // MARK: - Initializer
    
    /// 初始化自訂圖片視圖。
    ///
    /// 提供預設屬性配置，並支持靈活設置圖片的內容模式與圓角半徑。
    ///
    /// - Parameters:
    ///   - contentMode: 圖片的內容模式，默認為 `.scaleAspectFill`。
    ///   - cornerRadius: 圖片的圓角半徑，默認為 10。
    init(contentMode: UIView.ContentMode = .scaleAspectFill, cornerRadius: CGFloat = 10) {
        super.init(frame: .zero)
        setupImageView(contentMode: contentMode, cornerRadius: cornerRadius)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置圖片視圖的外觀與屬性。
    ///
    /// 此方法集中設置 `UIImageView` 的基本屬性，如內容模式、圓角等，確保圖片樣式一致性。
    ///
    /// - Parameters:
    ///   - contentMode: 圖片的內容模式。
    ///   - cornerRadius: 圖片的圓角半徑。
    private func setupImageView(contentMode: UIView.ContentMode, cornerRadius: CGFloat) {
        self.contentMode = contentMode
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
