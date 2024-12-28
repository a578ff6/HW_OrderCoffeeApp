//
//  EditOrderItemSection.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/24.
//

import Foundation

/// 定義`編輯飲品訂單項目`頁面中的各個區塊 (Section)。
///
/// 此列舉用於劃分`編輯飲品訂單項目`的 `UICollectionView` 的各個區段，
/// 方便資料源與視圖更新的邏輯管理。
///
/// - 使用 `CaseIterable` 協議，使其支援列舉所有區段。
/// - 每個區段的用途如下：
///   - `image`：展示飲品圖片。
///   - `info`：顯示飲品的名稱與描述。
///   - `sizeSelection`：提供用戶選擇飲品尺寸的功能。
///   - `priceInfo`：根據選擇的尺寸，展示價格資訊。
///   - `editOrderOptions`：包含`修改訂單按鈕`等操作功能。
enum EditOrderItemSection: Int, CaseIterable {
    case image
    case info
    case sizeSelection
    case priceInfo
    case editOrderOptions
}
