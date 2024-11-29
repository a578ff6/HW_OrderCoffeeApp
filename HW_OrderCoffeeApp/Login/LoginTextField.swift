//
//  LoginTextField.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/28.
//


// MARK: - LoginTextField 與 BottomLineTextField 關聯性筆記
/**

 ## LoginTextField 與 BottomLineTextField 關聯性筆記

 `* What - 什麼是 BottomLineTextField 和 LoginTextField`
 
 - `BottomLineTextField`：
   - 是一個自訂的 `UITextField`，擁有底線樣式並支援右側靜態或交互的圖標功能。
   - 右側按鈕可以是單純的圖標顯示（靜態）或具交互行為（例如切換密碼顯示）。
   
 - `LoginTextField`：
   - 繼承自 `BottomLineTextField`，針對登入頁面中的具體需求進行擴展。
   - 根據具體用途，提供不同的輸入功能，例如電子郵件輸入框或密碼輸入框。

 ----------------------------------------

` * Why - 為什麼需要 BottomLineTextField 和 LoginTextField 之間的關聯設計`

 `1. 重用性和一致性：`
 
    - `BottomLineTextField` 把通用的輸入框樣式、底線設置和右側按鈕功能統一封裝，這樣其他特定的輸入框（如 `LoginTextField`）就能重用這些基礎功能，保持一致的外觀和行為。
    - 在 `LoginView` 中，使用 `LoginTextField` 可以快速建立一致風格的輸入框，無論是密碼框還是郵件框，都是基於相同的基礎。

 `2. 單一責任，職責分離：`
 
    - 將通用的輸入框行為抽象到 `BottomLineTextField`，讓其負責樣式和按鈕設置，而 `LoginTextField` 僅負責與登入頁面相關的特定行為。這樣的分離讓每個類的職責更明確，代碼更易於維護。

 `3. 靈活性提升：`
 
    - 通過在 `BottomLineTextField` 中提供 `configureRightButton` 這樣的通用方法，可以讓 `LoginTextField` 自由選擇設置靜態按鈕（例如顯示郵件圖標）或交互按鈕（例如切換密碼顯示）。
    - 這樣的設計可以根據不同的需求來靈活配置右側按鈕行為。

 ----------------------------------------

 `* How - 如何使用 LoginTextField 與 BottomLineTextField 的關聯設計？`

` 1. BottomLineTextField 的核心功能：`
 
    - `底線設置`：
      - 通過 `setupBottomLine()` 來設置底線樣式，確保每次輸入框變更尺寸時都會調整底線的位置和寬度，增加視覺上的一致性。
 
    - `右側按鈕設置`：
      - 使用 `configureRightButton(iconName:isPasswordToggle:)` 方法，可以靈活設置右側靜態圖標或具交互行為的按鈕。
      - 透過傳入 `isPasswordToggle` 參數來決定按鈕的行為，如果是密碼顯示切換，則設置點擊行為為 `togglePasswordVisibility()`。

 `2. LoginTextField 的應用：`
 
    - `自訂輸入框類型`：
      - `LoginTextField` 繼承自 `BottomLineTextField`，根據不同的需求（例如 `emailTextField` 或 `passwordTextField`），通過 `setupTextField(placeholder:rightIconName:isPasswordField:)` 來設置輸入框屬性。
      - `isPasswordField` 參數用於指示該輸入框是否為密碼框。如果是，則會調用 `setRightInteractiveButtonForPasswordToggle(iconName:)`，設置密碼顯示/隱藏切換按鈕。
 
    - `統一風格`：
      - 無論是靜態的郵件圖標按鈕還是可交互的密碼切換按鈕，`LoginTextField` 都能重用 `BottomLineTextField` 的配置方法，確保在登入頁面中的輸入框樣式和操作行為保持一致。

 `3. 實際應用範例：`
 
    - `電子郵件輸入框 (emailTextField)`：
      - 使用 `LoginTextField` 並傳入 `placeholder` 為 "Email"，`rightIconName` 為 "envelope"，設置為靜態圖標按鈕。這樣用戶能夠直觀理解這個輸入框是用於輸入郵件。
 
    - `密碼輸入框 (passwordTextField)`：
      - 使用 `LoginTextField` 並傳入 `placeholder` 為 "Password"，`isPasswordField` 為 `true`。這樣就自動設置了右側交互按鈕，用戶可以通過點擊按鈕來切換密碼的顯示或隱藏狀態。

 ----------------------------------------

 `* 總結：`
 
    - `BottomLineTextField` 和 `LoginTextField` 的關聯設計在於將通用的 UI 功能抽象出來，再通過繼承來進行特定應用的擴展。
    - 這樣的設計讓代碼遵循了單一責任原則，使得每個類別的職責更加清晰，有助於提高代碼的重用性和一致性。
    - 在 `LoginView` 中，透過 `LoginTextField` 可以方便地創建具特定行為的輸入框，減少重複代碼，並且保持輸入框設計和交互的一致性，讓開發和維護更加輕鬆和直觀。
 
 */



// MARK: - LoginTextField 筆記
/**
 
 ## LoginTextField 筆記
 
` * What - 什麼是 LoginTextField`
 
 - `LoginTextField` 是繼承自 `BottomLineTextField` 的自訂輸入框類別，專門用於 `LoginView`。
 - 它支持設置佈局時的佔位符、右側靜態圖標，以及密碼顯示/隱藏的切換功能。

 ----------------------------------------

 `* Why - 為什麼需要 LoginTextField`
 
 - 在登入畫面中，輸入框需要額外的功能來提升用戶體驗，例如顯示郵件圖標或支援密碼顯示切換功能。
 - `LoginTextField` 通過繼承和擴展 `BottomLineTextField`，實現了這些專屬需求，使登入頁面的代碼更簡潔和更有可讀性。
 - 此外，使用專用類別有助於提升代碼的模組化，減少重複邏輯，並且使後續的維護和調整更容易。
 -  由於 LoginTextField 繼承了 BottomLineTextField，所有底線的設置、右側按鈕的配置等通用功能都可以共享，進一步減少重複代碼。

 
 ----------------------------------------

 `* How - 如何使用 LoginTextField`
 
 `1. 繼承 BottomLineTextField`：`

 - `LoginTextField` 繼承了 `BottomLineTextField`，因此它可以直接利用底線設置和右側按鈕設置等功能，並且擴展出一些特定的功能，比如密碼顯示切換。

 `2. 初始化方法：`
 
 - 在初始化過程中，`LoginTextField` 提供了三個參數：
    - `placeholder`：設置佔位符，幫助用戶理解要輸入的內容。
    - `rightIconName`：可選參數，設置右側靜態圖標，例如在電子郵件輸入框中顯示信封圖標。
    - `isPasswordField`：標誌是否是密碼框。如果是，則會提供顯示/隱藏密碼的功能。
 
 `3. 使用 setupTextField() 方法進行配置：
 `
    -  `setupTextField()` 方法中會根據不同的參數來設置對應的功能，包括佔位符、靜態圖標，以及密碼顯示切換功能。

 `4. BottomLineTextField 與 LoginTextField 的關聯性：`

    - `BottomLineTextField` 是通用的輸入框元件，提供底線和右側按鈕配置的基本功能。
    - `LoginTextField` 專注於登入頁面的需求，並基於 BottomLineTextField 增加了特定的登入功能，如密碼顯示切換。
    - `此設計讓兩個類別的職責分明`：`BottomLineTextField` 提供通用的視覺和交互基礎，而 `LoginTextField` 增強並針對登入場景進行特定化處理。
 
` 4. 使用方式：`
 
    - 創建郵件輸入框：
      ```swift
      let emailTextField = LoginTextField(placeholder: "Email", rightIconName: "envelope")
      ```
    - 創建密碼輸入框：
      ```swift
      let passwordTextField = LoginTextField(placeholder: "Password", isPasswordField: true)

      ```
 ----------------------------------------

 `* 總結`
 
    - LoginTextField 通過繼承 BottomLineTextField 提供的基礎功能，實現了特定場景的功能需求，如郵件圖標的靜態顯示和密碼顯示/隱藏切換的交互功能。
    - 此設計不僅提高了登入頁面的使用體驗，也確保代碼結構更加清晰和容易維護。
    - 將重複的配置邏輯提取到 BottomLineTextField 中，並在 LoginTextField 中根據具體需求擴展，這樣的設計實現了高內聚低耦合的代碼結構，使元件易於重用和擴展。
 */


import UIKit

/// 自訂的 `LoginTextField`，繼承自 `BottomLineTextField`
/// - 提供登入頁面中特定需求的輸入框，包括電子郵件與密碼輸入框
class LoginTextField: BottomLineTextField {
    
    // MARK: - Initializers
    
    /// 使用自訂的初始化方法來配置 `LoginTextField`
    /// - Parameters:
    ///   - placeholder: 文字輸入框的佔位符
    ///   - rightIconName: 右側圖標的名稱，可選
    ///   - isPasswordField: 是否為密碼輸入框（如果是，會配置密碼顯示切換功能）
    init(placeholder: String, rightIconName: String? = nil, isPasswordField: Bool = false) {
        super.init(frame: .zero)
        setupTextField(placeholder: placeholder, rightIconName: rightIconName, isPasswordField: isPasswordField)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 配置 `LoginTextField` 的基本屬性
    /// - Parameters:
    ///   - placeholder: 文字輸入框的佔位符
    ///   - rightIconName: 右側圖標的名稱，可選
    ///   - isPasswordField: 是否為密碼輸入框
    private func setupTextField(placeholder: String, rightIconName: String?, isPasswordField: Bool) {
        
        self.placeholder = placeholder
        // 如果提供了右側圖標名稱，根據是否為密碼框來設置交互行為
        if let iconName = rightIconName {
            configureRightButton(iconName: iconName, isPasswordToggle: isPasswordField)
        }
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
