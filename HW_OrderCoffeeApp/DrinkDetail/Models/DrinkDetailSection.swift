//
//  DrinkDetailSection.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/18.
//

// MARK: - 筆記：DrinkDetailSection
/**
 
 ## 筆記：DrinkDetailSection
 
 `* What`
 
 - `DrinkDetailSection` 是一個用於劃分飲品詳細資訊頁面不同區塊的列舉，幫助管理 UICollectionView 的區段。
 
 --------------------

 `* Why`
 
 `1.提升結構清晰度：`

 - 將頁面功能劃分為多個區塊，方便開發與維護。
 - 確保資料源與視圖更新能對應到具體區段，降低錯誤發生的機會。
 
 `2.簡化邏輯管理：`

 - 利用 `CaseIterable` 支援快速迭代所有區段，簡化區段數量計算與資料配置。
 - 使用列舉的 `rawValue`，能直觀對應區段索引（`IndexPath.section`）。
 
 `3.提高可讀性與擴展性：`

 - 清楚描述各區段的用途，未來新增區塊（例如評論區或推薦區）時，只需新增列舉值，修改成本低。
 
 --------------------

 `* How`
 
 1. 結構設計
 
 - 將頁面分為五個主要區段，涵蓋圖片展示、基本資訊、尺寸選擇、價格資訊與操作按鈕。
 - 每個區段具有單一責任，對應頁面中的具體視圖與功能。
 
 2. 使用方式
 
 - 在 `UICollectionViewDataSource` 的方法中使用此列舉：
 
 - 區段數量：透過 `DrinkDetailSection.allCases.count` 獲取。
 - 資料綁定：在 `cellForItemAt` 方法中，根據 `indexPath.section` 使用 `DrinkDetailSection(rawValue:) `確定當前區段。
 - 視圖更新：根據區段進行局部刷新，例如尺寸選擇區的按鈕刷新。
 
 --------------------
 
 `* 優化設計的優勢`
 
 `1.模組化與清晰性：`

 - 清楚描述頁面結構，避免數字索引（如 0、1）導致代碼模糊。
 
 `2.減少錯誤：`

 - 利用列舉的類型安全特性，避免區段索引出錯。
 */


import Foundation

/// 定義飲品詳細資訊頁面中的各個區塊 (Section)。
///
/// 此列舉用於劃分飲品詳細頁的 `UICollectionView` 的各個區段，
/// 方便資料源與視圖更新的邏輯管理。
///
/// - 使用 `CaseIterable` 協議，使其支援列舉所有區段。
/// - 每個區段的用途如下：
///   - `image`：展示飲品圖片。
///   - `info`：顯示飲品的名稱與描述。
///   - `sizeSelection`：提供用戶選擇飲品尺寸的功能。
///   - `priceInfo`：根據選擇的尺寸，展示價格資訊。
///   - `orderOptions`：包含加入購物車按鈕等操作功能。
enum DrinkDetailSection: Int, CaseIterable {
    case image
    case info
    case sizeSelection
    case priceInfo
    case orderOptions
}
