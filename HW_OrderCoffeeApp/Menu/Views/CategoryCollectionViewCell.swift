//
//  CategoryCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

/*
 ## CategoryCollectionViewCell：
 
    - 專門用於在 MenuViewController 中展示飲品的分類。它負責顯示每個飲品分類的圖片、標題和子標題。
 
    * 主要結構
        - categoryImageView：UIImageView 用於顯示飲品分類的圖片。
        - titleLabel：UILabel 用於顯示分類的主標題。
        - subtitleLabel：UILabel 用於顯示分類的子標題。
        - stackView：UIStackView 用於垂直排列 titleLabel 和 subtitleLabel，並控制其間距。
 
    * 主要功能
        - setupCellAppearance()：設置了單元格的外觀，包括圓角、邊框和背景顏色，使單元格的外觀一致並符合設計要求。
        - setupViews()：將 categoryImageView 和 stackView 添加到單元格的 contentView。
        - update(with:)：用於更新單元格的內容，根據傳入的 Category 對象設置圖片和文本。使用了 Kingfisher 來加載圖片，並設置了預設圖片。
 */


// MARK: - 已完善

import UIKit
import Kingfisher

/// 飲品種類的 Cell，用於 MenuViewController
class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CategoryCollectionViewCell"

    // MARK: - UI Elements
    
    let categoryImageView: UIImageView = createImageView()
    let titleLabel: UILabel = createLabel(fontSize: 18, textColor: .deepBrown, isBold: true)
    let subtitleLabel: UILabel = createLabel(fontSize: 14, textColor: .gray, isBold: false)
    let stackView: UIStackView = createStackView()
    
    // MARK: - Initialization

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

    private func setupCellAppearance() {
        self.layer.cornerRadius = 30
        self.layer.masksToBounds = true
//        self.layer.borderWidth = 2
//        self.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        
        // 設置 contentView 背景顏色
        self.contentView.backgroundColor = .lightWhiteGray
    }
    
    private func setupViews() {
        contentView.addSubview(categoryImageView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            categoryImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            categoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            categoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            // categoryImageView.heightAnchor.constraint(equalTo: categoryImageView.widthAnchor),
            
            // 修改高度约束，允許高度調整
            categoryImageView.heightAnchor.constraint(lessThanOrEqualTo: categoryImageView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: categoryImageView.bottomAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])
    }
    
    // MARK: - Helper Methods

    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
//        imageView.layer.borderWidth = 2
//        imageView.layer.masksToBounds = true
//        imageView.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }
 
    private static func createLabel(fontSize: CGFloat, textColor: UIColor, isBold: Bool) -> UILabel {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
         label.textColor = textColor
         label.textAlignment = .center
         label.numberOfLines = 0
         return label
     }
    
    private static func createStackView() -> UIStackView {
         let stackView = UIStackView()
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.axis = .vertical
         stackView.spacing = 3
         return stackView
     }
    
    // MARK: - Configuration

    /// 使用類別數據更新單元格。
    func update(with category: Category) {
        categoryImageView.kf.setImage(with: category.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = category.title
        subtitleLabel.text = category.subtitle
    }
    
}
