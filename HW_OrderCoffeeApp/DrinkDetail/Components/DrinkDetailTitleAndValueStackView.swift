//
//  DrinkDetailTitleAndValueStackView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/16.
//

 
// MARK: - 筆記：DrinkDetailTitleAndValueStackView
/**
 
 ## 筆記：DrinkDetailTitleAndValueStackView
 
 `* What`
 
 - `DrinkDetailTitleAndValueStackView` 是一個自訂的 `UIStackView`，專門用於展示結構化的資訊，例如飲品的價格、卡路里、咖啡因含量等。它的主要特性包括：

 1.`標題與數值排版`：以水平排列的方式，顯示屬性名稱（標題）與其對應的屬性值（數值）。
 2.`分隔線`：在標題與數值之間使用虛線進行視覺分隔，增強資訊可讀性。
 
 --------------
 
 `* Why`
 
 - 設計 `DrinkDetailTitleAndValueStackView` 的目的：

 `1.簡化視圖管理：`

 - 避免在多個地方重複實現標題與數值的排列邏輯。
 - 提供一個統一的元件來處理此種資訊結構。
 
 `2.視覺分隔與對齊：`

 - 使用虛線（`DottedLineView`）作為分隔，能夠清晰區分標題與數值。
 - 確保標題與數值在所有狀態下都能正常對齊與顯示。
 
 `3.提升重用性與可維護性：`

 - 提供可重用的元件，當需要變更排列邏輯或視覺效果時，只需在此類進行修改。
 
 --------------

 `* How`
 
 - `DrinkDetailTitleAndValueStackView` 的實現方式與使用建議：

 `1.初始化與配置：`

 - 在初始化中，透過 `configureStackView` 設定 StackView 的方向、間距、對齊及分佈。
 - 使用 `setupSubviews` 添加標題、虛線與數值至堆疊視圖中。
 
 `2.分隔線的處理：`

 - 虛線的生成由 `createDottedLineView` 方法封裝，統一配置高度與樣式。
 - 虛線使用 `DottedLineView`，確保分隔線的邏輯集中管理。
 
 `3.使用場景：`

 - 在飲品詳細頁的 Cell 或 StackView 中，直接實例化 `DrinkDetailTitleAndValueStackView`，並傳入標題與數值標籤即可。
 - 配合其他 StackView 或父視圖使用，能夠快速構建結構化資訊的展示。
 
 --------------

 `* 總結`
 
 `1.單一職責原則：`

 - `DrinkDetailTitleAndValueStackView` 僅負責管理標題、分隔線與數值的排版邏輯，不需關心數據來源或數據更新。
 
 `2.靈活性擴展：`

 - 若日後需要變更分隔線的樣式或標題與數值的對齊方式，只需修改此類中的對應方法即可。
 
 `3.與其他元件的整合：`

 - 建議搭配 `DrinkDetailStackView` 作為主堆疊，將多個 `DrinkDetailTitleAndValueStackView` 組合排列，形成結構化的完整資訊視圖。
 */


import UIKit

/// `DrinkDetailTitleAndValueStackView`
///
/// 自訂的 StackView，用於在飲品詳細頁展示`標題`與`數值`之間的結構化資訊，並透過`虛線`視圖進行分隔。
/// - 支援靈活配置標題與數值，適用於顯示多種飲品屬性（例如價格、卡路里、咖啡因含量等）。
/// - 使用 `DottedLineView` 提供清晰的視覺分隔效果，增強資訊的可讀性與結構化。
class DrinkDetailTitleAndValueStackView: UIStackView {
    
    // MARK: - Initializer
    
    /// 初始化堆疊視圖，並設定標題與數值
    /// - Parameters:
    ///   - titleLabel: 用於顯示屬性名稱的標籤，例如「價格」、「卡路里」。
    ///   - valueLabel: 用於顯示屬性值的標籤，例如「$100」、「50卡」。
    init(titleLabel: UILabel, valueLabel: UILabel) {
        super.init(frame: .zero)
        
        configureStackView()
        setupSubviews(titleLabel: titleLabel, valueLabel: valueLabel)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 配置 StackView 的基本屬性
    ///
    /// 設定堆疊方向為水平、間距、對齊方式，以及分佈規則，確保子視圖在視圖中正確排列。
    private func configureStackView() {
        axis = .horizontal
        spacing = 6
        alignment = .center
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 配置子視圖，包括標題、虛線分隔、數值
    ///
    /// - Parameters:
    ///   - titleLabel: 屬性名稱的標籤。
    ///   - valueLabel: 屬性值的標籤。
    private func setupSubviews(titleLabel: UILabel, valueLabel: UILabel) {
        let dottedLineView = createDottedLineView()
        addArrangedSubview(titleLabel)
        addArrangedSubview(dottedLineView)
        addArrangedSubview(valueLabel)
        
        // 設定內容壓縮優先級，確保標籤正常顯示
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    /// 創建虛線分隔視圖
    ///
    /// - Returns: 配置完成的虛線視圖，作為標題與數值間的分隔線。
    private func createDottedLineView() -> UIView {
        let dottedLineView = DottedLineView()
        dottedLineView.translatesAutoresizingMaskIntoConstraints = false
        dottedLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return dottedLineView
    }
}
