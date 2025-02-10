//
//  DrinkSubcategoryGridItemCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/28.
//



// MARK: - (v)

import UIKit

/// 用於顯示飲品子類別頁面中，網格布局飲品項目的自訂單元格。
///
/// 此類專為 `DrinkSubCategoryViewController` 的網格布局設計，
/// 用於展示飲品的圖片、名稱與副標題，並支持動態內容配置。
///
/// - 功能特色:
///   1. 支援網格布局的飲品資訊顯示，包含圖片、名稱與副名稱。
///   2. 提供 `configure(with:)` 方法，用於根據模型動態加載飲品資料。
///   3. 在 `prepareForReuse` 方法中重置圖片與文字，確保單元格在重用時維持正確狀態。
///
/// - 使用場景:
///   適用於展示飲品子類別頁面的 `UICollectionView` 網格布局單元格，
///   由 `DrinkSubCategoryHandler` 負責配置與管理。
class DrinkSubcategoryGridItemCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkSubcategoryGridItemCell"
    
    // MARK: - UI Elements
    
    /// 顯示飲品圖片的視圖，支援內容模式與圓角設置。
    private let subcategoryImageView = DrinkSubcategoryImageView(contentMode: .scaleAspectFit, cornerRadius: 20)
    
    /// 顯示飲品名稱的標籤，字體加粗，僅支持單行顯示。
    private let titleLabel = DrinkSubcategoyLabel(font: .boldSystemFont(ofSize: 18), textColor: .black, numberOfLines: 1, scaleFactor: 0.5, textAlignment: .center)
    
    /// 顯示飲品副名稱的標籤，支持最多兩行，字體較小且顏色偏灰。
    private let subtitleLabel = DrinkSubcategoyLabel(font: .systemFont(ofSize: 14), textColor: .gray, numberOfLines: 2, scaleFactor: 0.5, textAlignment: .center)
    
    /// 用於排列標題與副標題的垂直堆疊視圖。
    private let titleAndSubtitleStackView = DrinkSubcategoryStackView(axis: .vertical, spacing: 5, alignment: .fill, distribution: .equalSpacing)
    
    
    // MARK: - Initializers
    
    /// 初始化單元格並設置視圖層級與外觀。
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
    
    /// 配置單元格的外觀樣式。
    ///
    /// 包含圓角與背景顏色的設置，提升視覺效果。
    private func setupCellAppearance() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = .lightWhiteGray
    }
    
    /// 配置單元格的視圖層級與布局。
    ///
    /// 此方法依次添加子視圖、配置堆疊視圖，並設置約束條件以確保布局正確。
    private func setupViews() {
        setupSubviews()
        configureTitleAndSubtitleStackView()
        configureConstraints()
    }
    
    /// 添加子視圖至 contentView。
    private func setupSubviews() {
        contentView.addSubview(subcategoryImageView)
        contentView.addSubview(titleAndSubtitleStackView)
    }
    
    /// 配置標題與副標題的堆疊視圖。
    ///
    /// 此方法將 `titleLabel` 與 `subtitleLabel` 添加至垂直堆疊視圖中，統一管理文字區域。
    private func configureTitleAndSubtitleStackView() {
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleLabel)
    }
    
    /// 配置視圖的約束條件，確保圖片與文字區域布局一致性。
    ///
    /// - 約束圖片為正方形，寬高相等。
    /// - 保持文字區域與圖片的間距固定。
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            subcategoryImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            subcategoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            subcategoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            // 修改高度约束，允許高度調整
            subcategoryImageView.heightAnchor.constraint(lessThanOrEqualTo: subcategoryImageView.widthAnchor),
            
            titleAndSubtitleStackView.topAnchor.constraint(equalTo: subcategoryImageView.bottomAnchor, constant: 18),
            titleAndSubtitleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleAndSubtitleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleAndSubtitleStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -18)
        ])
    }
    
    
    // MARK: - Configure Method
    
    /// 配置單元格內容，包括飲品圖片、名稱與副名稱。
    ///
    /// 使用 Kingfisher 加載圖片，並設定飲品名稱與副名稱。
    ///
    /// - Parameter drinkViewModel: 包含飲品資料的 `DrinkViewModel` 實例。
    func configure(with drinkViewModel: DrinkViewModel) {
        subcategoryImageView.kf.setImage(with: drinkViewModel.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = drinkViewModel.name
        subtitleLabel.text = drinkViewModel.subName
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置單元格的圖片與文字，確保重用時狀態正確。
    ///
    /// 清空 `subcategoryImageView` 的圖片，以及 `titleLabel` 和 `subtitleLabel` 的文字內容。
    override func prepareForReuse() {
        super.prepareForReuse()
        subcategoryImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
}
