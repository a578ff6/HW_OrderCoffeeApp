//
//  EditOrderItemSizeSelectionCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/25.
//

import UIKit

/// `EditOrderItemSizeSelectionCollectionViewCell`
///
/// 用於顯示飲品尺寸的選擇項目，每個 Cell 包含一個尺寸按鈕，點擊後可觸發尺寸選擇的回調。
/// 支援根據選中狀態動態更新按鈕外觀，提供流暢的交互體驗。
///
/// ### 功能說明
/// - 顯示飲品尺寸選擇按鈕。
/// - 點擊按鈕時，回傳所選尺寸並觸發動畫效果。
/// - 支援動態更新按鈕樣式，根據選中狀態改變外觀。
class EditOrderItemSizeSelectionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Reuse Identifier
    
    /// Cell 的重用識別碼
    static let reuseIdentifier = "EditOrderItemSizeSelectionCollectionViewCell"
    
    // MARK: - Properties
    
    /// 儲存當前尺寸的字串
    private var size: String?
    
    /// 點擊尺寸按鈕時觸發的閉包，用於傳遞選中的尺寸
    var sizeSelected: ((String) -> Void)?
    
    // MARK: - UI Elements
    
    /// 尺寸選擇按鈕，提供圓角、填充顏色與動態外觀
    private let sizeButton = EditOrderItemSizeButton(cornerStyle: .small, baseBackgroundColor: .lightWhiteGray, baseForegroundColor: .black)
    
    // MARK: - Initializers
    
    /// 初始化方法，設置視圖與行為
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        configureTargets()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置尺寸按鈕的佈局與樣式
    private func setupView() {
        contentView.addSubview(sizeButton)
        
        NSLayoutConstraint.activate([
            sizeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            sizeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            sizeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            sizeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    /// 配置按鈕的點擊行為
    ///
    /// - 為按鈕添加觸發事件，處理點擊後的回調與動畫。
    private func configureTargets() {
        sizeButton.addTarget(self, action: #selector(sizeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Methods
    
    /// 按鈕被點擊時觸發事件，傳遞選中尺寸並觸發動畫效果
    @objc private func sizeButtonTapped() {
        guard let size = size else { return }
        sizeSelected?(size)
        sizeButton.addSpringAnimation()
    }
    
    // MARK: - Configure Method
    
    /// 配置 Cell 的尺寸與選中狀態
    ///
    /// - Parameters:
    ///   - size: 尺寸文字
    ///   - isSelected: 是否為選中狀態
    /// - 更新按鈕的文字內容與選中狀態的外觀。
    func configure(with size: String, isSelected: Bool) {
        self.size = size
        sizeButton.setTitle(size, for: .normal)
        sizeButton.updateAppearance(isSelected: isSelected)
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置 Cell 的狀態，防止重用時資料錯誤
    override func prepareForReuse() {
        super.prepareForReuse()
        sizeButton.updateAppearance(isSelected: false)
    }
    
}
