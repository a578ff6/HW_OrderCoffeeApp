//
//  SearchCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//


// MARK: - SearchCell 筆記
/**
 
 ## SearchCell 筆記


 `* What`

 - `SearchCell` 是一個自訂的 `UITableViewCell`，專門用於顯示搜尋結果中的飲品資訊。

 - 主要功能
 
 1. 顯示飲品的圖片、名稱與副標題。
 2. 使用堆疊視圖（`StackView`）進行結構化佈局，確保內容美觀整齊。
 3. 提供圖片快取與下載功能，使用 Kingfisher 進行圖片管理。

 ---
 
 - 使用場景
 
    - 搜尋結果列表的每個項目中，展示飲品的基本資訊，例如：
       - 飲品名稱。
       - 飲品副標題（如描述或類別）。
       - 飲品圖片。

 ---

 - 特性
 
    1. 重用設計：支援高效能的 `UITableView` 列表操作。
    2. 結構化佈局：採用水平與垂直 `StackView`，方便管理與調整子視圖。
    3. 圖片快取：整合 Kingfisher，實現高效的圖片下載與快取機制。
    4. 動態內容配置：可根據 `SearchResult` 動態更新顯示內容。

 ----------

 `* Why`

 - 設計目的
 
 1. 增強使用者體驗
 
    - 清晰展示飲品資訊，提升搜尋結果的易讀性與視覺效果。
    - 動態加載圖片與自訂文字樣式，讓結果列表更具吸引力。

 2. 效能優化
 
    - 使用 Kingfisher 快取圖片，減少不必要的網路請求。
    - `prepareForReuse` 方法重置內容，避免顯示舊資料，提升列表的平滑體驗。

 3. 遵循設計原則
 
    - 單一責任原則：每個方法專注於特定功能（如佈局設置、內容配置）。
    - 解耦：視圖結構（`StackView`）與內容配置分離，便於後續擴展或修改。

 4. 使用情境需求
 
    - 搜尋結果可能包含大量資料，`SearchCell` 需要在高效能的同時提供豐富的內容展示。
    - 圖片與文字資訊是搜尋結果的重要組成部分，需要結構化的視圖設計來呈現。

 ----------

 `* How`

 1. 定義 UI 元件
 
 - 圖片元件（`drinkImageView`）
 
   - 使用 `SearchImageView` 封裝飲品圖片的樣式與大小。
 
 - 文字元件（`nameLabel` 與 `subNameLabel`）
 
   - 使用 `SearchLabel` 配置飲品名稱與副標題，支援多行文字顯示與字體自訂。

 ---

 2. 使用堆疊視圖進行佈局
 
 - 垂直堆疊視圖（`labelsStackView`）
 
   - 將 `nameLabel` 和 `subNameLabel` 垂直排列，對齊方式設定為靠左。
 
 - 水平堆疊視圖（`mainStackView`）
 
   - 將 `drinkImageView` 與 `labelsStackView` 水平排列，確保視覺上圖片與文字對齊。

 ---
 
 3. 動態內容配置
 
 - 提供 `configure(with:)` 方法：
   - 動態更新 `nameLabel` 和 `subNameLabel` 的文字內容。
   - 使用 Kingfisher 加載圖片，並提供預設佔位圖。

 ---

 4. 資源清理與重用
 
 - 在 `prepareForReuse` 中：
   - 重置圖片與文字內容，確保 Cell 在重用時顯示正確資料。
   - 取消未完成的圖片下載任務，減少資源浪費。

 ---

 5. 配置 Auto Layout
 
 - 將 `mainStackView` 添加到 `contentView`，設置邊距與約束，確保內容在螢幕上正確顯示。

 ----------

 `* 完整實現流程`

 1. 初始化元件：
 
    - 定義 `drinkImageView`、`nameLabel`、`subNameLabel` 等 UI 元件，設定樣式與初始屬性。

 2. 配置堆疊視圖：
 
    - 使用 `labelsStackView` 將標籤排列，`mainStackView` 整合圖片與文字區域。

 3. 設置 Auto Layout：
 
    - 將 `mainStackView` 添加到 `contentView`，設置四周的邊距與約束。

 4. 提供內容更新方法：
 
    - `configure(with:)` 接收 `SearchResult`，更新標籤文字與圖片。

 5. 管理資源清理：
 
    - 在 `prepareForReuse` 中重置圖片與文字，確保列表滑動時不顯示錯誤內容。

 ----------

 `* 總結`

 - What
 
    - `SearchCell` 是一個用於顯示搜尋結果的自訂 Cell，包含圖片與文字資訊，使用堆疊視圖進行結構化佈局。

 - Why
 
    1. 增強搜尋結果的可視化，提升使用者體驗。
    2. 高效能列表操作，支援圖片快取與內容動態更新。
    3. 遵循單一責任與解耦原則，易於擴展與維護。

 - How
 
    1. 使用堆疊視圖（`StackView`）實現結構化佈局。
    2. 動態配置內容，並管理圖片快取與清理。
    3. 配置 Auto Layout，適配不同裝置螢幕尺寸。
 */




// MARK: - (v)

import UIKit
import Kingfisher

/// `SearchCell`
///
/// 一個自訂的 `UITableViewCell`，專門用於顯示搜尋結果中的飲品資訊。
///
/// - 功能：
///   1. 顯示飲品圖片、名稱與副標題。
///   2. 使用堆疊視圖（`StackView`）簡化佈局邏輯，確保內容的結構性與美觀。
///   3. 支援內容動態更新與圖片下載功能，使用 Kingfisher 優化圖片加載。
///
/// - 使用場景：
///   適用於搜尋結果列表中的每個項目，用於展示飲品的基本資訊。
///
/// - 特性：
///   1. 可重用的 `UITableViewCell`，提高列表效能。
///   2. 採用 Auto Layout 配置子視圖，適配不同螢幕尺寸。
///   3. 提供圖片下載功能，支援圖片快取與下載任務管理。
class SearchCell: UITableViewCell {
    
    static let reuseIdentifier = "SearchCell"
    
    // MARK: - UI Elements
    
    /// 飲品圖片
    private let drinkImageView = SearchImageView(borderWidth: 2.0, borderColor: .deepBrown, cornerRadius: 15, size: 80)
    
    /// 飲品名稱
    private let nameLabel = SearchLabel(font: .boldSystemFont(ofSize: 18), textColor: .black, numberOfLines: 0, scaleFactor: 0.75)
    
    /// 飲品副標題
    private let subNameLabel = SearchLabel(font: .systemFont(ofSize: 14), textColor: .gray, numberOfLines: 0, scaleFactor: 0.75)
    
    
    // MARK: - StackView
    
    /// 包含飲品名稱和副標題的垂直堆疊視圖
    ///
    /// - 用於排列 `nameLabel` 和 `subNameLabel`。
    private let labelsStackView = SearchStackView(axis: .vertical, spacing: 8, alignment: .leading, distribution: .fill)
    
    /// 包含飲品圖片和文字資訊的水平堆疊視圖
    ///
    /// - 用於排列 `drinkImageView` 和 `labelsStackView`。
    private let mainStackView = SearchStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
    
    // MARK: - Initializer
    
    ///
    /// - Parameters:
    ///   - style: Cell 的樣式，預設為 `.default`。
    ///   - reuseIdentifier: Cell 的重用標識符。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    
    /// 設置 UI 元件的佈局
    ///
    /// - 包含以下步驟：
    ///   1. 配置 `labelsStackView` 並添加 `nameLabel` 和 `subNameLabel`。
    ///   2. 配置 `mainStackView` 並添加 `drinkImageView` 和 `labelsStackView`。
    ///   3. 為 `mainStackView` 設置 Auto Layout 約束。
    private func setupUI() {
        setupLabelsStackView()
        setupMainStackView()
        setupConstraints()
    }
    
    /// 配置 `labelsStackView`
    ///
    /// - 添加 `nameLabel` 和 `subNameLabel` 作為子視圖。
    private func setupLabelsStackView() {
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(subNameLabel)
    }
    
    /// 配置 `mainStackView`
    ///
    /// - 添加 `drinkImageView` 和 `labelsStackView` 作為子視圖，並將 `mainStackView` 添加至 `contentView`。
    private func setupMainStackView() {
        mainStackView.addArrangedSubview(drinkImageView)
        mainStackView.addArrangedSubview(labelsStackView)
        contentView.addSubview(mainStackView)
    }
    
    /// 設置 `mainStackView` 的 Auto Layout 約束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: - Configuration Method
    
    /// 配置 Cell 的內容
    ///
    /// - Parameter searchResult: 包含飲品資訊的 `SearchResult` 物件。
    ///
    /// - 功能：
    ///   1. 動態更新 `nameLabel` 與 `subNameLabel` 的文字內容。
    ///   2. 使用 Kingfisher 加載圖片並快取，提供佔位圖避免空白顯示。
    func configure(with searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        subNameLabel.text = searchResult.subName
        drinkImageView.kf.setImage(with: searchResult.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
    }
    
    // MARK: - Lifecycle Methods
    
    /// 清理 Cell 中的資源
    ///
    /// - 功能：
    ///   1. 清除圖片下載任務，避免重複加載。
    ///   2. 重置文字內容與圖片，確保不會顯示舊資料。
    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.kf.cancelDownloadTask()  // 取消任何進行中的圖片下載任務
        drinkImageView.image = nil              // 清除目前顯示的圖片
        nameLabel.text = nil
        subNameLabel.text = nil
    }
    
}
