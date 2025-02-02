//
//  DrinkSubCategoryHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/4.
//


// MARK: - DrinkSubCategoryHandler 筆記
/**
 
 ### DrinkSubCategoryHandler 筆記

 
 `* What`

 - `DrinkSubCategoryHandler` 的功能：
 
   - 管理 `DrinkSubCategoryViewController` 中 `UICollectionView` 的數據邏輯與用戶交互行為。
   - 將 `UICollectionView` 的數據源（dataSource）與委派（delegate）邏輯分離出來，保持控制器的清晰與模組化。

 - 職責：
 
   1. 提供 `UICollectionView` 的 Section 數量與每個 Section 的項目數量。
   2. 根據當前的佈局類型配置不同的 Cell 樣式（如網格或列表）。
   3. 配置 Section Header 與 Footer，用於顯示子類別標題或分隔線。
   4. 處理用戶與 `UICollectionView` 的交互行為，例如點擊某個飲品項目時執行對應邏輯。

 - 設計目標：
 
   - 透過 `DrinkSubCategoryHandlerDelegate` 與控制器進行數據與行為的解耦。
   - 將與 `UICollectionView` 相關的所有操作集中在一個專用類別中，提高代碼的可維護性與可測試性。

 ----------

 `* Why`

 1. 分離數據與視圖邏輯：
 
    - 將 `UICollectionView` 的數據邏輯與行為管理從控制器中提取出來，減少控制器的責任，符合單一職責原則（SRP）。
    - 提升代碼的清晰度與模組化，讓控制器專注於業務邏輯，例如導航或數據加載。

 2. 提高代碼可維護性：
 
    - 集中處理與 `UICollectionView` 相關的邏輯（數據與行為），減少重複代碼，便於維護與測試。
    - 控制器與 `UICollectionView` 的耦合度降低，更容易進行單元測試。

 3. 提升擴展性：
 
    - 若需要更改佈局或添加新的交互行為，僅需修改 `DrinkSubCategoryHandler`，不會影響控制器的其他邏輯。
    - 支援不同的佈局類型（如網格與列表）以及動態 Section Header/Footer 配置。

 4. 加強解耦性：
 
    - 使用 `DrinkSubCategoryHandlerDelegate` 與控制器進行交互，使數據與行為的處理與控制器分離，提升架構的靈活性與模組化設計。

 ----------

 `* How`

 1. 初始化：
 
    - 在 `DrinkSubCategoryViewController` 中初始化 `DrinkSubCategoryHandler`，並設置 `UICollectionView` 的 dataSource 與 delegate：
 
      ```swift
      private func configureCollectionView() {
          let collectionView = drinkSubCategoryView.drinkSubCategoryCollectionView
          collectionView.dataSource = drinkSubCategoryHandler
          collectionView.delegate = drinkSubCategoryHandler
          drinkSubCategoryHandler.drinkSubCategoryHandlerDelegate = self
      }
      ```

 ---

 2. 提供數據：
 
    - `DrinkSubCategoryHandlerDelegate` 提供 `UICollectionView` 所需的數據與佈局類型：
 
      - 子類別清單：
 
        ```swift
        var subcategoryViewModels: [DrinkSubCategoryViewModel] {
            return drinkSubcategoryViewModels
        }
        ```
 
      - 當前佈局類型：
 
        ```swift
        var currentLayoutType: DrinkSubCategoryLayoutType {
            return layoutType
        }
        ```

 ---

 3. 配置 Cell：
 
    - 在 `cellForItemAt` 方法中根據佈局類型配置不同樣式的 Cell：
 
      ```swift
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let identifier = layoutType == .grid
              ? DrinkSubcategoryGridItemCell.reuseIdentifier
              : DrinkSubcategoryColumnItemCell.reuseIdentifier

          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
          // 配置 Cell
          if let columnCell = cell as? DrinkSubcategoryColumnItemCell {
              columnCell.configure(with: drinkViewModel)
          }
          return cell
      }
      ```

 ---

 4. 處理用戶交互：
 
    - 在 `didSelectItemAt` 方法中處理點擊事件，並透過 `Delegate` 將交互行為傳遞給控制器：
 
      ```swift
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          guard let categoryId = drinkSubCategoryHandlerDelegate?.categoryId,
                let subcategoryViewModel = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section],
                let drinkViewModel = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section].drinks[indexPath.item] else {
              return
          }
          // 傳遞點擊行為
          drinkSubCategoryHandlerDelegate?.didSelectDrink(
              categoryId: categoryId,
              subcategoryViewModel: subcategoryViewModel,
              drinkViewModel: drinkViewModel
          )
      }
      ```

 ---
 
 5. 配置 Section Header/Footer：
 
    - 動態添加 Section Header 或 Footer，顯示子類別標題或分隔線：
 
      ```swift
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         if kind == UICollectionView.elementKindSectionHeader {
             guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkSubCategorySectionHeaderView.headerIdentifier, for: indexPath) as? DrinkSubCategorySectionHeaderView else {
                 fatalError("Cannot create header view")
             }
             
             guard let subcategoryTitle = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section].subcategoryTitle else {
                 fatalError("Missing subcategory title for section \(indexPath.section)")
             }
             headerView.configure(with: subcategoryTitle)
             return headerView
             
         } else if kind == UICollectionView.elementKindSectionFooter {
             guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkSubCategorySectionFooterView.footerIdentifier, for: indexPath) as? DrinkSubCategorySectionFooterView else {
                 fatalError("Cannot create footer view")
             }
             return footerView
         }
         return UICollectionReusableView()
     }
      ```

 ----------

 `* 架構圖示`

     ```plaintext
     DrinkSubCategoryViewController
         ├── DrinkSubCategoryHandler
         │    ├── UICollectionViewDataSource
         │    ├── UICollectionViewDelegate
         │    └── DrinkSubCategoryHandlerDelegate
         └── UICollectionView (Managed by Handler)
     ```

 ----------

 `* 筆記摘要`

 1. 目的：
 
    - 分離 `UICollectionView` 的數據與交互行為，讓控制器專注於業務邏輯。
    - 提高代碼可讀性、可維護性與擴展性。

 2. 優勢：
 
    - 遵循單一職責原則（SRP），減少控制器臃腫。
    - 透過 Delegate 解耦，便於測試與模組化設計。

 3. 實現方式：
 
    - 初始化 `DrinkSubCategoryHandler` 並設置 `dataSource` 與 `delegate`。
    - 使用 `DrinkSubCategoryHandlerDelegate` 提供數據與交互行為。

 4. 適用場景：
 
    - 用戶切換佈局類型（列表與網格）。
    - 配置 Section Header 或 Footer。
    - 處理用戶點擊事件並導航至詳細頁面。
 */




// MARK: - (v)

import UIKit


/// `DrinkSubCategoryHandler` 負責管理 `DrinkSubCategoryViewController` 中的 `UICollectionView` 的 dataSource 與 delegate。
///
/// ### 設計目的
/// 1. 分離 `UICollectionView` 的數據邏輯與控制器，避免控制器臃腫，提升代碼可讀性與可維護性。
/// 2. 透過 `DrinkSubCategoryHandlerDelegate` 提供的數據與行為，實現與控制器的解耦，使邏輯更模組化與易於測試。
/// 3. 處理與 `UICollectionView` 有關的行為，包括配置 Cell、Section Header/Footer，以及處理用戶交互事件。
///
/// ### 職責
/// - 設定 `UICollectionView` 的數據來源，包括 Section 數量與每個 Section 的項目數量。
/// - 根據當前佈局類型配置不同的 Cell（如列表或網格樣式）。
/// - 配置 Section Header 與 Footer，為每個 Section 顯示標題或分隔線。
/// - 處理用戶點擊事件，並將點擊行為透過 Delegate 傳遞給控制器。
///
/// ### 使用場景
/// - 用於 `DrinkSubCategoryViewController` 中的 `UICollectionView`，管理其數據邏輯與用戶交互行為。
class DrinkSubCategoryHandler: NSObject {
    
    // MARK: - Properties
    
    /// 代理物件，負責提供數據與處理交互行為。
    ///
    /// ### 職責
    /// - 提供 `UICollectionView` 所需的數據（子類別與飲品清單）。
    /// - 提供當前佈局類型，協助配置不同樣式的 Cell。
    /// - 處理用戶點擊事件，將交互行為傳遞給控制器。
    weak var drinkSubCategoryHandlerDelegate: DrinkSubCategoryHandlerDelegate?
    
}

// MARK: - UICollectionViewDataSource
extension DrinkSubCategoryHandler: UICollectionViewDataSource {
    
    /// 設定 Section 的數量，對應子類別的數量。
    ///
    /// ### 功能
    /// 根據 `drinkSubCategoryHandlerDelegate` 提供的 `subcategoryViewModels`，設定 `UICollectionView` 的 Section 數量。
    ///
    /// ### 使用場景
    /// - 當需要根據子類別數據動態生成 Section 時。
    ///
    /// ### 回傳值
    /// - `Int`：子類別的數量，即 Section 的數量。
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let subcategories = drinkSubCategoryHandlerDelegate?.subcategoryViewModels else {
            return 0
        }
        return subcategories.count
    }
    
    /// 設定每個 Section 中的 Item 數量，對應每個子類別下的飲品數量。
    ///
    /// ### 功能
    /// 根據 `drinkSubCategoryHandlerDelegate` 提供的子類別模型，設定每個 Section 中的 Item 數量。
    ///
    /// ### 使用場景
    /// - 當子類別下包含多個飲品時，動態計算 Item 數量。
    ///
    /// ### 回傳值
    /// - `Int`：每個 Section 中的 Item 數量，對應子類別下的飲品數量。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let subcategories = drinkSubCategoryHandlerDelegate?.subcategoryViewModels,
              section < subcategories.count else {
            return 0
        }
        return subcategories[section].drinks.count
    }
    
    /// 配置並返回對應的 Cell，根據當前的佈局類型選擇不同的 Cell 樣式。
    ///
    /// ### 功能
    /// 根據當前的佈局類型（列表或網格），配置並返回對應的 Cell。
    ///
    /// ### 使用場景
    /// - 當需要根據佈局類型（如切換列表或網格）動態設置 Cell 的樣式。
    ///
    /// ### 參數
    /// - `indexPath`：當前的 Section 和 Item 索引。
    ///
    /// ### 回傳值
    /// - `UICollectionViewCell`：配置完成的 Cell。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let drinkViewModel = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section].drinks[indexPath.item],
              let layoutType = drinkSubCategoryHandlerDelegate?.currentLayoutType else {
            fatalError("Missing data")
        }
        
        let identifier = layoutType == .grid
        ? DrinkSubcategoryGridItemCell.reuseIdentifier
        : DrinkSubcategoryColumnItemCell.reuseIdentifier
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if let columnCell = cell as? DrinkSubcategoryColumnItemCell {
            print("[DrinkSubCategoryHandler]: Configuring Column Cell at \(indexPath)")
            columnCell.configure(with: drinkViewModel)
        } else if let gridCell = cell as? DrinkSubcategoryGridItemCell {
            print("[DrinkSubCategoryHandler]: Configuring Grid Cell at \(indexPath)")
            gridCell.configure(with: drinkViewModel)
        }
        return cell
    }
    
    /// 配置並返回 Section Header 或 Footer。
    ///
    /// ### 功能
    /// 根據 Section 的索引，配置並返回對應的 Header 或 Footer。
    ///
    /// ### 使用場景
    /// - 當需要為 Section 添加標題或分隔線時。
    ///
    /// ### 回傳值
    /// - `UICollectionReusableView`：配置完成的 Header 或 Footer。
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkSubCategorySectionHeaderView.headerIdentifier, for: indexPath) as? DrinkSubCategorySectionHeaderView else {
                fatalError("Cannot create header view")
            }
            
            guard let subcategoryTitle = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section].subcategoryTitle else {
                fatalError("Missing subcategory title for section \(indexPath.section)")
            }
            headerView.configure(with: subcategoryTitle)
            return headerView
            
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DrinkSubCategorySectionFooterView.footerIdentifier, for: indexPath) as? DrinkSubCategorySectionFooterView else {
                fatalError("Cannot create footer view")
            }
            return footerView
        }
        return UICollectionReusableView()
    }
    
}

// MARK: - UICollectionViewDelegate
extension DrinkSubCategoryHandler: UICollectionViewDelegate {
    
    /// 處理用戶點擊事件。
    ///
    /// ### 功能
    /// 當用戶點擊某個 Item 時，執行動畫效果並透過 Delegate 將交互行為傳遞給控制器。
    ///
    /// ### 使用場景
    /// - 用於處理點擊事件，例如導航到詳細頁面。
    ///
    /// ### 參數
    /// - `indexPath`：當前點擊的 Section 和 Item 索引。
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categoryId = drinkSubCategoryHandlerDelegate?.categoryId,
              let subcategoryViewModel = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section],
              let drinkViewModel = drinkSubCategoryHandlerDelegate?.subcategoryViewModels[indexPath.section].drinks[indexPath.item] else {
            return
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
            self.drinkSubCategoryHandlerDelegate?.didSelectDrink(
                categoryId: categoryId,
                subcategoryViewModel: subcategoryViewModel,
                drinkViewModel: drinkViewModel
            )
        }
    }
    
}
