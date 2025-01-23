//
//  MenuHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/23.
//


// MARK: - MenuHandlerDelegate 筆記
/**
 
 ### MenuHandlerDelegate 筆記

 `* What`
 
 - `MenuHandlerDelegate` 是一個代理協議，專為 `MenuCollectionHandler` 設計，負責處理與導航及用戶交互相關的操作。
 
 主要功能包括：
 
 1. 導航到飲品分類頁面：用戶點擊某個飲品分類後，通知控制器執行對應的頁面導航。
 2. 打開指定網站 URL：用戶點擊網站橫幅後，通知控制器打開對應的網站連結。

 ---------

 `* Why`
 
 1. 分離邏輯，提升模組化
 
    - 將 `MenuCollectionHandler` 的導航邏輯與數據展示邏輯分離，避免類的過度責任，使代碼更簡潔、可維護。

 2. 降低耦合，增強靈活性
 
    - 讓 `MenuCollectionHandler` 與具體控制器（如 `MenuViewController`）解耦，通過協議提供一個標準化的接口。
    - 支持不同的控制器或視圖組件共用此協議接口，提升重用性和靈活性。

 3. 符合設計原則
 
    - 單一職責原則 (SRP)：專注於定義導航相關的方法，不涉及其他邏輯。
    - 開閉原則 (OCP)：新增交互場景時，只需擴展協議，而不改變現有實現。

 ---------

 `* How`

 1. 定義協議方法
 
    - `openWebsite(url: URL)`：當用戶點擊網站橫幅時調用，負責處理網站導航邏輯。
    - `navigateToCategory(category: MenuDrinkCategoryViewModel)`：當用戶點擊飲品分類時調用，負責導航到具體分類頁面。

    範例：
 
    ```swift
    protocol MenuHandlerDelegate: AnyObject {
        func openWebsite(url: URL)
        func navigateToCategory(category: MenuDrinkCategoryViewModel)
    }
    ```

 ----
 
 2. MenuViewController 實現協議
 
    - `MenuViewController` 實現 `MenuHandlerDelegate`，處理用戶的導航邏輯。
 
    - 例如：
      ```swift
      extension MenuViewController: MenuHandlerDelegate {
          func openWebsite(url: URL) {
              AlertService.showAlert(
                  withTitle: "打開連結",
                  message: "確定要打開這個連結嗎？",
                  inViewController: self,
                  showCancelButton: true
              ) {
                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
          }
          
          func navigateToCategory(category: MenuDrinkCategoryViewModel) {
              let storyboard = UIStoryboard(name: "Main", bundle: nil)
              guard let drinksCategoryVC = storyboard.instantiateViewController(
                  withIdentifier: Constants.Storyboard.drinksCategoryViewController
              ) as? DrinksCategoryViewController else {
                  print("Failed to instantiate DrinksCategoryViewController")
                  return
              }
              
              drinksCategoryVC.categoryId = category.id
              drinksCategoryVC.categoryTitle = category.title
              self.navigationController?.pushViewController(drinksCategoryVC, animated: true)
          }
      }
      ```

 ----

 3. MenuCollectionHandler 使用代理
 
    - 在 `MenuCollectionHandler` 中，使用 `menuHandlerDelegate` 通知控制器處理用戶點擊事件。
 
    - 例如：
      ```swift
      extension MenuCollectionHandler: UICollectionViewDelegate {
          func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
              guard let sectionType = MenuSection(rawValue: indexPath.section) else { return }
              
              switch sectionType {
              case .websiteBanner:
                  guard let url = URL(string: websites[indexPath.item].url) else { return }
                  menuHandlerDelegate?.openWebsite(url: url)
              case .drinkCategories:
                  let selectedCategory = drinkCategories[indexPath.item]
                  menuHandlerDelegate?.navigateToCategory(category: selectedCategory)
              }
          }
      }
      ```

 ---------

 `* 總結`
 
 - What:
 
    - `MenuHandlerDelegate` 是一個代理協議，用於處理導航和用戶交互操作。
 
 - Why:
    
    - 它分離了導航邏輯與數據展示邏輯，降低耦合性並提升靈活性。
    
 - How:
 
   - 定義協議方法處理導航操作。
   - `MenuViewController` 實現協議並提供具體邏輯。
   - `MenuCollectionHandler` 使用代理將點擊事件委派給控制器處理。
 */



// MARK: - (v)

import Foundation

/// 定義 `MenuCollectionHandler` 的代理協議，負責處理與導航及用戶交互相關的操作。
///
/// 此協議的設計目的是將導航邏輯與數據展示邏輯分離，提升代碼的模組化程度和可維護性。
///
/// - 功能:
///   1. 提供一個標準化的接口，用於處理點擊操作的回應，例如導航到飲品分類頁面或打開網站連結。
///   2. 減少 `MenuCollectionHandler` 和具體控制器（如 `MenuViewController`）之間的耦合。
///   3. 支援更多的控制器或視圖使用相同的協議接口，提升可重用性。
///
/// - 設計原則:
///   - 單一職責原則 (SRP): 此協議僅負責定義導航相關的功能，不涉及其他邏輯。
///   - 開閉原則 (OCP): 如果需要支持更多的交互場景，可通過擴展協議新增方法，而不改變現有的實現。
///
/// - 使用場景:
///   1. `MenuCollectionHandler` 通過該協議通知控制器處理用戶點擊的操作。
///   2. `MenuViewController` 實現該協議，以便接收點擊事件並執行相應的導航邏輯。
protocol MenuHandlerDelegate: AnyObject {
    
    
    /// 打開指定的網站 URL。
    ///
    /// 此方法負責處理點擊網站橫幅時的操作，通常用於導航到外部鏈接。
    ///
    /// - Parameter url: 要打開的網站 URL。
    func openWebsite(url: URL)
    
    /// 導航到指定的飲品分類頁面。
    ///
    /// 此方法負責處理點擊飲品分類時的操作，通常用於展示分類下的具體飲品列表。
    ///
    /// - Parameter category: 包含飲品分類資訊的展示模型。
    func navigateToCategory(category: MenuDrinkCategoryViewModel)
    
}
