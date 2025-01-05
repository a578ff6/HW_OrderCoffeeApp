//
//  OrderCustomerNoteCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/14.
//

// MARK: - OrderCustomerNoteCell 的筆記
/**

 ## OrderCustomerNoteCell 的筆記

`* What`
 
 - `OrderCustomerNoteCell` 是一個自訂的 `UICollectionViewCell`，專門用於輸入備註或特殊需求的場景。此元件包含以下功能：

 `1. 備註輸入框：`
 
    - 支援提示文字（Placeholder）。
    - 內建字數限制，避免超過允許的字數範圍。
    - 動態樣式切換（如提示文字與輸入文字的顏色變化）。
 
 `2. 剩餘字數顯示：`
 
    - 即時顯示可輸入的剩餘字數。
    - 提供直觀的輸入提示，幫助使用者控制輸入內容。
 
 `3. 即時回調：`
 
    - 使用者輸入時會透過回調將內容及變更通知外部，方便整合與即時處理。

 -----------

 `* Why`
 
 `1. 提升使用者體驗：`
 
    - 備註輸入框提供清晰的提示文字及即時字數限制檢查，幫助使用者輸入有效且符合規範的內容。
 
` 2. 減少重複邏輯：`
 
    - 通過內建回調機制，外部僅需監聽內容變更即可更新狀態，減少額外的檢查與監聽邏輯。
 
 `3. 維持一致性：`
 
    - 該元件的設計與其他輸入框元件保持一致，確保視覺與行為的統一性。

 -----------

 `* How`
 
 `1. 初始化與佈局：`
 
 - 初始化時，通過 `setupViews` 方法建立並佈局 `characterCountLabel`（剩餘字數顯示）與 `noteTextView`（備註輸入框）。
 - 使用垂直堆疊視圖 `characterCountAndNoteStackView` 來組合這兩個子元件，並設定自適應的約束。

` 2. 動態監聽輸入變更：`
 
    - 在 `setupActions` 中綁定 `noteTextView` 的 `onContentUpdate` 回調：
      - 當使用者輸入內容變更時，更新剩餘字數標籤的文字。
      - 通知外部回調（`onNoteUpdated`）以即時處理變更的內容。

 `3. 外部使用方式：`
 
 - 初始化並註冊 `OrderCustomerNoteCell`：
 
      ```swift
      collectionView.register(OrderCustomerNoteCell.self, forCellWithReuseIdentifier: OrderCustomerNoteCell.reuseIdentifier)
      ```
 
 - 在 `UICollectionView` 的 data source 方法中使用：
 
      ```swift
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCustomerNoteCell.reuseIdentifier, for: indexPath) as! OrderCustomerNoteCell
          cell.configure(with: "預設備註內容")
          cell.onNoteUpdated = { updatedNote in
              print("備註已更新為：\(updatedNote)")
          }
          return cell
      }
      ```

 `4. 內容與樣式同步：`
 
    - 使用 `configure(with:)` 方法設置初始內容：
      - 初始化時同步計算剩餘字數。
      - 根據初始文字內容自動設置輸入框的樣式與狀態。

 -----------

` * 筆記補充`
 
 `1.使用場景：`
 
 - `OrderCustomerNoteCell` 適用於需要用戶輸入附加資訊或備註的模組化場景，例如：
   - 訂單附加需求（如特殊配送需求）。
   - 表單中對額外資訊的填寫。
   
 `2.關鍵功能：`
 
   - 提供即時的內容同步與字數限制檢查。
   - 將剩餘字數顯示與輸入框邏輯分離，保持職責單一且易於維護。
   
 `3.最佳實踐：`
 
   - 外部僅需專注於監聽 `onNoteUpdated` 回調，減少額外處理輸入框邏輯的需求。
   - 透過 `configure(with:)` 設置初始狀態，避免初始化或重用過程中狀態不一致的問題。
 
 -----------

 `* 設計考量：`

 `1. 用戶體驗：`
 
 - 使用提示文字和字數限制來引導用戶。
 - 當用戶點擊備註輸入框時，自動清除提示文字，讓用戶有直觀的輸入體驗。

 `2. 靈活性：`
 
 - `configure(with:)` 方法的設計讓 `OrderCustomerNoteCell` 可以在需要時配置現有的備註資料，使得該元件可重複使用於不同情境下。
 - `cconfigure(with:) `方法的使用，由於 `UserDetails` 中並沒有 `notes` 屬性，但 `CustomerDetails` 中有。因此，`OrderCustomerNoteCell` 的 `configure` 方法應從 `CustomerDetails` 中填充 `notes`，而不是從 `UserDetails`。
 
 `3. 即時反饋：`
 
 - 通過剩餘字數的顯示和字數限制的應用，確保用戶輸入的內容符合限制，並且不會因為輸入過多內容而影響使用者體驗。
 
 -----------

 `* 未來改進空間：`
    
 - 字數警告： 可以考慮在用戶即將超過字數限制時，改變 characterCountLabel 的顏色，以引起用戶的注意。
 - UI 改善：目前的邊框顏色是淺灰色，可以根據應用的主題顏色進一步調整，以提升視覺一致性。
 - 驗證格式：儘管備註沒有固定格式，但可以考慮提供一些快速填寫模板，方便用戶輸入常見的需求。
 - 保持文字：回到上一個視圖時，可以保留填寫的文字，而非回到該頁面時，再次清空 TextView 的 note 內容。
 
 */


import UIKit

/// 設置備註輸入框的自訂 Cell，適用於 CustomerDetails 中的備註輸入（選填），可用於填寫特殊需求或提醒事項。
///
/// ### 功能說明
/// - 備註輸入框：提供輸入備註的區域，支援提示文字、自動更新字數限制及動態樣式切換。
/// - 剩餘字數顯示：即時顯示剩餘可輸入字數，提供直觀的編輯提示。
/// - 回調通知：當使用者編輯備註時，透過回調通知外部更新內容。
///
/// ### 使用場景
/// 適用於需要輸入備註的功能模組，例如：
/// - 訂單中的特殊需求備註（例如：外送注意事項、客戶需求）。
/// - 提供與其他輸入框一致的樣式與行為。
///
/// ### 使用方式
/// 1. 初始化 Cell：在 `UICollectionView` 的 data source 方法中使用並註冊此自訂 Cell。
/// 2. 配置初始數據：使用 `configure(with:)` 設定初始內容，並自動同步字數及樣式狀態。
/// 3. 監聽輸入變更：設置 `onNoteUpdated` 回調，處理使用者輸入的即時更新。
class OrderCustomerNoteCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "OrderCustomerNoteCell"
    
    // MARK: - Callbacks
    
    /// 回調：當備註內容變更時通知外部
    ///
    /// - Parameter text: 使用者輸入的當前備註內容
    var onNoteUpdated: ((String) -> Void)?
    
    // MARK: - UI Elements
    
    /// 剩餘字數顯示標籤
    ///
    /// 用於顯示當前可輸入的剩餘字數，初始顯示為 150。
    private let characterCountLabel = OrderCustomerDetailsLabel(text: "Characters Left：150", font: .systemFont(ofSize: 14), textColor: .darkGray, numberOfLines: 1, textAlignment: .right)
    
    /// 備註輸入框
    ///
    /// 支援提示文字、字數限制、動態更新回調的自訂輸入框。
    private let noteTextView = OrderCustomerDetailsNoteTextView(placeholder: "This field is optional. Add any special requests or notes...", maxCharacters: 150)
    
    /// 包含字數標籤與備註輸入框的垂直堆疊視圖
    private let characterCountAndNoteStackView = OrderCustomerDetailsStackView(axis: .vertical, spacing: 15, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 配置 Cell 的主要 UI 元素
    ///
    /// - 建立字數顯示標籤與備註輸入框的佈局。
    private func setupViews() {
        characterCountAndNoteStackView.addArrangedSubview(characterCountLabel)
        characterCountAndNoteStackView.addArrangedSubview(noteTextView)
        contentView.addSubview(characterCountAndNoteStackView)
        
        NSLayoutConstraint.activate([
            characterCountAndNoteStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            characterCountAndNoteStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            characterCountAndNoteStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            characterCountAndNoteStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    /// 設置回調機制處理輸入框的內容變更
    ///
    /// - 綁定 `noteTextView` 的 `onContentUpdate`，同步更新剩餘字數標籤與外部回調。
    private func setupActions() {
        noteTextView.onContentUpdate = { [weak self] text, remainingCharacters in
            self?.characterCountLabel.text = "Characters Left：\(remainingCharacters)"
            self?.onNoteUpdated?(text)
        }
    }
    
    // MARK: - Configuration
    
    /// 配置 Cell 的初始數據
    ///
    /// - Parameter note: 初始備註內容
    ///
    /// 此方法會同步設定輸入框內容，並自動計算剩餘字數。
    func configure(with note: String?) {
        noteTextView.setText(note)
    }
    
}
