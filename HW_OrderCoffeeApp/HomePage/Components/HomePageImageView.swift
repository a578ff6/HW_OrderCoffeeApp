//
//  HomePageImageView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/3.
//

// MARK: - 重點筆記 - HomePageImageView
/**
 
 ## 重點筆記 - HomePageImageView
 
 `* What`
 
 - HomePageImageView 是一個自訂的 UIImageView，主要用於首頁，顯示特定的圖片。
 - 它能夠透過簡單的初始化方法，設定圖片名稱與顯示模式，以便快速創建具有統一風格的圖片元件。
 
 --------------------------------
 
 `* Why`
 
 - 統一樣式：在首頁顯示圖片時，可能會有多個地方使用相同風格的圖片。透過自訂 HomePageImageView，可以確保這些圖片的樣式（如顯示模式、佈局）一致。
 - 減少重複代碼：重複設定 UIImageView 的圖片名稱、顯示模式等屬性會導致代碼冗長。透過這個類別，可以集中管理這些屬性，減少重複的設置，提高代碼的可維護性。
 
 --------------------------------

 `* How`
 
 `1.初始化圖片視圖：`

 - 使用初始化方法 init(imageName:contentMode:)，可以方便地設置圖片和顯示模式。例如：
 
 ```swift
 複製程式碼
 let logoImageView = HomePageImageView(imageName: "homeLogo", contentMode: .scaleAspectFit)
 ```
 
 - 這樣可以簡化 UIImageView 的創建，並確保樣式的一致性。

 --------------------------------

 `* 設計方法：`

 - 設定圖片名稱與顯示模式：初始化時直接設定圖片和顯示模式，避免多次調用屬性設定方法。
 - 關閉自動佈局 (translatesAutoresizingMaskIntoConstraints = false)：為了方便後續使用 Auto Layout 進行佈局，初始化時即關閉自動佈局屬性。
 */

import UIKit

/// 自訂的首頁圖片視圖，用於顯示特定樣式的圖片
class HomePageImageView: UIImageView {
    
    /// 初始化方法
    /// - Parameters:
    ///   - imageName: 圖片名稱
    ///   - contentMode: 顯示模式
    init(imageName: String, contentMode: UIView.ContentMode) {
        super.init(frame: .zero)
        self.image = UIImage(named: imageName)
        self.contentMode = contentMode
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
