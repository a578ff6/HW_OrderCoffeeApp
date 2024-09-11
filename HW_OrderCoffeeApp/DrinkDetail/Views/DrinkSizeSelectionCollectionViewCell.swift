//
//  DrinkSizeSelectionCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/14.
//


/*
 ## DrinkSizeSelectionCollectionViewCell：

    * 功能： 用來展示飲品尺寸選擇的 UICollectionViewCell，按鈕會顯示不同尺寸的選項，並可切換選中狀態。
 
    * UI 設計： 使用一個圓角邊框按鈕作為顯示尺寸的主要介面元素，按鈕會根據是否選中變換外觀。

    * 自定義屬性：
        - size： 儲存按鈕的尺寸文字，當尺寸被設置時會自動更新按鈕標題。
        - isSelectedSize： 按鈕的選中狀態，根據選中狀態更新按鈕外觀。
        - sizeSelected： 尺寸選擇的閉包，當按鈕被點擊時傳遞選中的尺寸。

    * 動態外觀更新：
        - updateButtonTitle()：更新按鈕顯示的文字。
        - updateButtonAppearance()：根據選中狀態調整按鈕的邊框顏色與背景顏色。

    * 主要流程：
     
        1. 按鈕點擊行為：
            - 當按鈕被點擊時，透過 sizeButtonTapped 方法觸發 sizeSelected 閉包，將選中的尺寸名稱傳遞給外部進行處理，並添加彈簧動畫。

        2. 外觀更新：
            - 當 size 或 isSelectedSize 的值變化時，分別透過 updateButtonTitle 和 updateButtonAppearance 來更新按鈕的標題與外觀。
     
        3. 重置狀態：
            - 在 prepareForReuse() 中重置 isSelectedSize 為 false 並清除 size，避免 cell 重用時顯示上次選擇的狀態。

    * 關鍵方法：
        - configure(with:isSelected:)： 設定按鈕顯示的尺寸名稱及其選中狀態。
        - createButton()：封裝按鈕的建立邏輯，保持按鈕的初始狀態一致性。
        - sizeButtonTapped()：當按鈕被點擊時，觸發閉包並處理點擊邏輯。
 
 -----------------------------------------------------------------------------------------------------------------------------------------
 
 ## DrinkSizeSelectionCollectionViewCell 和 DrinkOrderOptionsCollectionViewCell 狀態更新的區別

    & DrinkSizeSelectionCollectionViewCell 需要依賴 DrinkDetailViewController 刷新狀態的原因：
        - 共享狀態：飲品的尺寸選擇是多選一的情境，只有一個尺寸能被選中。當用戶點擊某個尺寸時，需保證其他所有尺寸按鈕的狀態都要被取消選中。
        - 集中管理：DrinkDetailViewController 負責管理當前選中的尺寸（即 selectedSize），這樣能保證狀態的統一性與一致性。
        - 狀態變更的觸發：當選中的尺寸改變後，DrinkDetailViewController 會觸發 refreshSizeSelectionButton 來更新尺寸按鈕的狀態，確保正確的選中顯示。

    & DrinkOrderOptionsCollectionViewCell 可以自行處理狀態更新的原因
        - 獨立狀態：按鈕的狀態只取決於是否處於編輯模式（isEditingOrderItem），不會影響其他 cell，因此可以獨立於 cell 自行更新狀態。
        - 簡單的狀態切換：該按鈕的狀態是局部且單獨的，不需要與其他 cell 共享狀態，因此不需要依賴外部的管理。
 
    & 兩者的關鍵區別
        - 尺寸選擇：這是一個多選一的全局狀態，必須由 DrinkDetailViewController 管理，確保其他 cell 同步更新。
        - 訂單按鈕：這是一個單一獨立的狀態，可以在 cell 內自行處理更新。

 */


// MARK: - 完全使用閉包（重構）


import UIKit

/// 展示飲品尺寸選擇的 CollectionViewCell
class DrinkSizeSelectionCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DrinkSizeSelectionCollectionViewCell"
    
    // MARK: - Properties
    
    /// 儲存按鈕顯示的尺寸文字
    var size: String? {
        didSet {
            updateButtonTitle()
        }
    }
    
    /// 儲存按鈕是否為選中狀態
    var isSelectedSize: Bool = false {
        didSet {
            updateButtonAppearance()
        }
    }
    
    /// 點擊尺寸按鈕時觸發的閉包，用於傳遞選中的尺寸。
    var sizeSelected: ((String) -> Void)?
    
    // MARK: - UI Elements
    
    /// 尺寸選擇的按鈕
    private let sizeButton = createButton()
    
    // MARK: - Initializers
    
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
        contentView.addSubview(sizeButton)
        sizeButton.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            sizeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            sizeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            sizeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            sizeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    
    // MARK: - Factory Methods
    
    private static func createButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray.cgColor
        return button
    }
    
    // MARK: - Action Methods

    /// 按鈕被點擊時觸發事件，將選中尺寸傳遞出去並增加彈簧動畫效果
    @objc private func sizeButtonTapped(_ sender: UIButton) {
        guard let size = size else { return }
        sizeSelected?(size)                                  // 傳遞選中的尺寸
        sizeButton.addSpringAnimation()
    }
    
    // MARK: - UI Update Methods

    /// 更新按鈕標題
    private func updateButtonTitle() {
        sizeButton.setTitle(size, for: .normal)
    }
    
    /// 更新按鈕外觀根據選中狀態
    private func updateButtonAppearance() {
        sizeButton.layer.borderColor = isSelectedSize ? UIColor.deepBrown.cgColor : UIColor.systemGray.cgColor
        sizeButton.backgroundColor = isSelectedSize ? UIColor.deepGreen.withAlphaComponent(0.2) : UIColor.clear
    }
    
    // MARK: - Configure Method
    
    /// 設置按鈕的尺寸和選中狀態
    func configure(with size: String, isSelected: Bool) {
        self.size = size
        self.isSelectedSize = isSelected         
    }
    
    // MARK: - Lifecycle Methods
    
    /// 重置 cell 的狀態，防止重複使用時數據錯誤
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelectedSize = false
    }
    
}
