//
//  DrinkSubCategoryLayoutType.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/25.
//

// MARK: - DrinkSubCategoryLayoutType 筆記
/**
 
 ### DrinkSubCategoryLayoutType 筆記

 `* What`
 
 - `DrinkSubCategoryLayoutType` 是一個用於定義飲品子類別頁面視圖佈局樣式的枚舉，提供兩種主要佈局：
 
 - `column`：列表佈局
 - `grid`：網格佈局

 此枚舉的設計目的是將佈局樣式的定義與具體邏輯分離，搭配 `DrinkSubCategoryLayoutProvider` 生成對應的 `UICollectionView` 佈局。

 ----------

 `* Why`
 
 1. 職責單一：
 
    - `DrinkSubCategoryLayoutType` 專注於定義佈局樣式，而不涉及具體佈局邏輯，符合單一職責原則。
    - 提高程式碼的可讀性和維護性，讓開發者能快速理解佈局的核心需求。

 2. 擴展性高：
 
    - 當需要新增其他佈局（如 `card` 卡片佈局）時，只需擴充此枚舉即可，不會影響其他模組的設計。
    - 避免在程式中使用硬編碼（如 `if` 或 `switch` 的文字判斷），提高程式的穩定性與一致性。

 3. 易於整合：
 
    - 搭配 `DrinkSubCategoryLayoutProvider` 和 `DrinkSubCategoryViewController`，實現佈局樣式的靈活切換，符合現代 iOS 設計理念。

 ----------

 `* How`
 
 1. 定義佈局樣式：
 
    - 使用枚舉值描述頁面所需的佈局樣式，例如：
 
    ```swift
    var activeLayout: DrinkSubCategoryLayoutType = .column
    ```

 ---

 2. 搭配 `DrinkSubCategoryLayoutProvider`：
 
    - 傳遞佈局類型到 `DrinkSubCategoryLayoutProvider`，生成對應的 `UICollectionView` 佈局：
 
    ```swift
    let layout = layoutProvider.getLayout(for: .grid, isLastSection: false)
    ```

 ---

 3. 切換佈局：
 
    - 在 `DrinkSubCategoryViewController` 中切換佈局：
 
    ```swift
    @objc private func switchLayoutsButtonTapped() {
        activeLayout = (activeLayout == .grid) ? .column : .grid
    }
    ```
 
 ---

 4. 新增類型：
 
    - 若需新增其他佈局（如卡片佈局 `card`），只需在 `DrinkSubCategoryLayoutType` 中新增一個 case：
 
    ```swift
    case card
    ```

 ---
 
 5. 好處：
 
    - 將佈局樣式的處理邏輯與定義分離，讓程式更容易維護。
    - 可透過 `switch` 或 `if` 判斷使用不同邏輯：
 
      ```swift
      switch activeLayout {
      case .grid:
          print("網格佈局")
      case .column:
          print("列表佈局")
      }
      ```

 ----------

 `* 總結`
 
 - `DrinkSubCategoryLayoutType` 是一個簡單但功能強大的抽象設計，專注於定義飲品子類別的佈局樣式，具備以下優點：
 
    - 符合職責單一原則，簡化程式碼邏輯。
    - 提供高擴展性，未來可輕鬆新增更多佈局類型。
    - 增強團隊協作，讓開發者能快速理解和使用佈局邏輯。

 */


// MARK: - (v)

import Foundation

/// 定義 DrinkSubCategory 頁面的佈局類型。
///
/// 此枚舉用於描述「飲品子類別頁面」的視圖佈局樣式，
/// 提供兩種主要的展示方式：
///
/// - `column`：列表佈局
/// - `grid`：網格佈局
///
/// - 使用場景:
///   此類型用於 `DrinkSubCategoryViewController` 中，
///   搭配 `DrinkSubCategoryLayoutProvider` 根據佈局類型生成對應的 `UICollectionView` 佈局。
///
/// - 設計原則:
///   1. 職責單一：專注於描述佈局樣式，與具體佈局邏輯分離。
///   2. 擴展性：未來若新增其他佈局類型（例如卡片佈局），
///      只需擴充此枚舉即可，對現有程式影響最小。
enum DrinkSubCategoryLayoutType {
    
    /// 列表佈局
    case column
    
    /// 網格佈局
    case grid
}
