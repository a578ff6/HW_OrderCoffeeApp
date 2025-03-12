//
//  EditProfileTableHandlerDelegate.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/4.
//

// MARK: - EditProfileTableHandlerDelegate 筆記
/**
 
 ## EditProfileTableHandlerDelegate 筆記

 `* What`
 
 - `EditProfileTableHandlerDelegate` 是一個用於主控制器與表格處理器之間進行數據和行為通信的協定。
 - 該協定的作用是保持主控制器作為數據的唯一管理者，而表格處理器僅負責界面顯示與交互邏輯。
 
 - `EditProfileTableHandlerDelegate` 是一個協定，主要提供了兩個方法：

 1.`getProfileEditModel()`：用來取得目前的個人資料模型。
 2.`updateProfileEditModel(_ model: ProfileEditModel)`：用來更新個人資料模型的數據。
 
 -----------------
 
` * Why`
 
` 1.責任分離：`

 - 主控制器專注於管理數據模型（如 `ProfileEditModel`），並處理與後端交互的邏輯。
 - 表格處理器專注於配置表格的行為和外觀，避免直接操作主控制器內部邏輯，減少耦合。
 
` 2.雙向數據同步：`

 - 主控制器通過` getProfileEditModel() `提供用戶資料給表格處理器，以配置 UI。
 - 當用戶在表格中編輯資料後，通過 `updateProfileEditModel()` 通知主控制器更新數據模型，確保數據一致性。
 
` 3.維護代碼可讀性與擴展性：`

 - 將數據操作和表格邏輯分開，有助於維護和擴展特定模塊，而不影響整體架構。
 
 -----------------
 
 `* How`
 
 `1.從主控制器獲取數據：`

 - 在 `EditProfileTableHandler` 中，通過 `getProfileEditModel() `獲取當前用戶模型，配置每個單元格的顯示內容。

 ```swift
 guard let profileEditModel = delegate?.getProfileEditModel() else { return UITableViewCell() }
 ```
 
 `2.更新主控制器的數據模型：`

 - 當用戶在單元格中編輯內容後，通過 `updateProfileEditModel() `將更改的模型回傳給主控制器。

 ```swift
 cell.onTextChanged = { [weak self] updatedText in
     guard let self = self, let updatedText = updatedText else { return }
     guard var updatedModel = self.delegate?.getProfileEditModel() else { return }
     updatedModel.fullName = updatedText
     self.delegate?.updateProfileEditModel(updatedModel)
 }
 ```
 
 -----------------
 
 `* 適用場景`
 
 - 表格處理器需要從主控制器獲取數據（例如用戶的姓名、電話等）。
 - 用戶對表格進行編輯操作（例如修改姓名或電話），需要同步更新主控制器中的數據模型。
 - 主控制器希望保持對數據的唯一控制權，而不讓表格直接修改數據。
 
 -----------------
 
 `* 總結`
 
 - `EditProfileTableHandlerDelegate` 提供了一種清晰、低耦合的數據與邏輯分層方式，適合需要頻繁同步用戶操作與數據模型的編輯場景。
 - 此調整後的協定更加專注於數據傳遞，避免了不必要的行為回調，使代碼結構更簡潔明確。
 */


// MARK: - 筆記：委託（Delegate）與閉包（Closure）的使用選擇與搭配
/**
 
 ## 筆記：委託（Delegate）與閉包（Closure）的使用選擇與搭配

 `* 委託的使用情境`

 - `適合情境:`
 
 - 委託適合於需要 `多對一` 的持續性溝通場景，特別是在需要明確角色責任的情況。

 `1. 跨模塊的雙向通信：`
 
 - 表格處理器（如 `EditProfileTableHandler`）需要與主控制器（如 `EditProfileViewController`）同步數據和行為。
 - 主控制器負責管理核心數據和後端交互，避免處理器直接操控數據。

 `2. 需要持續性的狀態同步：`
 
 - 例如：同步 `ProfileEditModel` 或觸發保存邏輯。

 `3. 模組之間低耦合性：`
 
 - 委託模式強調清晰角色分工，避免子模塊直接干涉高層級邏輯。

 `4.優勢`
 
 - 提高結構的清晰性。
 - 適合需要多個回調方法或雙向溝通的場景。
 - 易於維護和測試。

 `5.範例`
 
 目前的 `EditProfileTableHandlerDelegate` 使用委託處理雙向數據：
 ```swift
 protocol EditProfileTableHandlerDelegate: AnyObject {
     func getProfileEditModel() -> ProfileEditModel?
     func updateProfileEditModel(_ model: ProfileEditModel)
 }
 ```

 ---------------

 `* 閉包的使用情境`

 `- 適合情境`
 
 - 閉包適合用於` 一次性回調或輕量行為傳遞`，通常用於單一事件的處理。

 `1. 輕量操作：`
 
 - 適用於如按鈕點擊的事件回傳。

` 2. 單向通信：`

 - 子視圖向外部傳遞事件，但不需要外部返回狀態。

 `3. 靈活設置回調：`
 
 - 閉包可動態定義具體邏輯，適用於需要高度靈活的場景。

` 4.優勢`
 
 - 簡化代碼，降低額外定義協定的複雜度。
 - 適用於單一功能性需求，不需要額外的狀態管理。

 `5. 範例`
 
 `ProfileImageViewCell` 使用閉包處理單一事件：
 ```swift
 cell.onChangePhotoButtonTapped = { [weak self] in
     self?.delegate?.didTapChangePhotoButton()
 }
 ```

 ---------------

 `* 委託與閉包的搭配使用情境`

 `- 適合情境`
 
 - 委託與閉包可以靈活搭配，形成高效的架構。

 `1. 高層級使用委託：`
 
 - 用於模組間的核心行為同步和數據管理（如主控制器與表格處理器之間）。

 `2. 低層級使用閉包：`

 - 用於細化事件回傳（如視圖內部按鈕點擊事件）。

 `3.搭配示例`
 
` * 在 ProfileImageViewCell 使用閉包：`
 
    - 點擊按鈕後，透過閉包通知表格處理器：
    ```swift
    cell.onChangePhotoButtonTapped = { [weak self] in
        self?.delegate?.didTapChangePhotoButton()
    }
    ```

` * 在 EditProfileTableHandler 使用委託：`
 
    - 將通知邏輯交給主控制器：
    ```swift
    func didTapChangePhotoButton() {
        profileImageCoordinator?.handleChangePhotoButtonTapped { [weak self] selectedImage in
            guard let self = self else { return }
            // 更新視圖邏輯或數據
        }
    }
    ```

 ---------------

 `* 總結`

` 1.使用原則`
 
 - `高層級行為控制：`
 
 - 使用委託模式，確保數據同步與邏輯集中在主控制器或核心模組。

 -  `單一、輕量事件回調：`

 - 使用閉包簡化代碼，減少額外的協定定義。

 - `混合搭配：`
 
 - 閉包處理單一事件回傳，委託處理全局行為。

` -  統整`
 - 委託模式：適用於需要多方法或持續狀態同步的場景，強調模組角色分工。
 - 閉包模式：適用於單一事件的簡單回傳，靈活高效。
 - 搭配使用：在架構中閉包與委託搭配，是平衡靈活性與結構性的最佳選擇。
 */




import Foundation

/// `EditProfileTableHandlerDelegate` 協定，用於定義表格處理器 (`EditProfileTableHandler`) 與主視圖控制器 (`EditProfileViewController`) 之間的數據與交互接口。
///
/// - 核心功能：
///   1. 雙向數據傳遞：
///      - 提供從主控制器獲取用戶資料的方式（如姓名、電話等）。
///      - 支持用戶編輯數據後，將更改同步回主控制器的數據模型。
///   2. 統一管理交互邏輯：
///      - 表格中的用戶操作（如編輯欄位）需通過協定回傳主控制器處理，避免表格與控制器之間的耦合。
///
/// - 適用場景：
///   - 當表格處理器需要與主控制器協作完成資料同步及界面更新時，使用該協定。
protocol EditProfileTableHandlerDelegate: AnyObject {
    
    /// 取得當前的個人資料模型
    /// - 使用場景：
    ///   - 表格處理器需要從主控制器獲取當前的用戶資料，並據此配置表格每個欄位的顯示內容（如姓名、電話等）。
    /// - 回傳：
    ///   - `ProfileEditModel?`：當前的個人資料模型。
    ///     - 若用戶資料尚未加載完成，則可能回傳 `nil`。
    func getProfileEditModel() -> ProfileEditModel?
    
    
    /// 更新個人資料模型
    /// - 使用場景：
    ///   - 用戶在表格中編輯資料（如更改姓名、電話）後，通知主控制器更新對應的模型數據。
    /// - 參數：
    ///   - `model`：編輯完成後的 `ProfileEditModel`，用於同步更新主控制器中的數據。
    func updateProfileEditModel(_ model: ProfileEditModel)
    
}
