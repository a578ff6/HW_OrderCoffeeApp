//
//  OrderActionButtonsCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/6.
//

/*
 
 PS:
 一開始只打算設置 proceedButton 進入到下一個頁面去填寫詳細資料。
 雖然 OrderItemCollectionViewCell 有提供刪除「個別」項目的能力，但是考量到如果是訂單飲品項目較多的時候，那設置一個 clearButton 來做清空「整個訂單項目」的行為，在操作上會更方便。
 也因此讓我開始思考，proceedButton 與 clearButton 是否應該放在同一個 Cell 中。
 
 -----------------------------------------------------------------------------------
 
 ## 關於 proceedButton & clearButton 這兩個按鈕是否應該放在同一個 OrderActionButtonsCell 還是分成兩個 UICollectionViewCell：
 
    - 如果「繼續下一步」和「清空訂單」的行為密切相關，例如都屬於結帳步驟的一部分，那麼將它們放在同一個 UICollectionViewCell 中並使用 UIStackView 來管理是比較合理的。
 
    - 如果這些按鈕的行為相對獨立，或者清空訂單的功能更傾向於「管理」而不是「結帳」，那麼將它們分別放置在不同的 UICollectionViewCell 中會讓架構更清晰，每個 Cell 的責任更單一。
 
    - 基於需求和界面整體的一致性，我在 OrderActionButtonsCell 中添加 clearButton，並使用 UIStackView 來管理這些按鈕。這樣會使結帳和清空訂單的功能更一致地呈現在用戶面前，也更加符合結帳流程的整體設計。
 
 &. 對於添加「清空訂單」的按鈕，有以下兩種方式：

    1. 在 OrderActionButtonsCell 中添加 UIButton：
    
        - 直接在現有的 OrderActionButtonsCell 裡添加另一個按鈕來實現「清空訂單」的功能，並使用 UIStackView 來管理這兩個按鈕的布局。
        - 這樣的好處是可以將兩個按鈕整合到同一個 Cell 中，簡化 Collection View 的結構，使 UI 更加一致和整潔。

    2. 使用一個單獨的 UICollectionViewCell 來處理清空訂單的按鈕
 
        - 另一個方法是為「清空訂單」按鈕創建一個獨立的 UICollectionViewCell。
        - 這樣可以使 OrderActionButtonsCell 的責任更加單一，並且在處理清空訂單的相關行為時可以獨立擴展。
 
 -----------------------------------------------------------------------------------

 &. 評估依據：
 
    1. 功能性邏輯和交互設計：
    
    * Proceed Button（進入下一步按鈕）：
        - proceedButton 的主要作用是幫助使用者進入下一個操作步驟，所以它應該只有在有訂單項目的情況下才能啟用。
        - 如果沒有訂單項目，這個按鈕應該處於不可用狀態，以免使用者進行無效操作。
 
    * Clear Button（清空訂單按鈕）：
        - clearButton 的作用是清空所有訂單項目，如果沒有訂單項目時，點擊這個按鈕應該彈出警告，告知使用者訂單已經為空。
        - 因此，這個按鈕的設計需要考慮到當訂單項目數量為零的情況下，給予使用者相應的提示。
 
 &. 對應的設計選擇：
 
    1. 放在同一個 Cell 中：

    * 如果打算在同一個操作界面上為使用者提供進一步操作的選項（例如在下單之前可以選擇清空或繼續），那麼把這兩個按鈕放在同一個 OrderActionButtonsCell 中是合適的。
      這樣可以讓使用者很清楚地看到兩個選擇之間的關係。
 
    * 尤其是當這兩個按鈕的操作邏輯相輔相成時，比如：
        - 如果訂單項目存在，proceedButton 可用並且用於進入下一步。
        - 如果使用者決定不進行下單，可以選擇 clearButton 清空訂單。
        - 在這種情況下，這兩個按鈕放在同一個 Cell 中可以讓界面更加直觀且減少界面切換，適合“決策點”的場景。
 
    2. 放在不同的 Cells 中：

    * 如果這兩個操作的上下文比較不同，並且希望將這些操作分開，例如在界面上更清晰地標示出清空訂單和繼續操作的不同屬性，可以考慮將它們放在不同的 Cells 中。
    
    * 如果希望把“清空訂單”這個操作視為一種“危險操作”（例如，可能會引起數據丟失或使用者需要謹慎執行的行為），將它分開顯示並設置不同的樣式，這樣使用者在進行這個操作時會更明確。
 
 &. 綜合考量：
 
    1. 考慮使用者體驗和簡化操作：

    * 如果這兩個操作有明顯的邏輯順序（比如清空訂單和進入下一步），那麼放在同一個 Cell 中並通過 UIStackView 來進行按鈕佈局會是個更好的選擇。
 
    * 特別是如果打算在同一個界面上顯示出所有的操作選項，放在同一個 Cell 可以幫助使用者一目了然地看到他們的可選擇行動。

    * 這樣也能減少界面上的複雜性，保持一致的操作流程，讓 OrderActionButtonsCell 負責所有訂單操作的選擇點。
 
 &. 按鈕的互動設計：
 
    * 當訂單項目不存在時，proceedButton 應該顯示為灰色並禁用（isEnabled = false），而且不應觸發進一步操作。

    * 而 clearButton 仍然保持可用，但需要在點擊後檢查訂單項目是否存在，並在無項目時顯示一個警告提醒使用者。
 
 -----------------------------------------------------------------------------------

 ## OrderActionButtonsCell：
 
    * 功能：
        - 顯示兩個操作按鈕，允許使用者「繼續到顧客資料的下一步」或「清空訂單」。
 
    * 按鈕設置：
        - 使用 UIButton.Configuration 配置按鈕，包括標題、背景顏色、字體樣式和 SF Symbol 圖標。
        - 圖標位於按鈕的右側，標題和圖標之間設置間距。
        - proceedButton 和 clearButton 各自用於進入下一步或清空訂單。
 
    * 回調閉包：
        - 提供 onProceedButtonTapped 和 onClearButtonTapped 兩個閉包，用來在按鈕點擊時處理對應的行為。
 
    * 按鈕自定義方法：
        - 使用靜態方法 createButton() 建立按鈕，配置按鈕標題、字體、顏色和圖標，並設定使用自動佈局。
 
    * 堆疊視圖設置：
        - 使用 createStackView() 靜態方法創建 UIStackView，用於垂直排列兩個按鈕，並設置相應的間距、對齊方式及填充策略。
 
    * 按鈕狀態：
        - updateClearButtonState 更新清空按鈕的啟用狀態，並搭配改變透明度以反映按鈕的狀態。
 
    * 關於優化部分：
        - 使用 UIButton.Configuration 取代過時的屬性，imageEdgeInsets符合 iOS 新的 API 標準。
        - 此外，使用這個方式也能更方便地管理按鈕的各種屬性，例如圖標、標題、間距等，使您的代碼更簡潔且易於維護。
        - 使用 UIButton.Configuration，不再需要手動處理按鈕的點擊顏色變更（如 handleButtonTouchDown、handleButtonTouchUp 等）。因為 UIButton.Configuration 已經能夠自動管理按鈕的不同狀態下的外觀。
 */


// MARK: - 設置清空訂單

import UIKit

/// 顯示包含「繼續」和「清空訂單」按鈕的 Cell
class OrderActionButtonsCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderActionButtonsCell"
    
    // MARK: - Callback Closure
    
    var onProceedButtonTapped: (() -> Void)?
    
    var onClearButtonTapped: (() -> Void)?
    
    // MARK: - UI Elements
    
    /// 繼續到下一步的按鈕
    let proceedButton = createButton(title: "Proceed", font: UIFont.systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, titleColor: .white, iconName: "arrowshape.right.fill")
    
    /// 清空訂單項目的按鈕
    let clearButton = createButton(title: "Clear Order", font: UIFont.systemFont(ofSize: 18, weight: .semibold), backgroundColor: .lightWhiteGray, titleColor: .white, iconName: "trash.fill")
    
    /// 包含按鈕的堆疊視圖
    let buttonStackView = createStackView(axis: .vertical, spacing: 12)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtonStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設定堆疊視圖和按鈕的布局及其屬性
    private func setupButtonStackView() {
        
        buttonStackView.addArrangedSubview(proceedButton)
        buttonStackView.addArrangedSubview(clearButton)
        
        contentView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        // 每個按鈕的高度設置為固定值，防止堆疊視圖壓縮
        proceedButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        // 添加按鈕的點擊事件
        proceedButton.addTarget(self, action: #selector(handleProceedButtonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(handleClearButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Factory Method
    
    /// 建立一個帶有`圖標`和`文字`的按鈕
    private static func createButton(title: String, font: UIFont, backgroundColor: UIColor, titleColor: UIColor, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        // 使用 UIButton.Configuration 來設置按鈕外觀
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = titleColor // 設置文字顏色
        config.baseBackgroundColor = backgroundColor // 設置背景顏色
        config.image = UIImage(systemName: iconName) // 設置 SF Symbol 圖標
        config.imagePadding = 8 // 圖標和文字之間的間距
        config.imagePlacement = .trailing // 圖標顯示在文字右側
        
        // 設置字體
        var titleAttr = AttributedString(title)
        titleAttr.font = font
        config.attributedTitle = titleAttr
        
        button.configuration = config
        
        return button
    }
    
    /// 建立一個 `UIStackView`，用於`垂直`排列子視圖
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fillEqually) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Action Handler
    
    /// 當`繼續`按鈕被點擊時呼叫，進入下一個視圖
    @objc private func handleProceedButtonTapped() {
        onProceedButtonTapped?()
    }
    
    /// 當`清空訂單`按鈕被點擊時呼叫
    @objc private func handleClearButtonTapped() {
        onClearButtonTapped?()
    }
    
    // MARK: - Update Button State
    
    /// 更新清空按鈕的啟用狀態
    ///
    /// 改變透明度以反映按鈕的狀態
    func updateClearButtonState(isEnabled: Bool) {
        clearButton.isEnabled = isEnabled
        clearButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
}

