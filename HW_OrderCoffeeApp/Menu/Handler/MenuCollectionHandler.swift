//
//  MenuCollectionHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

// MARK: - MenuCollectionHandler 筆記
/**
 
 ## MenuCollectionHandler 筆記

 
 `* What`
 
 - `MenuCollectionHandler` 是一個專門用於處理 `MenuViewController` 的 `UICollectionView` 資料源與委託邏輯的類別。

 - 主要功能
 
 1. 資料管理：
 
    - 儲存並管理飲品分類（`drinkCategories`）與網站橫幅（`websites`）的資料。
    - 根據 `MenuSection` 不同，返回對應的資料數量與內容。

 2. 視圖處理：
 
    - 動態生成並配置 `UICollectionViewCell` 和 `Supplementary View`（如 Header 和 Footer）。
    - 支援多個 section 的展示邏輯，包括網站橫幅和飲品分類。

 3. 用戶交互：
 
    - 處理 `UICollectionView` 的點擊事件，並通過 `MenuHandlerDelegate` 通知控制器進行導航操作。

 ---------

 `* Why`

 - 設計背景
 
    - 在 `MenuViewController` 中，`UICollectionView` 是一個關鍵的視圖組件，負責展示網站橫幅與飲品分類。
    - 隨著業務邏輯的增多，直接在控制器內處理所有 `UICollectionView` 的資料源與委託邏輯，會導致代碼冗長且難以維護。

 - 設計目的
 
 1. 單一職責原則 (SRP)：
 
    - 將 `UICollectionView` 的資料源與委託邏輯從控制器中分離，讓控制器專注於業務邏輯與數據加載。
    - 提高代碼的可讀性與可維護性。

 2. 低耦合、高內聚：
 
    - 控制器只需提供數據給 `MenuCollectionHandler`，並通過協議接收點擊事件，兩者責任明確且相互獨立。

 3. 提升可測試性：
 
    - 分離的 `MenuCollectionHandler` 更易於單元測試，例如驗證資料處理邏輯和點擊行為。

 4. 可擴展性：
 
    - 如果未來需要新增 section 或修改點擊行為，只需擴展 `MenuCollectionHandler`，而無需改動控制器代碼。

 5. 常見問題：
 
 - 為什麼要用單獨的處理類？
 
    - 如果所有 `UICollectionView` 的邏輯都在控制器內，會增加耦合性，影響代碼的可讀性與重用性。
 
 - 為什麼使用代理模式？
 
    - 將點擊事件的處理交給控制器，符合控制器作為中樞的角色，同時保持視圖邏輯的簡潔。

 ---------

 `* How`

 1. 資料管理
 
 - 使用兩個數組屬性分別存儲飲品分類和網站橫幅數據：
    - `drinkCategories`: 儲存飲品分類的展示模型數據。
    - `websites`: 儲存網站橫幅的模型數據。

 2. 資料源邏輯
 
 - 實現 `UICollectionViewDataSource`：
 
    - Section 數量：通過 `MenuSection.allCases.count` 動態設置。
    - Item 數量：根據 section 類型返回對應的資料數量。
    - Cell 配置：根據 section 類型，生成 `MenuWebsiteBannerImageCell` 或 `MenuDrinkCategoryCell`。

 3. 用戶交互
 
 - 實現 `UICollectionViewDelegate`：
 
    - 點擊事件：根據 section 類型，執行不同的導航操作。
    - 使用 `MenuHandlerDelegate` 回調控制器，進行網站連結的打開或飲品分類的導航。

 4. 補充設計
 
 - 補充 Header 和 Footer：
 
    - 使用 Supplementary View 顯示區域標題或分隔效果，增強視覺層次。

 ---------

 `* 優勢與改善`
 
 - 優勢
 
    - 高內聚：專注於 `UICollectionView` 的資料處理與行為邏輯，邏輯清晰且模組化。
    - 低耦合：與控制器責任分離，控制器專注於業務邏輯。
    - 可擴展：未來若新增展示需求或修改邏輯，只需擴展 `MenuCollectionHandler`。

 ---------

 `* 總結`
 
 - `MenuCollectionHandler` 是一個專注於 `UICollectionView` 資料邏輯和交互的高內聚類別。
 - 它符合單一職責原則，降低了 `MenuViewController` 的代碼複雜度，並通過代理模式提升了視圖與控制器之間的靈活性。
 */




// MARK: - (v)

import UIKit

/// 負責處理 `MenuViewController` 的 `UICollectionView` 資料源與委託邏輯的類別。
///
/// - 設計目標:
///   1. 將 `UICollectionView` 的數據源與委託邏輯從控制器中分離，提升模組化程度。
///   2. 支援多個 section 的顯示，包括網站橫幅和飲品分類，確保可擴展性。
///   3. 提供點擊事件的統一回調接口，通過 `MenuHandlerDelegate` 將導航操作轉交給控制器。
///
/// - 功能:
///   1. 根據 `MenuSection` 顯示不同的內容（網站橫幅、飲品分類）。
///   2. 支援點擊事件的處理，包括網站連結的打開與分類頁面的導航。
///   3. 提供數據接口，供 `MenuViewController` 更新顯示內容。
///
/// - 使用場景:
///   作為 `MenuViewController` 的 `UICollectionView` 資料源與委託的專屬處理類別，負責界面展示與用戶互動邏輯。
class MenuCollectionHandler: NSObject {
    
    // MARK: - Properties
    
    /// 網站橫幅資料，顯示於 `UICollectionView` 的 `websiteBanner` section。
    var websites: [Website] = []
    
    /// 飲品分類資料，顯示於 `UICollectionView` 的 `drinkCategories` section。
    var drinkCategories: [MenuDrinkCategoryViewModel] = []
    
    /// 用於處理導航操作的代理協議。
    weak var menuHandlerDelegate: MenuHandlerDelegate?

}

// MARK: - UICollectionViewDataSource
extension MenuCollectionHandler: UICollectionViewDataSource {
    
    /// 返回 section 的數量。
    ///
    /// - 根據 `MenuSection.allCases.count` 設置總的 section 數量。
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MenuSection.allCases.count
    }
    
    /// 返回指定 section 中的 item 數量。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = MenuSection(rawValue: section) else { return 0 }
        switch sectionType {
        case .websiteBanner:
            //            print("Websites count: \(websites.count)")
            return websites.count
        case .drinkCategories:
            return drinkCategories.count
        }
    }
    
    /// 配置並返回對應的 UICollectionViewCell。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = MenuSection(rawValue: indexPath.section) else { fatalError("Invalid section") }
        
        switch sectionType {
        case .websiteBanner:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuWebsiteBannerImageCell.reuseIdentifier, for: indexPath) as? MenuWebsiteBannerImageCell else {
                fatalError("[MenuCollectionHandler]: Cannot create MenuWebsiteBannerImageCell")
            }
            let website = websites[indexPath.item]
            guard let url = URL(string: website.imagePath) else { return cell }
            cell.configure(with: url)
            return cell
            
        case .drinkCategories:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuDrinkCategoryCell.reuseIdentifier, for: indexPath) as? MenuDrinkCategoryCell else {
                fatalError("[MenuCollectionHandler]: Cannot create MenuDrinkCategoryCell")
            }
            let drinkCategory = drinkCategories[indexPath.row]
            cell.configure(with: drinkCategory)
            return cell
        }
        
    }
    
    /// 配置並返回對應的 Supplementary View（如 Header 或 Footer）。
    ///
    /// - 根據 kind 返回指定的 Header 或 Footer。
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let section = MenuSection(rawValue: indexPath.section),
                  let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MenuSectionHeaderView.headerIdentifier, for: indexPath) as? MenuSectionHeaderView else {
                fatalError("[MenuCollectionHandler]: Invalid header configuration")
            }
            headerView.configure(with: section.title)
            return headerView
            
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MenuSectionFooterView.footerIdentifier, for: indexPath) as? MenuSectionFooterView else {
                fatalError("[MenuCollectionHandler]: Invalid footer configuration")
            }
            return footerView
        }
        
        fatalError("[MenuCollectionHandler]: Invalid supplementary view kind")
    }
    
}

// MARK: - UICollectionViewDelegate
extension MenuCollectionHandler: UICollectionViewDelegate {
    
    /// 處理使用者點擊事件。
    ///
    /// - 根據 section 類型執行相應的導航操作。
    /// - Parameters:
    ///   - collectionView: 當前的 `UICollectionView`。
    ///   - indexPath: 被點擊的 Cell 的索引位置。
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = MenuSection(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .websiteBanner:
            guard let cell = collectionView.cellForItem(at: indexPath) as? MenuWebsiteBannerImageCell,
                  let url = URL(string: websites[indexPath.item].url)
            else { return }
            cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
                self.menuHandlerDelegate?.openWebsite(url: url)
            }
            
        case .drinkCategories:
            guard let cell = collectionView.cellForItem(at: indexPath) as? MenuDrinkCategoryCell else { return }
            cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
                let selectedCategory = self.drinkCategories[indexPath.item]
                self.menuHandlerDelegate?.navigateToCategory(category: selectedCategory)
            }
        }
    }
    
}
