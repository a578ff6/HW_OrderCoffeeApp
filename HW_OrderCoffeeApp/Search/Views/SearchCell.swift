//
//  SearchCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// MARK: -  SearchCell 重點整理筆記
/**
 ## SearchCell 重點整理筆記
 
 `1. What `
 
 - `SearchCell` 是客製化的 UITableViewCell，用於顯示飲品搜尋結果。它包含飲品的圖片、名稱、副標題等資訊，。

 `2. Why`
 
 - `UI 設置的模組化`： 使用 Factory (createLabel, createImageView, createStackView) 來創建 UI 元素，確保每個 UI 元素的風格和行為一致，並且易於維護和重複使用。
 - `結構化的佈局`： 透過 UIStackView 來排列標籤，簡化佈局的管理並保持佈局整潔。
 - `重用處理 (prepareForReuse)`： 當 cell 被重用時，確保清理掉之前的內容，例如圖片、標籤文字，避免資料顯示錯誤。
 
 `3. How`
 
 * `UI 初始化與佈局`：
    - rinkImageView、nameLabel、subNameLabel 都使用自定義的工廠方法創建。
    - 透過 NSLayoutConstraint 設置佈局，並使用 UIStackView 來整理 nameLabel 和 subNameLabel 的排版，使得代碼更簡潔。
 
 * `圖片加載 (Kingfisher)`：
    - 在 configure(with:) 方法中，使用 Kingfisher 的 setImage(with:placeholder:) 來下載和設置圖片，並使用 starbucksLogo 作為預設圖片，確保圖片加載失敗時不會顯示空白。
 
 * `Cell 重用 (prepareForReuse)`：
    - 使用 drinkImageView.kf.cancelDownloadTask() 來取消圖片下載，避免因重用而顯示錯誤的圖片。
    - 清除所有標籤的文字，確保不會顯示到前一個資料的內容。
 */

import UIKit
import Kingfisher

/// `SearchCell` 是一個客製化的 UITableViewCell，用來顯示搜尋結果中的飲品資訊。
class SearchCell: UITableViewCell {
    
    static let reuseIdentifier = "SearchCell"
    
    // MARK: - UI Elements
    
    /// 飲品圖片
    private let drinkImageView = createImageView(height: 80, weight: 80)
    /// 飲品名稱
    private let nameLabel = createLabel(font: .boldSystemFont(ofSize: 18), textColor: .black, numberOfLines: 0)
    /// 飲品副標題
    private let subNameLabel = createLabel(font: .systemFont(ofSize: 14), textColor: .gray, numberOfLines: 0)
    
    /// 包含飲品名稱和副標題的 StackView
    private let labelsStackView = SearchCell.createStackView(axis: .vertical, spacing: 4, alignment: .leading, distribution: .fill)
    
    /// 創建水平排列的主 StackView
    private let mainStackView = SearchCell.createStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)

    
    // MARK: - Initializer
    
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
    private func setupUI() {
        // 將 nameLabel 和 subNameLabel 添加到 labelsStackView
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(subNameLabel)
        
        // 將 drinkImageView 和 labelsStackView 添加到 mainStackView
        mainStackView.addArrangedSubview(drinkImageView)
        mainStackView.addArrangedSubview(labelsStackView)
        
        // 將 mainStackView 添加到 contentView
        contentView.addSubview(mainStackView)
        
        // 設置 mainStackView 的 Auto Layout 約束
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: - Factory Method
    
    /// 創建 UILabel
    private static func createLabel(font: UIFont, textColor: UIColor, numberOfLines: Int) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75 
        return label
    }
    
    ///創建 UIImageView
    private static func createImageView(height: CGFloat, weight: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.deepBrown.cgColor
        imageView.layer.cornerRadius = 15
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: weight).isActive = true
        imageView.clipsToBounds = true
        return imageView
    }
    
    /// 建立並配置 UIStackView
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Configuration Method
    
    /// 配置 Cell 的內容
    /// - Parameter searchResult: 一個 `SearchResult` 物件，包含飲品的名稱、副標題和圖片 URL。
    func configure(with searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        subNameLabel.text = searchResult.subName
        drinkImageView.kf.setImage(with: searchResult.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
    }

    // MARK: - Lifecycle Methods

    /// 清理 Cell 中的資源，確保不會重複顯示舊內容
    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.kf.cancelDownloadTask()  // 取消任何進行中的圖片下載任務
        drinkImageView.image = nil              // 清除目前顯示的圖片
        nameLabel.text = nil
        subNameLabel.text = nil
    }
}
