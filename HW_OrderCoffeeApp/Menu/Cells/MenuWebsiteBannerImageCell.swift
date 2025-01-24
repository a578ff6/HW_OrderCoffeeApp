//
//  MenuWebsiteBannerImageCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/1.
//


// MARK: - MenuWebsiteBannerImageCell 筆記
/**
 
 ## MenuWebsiteBannerImageCell 筆記
 

 `* What`
 
 - `MenuWebsiteBannerImageCell` 是一個自訂的 `UICollectionViewCell`，專為菜單頁面的網站橫幅設計，負責顯示網站橫幅圖片。

 - 功能
 
 1. 橫幅圖片展示：
 
    - 使用自訂的 `MenuImageView` 顯示橫幅圖片，並應用統一的樣式（如圓角與內容模式）。

 2. 圖片配置：
 
    - 提供 `configure(with:)` 方法，動態加載並展示指定的圖片 URL。

 3. 狀態重置：
 
    - 在 `prepareForReuse` 方法中重置圖片，確保單元格重用時不會出現舊圖片殘留。

 --------

 `* Why`

 - 問題
 
 1. 重複性與樣式不一致：
 
    - 如果每個橫幅圖片都單獨設置樣式（如圓角、內容模式），可能導致程式碼重複且樣式不一致。

 2. 複雜度分散：
 
    - 將圖片樣式與加載邏輯直接混合在控制器中會增加複雜度，降低可讀性。

 3. 重用效率低：
 
    - 若不重置圖片，單元格重用時可能出現圖片錯位或殘留。

 ----
 
 - 解決方式
 
 1. 集中管理樣式：
 
    - 使用自訂的 `MenuImageView`，統一橫幅圖片的樣式設置，減少程式碼重複。

 2. 解耦邏輯：
 
    - 將橫幅圖片的顯示邏輯封裝在 `MenuWebsiteBannerImageCell` 中，提升控制器的可讀性。

 3. 增強重用性：
 
    - 在 `prepareForReuse` 中重置圖片，確保每次使用時狀態一致。

 --------

 `* How`

 1. 初始化並註冊單元格
 
    - 在 `MenuCollectionView` 或相關元件中，註冊並配置 `MenuWebsiteBannerImageCell`：

     ```swift
     menuCollectionView.register(
         MenuWebsiteBannerImageCell.self,
         forCellWithReuseIdentifier: MenuWebsiteBannerImageCell.reuseIdentifier
     )
     ```

 ---

 2. 配置橫幅圖片
 
    - 通過 `configure(with:)` 方法加載圖片：

     ```swift
     guard let cell = collectionView.dequeueReusableCell(
         withReuseIdentifier: MenuWebsiteBannerImageCell.reuseIdentifier,
         for: indexPath
     ) as? MenuWebsiteBannerImageCell else {
         fatalError("Cannot create MenuWebsiteBannerImageCell")
     }

     if let url = URL(string: website.imagePath) {
         cell.configure(with: url)
     }
     ```

 ---

 3. 確保狀態重置
 
    - 在單元格重用時，框架會自動調用 `prepareForReuse`，以清空圖片並避免殘留：

     ```swift
     override func prepareForReuse() {
         super.prepareForReuse()
         websiteBannerImageView.image = nil // 清空圖片
     }
     ```

 --------

 `* 總結`

 - What：
 
    - `MenuWebsiteBannerImageCell` 是專為菜單頁面的網站橫幅設計的單元格，負責圖片展示與樣式統一。
 
 - Why：
 
   - 解決程式碼重複與樣式不一致問題，減少控制器負擔。
   - 提升重用效率，避免圖片錯位或殘留。
 
 - How：
 
   - 通過 `configure(with:)` 加載圖片，並在 `prepareForReuse` 中重置狀態，確保展示效果一致。
 
 */




// MARK: - (v)

import UIKit

/// 用於顯示菜單頁面中的網站橫幅圖片的自訂單元格。
///
/// 此類專為菜單頁面的網站橫幅區域設計，
/// 包含一個自訂的 `MenuImageView`，用於統一管理圖片的樣式與屬性。
///
/// - 功能特色:
///   1. 支援橫幅圖片的顯示，並應用統一的樣式（如圓角與內容模式）。
///   2. 提供配置方法 `configure(with:)`，用於動態加載圖片 URL。
///   3. 在 `prepareForReuse` 中重置圖片，確保單元格重用時狀態正確。
///
/// - 使用場景:
///   適用於展示網站橫幅的 `UICollectionView` 單元格，
///   通常由 `MenuCollectionHandler` 配置並管理。
class MenuWebsiteBannerImageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MenuWebsiteBannerImageCell"
    
    // MARK: - UI Elements
    
    /// 用於顯示網站橫幅的圖片視圖。
    private let websiteBannerImageView = MenuImageView(contentMode: .scaleToFill, cornerRadius: 10)
    
    
    // MARK: - Initializer
    
    /// 初始化單元格。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置單元格的視圖層級與佈局。
    ///
    /// - 將 `websiteBannerImageView` 添加到內容視圖中。
    /// - 設置其約束，確保圖片視圖填滿整個單元格。
    private func setupViews() {
        contentView.addSubview(websiteBannerImageView)
        NSLayoutConstraint.activate([
            websiteBannerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            websiteBannerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            websiteBannerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            websiteBannerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    /// 配置單元格以顯示指定的圖片 URL。
    ///
    /// 使用 Kingfisher 加載圖片，並應用到 `websiteBannerImageView`。
    ///
    /// - Parameter imageURL: 要加載的圖片 URL。
    func configure(with imageURL: URL) {
        websiteBannerImageView.kf.setImage(with: imageURL, placeholder: UIImage.from(color: .lightWhiteGray))
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置單元格狀態。
    ///
    /// 清空圖片，確保重用時不會殘留舊的圖片內容。
    override func prepareForReuse() {
        super.prepareForReuse()
        websiteBannerImageView.image = nil 
    }
    
}
