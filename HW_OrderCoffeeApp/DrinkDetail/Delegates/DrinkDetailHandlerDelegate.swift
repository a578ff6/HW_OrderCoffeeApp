//
//  DrinkDetailHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/18.
//


// MARK: - DrinkDetailHandlerDelegate 筆記
/**
  
  ## DrinkDetailHandlerDelegate 筆記
  
 `* What`
 
  - `DrinkDetailHandlerDelegate` 是一個協定，負責將與飲品詳細頁面相關的資料讀取需求及互動事件（如選擇尺寸或加入購物車）傳遞到控制器處理。
  
 `* Why`
 
  `1. 資料來源集中管理：`
 
     - 透過 `getDrinkDetailModel` 和 `getSelectedSize` 方法，將資料的持有與管理集中到控制器中，避免資料散落於多個組件間。
  
  `2. 解耦業務邏輯與視圖細節：`
 
     - 讓控制器專注處理業務邏輯，`DrinkDetailHandler` 只負責視圖交互與事件通知。
  
  `3. 提升代碼可讀性與測試性：`
 
     - 將業務邏輯集中在控制器中，方便未來擴展功能或進行測試。
  
 ---------------
  
` * How`
  
 `1. 在控制器中實作 DrinkDetailHandlerDelegate：`
 
  - 控制器需提供 `DrinkDetailModel` 和 `selectedSize`，並處理與尺寸更新、購物車相關的業務邏輯。
  
  ```swift
  extension DrinkDetailViewController: DrinkDetailHandlerDelegate {
      
      func getDrinkDetailModel() -> DrinkDetailModel {
          guard let drinkDetailModel else {
              fatalError("DrinkDetailModel 尚未加載")
          }
          return drinkDetailModel
      }
      
      func getSelectedSize() -> String {
          guard let selectedSize else {
              fatalError("SelectedSize 尚未設置")
          }
          return selectedSize
      }
      
      func didSelectSize(_ newSize: String) {
          selectedSize = newSize
          print("尺寸已更新：\(newSize)")
          // 更新價格資訊
          drinkDetailView.drinkDetailCollectionView.reloadSections(
              IndexSet(integer: DrinkDetailSection.priceInfo.rawValue)
          )
      }
      
      func didTapAddToCart(quantity: Int) {
          guard let drinkDetailModel, let selectedSize else { return }
          print("加入購物車 - 飲品：\(drinkDetailModel.name)，尺寸：\(selectedSize)，數量：\(quantity)")
          // 呼叫 OrderManager 處理邏輯
      }
  }
 */


import Foundation


/// `DrinkDetailHandlerDelegate` 負責處理與飲品詳細資訊互動相關的委派方法。
///
/// 設計目標：
/// - 提供清晰的委派方法，讓控制器能接收與飲品資料相關的讀取需求（如 `DrinkDetailModel` 和 `selectedSize`）。
/// - 分離業務邏輯與視圖層細節，提升可讀性與維護性。
///
/// 功能說明：
/// - 控制器需實作 `getDrinkDetailModel` 與 `getSelectedSize`，供 `DrinkDetailHandler` 動態訪問數據來源。
/// - 當使用者選擇飲品尺寸時，透過 `didSelectSize(_:)` 通知控制器更新尺寸狀態。
/// - 當使用者操作加入購物車按鈕時，透過 `didTapAddToCart(quantity:)` 傳遞購買數量。
protocol DrinkDetailHandlerDelegate: AnyObject {
    
    /// 提供飲品詳細資料模型
    /// - Returns: 當前飲品的詳細資訊模型 `DrinkDetailModel`
    func getDrinkDetailModel() -> DrinkDetailModel
    
    /// 提供使用者當前選擇的飲品尺寸
    /// - Returns: 當前選中的尺寸，例如 "Medium" 或 "Large"
    func getSelectedSize() -> String
    
    /// 使用者選擇了新的飲品尺寸
    /// - Parameter selectedSize: 使用者選擇的飲品尺寸，例如 "Medium" 或 "Large"
    func didSelectSize(_ newSize: String)
    
    /// 使用者點擊加入購物車按鈕
    /// - Parameter quantity: 要加入購物車的飲品數量
    func didTapAddToCart(quantity: Int)
    
}
