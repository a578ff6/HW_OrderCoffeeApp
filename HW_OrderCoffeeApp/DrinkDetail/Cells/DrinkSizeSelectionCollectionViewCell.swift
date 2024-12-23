//
//  DrinkSizeSelectionCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/14.
//

// MARK: - DrinkSizeSelectionCollectionViewCell 筆記
/**
 
 ## DrinkSizeSelectionCollectionViewCell 筆記
 
 `* What`
 
 - `DrinkSizeSelectionCollectionViewCell` 是一個自訂的 UICollectionViewCell，用於顯示飲品的尺寸選項，支援以下功能：

 1.`尺寸顯示`：使用 `DrinkDetailSizeButton` 作為核心按鈕，顯示飲品的尺寸文字。
 2.`狀態管理`：根據選中與未選中狀態動態調整按鈕外觀。
 3.`事件回調`：透過閉包 (`sizeSelected`) 傳遞選中的尺寸資訊，支援外部處理邏輯。
 
 --------------------------
 
 `* Why`
 
 `1.封裝性強：`
 
 - 透過自訂 Cell 和按鈕，將按鈕樣式與邏輯封裝於 `DrinkSizeSelectionCollectionViewCell`，提高程式碼可讀性與可維護性。

` 2.減少重複程式碼：`
 
 - 將尺寸按鈕的樣式與狀態更新邏輯統一於 `DrinkDetailSizeButton`，避免重複撰寫按鈕的樣式設定。

 `3.彈性設計：`
 
 - 支援初始化時自訂尺寸樣式，並透過 `configure(with:isSelected:) `方法設定按鈕內容，靈活應對不同 UI 設計需求。

 --------------------------

 `* How`
 
 `1.尺寸按鈕的設定：`
 
 - 使用 `DrinkDetailSizeButton` 作為核心按鈕，初始化時自訂按鈕的樣式，並根據需要更新按鈕的外觀。

 ```swift
 private let sizeButton = DrinkDetailSizeButton(
     cornerStyle: .small,
     baseBackgroundColor: .lightWhiteGray,
     baseForegroundColor: .black
 )
 ```
 
 `2.狀態管理與事件回調：`

 - 使用 `updateAppearance` 動態更新按鈕的選中狀態。
 - 透過 `sizeSelected` 閉包將使用者選中的尺寸傳遞給外部，支援事件處理邏輯。
 
 ```swift
 sizeSelected?(size)  // 傳遞選中尺寸
 sizeButton.updateAppearance(isSelected: true)
 ```
 
 `3.靈活配置：`
 
 - 提供 `configure(with:isSelected:) `方法，讓外部使用時能根據當前資料更新尺寸文字與按鈕狀態。

 ```swift
 func configure(with size: String, isSelected: Bool) {
     self.size = size
     sizeButton.setTitle(size, for: .normal)
     sizeButton.updateAppearance(isSelected: isSelected)
 }
 ```
 
 --------------------------

 `* 優勢`
 
 `1.模組化設計：`

 - 按鈕邏輯集中在 `DrinkDetailSizeButton`，而事件管理和數據配置則在 `DrinkSizeSelectionCollectionViewCell`，清晰分工。

 `2.易於測試與維護：`

 - 狀態更新、樣式設定與事件傳遞邏輯分離，容易測試每個模組的功能。
 
 --------------------------

 `* 適用場景`
 
 1.`飲品尺寸選擇`：使用於需要多個按鈕顯示飲品尺寸的場景，例如飲品詳細頁面。
 2.`狀態切換按鈕`：應用於任何需要動態切換外觀的按鈕組件，例如篩選或選項選擇。
 
 */


// MARK: - (v)

import UIKit

/// `DrinkSizeSelectionCollectionViewCell`
///
/// 用於顯示飲品尺寸的選擇項目，每個 Cell 包含一個尺寸按鈕，點擊後可觸發尺寸選擇的回調。
/// 支援根據選中狀態動態更新按鈕外觀，提供流暢的交互體驗。
///
/// ### 功能說明
/// - 顯示飲品尺寸選擇按鈕。
/// - 點擊按鈕時，回傳所選尺寸並觸發動畫效果。
/// - 支援動態更新按鈕樣式，根據選中狀態改變外觀。
class DrinkSizeSelectionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Reuse Identifier
    
    /// Cell 的重用識別碼
    static let reuseIdentifier = "DrinkSizeSelectionCollectionViewCell"
    
    // MARK: - Properties
    
    /// 儲存當前尺寸的字串
    private var size: String?
    
    /// 點擊尺寸按鈕時觸發的閉包，用於傳遞選中的尺寸
    var sizeSelected: ((String) -> Void)?
    
    // MARK: - UI Elements
    
    /// 尺寸選擇按鈕，提供圓角、填充顏色與動態外觀
    private let sizeButton = DrinkDetailSizeButton(cornerStyle: .small, baseBackgroundColor: .lightWhiteGray, baseForegroundColor: .black)
    
    // MARK: - Initializers
    
    /// 初始化方法，設置視圖與行為
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        configureTargets()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置尺寸按鈕的佈局與樣式
    private func setupView() {
        contentView.addSubview(sizeButton)
        
        NSLayoutConstraint.activate([
            sizeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            sizeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            sizeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            sizeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    /// 配置按鈕的點擊行為
    ///
    /// - 為按鈕添加觸發事件，處理點擊後的回調與動畫。
    private func configureTargets() {
        sizeButton.addTarget(self, action: #selector(sizeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Methods
    
    /// 按鈕被點擊時觸發事件，傳遞選中尺寸並觸發動畫效果
    @objc private func sizeButtonTapped() {
        guard let size = size else { return }
        sizeSelected?(size)
        sizeButton.addSpringAnimation()
    }
    
    // MARK: - Configure Method
    
    /// 配置 Cell 的尺寸與選中狀態
    ///
    /// - Parameters:
    ///   - size: 尺寸文字
    ///   - isSelected: 是否為選中狀態
    /// - 更新按鈕的文字內容與選中狀態的外觀。
    func configure(with size: String, isSelected: Bool) {
        self.size = size
        sizeButton.setTitle(size, for: .normal)
        sizeButton.updateAppearance(isSelected: isSelected)
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置 Cell 的狀態，防止重用時資料錯誤
    override func prepareForReuse() {
        super.prepareForReuse()
        sizeButton.updateAppearance(isSelected: false)
    }
    
}
