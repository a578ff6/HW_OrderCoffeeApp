//
//  OrderTermsMessageCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/12.
//

// MARK: - OrderTermsMessageCell 筆記
/**
 
 ## OrderTermsMessageCell 筆記

 ---

 * What
 
 - `OrderTermsMessageCell` 是一個自訂的 `UICollectionViewCell`，專門用於顯示訂單規範訊息，包含以下內容：
 
 1. 標題 (`titleLabel`)：顯示主要提示文字（例如「Please confirm and submit your order」）。
 2. 規範訊息 (`termsMessageTextView`)：靜態的條款與政策文字，支援超連結功能（如 `refund policy` 和 `privacy policy`）。
 3. 垂直排列的 StackView (`orderTermsStackView`)：包含標題與規範訊息，負責管理子視圖的佈局。

 -` 該類別的主要用途：`
 
    - 在訂單確認頁面中，向用戶展示訂單條款與政策的訊息。

 ---

 * Why

 1. 模組化設計
 
 - 通過獨立的 `UICollectionViewCell`，可以將訂單規範訊息的 UI 與邏輯從其他部分分離，便於重用與維護。

 2. 清晰的層次結構
 
 - 使用 `OrderCustomerDetailsLabel` 和 `OrderCustomerDetailsTermsMessageTextView` 等專屬類別，簡化內部組件的初始化與樣式設置。
 - 使用 `StackView` 統一管理子視圖的佈局，減少冗餘的佈局代碼。

 3.使用場景
 
 - 訂單確認頁面：展示提示用戶確認訂單的條款與政策。
 - 條款頁面的一部分：作為條款和條件的展示模組。

 ---

 * How

 1. 結構與功能
 
 - 標題 (`titleLabel`)
   - 使用 `OrderCustomerDetailsLabel` 顯示標題文字，字體樣式為粗體且尺寸適中（18px）。

 - 規範訊息 (`termsMessageTextView`)
   - 使用 `OrderCustomerDetailsTermsMessageTextView` 顯示條款文字，支援超連結，並設置不可編輯和不可滾動。

 - 垂直 StackView (`orderTermsStackView`)
   - 包含 `titleLabel` 和 `termsMessageTextView`，用於統一管理垂直方向的佈局與間距（6px）。

 - 視圖配置與佈局
   - 通過 `setupView` 方法，將 `StackView` 添加到 `contentView` 並設置邊距，確保內容居中並適配屏幕。

 ---

 2. 關鍵代碼解析

 1. 初始化子視圖
 
    - 初始化時，配置 `titleLabel` 和 `termsMessageTextView`，並將它們添加到 `orderTermsStackView` 中：
      ```swift
      private func setupView() {
          orderTermsStackView.addArrangedSubview(titleLabel)
          orderTermsStackView.addArrangedSubview(termsMessageTextView)
          contentView.addSubview(orderTermsStackView)
      }
      ```

 2. StackView 的佈局
 
    - 使用 Auto Layout 設置 StackView 與 Cell 邊緣的間距：
 
      ```swift
      NSLayoutConstraint.activate([
          orderTermsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
          orderTermsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
          orderTermsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
          orderTermsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
      ])
      ```

 3. 組件重用
 
    - 標題和訊息使用專屬類別進行初始化，提升代碼的重用性和一致性：
 
      ```swift
      private let titleLabel = OrderCustomerDetailsLabel(
          title: "Please confirm and submit your order",
          font: .systemFont(ofSize: 18, weight: .semibold),
          textColor: .black
      )
      private let termsMessageTextView = OrderCustomerDetailsTermsMessageTextView()
      ```
 */



import UIKit

/// 用於顯示`訂單規範訊息`
class OrderTermsMessageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderTermsMessageCell"
    
    // MARK: - UI Elements
    
    /// 大標題
    private let titleLabel = OrderCustomerDetailsLabel(text: "Please confirm and submit your order", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    
    /// 訊息文字
    private let termsMessageTextView = OrderCustomerDetailsTermsMessageTextView()
    
    /// 包含標題和訊息的 StackView
    private let orderTermsStackView = OrderCustomerDetailsStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置視圖和佈局
    private func setupView() {
        orderTermsStackView.addArrangedSubview(titleLabel)
        orderTermsStackView.addArrangedSubview(termsMessageTextView)
        
        contentView.addSubview(orderTermsStackView)
        NSLayoutConstraint.activate([
            orderTermsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            orderTermsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            orderTermsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            orderTermsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
}
