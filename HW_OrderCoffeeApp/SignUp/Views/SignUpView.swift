//
//  SignUpView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/18.
//

// MARK: - 註冊須知連結與「同意條款」確認框的流程設計
/**
 
 ## 註冊須知連結與「同意條款」確認框的流程設計

 `* What`
 
 - 在註冊過程中，用戶必須點擊查看「註冊須知連結」後，才能啟用並勾選「同意條款」的確認框，進而進行註冊。

 -------------------------------

 `* Why`
 
 1. `法律合規`：確保用戶在註冊前已閱讀並同意服務條款和隱私政策，符合法律合規要求。
 2. `使用者權益保障`：透過讓用戶主動閱讀條款內容，可以避免未來因為用戶未了解條款內容而引起的誤解或糾紛，增強用戶體驗與企業的信任感。
 3. `流程控制`：防止用戶未經閱讀條款即勾選「同意條款」，減少潛在風險，確保用戶了解和接受相關政策。

 -------------------------------

 `* How`
 
 `1. 禁用「同意條款」的確認框：`
    - 一開始禁用「同意條款」的確認框（`setTermsCheckBoxEnabled(false)`），確保在使用者尚未點擊「註冊須知連結」之前無法勾選。
 
 `2. 點擊「註冊須知連結」後啟用確認框：`
    - 當使用者點擊「註冊須知連結」時，打開條款的網頁，並且在成功打開之後啟用「同意條款」的確認框（`setTermsCheckBoxEnabled(true)`）。這樣確保用戶在確實查看條款之後，才可以勾選同意。
 
 `3. 註冊時驗證確認框狀態：`
    - 在註冊按鈕的處理邏輯中（`signUpViewDidTapSignUpButton()`），首先驗證「同意條款」的確認框是否被選中（`validateTermsCheckBox()`）。
    - 若未勾選，則顯示提示訊息，阻止註冊流程進行，直到用戶同意條款為止。

 -------------------------------

 *` 筆記總結`
 
 - 這個流程的設計目的是為了提高用戶對條款的了解度，並滿足法律合規的要求。
 - 在註冊流程中，只有在使用者點擊「註冊須知連結」並確定查看後，才會允許他們勾選「同意條款」並完成註冊。
 - 這樣的設計有效地將法律義務、用戶權益保護，以及流程的可控性緊密結合在一起。
 */


// MARK: - SignUpView 的設計重點
/**

 ### SignUpView 的設計重點

` * What`
 
 - `SignUpView` 是註冊畫面的主要 UI 元件視圖，負責顯示並管理註冊相關的使用者介面，包含標籤、輸入框、按鈕、勾選框等元素。
 - 它是 `SignUpViewController` 的主要視圖，包含所有註冊過程中的使用者輸入和互動元件。

 -------------------------------

 `* Why：為什麼這樣設計`
 
 `1. 提高模組化與責任分離：`
 
    - `解耦 UI 與業務邏輯`：
        - `SignUpView` 負責管理 UI 元件及其佈局，這樣可以將 UI 相關的處理與控制器中的邏輯解耦，提高代碼的可維護性與可讀性。
    
 - `清晰職責分工`：
        - `SignUpView` 專注於視圖的設計和佈局，`SignUpViewController` 負責行為邏輯與用戶操作處理，這樣可以更好地分工並遵循單一職責原則（Single Responsibility Principle）。

 `2. 保持一致的 UI 元件佈局：`
 
    - 利用 `StackView` 和 `ScrollView` 將所有元件進行合理排列，確保 UI 在不同的設備和情況下（如顯示鍵盤時）能保持一致性，改善使用者體驗。

 `3. 重用與擴充性：`
 
    - 透過自定義 UI 元件（如 `SignUpLabel`、`SignUpTextField`、`SignUpFilledButton` 等），可以提高元件的重用性和一致性，減少重複代碼，並方便未來擴充 UI。

 -------------------------------

 `* How：如何實作`
 
 `1. UI 元件與佈局設置：`
 
    - `標籤與輸入框`：
      - 使用自定義的 `SignUpLabel` 和 `SignUpTextField`，來分別設置註冊標題、全名、電子郵件、密碼等欄位的標籤和輸入框，確保外觀一致。
 
    - `同意條款`：
      - 添加「閱讀條款」的按鈕和「我同意條款」的勾選框，並以 `iagreeToTheTermsAndReadTheTermsStackView` 來組合排列，控制其顯示和操作順序。
 
    - `分隔線與第三方登入按鈕`：
      - 使用 `SignUpSeparatorView` 和第三方登入按鈕 (`Google` 和 `Apple`) 來實現分隔與社群註冊選項，增加使用者的註冊方式選擇。

 `2. 元件的 StackView 佈局：`
 
    - `主 StackView`：
        - `mainStackView` 將所有 UI 元件垂直排列，用以控制各元件在畫面中的佈局和間距，確保視覺上的一致性和良好的使用者體驗。
 
    - `ScrollView 的包裹`：
        - 將 `mainStackView` 放置在 `mainScrollView` 中，讓畫面能支援垂直滾動，特別是當鍵盤顯示時，使用者仍能操作其他輸入框。

 `3. 公開存取方法：`
 
    - 提供公共存取方法（如 `getFullName()`、`getEmail()` 等）讓 `SignUpViewController` 能夠存取輸入值或按鈕，從而控制註冊行為。
    - 例如，`enableTermsCheckBox()` 允許在使用者查看條款後啟用「同意條款」的確認框，達成控制流與 UI 的良好互動。

 -------------------------------

 `* 筆記總結：`
 
 - `SignUpView` 的設計遵循單一職責原則，通過自定義元件及 `StackView` 組合來維持一致的 UI 風格與高重用性，並且借助公開存取方法與 `SignUpViewController` 進行互動。
 - 這樣的架構清楚地分離 UI 與邏輯，還可以使視圖更具擴展性和可維護性。
 */



// MARK: - 關於 `.trimmingCharacters(in: .whitespacesAndNewlines)` 的筆記
/**

 ## 關於 `.trimmingCharacters(in: .whitespacesAndNewlines)` 的筆記
 
 `* What`
 
 - `.trimmingCharacters(in: .whitespacesAndNewlines)` ，用於去除字串開頭和結尾的特定字符。
 - 使用 `.whitespacesAndNewlines`，這表示移除字串開頭和結尾的空格（`whitespaces`）和換行符號（`newlines`）。

 -------------------------------
 
 `* Why`
 
 - 在表單輸入驗證中，使用者有可能不小心（或故意）只輸入空格或包含多餘的空格，例如在姓名、電子郵件或密碼等欄位中。如果不處理這些空格：
 
 1. 使用者可能會通過檢查並註冊成功，但註冊的資料是不完整或不符合規範的。
 2. 這些多餘的空格也可能在後續操作中帶來不必要的問題，例如資料查詢和格式化時的不一致。
 3.使用 `.trimmingCharacters(in: .whitespacesAndNewlines)` 可以確保輸入資料的質量和一致性，避免因多餘空格造成的潛在問題。

 -------------------------------

 `* How`
 
 - 使用 `.trimmingCharacters(in: .whitespacesAndNewlines)` 去除全名、電子郵件、密碼和確認密碼欄位中的多餘空格和換行符號。
 - 這樣的處理保證了在進行資料驗證前，這些欄位的值都是去除掉前後空格的結果，確保輸入的資料是有效的。

 - 示例：
 
 ```swift
 var password: String {
     passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
 }
 ```
 
-  以上方法能確保輸入框中的資料在檢查時已經去除了不必要的空格和換行符號。

 -------------------------------
 
 `* Step-by-Step Example`
 
 `1. .trimmingCharacters(in: .whitespacesAndNewlines) 使用的效果：`
 
 - 在 SignUpView 的 getter 方法中，例如 getFullName()，已經使用了 .trimmingCharacters(in: .whitespacesAndNewlines)。
 - 這會將輸入中前後的空格和換行符號去除。因此，如果使用者在輸入框中`僅輸入空格`，這些方法返回的會是空字串 ""，而不是包含空格的字串。

 `2. 例如：`

 - 使用者在全名欄位中輸入 " "（三個空格）。
 - getFullName() 會返回 ""，因為所有的空格都被 .trimmingCharacters(in: .whitespacesAndNewlines) 去掉了。

 -------------------------------

 `* Summary`
 
 - 使用 `.trimmingCharacters(in: .whitespacesAndNewlines)` 可以防止使用者輸入中包含多餘空格和換行符號，並確保在註冊或提交資料時，避免錯誤的資料被存儲。
 */


// MARK: - 筆記：為何在 SignUpView 中設置 setTermsCheckBoxEnabled、isTermsCheckBoxSelected、isTermsCheckBoxEnabled、toggleTermsCheckBox
/**
 ### 筆記：為何在 SignUpView 中設置 setTermsCheckBoxEnabled、isTermsCheckBoxSelected、isTermsCheckBoxEnabled、toggleTermsCheckBox
 
` * 與原本未重構時的差別`
 
 `1.舊設計：`

 - 原先 termsCheckBox 的狀態是直接由 SignUpViewController 操作屬性，例如 termsCheckBox.isEnabled = true。
 - 這樣的設計導致控制層（ViewController）與視圖層（SignUpView）耦合緊密，分工不明。
 
` 2.重構後：`

 - 透過封裝 API（如 setTermsCheckBoxEnabled 和 toggleTermsCheckBox），將視圖邏輯與控制層的業務邏輯分離：
 - SignUpViewController 專注於「何時應該改變狀態」的邏輯判斷。
 - SignUpView 專注於「如何改變狀態」的具體操作。
 
 -------------------------------

 `* What`

 - `SignUpView` 中目前包含以下公開方法和屬性，用於管理「我同意條款」的勾選框狀態：
 
 `1.方法：`
 
 - `setTermsCheckBoxEnabled(_ enabled: Bool)`：設定勾選框是否可以被操作。
 - `toggleTermsCheckBox()：`切換勾選框的選中狀態。
 
` 2.屬性：`
 
 - `isTermsCheckBoxSelected`：查詢勾選框當前是否選中。
 - `isTermsCheckBoxEnabled`：查詢勾選框當前是否可被操作。

 -------------------------------

 `* Why`
 
 - 重構後將這些方法設置在 `SignUpView`，其目的是為了提高代碼的清晰度和遵守責任分配原則。
 
 `1.封裝視圖狀態的操作`

 - 狀態操作被封裝在 SignUpView 中，避免控制器直接操作內部 UI 元件的屬性，減少耦合。
 
 - 例如：
 
 ```swift
 signUpView.setTermsCheckBoxEnabled(true)
 ```
 
 - 而非：
 ```swift
 signUpView.termsCheckBox.isEnabled = true
 ```
 
` 2.遵守單一職責原則（Single Responsibility Principle, SRP）`

 - 控制層：負責業務邏輯判斷，例如判斷用戶是否已閱讀條款，並決定是否啟用勾選框。
 - 視圖層：負責視圖狀態的改變，不處理業務邏輯。
 - 重構後的代碼分工清晰，降低了維護難度。
 
` 3.提高代碼可讀性與重用性`

 - 將視圖操作方法抽象成通用 API，可以簡化控制層的邏輯表達：
 - 使用者是否閱讀條款 → 調用 `setTermsCheckBoxEnabled` 或 `toggleTermsCheckBox`。
 - 集中管理 UI 行為，使 SignUpView 更容易被重用。

 -------------------------------

` * How`
 
 - 這些調整使得 `SignUpView` 提供了一組操作勾選框的公共方法：
 
 
 `1. setTermsCheckBoxEnabled(_ enabled: Bool)`：
 
    - 提供具體的啟用或禁用控制，可以根據業務邏輯設置 `termsCheckBox` 是否可被操作。
 
 ```
 func signUpViewDidTapTermsButton() {
     if let url = URL(string: "https://example.com/terms") {
         UIApplication.shared.open(url) { [weak self] success in
             if success {
                 self?.signUpView.setTermsCheckBoxEnabled(true)
             }
         }
     }
 }
```
 
 ------
 
 `2. 屬性 isTermsCheckBoxSelected 和 isTermsCheckBoxEnabled`：
 
    - 提供查詢狀態的接口，用於業務邏輯判斷：
    - 用戶是否選中條款勾選框？
    - 條款勾選框是否啟用？
 
 ```
 guard signUpView.isTermsCheckBoxSelected else {
     // 顯示錯誤提示
     return
 }
```
 
 ------

 `3. toggleTermsCheckBox()：`
 
    - 切換選中狀態，視圖層提供該方法供控制層使用，避免直接操作 isSelected。
 
 ```
 func signUpViewDidTapTermsCheckBox() {
     guard signUpView.isTermsCheckBoxEnabled else {
         signUpView.setTermsCheckBoxEnabled(false)
         return
     }
     signUpView.toggleTermsCheckBox()
 }
```

 -------------------------------

 `* 總結`
 
 - 這些方法在 `SignUpView` 中集中管理，減少了 UI 元件的直接操作，增強了視圖和控制層的分離。
 - 相較於重構前的設計，這些方法使代碼的邏輯更加分明，讓各層專注於自己的責任領域。
 - 重構前，控制器直接操作 UI 元件的屬性，這樣容易導致視圖和控制器之間的耦合性過高，且降低了代碼的可讀性和可維護性。
 */


// MARK: - 筆記：SignUpCheckBoxButton 的狀態控制與責任分配（重要）
/**
 
 ## 筆記：SignUpCheckBoxButton 的狀態控制與責任分配

 - 主要是 termsCheckBox 初始狀態為 false，原本的想法是直接設置在 SignUpCheckBoxButton中，但又考慮到會影響到職責劃分問題。
 
 `* 重點`
 
 `1.單一職責原則 (Single Responsibility Principle)`

 - `SignUpCheckBoxButton` 主要負責定義 UI 元件的外觀和互動行為，如勾選與未勾選的狀態顯示。
 - 不應包含與業務邏輯相關的狀態控制（例如 "`termsCheckBox`" 是否可被啟用），這會增加 `SignUpCheckBoxButton` 的責任，違反單一職責原則，降低其重用性和維護性。
 - 與業務邏輯相關的狀態控制（如 termsCheckBox 是否可用）被移至 SignUpView，進一步強化了單一職責原則，使元件具備更高的重用性和可維護性。

 `2.行為邏輯由控制層處理`
 
 - `termsCheckBox` 的可用性或選中狀態，應由控制層（如 `SignUpViewController` 或 `SignUpActionHandler`）負責根據業務邏輯進行控制。
 - `SignUpView` 提供公開方法和屬性（如 `setTermsCheckBoxEnabled(_:) `和 `toggleTermsCheckBox()`），用於控制層與視圖層的互動，而不直接暴露內部實現細節。
 
` 3.狀態控制方法的封裝`

 - 狀態控制相關的方法（如 `setTermsCheckBoxEnabled`、`isTermsCheckBoxSelected` 等）被封裝在 SignUpView 中。
 - 這些方法提供了與 `termsCheckBox` 互動的接口，而不是在控制器中直接操作屬性，這樣可以：
    - 增強代碼的可讀性，使控制層的業務邏輯更加語義化。
    - 減少控制層和視圖層之間的耦合度，使代碼更具可維護性和重用性。
 
` 4.具體實作建議`

 - `業務邏輯層（例如 SignUpViewController 或 SignUpActionHandler）：`
    - 應負責判斷業務邏輯，例如：用戶是否已閱讀條款，並根據結果調用 SignUpView 的方法。
 
 - `UI 層（如 SignUpCheckBoxButton 和 SignUpView）：`
    - 應專注於視圖邏輯和狀態更新，不直接處理業務邏輯。

 */


// MARK: - 處理佈局約束、封裝性。(v)

import UIKit

/// 處理 SignUpViewController 相關 UI元件 佈局
class SignUpView: UIView {
    
    // MARK: - UI Elements
    
    /// 註冊標題 Label
    private let titleLabel = SignUpLabel(text: "Sign up for an account", fontSize: 28, weight: .black, textColor: .deepGreen)
    
    /// 註冊說明 Label
    private let signUpLabel = SignUpLabel(text: "Sign up with email", fontSize: 14, weight: .medium, textColor: .lightGray)
    
    /// 全名標籤及輸入框
    private let fullNameLabel = SignUpLabel(text: "Full Name", fontSize: 14, weight: .medium, textColor: .darkGray)
    private let fullNameTextField = SignUpTextField(placeholder: "Full Name", rightIconName: "person.fill", isPasswordField: false, fieldType: .name)
    
    /// 電子郵件標籤及輸入框
    private let emailLabel = SignUpLabel(text: "Email", fontSize: 14, weight: .medium, textColor: .darkGray)
    private let emailTextField = SignUpTextField(placeholder: "Email", rightIconName: "envelope", isPasswordField: false, fieldType: .email)
    
    /// 密碼標籤及輸入框
    private let passwordLabel = SignUpLabel(text: "Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    private let passwordTextField = SignUpTextField(placeholder: "Password", rightIconName: "eye", isPasswordField: true, fieldType: .password)
    
    /// 確認密碼標籤及輸入框
    private let confirmPasswordLabel = SignUpLabel(text: "Confirm Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    private let confirmPasswordTextField = SignUpTextField(placeholder: "Confirm Password", rightIconName: "eye", isPasswordField: true, fieldType: .password)
    
    /// 同意條款勾選框與按鈕
    private(set) var termsCheckBox = SignUpCheckBoxButton(title: " I agree to the terms")
    private(set) var termsButton = SignUpAttributedButton(mainText: "", highlightedText: "Read the terms", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)
    
    /// 註冊按鈕
    private(set) var signUpButton = SignUpFilledButton(title: "Sign Up", textFont: .systemFont(ofSize: 18, weight: .black), textColor: .white, backgroundColor: .deepGreen)
    
    /// 分隔線與第三方登入按鈕
    private let separatorView = SignUpSeparatorView(text: "Or Sign Up with", textColor: .lightGray, lineColor: .lightGray)
    private(set) var googleLoginButton = SignUpFilledButton(title: "Sign Up with Google", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "google48")
    private(set) var appleLoginButton = SignUpFilledButton(title: "Sign Up with Apple", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "apple50")
    
    
    // MARK: - StackView
    
    /// 主垂直 StackView，用來排列主要的 UI 元素
    private let mainStackView = SignUpStackView(axis: .vertical, spacing: 15, alignment: .fill, distribution: .fill)
    
    /// 全名的 StackView
    private let fullNameStackView = SignUpStackView(axis: .vertical, spacing: 5, alignment: .fill, distribution: .fill)
    
    /// 電子郵件的 StackView
    private let emailStackView = SignUpStackView(axis: .vertical, spacing: 5, alignment: .fill, distribution: .fill)
    
    /// 密碼的 StackView
    private let passwordStackView = SignUpStackView(axis: .vertical, spacing: 5, alignment: .fill, distribution: .fill)
    
    /// 確認密碼的 StackView
    private let confirmPasswordStackView = SignUpStackView(axis: .vertical, spacing: 5, alignment: .fill, distribution: .fill)
    
    /// 條款相關按鈕的水平 StackView
    private let iagreeToTheTermsAndReadTheTermsStackView = SignUpStackView(axis: .horizontal, spacing: 0, alignment: .fill, distribution: .equalSpacing)
    
    // MARK: - ScrollView
    
    /// ScrollView 用來包裹所有 StackView，支援畫面滾動，特別是在鍵盤顯示時仍能滾動
    private let mainScrollView = SignUpScrollView()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()                         // 設置 mainScrollView
        setupMainStackView()                      // 設置 mainStackView 和其子視圖
        setupMainStackViewConstraints()           // 設置約束
        setViewHeights()                          // 設置元件高度
        setupBackground()                         // 設置背景色
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// 設置 ScrollView
    private func setupScrollView() {
        mainScrollView.setupConstraints(in: self) // 將 scrollView 加入 SignUpView 並設置其約束
    }
    
    /// 設置主要的 StackView，包含所有主要的 UI 元件，並加入到 mainScrollView 中
    private func setupMainStackView() {
        
        // 設置輸入欄的 StackView
        fullNameStackView.addArrangedSubview(fullNameLabel)
        fullNameStackView.addArrangedSubview(fullNameTextField)
        
        emailStackView.addArrangedSubview(emailLabel)
        emailStackView.addArrangedSubview(emailTextField)
        
        passwordStackView.addArrangedSubview(passwordLabel)
        passwordStackView.addArrangedSubview(passwordTextField)
        
        confirmPasswordStackView.addArrangedSubview(confirmPasswordLabel)
        confirmPasswordStackView.addArrangedSubview(confirmPasswordTextField)
        
        // 設置 "我同意該條款" 和 "閱讀條款" 按鈕的 StackView
        iagreeToTheTermsAndReadTheTermsStackView.addArrangedSubview(termsCheckBox)
        iagreeToTheTermsAndReadTheTermsStackView.addArrangedSubview(termsButton)
        
        // 將所有子視圖添加到 mainStackView 中
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(signUpLabel)
        mainStackView.addArrangedSubview(fullNameStackView)
        mainStackView.addArrangedSubview(emailStackView)
        mainStackView.addArrangedSubview(passwordStackView)
        mainStackView.addArrangedSubview(confirmPasswordStackView)
        mainStackView.addArrangedSubview(iagreeToTheTermsAndReadTheTermsStackView)
        mainStackView.addArrangedSubview(signUpButton)
        mainStackView.addArrangedSubview(separatorView)
        mainStackView.addArrangedSubview(googleLoginButton)
        mainStackView.addArrangedSubview(appleLoginButton)
        
        // 將 mainStackView 添加到 ScrollView 中
        mainScrollView.addSubview(mainStackView)
    }
    
    /// 設置主要的約束
    private func setupMainStackViewConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 30),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -30),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: mainScrollView.bottomAnchor, constant: -10),
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -60)
        ])
    }
    
    /// 設置元件高度
    private func setViewHeights() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            signUpLabel.heightAnchor.constraint(equalToConstant: 20),
            fullNameTextField.heightAnchor.constraint(equalToConstant: 40),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 40),
            signUpButton.heightAnchor.constraint(equalToConstant: 55),
            separatorView.heightAnchor.constraint(equalToConstant: 30),
            googleLoginButton.heightAnchor.constraint(equalToConstant: 55),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    /// 設置背景顏色
    private func setupBackground() {
        backgroundColor = .white
    }
    
    // MARK: - Public Methods: Getters

    /// 使用者輸入的全名
    var fullName: String {
        fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 使用者輸入的電子郵件
    var email: String {
        emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 使用者輸入的密碼
    var password: String {
        passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 使用者輸入的確認密碼
    var confirmPassword: String {
        confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 檢查「我同意條款」勾選框的選中狀態
    /// - Returns: 布林值，表示勾選框當前是否被選中 (true 表示已選中，false 表示未選中)
    var isTermsCheckBoxSelected: Bool {
        termsCheckBox.isSelected
    }
    
    /// 檢查「我同意條款」勾選框是否啟用
    /// - Returns: 布林值，表示勾選框當前是否可被操作 (true 表示可操作，false 表示不可操作)
    var isTermsCheckBoxEnabled: Bool {
        termsCheckBox.isEnabled
    }
    
    /// 設置「我同意條款」勾選框的啟用狀態
    /// - Parameter enabled: 設定勾選框是否可以被用戶操作 (true 表示啟用，false 表示禁用)
    func setTermsCheckBoxEnabled(_ enabled: Bool) {
        termsCheckBox.isEnabled = enabled
    }
    
    /// 切換「我同意條款」勾選框的選中狀態
    /// - 根據當前狀態切換勾選框的選中與未選中狀態。
    /// - 如果目前是選中狀態，則取消選中；如果目前未選中，則設置為選中。
    func toggleTermsCheckBox() {
        termsCheckBox.isSelected.toggle()
    }
    
}
