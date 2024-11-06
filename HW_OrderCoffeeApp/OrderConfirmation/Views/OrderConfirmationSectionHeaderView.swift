//
//  OrderConfirmationSectionHeaderView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/5.
//

// MARK: - 重點筆記：UICollectionView Header 重用與手勢問題
/**
 ## 重點筆記：UICollectionView Header 重用與手勢問題
 
 `* 問題點：`
    - 因為在測試點擊 HeaderView 展開收起區域時，發現當我滾動視圖後，會導致其他沒有被設置手勢的HeaderView也可以去點擊並且驅動到`ItemDeatils`的展開收起。
    - 在 UICollectionView 中，Supplementary View（例如 Section Header）會被重用，這意味著同一個 headerView 可能被多次使用於不同的區域中。
    - 如果沒有妥善處理重用，會導致手勢識別器多次附加到同一個 headerView 上，造成以下問題：
 
 `1.手勢重複附加：`
    - 每次重用 headerView 時，新的手勢識別器會被附加，導致該 headerView 擁有多個手勢識別器。這樣當用戶點擊標題時，會觸發多次相同的手勢回調，導致誤操作。

 `2.手勢觸發錯誤：`
    - 如果 headerView 在不同區域中被重用，但之前附加的手勢識別器未被移除，那麼點擊非預期區域的標題也可能觸發其他區域的展開/收起邏輯，造成不正確的顯示狀態。

 `* 解決方法：重置 headerView 的手勢識別器`
    - 在 prepareForReuse() 方法中清除 headerView 上所有的手勢識別器可以有效解決此問題
 
 `1.prepareForReuse() 的作用：`
    - 當 UICollectionView 重用 headerView 時，會調用 prepareForReuse() 方法。在這個方法中，重置 headerView 的狀態是很重要的，以保證新的顯示不受之前狀態的影響。

` 2.gestureRecognizers?.forEach { removeGestureRecognizer($0) } 的作用：`
    - 移除所有已附加的手勢識別器，確保每次重用 headerView 時，該視圖上沒有殘留的手勢。
    - 防止手勢識別器被多次附加，避免不正確的點擊行為。

 `* 總結`
    - `消除重複手勢的影響`：每次重用 headerView 時，移除已有的手勢，可以確保每個 headerView 只有一個手勢識別器，不會因為重複的手勢附加而導致多次觸發回調。
    - `確保手勢識別器只作用於當前的區域`：這樣可以避免點擊其他區域的 headerView 卻誤觸發到錯誤區域的展開/收起邏輯，保證了手勢行為的正確性。
 */


// MARK: - OrderConfirmationSectionHeaderView 筆記
/**
 ## OrderConfirmationSectionHeaderView 筆記

 `* 目的`
    - `OrderConfirmationSectionHeaderView` 的主要目的是為訂單確認頁面的每個區塊（Section）提供統一的標題顯示視圖。
    - 這個視圖包含標題文字和一個箭頭符號，箭頭指示區塊的展開或收起狀態，讓使用者可以一目瞭然地瞭解區塊的目前狀態並方便進行切換。

 `* 功能簡介`
    - `標題顯示`：每個區塊都有標題文字，以明確告知使用者此區塊的內容。
    - `箭頭符號`：當區塊可展開或收起時，會顯示箭頭符號（向右箭頭代表收起，向下箭頭代表展開）。這樣的符號設計有助於使用者了解目前的顯示狀態。
    - `分隔線`：標題和其他視圖之間的分隔線提供了清晰的視覺層次，提升了頁面的整體可讀性。

` * 主要功能`
 
    `1. UI 設置`
        - `標題與箭頭堆疊視圖`：標題和箭頭放在一個水平的 UIStackView 中，方便調整標題和箭頭的相對位置。
        - `分隔線`：在標題下方添加了一條分隔線，以保持視覺層次感。
 
    `2. 箭頭狀態控制`
        - 利用 `configure(with:isExpanded:showArrow:) `方法，設置標題文字、是否顯示箭頭以及箭頭的方向。
        - 根據區塊是否可展開來顯示或隱藏箭頭，確保只有那些可以展開或收起的區塊會顯示箭頭符號。

    `3. 手勢重複附加問題`
        - 在` prepareForReuse()` 方法中，移除所有附加的手勢識別器，以避免在重複使用視圖時附加多個手勢，造成手勢處理的問題。
 
 `* 使用情境`
    - 在訂單確認頁面中，每個區塊的標題和展開狀態需要有一致的呈現方式。
    - 使用這個 HeaderView 可以讓所有區塊的標題顯示保持一致，並且可以清楚地指示目前的展開狀態，使使用者能夠輕鬆地理解並操作各個區塊的內容。

 `* 問題與挑戰`
 
    `1. 手勢重複附加`
        - 當多次重用 HeaderView 時，若不先清除之前附加的手勢識別器，可能會導致重複附加手勢，從而導致手勢操作異常。
        - `解決方法`：在 prepareForReuse() 中移除所有現有手勢，確保每次只有一個手勢被正確地附加。
 
    `2. 箭頭符號顯示`
        - 只有可以展開或收起的區塊才需要顯示箭頭，對於無法展開的區塊，箭頭應隱藏，以避免使用者誤解。
        - 在 configure 方法中根據參數控制箭頭的顯示與否，確保使用者能夠清楚了解哪些區塊可以展開。
 */



// MARK: - SectionHeader、分格線

import UIKit

/// OrderConfirmationViewController 佈局使用，設置 Section Header
class OrderConfirmationSectionHeaderView: UICollectionReusableView {
    
    static let headerIdentifier = "OrderConfirmationSectionHeaderView"
    
    // MARK: - UI Elements
    
    /// 標題標籤，顯示每個區塊的名稱
    private let titleLabel = OrderConfirmationSectionHeaderView.createLabel(font: .systemFont(ofSize: 22, weight: .semibold), textColor: .black)
    /// 箭頭符號，指示區塊的展開或收起狀態
    private let arrowImageView = OrderConfirmationSectionHeaderView.createArrowImageView()
    /// 分隔線視圖，用於增強視覺上的分隔效果
    private let separatorView = OrderConfirmationSectionHeaderView.createSeparatorView(height: 2)
    
    /// 標題和箭頭的堆疊視圖，用於排列標題文字和箭頭符號
    private let titleAndArrowStackView = OrderConfirmationSectionHeaderView.createStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    
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
    
    private func setupView() {
        titleAndArrowStackView.addArrangedSubview(titleLabel)
        titleAndArrowStackView.addArrangedSubview(arrowImageView)
        
        addSubview(titleAndArrowStackView)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            titleAndArrowStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleAndArrowStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleAndArrowStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            separatorView.topAnchor.constraint(equalTo: titleAndArrowStackView.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    // MARK: - Factory Methods
    
    /// 建立標題標籤
    private static func createLabel(font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = textColor
        return label
    }
    
    /// 建立箭頭符號視圖
    /// - Returns: 配置好的箭頭符號視圖，預設為向右箭頭
    private static func createArrowImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "chevron.right")  // 預設顯示向右箭頭
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return imageView
    }
    
    /// 建立分隔線視圖
    private static func createSeparatorView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .deepGreen.withAlphaComponent(0.5)
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    /// 建立 UIStackView
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
    
    /// 設置標題文字並更新箭頭方向
    /// - Parameters:
    ///   - title: 標題文字
    ///   - isExpanded: 是否展開狀態，展開時顯示向下箭頭
    ///   - showArrow: 是否顯示箭頭，對於無法展開的區塊則隱藏
    func configure(with title: String, isExpanded: Bool, showArrow: Bool) {
        titleLabel.text = title
        arrowImageView.isHidden = !showArrow
        arrowImageView.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置視圖的狀態以便重複使用
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        arrowImageView.image = UIImage(systemName: "chevron.right")
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }  // 清除手勢識別器，避免重複附加
    }
}
