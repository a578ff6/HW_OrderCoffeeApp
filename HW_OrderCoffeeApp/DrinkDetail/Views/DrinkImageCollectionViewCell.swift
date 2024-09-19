//
//  DrinkImageCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/18.
//

/*
 ## DrinkImageCollectionViewCell：
 
    * 功能：
        - DrinkImageCollectionViewCell 用來顯示飲品的圖片，使用 Kingfisher 來處理圖片載入。
 
    * UI 設計：
        - 使用 UIImageView 來顯示飲品圖片，並設置為 scaleAspectFit 以確保圖片比例不變。
        - 透過約束設置圖片的寬高相等，保證顯示為正方形。
 
    * 配置方法（比較）：
        1. configure(with imageUrl: URL)：
            - 功能：接收一個圖片的 URL，使用 Kingfisher 來下載並顯示圖片。
            - 使用場景：當只需傳遞圖片的 URL 給 cell 時，適合使用這個方法，簡潔且直觀。
 
        2. configure(with drink: Drink)：
            - 功能：接收一個 Drink 物件，從中提取 imageUrl 並設置圖片。
            - 使用場景：當其他方法已經處理了 Drink 物件時，這個方法可以更直接地使用 Drink 物件來設置圖片。

    * 差異：
        - configure(with imageUrl: URL)：只傳入圖片的 URL，適合只需設置圖片時使用，較為簡單。
        - configure(with drink: Drink)：傳入整個 Drink 物件，當需要處理更多飲品資料時，這種方式較為靈活。
 */

import UIKit

/// 展示飲品的圖片
class DrinkImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkImageCollectionViewCell"
    
    // MARK: - UI Elements
    let drinkImageView = createImageView(contentMode: .scaleAspectFit)

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupViews() {
        contentView.addSubview(drinkImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            drinkImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            drinkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor, multiplier: 1.0)
        ])
    }

    // MARK: - Factory Methods
    
    private static func createImageView(contentMode: UIView.ContentMode) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    // MARK: - Configure Method
    
    /// 配置 cell 顯示的內容
    /// - Parameter imageUrl: 要顯示的圖片 URL
    func configure(with imageUrl: URL) {
        drinkImageView.kf.setImage(with: imageUrl)
    }

    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.image = nil
    }
    
}
