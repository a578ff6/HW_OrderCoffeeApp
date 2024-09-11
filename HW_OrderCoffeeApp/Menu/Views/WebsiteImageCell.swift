//
//  WebsiteImageCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/1.
//

/*
 ## WebsiteImageCell：

    - 專門用來顯示網站橫幅圖片。
 
    * 主要結構：
        - imageView：用來顯示橫幅圖片的 UIImageView，設置了適當的內容模式及約束條件。
 
    * 主要流程：
        - 在初始化時，通過 setupViews 方法將 imageView 添加到 contentView 中，並設置其約束。
        - 通過 configure(with:) 方法來加載並顯示指定 URL 的圖片。
 */


// MARK: - 已完善

import UIKit

/// 用於顯示網站橫幅圖片。
class WebsiteImageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "WebsiteImageCell"

    // MARK: - UI Elements

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    private func setupViews() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration

    /// 配置單元格以顯示指定 URL 的圖片。
    /// - Parameter imageURL: 要加載的圖片 URL。
    func configure(with imageURL: URL) {
        imageView.kf.setImage(with: imageURL)
    }
    
    // MARK: - Lifecycle Methods

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil // 重置圖片
    }

}

