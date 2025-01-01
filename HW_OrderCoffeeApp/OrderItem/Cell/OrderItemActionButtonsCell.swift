//
//  OrderItemActionButtonsCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/6.
//

// MARK: - 初期想法
/**
 
 ## 初期想法：
 
` * PS:`
 
 一開始只打算設置 `proceedButton` 進入到下一個頁面去填寫詳細資料。
 雖然 `OrderItemCollectionViewCell` 有提供刪除「個別」項目的能力，但是考量到如果是訂單飲品項目較多的時候，那設置一個 `clearButton` 來做清空「整個訂單項目」的行為，在操作上會更方便。
 也因此讓我開始思考，proceedButton 與 clearButton 是否應該放在同一個 Cell 中。
 
 ---------------------
 
 * 關於 `proceedButton` & `clearButton` 這兩個按鈕是否應該放在同一個 `OrderItemActionButtonsCell` 還是分成兩個 `UICollectionViewCell`：
 
    - 如果「繼續下一步」和「清空訂單」的行為密切相關，例如都屬於結帳步驟的一部分，那麼將它們放在同一個 UICollectionViewCell 中並使用 UIStackView 來管理是比較合理的。
 
    - 如果這些按鈕的行為相對獨立，或者清空訂單的功能更傾向於「管理」而不是「結帳」，那麼將它們分別放置在不同的 UICollectionViewCell 中會讓架構更清晰，每個 Cell 的責任更單一。
 
    - 基於需求和界面整體的一致性，我在 OrderItemActionButtonsCell 中添加 clearButton，並使用 UIStackView 來管理這些按鈕。這樣會使結帳和清空訂單的功能更一致地呈現在用戶面前，也更加符合結帳流程的整體設計。
 
 ---------------------

 `* 對於添加「清空訂單」的按鈕，有以下兩種方式：`

    `1. 在 OrderItemActionButtonsCell 中添加 UIButton：`
    
    - 直接在現有的 `OrderItemActionButtonsCell` 裡添加另一個按鈕來實現「清空訂單」的功能，並使用 UIStackView 來管理這兩個按鈕的布局。
    - 這樣的好處是可以將兩個按鈕整合到同一個 Cell 中，簡化 Collection View 的結構，使 UI 更加一致和整潔。

    `2. 使用一個單獨的 UICollectionViewCell 來處理清空訂單的按鈕`
 
    - 另一個方法是為「清空訂單」按鈕創建一個獨立的 UICollectionViewCell。
    - 這樣可以使 `OrderItemActionButtonsCell` 的責任更加單一，並且在處理清空訂單的相關行為時可以獨立擴展。
 
 ---------------------

 `* 評估依據：`
 
    `1. 功能性邏輯和交互設計：`
    
    - `Proceed Button（進入下一步按鈕）：`
        - proceedButton 的主要作用是幫助使用者進入下一個操作步驟，所以它應該只有在有訂單項目的情況下才能啟用。
        - 如果沒有訂單項目，這個按鈕應該處於不可用狀態，以免使用者進行無效操作。
 
    - `Clear Button（清空訂單按鈕）：`
        - clearButton 的作用是清空所有訂單項目，如果沒有訂單項目時，點擊這個按鈕應該彈出警告，告知使用者訂單已經為空。
        - 因此，這個按鈕的設計需要考慮到當訂單項目數量為零的情況下，給予使用者相應的提示。
 
    `2.對應的設計選擇：`
 
    - 放在同一個 Cell 中：
        - 如果打算在同一個操作界面上為使用者提供進一步操作的選項（例如在下單之前可以選擇清空或繼續），那麼把這兩個按鈕放在同一個 OrderItemActionButtonsCell 中是合適的。
        - 這樣可以讓使用者很清楚地看到兩個選擇之間的關係。
 
    - 尤其是當這兩個按鈕的操作邏輯相輔相成時，比如：
        - 如果訂單項目存在，proceedButton 可用並且用於進入下一步。
        - 如果使用者決定不進行下單，可以選擇 clearButton 清空訂單。
        - 在這種情況下，這兩個按鈕放在同一個 Cell 中可以讓界面更加直觀且減少界面切換，適合“決策點”的場景。
 
    `3. 放在不同的 Cells 中：`

    - 如果這兩個操作的上下文比較不同，並且希望將這些操作分開，例如在界面上更清晰地標示出清空訂單和繼續操作的不同屬性，可以考慮將它們放在不同的 Cells 中。
    - 如果希望把“清空訂單”這個操作視為一種“危險操作”（例如，可能會引起數據丟失或使用者需要謹慎執行的行為），將它分開顯示並設置不同的樣式，這樣使用者在進行這個操作時會更明確。
 
 ---------------------

 `* 綜合考量：`
 
    `1. 考慮使用者體驗和簡化操作：`

    - 如果這兩個操作有明顯的邏輯順序（比如清空訂單和進入下一步），那麼放在同一個 Cell 中並通過 UIStackView 來進行按鈕佈局會是個更好的選擇。
    - 特別是如果打算在同一個界面上顯示出所有的操作選項，放在同一個 Cell 可以幫助使用者一目了然地看到他們的可選擇行動。
    - 這樣也能減少界面上的複雜性，保持一致的操作流程，讓 OrderItemActionButtonsCell 負責所有訂單操作的選擇點。
 
    `2. 按鈕的互動設計：`
 
    _ 當訂單項目不存在時，proceedButton 應該顯示為灰色並禁用（isEnabled = false），而且不應觸發進一步操作。
    - 而 clearButton 仍然保持可用，但需要在點擊後檢查訂單項目是否存在，並在無項目時顯示一個警告提醒使用者。
 */


// MARK: - OrderItemActionButtonsCell 筆記
/**
 
 ## OrderItemActionButtonsCell 筆記

 `* What`
 
 `OrderItemActionButtonsCell` 是一個自訂的 `UICollectionViewCell`，專為訂單操作設計。其主要功能是展示兩個按鈕：
 
 1. Proceed Button（繼續按鈕）：進入下一個步驟，例如填寫顧客資料。
 2. Clear Button（清空按鈕）：清空目前所有的訂單項目。

 該 Cell 使用垂直排列的 `StackView`，統一管理按鈕的視覺樣式和布局，並提供按鈕的點擊回呼，讓外部可處理具體的邏輯。

 ---

 `* Why`
 
 設計這個 Cell 的原因：
 
 1. 提高視覺一致性：透過使用自訂按鈕 `OrderItemActionButton` 和 `StackView`，確保所有按鈕的樣式和行為在各個情境中保持一致。
 2. 簡化業務邏輯：將按鈕的外觀與行為封裝在 Cell 中，外部僅需關注點擊回呼即可，降低耦合度。
 3. 易於維護：按鈕的狀態更新（如啟用與禁用）集中在一個方法中處理，方便擴展與調整。
 4. 提升可讀性：使用 `OrderItemActionButton` 確保程式碼結構清晰，具備彈性。

 ---

 `* How`
 
 以下是該 Cell 的設計與使用方法：

 1. 視圖結構
 
    - 使用一個垂直的 `StackView`，將 `Proceed Button` 和 `Clear Button` 依序排列。
    - 每個按鈕的高度固定，防止佈局因內容而變化。

 2. 按鈕點擊行為
 
    - 點擊 **Proceed Button** 時，觸發動畫後，執行回呼 `onProceedButtonTapped`。
    - 點擊 **Clear Button** 時，觸發動畫後，執行回呼 `onClearButtonTapped`。

 3. 按鈕狀態更新
 
    - 當訂單為空時，按鈕會設為不可點擊，透明度降低。
    - 使用 `updateActionButtonsState(isOrderEmpty:)` 方法來根據訂單狀態動態更新按鈕。

 4. 適用場景
 
    - 訂單結算頁面或操作頁面，需進行「繼續」或「清空訂單」的行為。

 */



// MARK: - 設置清空訂單

import UIKit

/// `OrderItemActionButtonsCell` 是一個自訂的 `UICollectionViewCell`，
/// 用於展示「繼續」與「清空訂單」按鈕。
///
/// ### 功能說明
/// - 此 Cell 包含兩個按鈕：
///   1. `proceedButton`：進入下一個步驟（例如顧客資料填寫）。
///   2. `clearButton`：清空所有訂單項目。
/// - 提供按鈕點擊的回呼（Closure），讓外部處理具體的行為邏輯。
/// - 支援動態更新按鈕的啟用狀態（根據訂單是否為空）。
///
/// ### 結構說明
/// - 使用垂直的 `StackView` 排列按鈕，確保視圖結構清晰且易於調整。
/// - 使用自訂的 `OrderItemActionButton`，統一按鈕樣式與功能。
///
/// ### 適用情境
/// - 訂單結算頁面，讓用戶快速操作。
class OrderItemActionButtonsCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    /// Cell 的重複使用識別碼
    static let reuseIdentifier = "OrderItemActionButtonsCell"
    
    // MARK: - Callback Closure
    
    /// 「繼續」按鈕點擊事件的回呼
    var onProceedButtonTapped: (() -> Void)?
    
    /// 「清空訂單」按鈕點擊事件的回呼
    var onClearButtonTapped: (() -> Void)?
    
    // MARK: - UI Elements
    
    /// 繼續到下一步的按鈕
    private let proceedButton = OrderItemActionButton(title: "Proceed", font: .systemFont(ofSize: 18, weight: .semibold), backgroundColor: .deepGreen, titleColor: .white, iconName: "arrowshape.right.fill")
    
    /// 清空訂單項目的按鈕
    private let clearButton = OrderItemActionButton(title: "Clear Order", font: .systemFont(ofSize: 18, weight: .semibold), backgroundColor: .lightWhiteGray, titleColor: .white, iconName: "trash.fill")
    
    /// 包含按鈕的堆疊視圖
    private let buttonStackView = OrderItemStackView(axis: .vertical, spacing: 12, alignment: .fill, distribution: .fillEqually)
    
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
    
    /// 主設置方法，包含視圖層級、布局約束及事件綁定
    private func setupView() {
        setupStackViewHierarchy()
        setupConstraints()
        setupButtonActions()
    }
    
    /// 設置按鈕與 StackView 的層級結構
    ///
    /// - 將 `proceedButton` 和 `clearButton` 添加到 `buttonStackView`。
    /// - 將 `buttonStackView` 添加到 `contentView`。
    private func setupStackViewHierarchy() {
        buttonStackView.addArrangedSubview(proceedButton)
        buttonStackView.addArrangedSubview(clearButton)
        contentView.addSubview(buttonStackView)
    }
    
    /// 配置 StackView 和按鈕的布局約束
    ///
    /// - 設置 `buttonStackView` 與 `contentView` 的邊距。
    /// - 設置按鈕的固定高度。
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            proceedButton.heightAnchor.constraint(equalToConstant: 55),
            clearButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    /// 綁定按鈕的點擊事件
    ///
    /// - 綁定 `proceedButton` 的點擊事件，觸發 `onProceedButtonTapped`。
    /// - 綁定 `clearButton` 的點擊事件，觸發 `onClearButtonTapped`。
    private func setupButtonActions() {
        proceedButton.addTarget(self, action: #selector(handleProceedButtonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(handleClearButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Handler
    
    /// 當`繼續`按鈕被點擊時呼叫
    ///
    /// - 觸發彈簧動畫後，執行 `onProceedButtonTapped` 回呼。
    @objc private func handleProceedButtonTapped() {
        proceedButton.addSpringAnimation(scale: 1.05) {_ in
            self.onProceedButtonTapped?()
        }
    }
    
    /// 當`清空訂單`按鈕被點擊時呼叫
    ///
    /// - 觸發彈簧動畫後，執行 `onClearButtonTapped` 回呼。
    @objc private func handleClearButtonTapped() {
        clearButton.addSpringAnimation(scale: 1.05) {_ in
            self.onClearButtonTapped?()
        }
    }
    
    // MARK: - Update Button State
    
    /// 更新`清空按鈕`和`繼續按鈕`的啟用狀態
    ///
    /// - 當訂單為空時，按鈕不可點擊，並降低透明度。
    /// - 當訂單不為空時，按鈕可正常使用。
    /// - Parameters:
    ///   - isOrderEmpty: 當前訂單是否為空。
    func updateActionButtonsState(isOrderEmpty: Bool) {
        proceedButton.updateState(isEnabled: !isOrderEmpty)
        clearButton.updateState(isEnabled: !isOrderEmpty)
    }
    
}

