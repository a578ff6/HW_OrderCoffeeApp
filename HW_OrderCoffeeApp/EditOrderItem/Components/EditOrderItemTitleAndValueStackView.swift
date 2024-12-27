//
//  EditOrderItemTitleAndValueStackView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//

import UIKit

/// `EditOrderItemTitleAndValueStackView`
///
/// 自訂的 StackView，用於在 `編輯飲品訂單項目` 展示`標題`與`數值`之間的結構化資訊，並透過`虛線`視圖進行分隔。
/// - 支援靈活配置標題與數值，適用於顯示多種飲品屬性（例如價格、卡路里、咖啡因含量等）。
/// - 使用 `DottedLineView` 提供清晰的視覺分隔效果，增強資訊的可讀性與結構化。
class EditOrderItemTitleAndValueStackView: UIStackView {

    // MARK: - Initializer

    /// 初始化堆疊視圖，並設定標題與數值
    /// - Parameters:
    ///   - titleLabel: 用於顯示屬性名稱的標籤，例如「價格」、「卡路里」。
    ///   - valueLabel: 用於顯示屬性值的標籤，例如「$100」、「50卡」。
    init(titleLabel: UILabel, valueLabel: UILabel) {
        super.init(frame: .zero)
        configureStackView()
        setupSubviews(titleLabel: titleLabel, valueLabel: valueLabel)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 配置 StackView 的基本屬性
    ///
    /// 設定堆疊方向為水平、間距、對齊方式，以及分佈規則，確保子視圖在視圖中正確排列。
    private func configureStackView() {
        axis = .horizontal
        spacing = 6
        alignment = .center
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 配置子視圖，包括標題、虛線分隔、數值
    ///
    /// - Parameters:
    ///   - titleLabel: 屬性名稱的標籤。
    ///   - valueLabel: 屬性值的標籤。
    private func setupSubviews(titleLabel: UILabel, valueLabel: UILabel) {
        let dottedLineView = createDottedLineView()
        addArrangedSubview(titleLabel)
        addArrangedSubview(dottedLineView)
        addArrangedSubview(valueLabel)

        // 設定內容壓縮優先級，確保標籤正常顯示
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    /// 創建虛線分隔視圖
    ///
    /// - Returns: 配置完成的虛線視圖，作為標題與數值間的分隔線。
    private func createDottedLineView() -> UIView {
        let dottedLineView = EditOrderItemDottedLineView()
        dottedLineView.translatesAutoresizingMaskIntoConstraints = false
        dottedLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return dottedLineView
    }
}
