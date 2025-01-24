//
//  UIImage+ColorPlaceholder.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/22.
//

// MARK: - 筆記: 動態生成單色圖片的擴展方法
/**
 
 ## 筆記: 動態生成單色圖片的擴展方法


 `* What`
 
 - 這是一個 `UIImage` 的擴展方法，用於生成指定顏色和尺寸的單色圖片。
 - 因為採用一般的圖片，在等待過程中我覺得很突兀，因此就另外設置純色塊的使用。
 
 - 功能：
 
   - 動態生成一張圖片，圖片顏色和尺寸可以自由指定。
   - 適合用於佔位圖片、背景色塊或其他需要單色圖片的場景。

 -------

` * Why`
 
 - 開發過程中，經常需要生成簡單的單色圖片以提升 UI 一致性或作為動態需求的占位圖片。

 1. 動態需求：
 
    - 使用者介面設計可能需要不同尺寸或顏色的占位圖片，靜態圖片無法靈活應對。
    
 2. 減少資源管理負擔：
 
    - 通過程式生成單色圖片，避免設計大量靜態圖片資源，減少應用程式的資源文件數量和大小。

 3. 深淺模式支持：
 
    - 可以根據主題動態生成不同顏色的圖片，提升使用者體驗。

 -------

 *` How`

 - 實現方法：
 
 1. 使用 `UIGraphicsImageRenderer`：
 
    - 引入自 iOS 10 的高效圖形生成工具，用於創建圖片。
    - 提供自動管理上下文和優化性能的功能。

 2. 具體實現邏輯：
 
    - 定義一個圖片的尺寸（`CGSize`）。
    - 初始化一個圖形渲染器（`UIGraphicsImageRenderer`）。
    - 設定填充顏色，並填充至指定尺寸的矩形區域。

 -------

 `* 程式碼範例：`

    - 輸出：生成一張 100x100 大小的紅色圖片。

     ```swift
     let redImage = UIImage.from(color: .red, size: CGSize(width: 100, height: 100))
     ```

 -------

 `* 使用場景：`
 
 1. 佔位圖片：
 
    - 在網路加載圖片失敗時，提供單色背景作為佔位。
    
 2. 背景色塊：
 
    - 用於自訂的按鈕、圖層背景或其他 UI 元素。

 -------

` * 注意事項`
 
 - 確保圖片尺寸和顏色符合設計需求。
 - 如果應用程式最低支援版本低於 iOS 10，需使用 `UIGraphicsBeginImageContextWithOptions` 替代。
 
 */


// MARK: - (v)

import UIKit

extension UIImage {
    
    
    /// 生成指定顏色與尺寸的單色圖片。
    ///
    /// 此方法使用 `UIGraphicsImageRenderer` 生成一張填充指定顏色的圖片，
    /// 適用於需要動態生成佔位圖片或背景圖片的場景。
    ///
    /// - Parameters:
    ///   - color: 圖片的填充顏色，必須為 `UIColor`。
    ///   - size: 圖片的尺寸，默認為 1x1。
    ///           提供自訂尺寸以生成更大或更小的圖片。
    /// - Returns: 一張填充指定顏色的圖片，類型為 `UIImage`。
    ///
    /// - Example:
    ///   ```swift
    ///   let redImage = UIImage.from(color: .red, size: CGSize(width: 100, height: 100))
    ///   ```
    static func from(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
}
