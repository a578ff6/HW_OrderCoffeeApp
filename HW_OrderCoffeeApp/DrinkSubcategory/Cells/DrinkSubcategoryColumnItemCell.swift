//
//  DrinkSubcategoryColumnItemCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/28.
//




// MARK: - (v)

import UIKit

/// 用於顯示飲品子類別頁面中，列布局飲品項目的自訂單元格。
///
/// 此類專為 `DrinkSubCategoryViewController` 的列表布局設計，
/// 主要用於顯示飲品的圖片、名稱與副標題，並提供動態配置功能。
///
/// - 功能特色:
///   1. 支援列布局的飲品資訊顯示，包含飲品圖片、名稱、副名稱。
///   2. 提供 `configure(with:)` 方法，用於動態加載飲品資料。
///   3. 在 `prepareForReuse` 方法中重置圖片與文字，確保單元格重用時狀態正確。
///
/// - 使用場景:
///   適用於展示飲品子類別頁面的 `UICollectionView` 列布局單元格，
///   通常由 `DrinkSubCategoryHandler` 配置並管理。
class DrinkSubcategoryColumnItemCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkSubcategoryColumnItemCell"
    
    // MARK: - UI Elements
    
    /// 用於顯示飲品圖片的圖片視圖。
    private let subcategoryImageView = DrinkSubcategoryImageView(contentMode: .scaleAspectFit, cornerRadius: 15)
    
    /// 用於顯示飲品名稱的標籤。
    private let titleLabel = DrinkSubcategoyLabel(font: .boldSystemFont(ofSize: 16), textColor: .black, numberOfLines: 1, scaleFactor: 0.5)
    
    /// 用於顯示飲品副名稱的標籤。
    private let subtitleLabel = DrinkSubcategoyLabel(font: .systemFont(ofSize: 14), textColor: .gray, numberOfLines: 0, scaleFactor: 0.5)
    
    
    // MARK: - Stack View
    
    /// 用於排列飲品名稱與副名稱的垂直堆疊視圖。
    private let titleAndSubtitleStackView = DrinkSubcategoryStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    
    /// 用於排列圖片與文字區域的水平堆疊視圖。
    private let mainStackView = DrinkSubcategoryStackView(axis: .horizontal, spacing: 20, alignment: .center, distribution: .fill)
    
    
    // MARK: - Initializers
    
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
    
    // MARK: - UI Setup Methods
    
    /// 設置單元格的外觀樣式。
    ///
    /// 包含圓角與背景顏色的設置。
    private func setupCellAppearance() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = .lightWhiteGray
    }
    
    /// 配置單元格的視圖層級與佈局。
    ///
    /// 此方法將子視圖添加到堆疊視圖中，並設置相應約束。
    private func setupViews() {
        setupTitleAndSubtitleStackView()
        setupMainStackView()
        setupConstraints()
    }
    
    /// 配置標籤的垂直堆疊視圖，排列飲品名稱與副名稱。
    private func setupTitleAndSubtitleStackView() {
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleLabel)
    }
    
    /// 配置主要的水平堆疊視圖，包含圖片和文字堆疊。
    private func setupMainStackView() {
        mainStackView.addArrangedSubview(subcategoryImageView)
        mainStackView.addArrangedSubview(titleAndSubtitleStackView)
        contentView.addSubview(mainStackView)
    }
    
    /// 設置堆疊視圖和圖片的約束，確保佈局正確。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            subcategoryImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 70),
            subcategoryImageView.heightAnchor.constraint(equalTo: subcategoryImageView.widthAnchor)
        ])
    }
    
    // MARK: - Configure Method
    
    /// 配置單元格內容，包括飲品圖片、名稱與副名稱。
    ///
    /// 使用 Kingfisher 加載圖片，並設定飲品名稱與副名稱。
    ///
    /// - Parameter drinkViewModel: 包含飲品資料的 `DrinkViewModel` 實例。
    func configure(with drinkViewModel: DrinkViewModel) {
        subcategoryImageView.kf.setImage(with: drinkViewModel.imageUrl, placeholder: UIImage(named: "placeholderImage"))
        titleLabel.text = drinkViewModel.name
        subtitleLabel.text = drinkViewModel.subName
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置單元格的圖片與文字，確保重用時狀態正確。
    ///
    /// 清空 `imageView` 的圖片，以及 `titleLabel` 和 `subtitleNameLabel` 的文字內容。
    override func prepareForReuse() {
        super.prepareForReuse()
        subcategoryImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
}
