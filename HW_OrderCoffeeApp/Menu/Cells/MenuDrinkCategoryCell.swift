//
//  MenuDrinkCategoryCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

// MARK: - MenuDrinkCategoryCell 筆記
/**
 
 ## MenuDrinkCategoryCell 筆記


 `* What`

 - `MenuDrinkCategoryCell` 是一個自訂的 `UICollectionViewCell`，專為 `MenuViewController` 的飲品分類設計。它包含以下主要元素：

 1. `categoryImageView`：顯示飲品分類的圖片。
 2. `titleLabel`和 `subtitleLabel`：分別顯示分類的標題與副標題。
 3. `titleAndSubtitleStackView`：垂直堆疊的文字區域，用於管理標題與副標題的排列與間距。
 4. `mainStackView`：主堆疊視圖，包含圖片與文字區域，負責整體布局。

 該類的功能包括：
 
 - 動態展示分類資料，包括圖片、標題、副標題。
 - 使用 Kingfisher 加載圖片。
 - 提供結構清晰的布局，便於擴展與維護。

 -------

 `* Why`

 1. 使用場景
 
 此單元格設計的目的是在 `MenuViewController` 的 `UICollectionView` 中展示飲品分類列表。例如：

 - 咖啡類
 - 茶類
 - 冰沙類

 ---
 
 2. 為何需要這樣的結構設計
 
 - 分層清晰：使用 `titleAndSubtitleStackView` 管理標題與副標題的布局，再通過 `mainStackView` 將圖片與文字整合到一起，提升結構可讀性與邏輯性。
 - 易於擴展：未來若需要新增其他元素（例如標籤、按鈕），可以直接調整 `mainStackView`，而不需要大幅改動現有代碼。
 - 提升可維護性：將圖片、文字與布局分離，當樣式需要調整時，只需修改對應部分。

 3. 為何使用 `MenuDrinkCategoryViewModel`
 
 - 命名語意更清晰：使用 `MenuDrinkCategoryViewModel` 表明該模型是為展示層準備的，避免與 `Category` 混淆。
 - 面向展示層設計：`MenuDrinkCategoryViewModel` 是輕量化的模型，只包含展示層需要的數據，減少與資料層耦合。
 - 統一數據來源：通過 `update(with drinkCategory:)` 方法，可以輕鬆更新單元格內容，且不受資料結構變動影響。
 
 4. 為何重用性高
 
 - 提供了標準化的更新方法（`configure(with:)`），可輕鬆根據不同的 `MenuDrinkCategoryViewModel` 資料更新內容。
 - 使用 `prepareForReuse` 清空內容，避免單元格重用時出現錯誤或殘留數據。

 ---

 *` How`

 1. 初始化
 
 - 外觀設置（`setupCellAppearance`）
 
   - 設置圓角與背景色，提升視覺效果並與整體界面風格保持一致。
 
 - 視圖層級與布局（`setupViews`）
 
   - 使用兩層堆疊視圖管理結構：`titleAndSubtitleStackView` 和 `mainStackView`。
   - 約束設置中確保圖片與文字間距一致，並讓圖片高度適應其寬度。

 2. 配置內容
 
 - 使用 `update(with drinkCategory:)` 方法，將分類圖片、標題、副標題更新到單元格。
 - 使用 Kingfisher 動態加載圖片，支持圖片異步加載並設置占位圖。

 3. 單元格重用
 
 - 在 `prepareForReuse` 方法中重置圖片與文字，避免單元格重用時殘留舊內容，確保 UI 一致性。

 ---

 `* 結構總結`

 1. 圖片與文字分離：
 
    - `categoryImageView` 負責展示分類圖片，樣式統一。
    - 文字區域由 `titleAndSubtitleStackView` 管理，包含標題與副標題，排列整齊。

 2. 使用堆疊視圖進行布局：
 
    - `titleAndSubtitleStackView` 管理文字部分。
    - `mainStackView` 負責將圖片與文字整合，確保視圖層級簡潔明瞭。

 3. 高度自適應：
 
    - 確保圖片高度不超過寬度，並允許根據內容調整。

 ---

 `* 總結`

 - What：
 
   `MenuDrinkCategoryCell` 是一個用於展示飲品分類的自訂單元格，結構分層清晰，適合展示圖片、標題與副標題。

 - Why：
 
   - 使用堆疊視圖分層管理，提高結構可讀性與擴展性。
   - 提供統一的更新與重置方法，方便重用與數據綁定。

 - How：
 
   - 通過 `setupCellAppearance`、`setupViews` 配置布局與樣式。
   - 使用 `update(with drinkCategory:)` 動態更新內容，並在 `prepareForReuse` 中重置狀態。
   - 使用 Kingfisher 加載圖片，確保圖片加載效率與性能。
 
 */


// MARK: - (v)

import UIKit

/// 用於顯示飲品種類的自訂單元格，適用於 Menu 頁面的 UICollectionView。
///
/// 此類專為展示飲品種類設計，包含圖片與標題、副標題，並使用兩層 StackView 統一管理佈局與樣式。
///
/// - 功能特色:
///   1. 圖片顯示：支援顯示類別圖片，並應用統一樣式（如內容模式、圓角）。
///   2. 文字區域：提供標題與副標題區域，使用垂直堆疊布局，支援多行文字顯示。
///   3. 結構清晰：通過 `MainStackView` 管理圖片與文字的整體布局，便於擴展與維護。
///
/// - 使用場景:
///   用於 Menu 頁面的飲品分類展示，如咖啡類、茶類等。
///   由 `MenuCollectionHandler` 配置並管理。
class MenuDrinkCategoryCell: UICollectionViewCell {
    
    /// 單元格的重用識別符。
    static let reuseIdentifier = "MenuDrinkCategoryCell"
    
    // MARK: - UI Elements
    
    /// 用於顯示類別圖片。
    private let categoryImageView = MenuImageView(contentMode: .scaleAspectFit, cornerRadius: 20)
    
    /// 用於顯示類別標題。
    private let titleLabel = MenuLabel(font: .boldSystemFont(ofSize: 18), textColor: .deepBrown, numberOfLines: 0, textAlignment: .center)
    
    /// 用於顯示類別副標題。
    private let subtitleLabel = MenuLabel(font: .systemFont(ofSize: 14), textColor: .gray, numberOfLines: 0, textAlignment: .center)
    
    /// 垂直堆疊的文字區域，包括標題與副標題。
    private let titleAndSubtitleStackView = MenuStackView(axis: .vertical, spacing: 5, alignment: .center, distribution: .fill)
    
    /// 主堆疊視圖，包含圖片與文字區域，負責整體布局。
    private let mainStackView = MenuStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    
    // MARK: - Initialization
    
    /// 初始化單元格。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置單元格的外觀屬性。
    ///
    /// 包括圓角與背景色的設置，提升視覺效果。
    private func setupCellAppearance() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = .lightWhiteGray
    }
    
    /// 配置視圖層級與布局。
    ///
    /// 包括:
    /// - 配置標題與副標題的 StackView。
    /// - 配置主 StackView。
    /// - 配置約束條件。
    private func setupViews() {
        setupTitleAndSubtitleStackView()
        setupMainStackView()
        setupConstraints()
    }
    
    /// 配置標題與副標題的 StackView。
    private func setupTitleAndSubtitleStackView() {
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleLabel)
    }
    
    /// 配置主 StackView。
    private func setupMainStackView() {
        mainStackView.addArrangedSubview(categoryImageView)
        mainStackView.addArrangedSubview(titleAndSubtitleStackView)
        contentView.addSubview(mainStackView)
    }
    
    /// 配置約束條件。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            
            // 圖片高度不超過寬度，並允許自適應
            categoryImageView.heightAnchor.constraint(lessThanOrEqualTo: categoryImageView.widthAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    /// 使用飲品分類展示模型更新單元格內容。
    ///
    /// - Parameter viewModel: 飲品分類的展示模型，包含圖片、標題與副標題。
    func configure(with drinkCategory: MenuDrinkCategoryViewModel) {
        categoryImageView.kf.setImage(with: drinkCategory.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = drinkCategory.title
        subtitleLabel.text = drinkCategory.subtitle
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置單元格狀態。
    ///
    /// 清空圖片與文字，確保重用時不會殘留舊的內容。
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
}
