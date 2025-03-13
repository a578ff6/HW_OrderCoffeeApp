//
//  EditProfileSegmentedControl.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/5.
//

// MARK: - EditProfileSegmentedControl 筆記
/**
 
 ## EditProfileSegmentedControl 筆記
 
 `* What`
 
 - `EditProfileSegmentedControl` 是一個通用的選擇控制元件，繼承自 `UISegmentedControl`。
 - 支援接收選項列表 (`items`)，允許多場景中自定義選項。
 
 - `提供兩個核心方法`：
    - `getSelectedOption`：取得目前選中的選項。
    - `setSelectedOption`：設置當前選擇的選項，若傳入值不符合選項列表，則設為未選擇狀態。
 
 ------------------------------
 
 `* Why`
 
 `1.高可重用性：`

 - 通用元件可適應不同場景需求（如性別選擇、分類選擇、語言選擇）。
 - 減少開發和維護多個類似元件的工作量。
 
 `2.數據驅動設計：`

 - 選項列表可動態生成，避免選項硬編碼。
 - 提升靈活性與適配能力。
 
 `3.易於維護：`

 - 集中邏輯處理（如選項設置、獲取）在單一元件中，減少重複代碼。
 - 一次改進可影響所有使用場景，降低錯誤風險。
 
 `4.容錯能力：`

 - 當傳入的選項值不在預設選項中，控制元件會自動設為未選擇狀態，避免潛在錯誤。
 
 ------------------------------

 `* How`
 
 `1.初始化與選項設置：`

 - 使用` init(items:) `傳入選項列表以初始化元件。
 
 `2.獲取選項：`

 - `getSelectedOption`：返回當前選中的選項，若未選擇則返回空字串。
 
 `3.設置選項：`

 - `setSelectedOption`：
    - 傳入選項值。
    - 自動比對選項列表，若找到對應索引，設置為選中狀態。
    - 若選項不匹配，設置為未選擇狀態。

 */


import UIKit

/// 通用選擇控制元件，繼承自 `UISegmentedControl`，支持多種選項配置。
/// - 支援設置與獲取當前選中的選項，並提供容錯機制。
class EditProfileSegmentedControl: UISegmentedControl {

    // MARK: - Initializer
    
    /// 初始化通用選擇控制元件，接受選項列表作為參數。
    /// - Parameter items: 控制元件的選項列表。
    init(items: [String]) {
        super.init(items: items)
        setupControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    /// 設定基本屬性。
    private func setupControl() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Public Methods
    
    /// 獲取當前選中的選項。
    /// - Returns: 當前選中的選項，若未選擇則返回空字串。
    func getSelectedOption() -> String {
        return titleForSegment(at: selectedSegmentIndex) ?? ""
    }
    
    /// 設置當前選擇的選項。
    /// - Parameter option: 要設置的選項值。
    func setSelectedOption(_ option: String) {
        if let index = (0..<numberOfSegments).first(where: { titleForSegment(at: $0) == option }) {
            selectedSegmentIndex = index
        } else {
            selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
}
