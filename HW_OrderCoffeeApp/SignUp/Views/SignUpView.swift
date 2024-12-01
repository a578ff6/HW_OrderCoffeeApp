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
    - 當使用者點擊「註冊須知連結」時，打開條款的網頁，並且在成功打開之後啟用「同意條款」的確認框（`enableTermsCheckBox()`）。這樣確保用戶在確實查看條款之後，才可以勾選同意。
 
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
 /// 獲取使用者輸入的全名
 /// - Returns: FullName 字串
 func getFullName() -> String {
     return fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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


// MARK: - 筆記：為何在 `SignUpView` 中設置 `enableTermsCheckBox`、`setTermsCheckBoxEnabled`、`isTermsCheckBoxSelected`、`isTermsCheckBoxEnabled`、toggleTermsCheckBoxSelection
/**
 ### 筆記：為何在 `SignUpView` 中設置 `enableTermsCheckBox`、`setTermsCheckBoxEnabled`、`isTermsCheckBoxSelected`、`isTermsCheckBoxEnabled`、toggleTermsCheckBoxSelection
 
` * 與原本未重構時的差別`
 
 - 在重構之前，`termsCheckBox` 的狀態控制是直接由 `SignUpViewController` 操作其屬性，如 termsCheckBox.isEnabled = true。
 - 上一個版本在寫的時候就覺得控制狀態有點分散，這種做法會讓視圖層的邏輯混入控制層中，增加維護難度。
 - 重構後，SignUpView 負責提供簡單的 API 來管理按鈕狀態（例如啟用、禁用、切換選中狀態等），而控制層專注於判斷和決策邏輯，這符合單一職責原則，使邏輯更加清晰且易於維護。
 
 -------------------------------

 `* What`
 
 `1.在 SignUpView 中新增了以下方法來管理「我同意條款」的勾選框狀態：`
    - `enableTermsCheckBox()`
    - `setTermsCheckBoxEnabled(_ enabled: Bool)`
    - `isTermsCheckBoxSelected()`
    - `isTermsCheckBoxEnabled()`
    - `toggleTermsCheckBoxSelection()`

 `2.這些方法被用於控制勾選框的啟用、選擇狀態查詢等功能。`

 -------------------------------

 `* Why`
 
 - 重構後將這些方法設置在 `SignUpView`，其目的是為了提高代碼的清晰度和遵守責任分配原則。

 `1.封裝視圖狀態的操作`：
    - 將有關勾選框狀態的操作封裝到 `SignUpView` 中，讓視圖層只負責管理 UI，並提供更易理解的公共 API。
    - 這樣可以使 `SignUpViewController` 更專注於業務邏輯，而不需要直接操作具體的 UI 元件屬性，減少了耦合度。
   
 `2.單一職責原則 (SRP)：`
    - `SignUpViewController` 負責管理業務流程，例如當用戶完成閱讀條款後決定是否啟用勾選框，而具體的啟用操作由 `SignUpView` 完成，這樣使得控制層和視圖層各司其職。
   
 `3.重用性和可讀性`：
    - 把勾選框的操作集中在 `SignUpView` 中，可以提高代碼的重用性。

 -------------------------------

` * How`
 
 - 這些調整使得 `SignUpView` 提供了一組操作勾選框的公共方法：
 
 `1. enableTermsCheckBox()`：
    - 這個方法是高層抽象，簡單地啟用「我同意條款」的勾選框，使其可被用戶選擇。內部實際上是呼叫了 `setTermsCheckBoxEnabled(true)`。
 
 `2. setTermsCheckBoxEnabled(_ enabled: Bool)`：
    - 提供具體的啟用或禁用控制，可以根據業務邏輯設置 `termsCheckBox` 是否可被操作。
 
 `3. isTermsCheckBoxSelected()` 和 `isTermsCheckBoxEnabled()`：
    - 提供檢查勾選框當前狀態的方法，讓控制層可以根據這些狀態決定下一步操作。
 
 `4. toggleTermsCheckBoxSelection()：`
    - 切換勾選框的選中狀態，這種操作的封裝使得控制層不需要知道具體如何切換狀態，只需簡單地調用此方法即可完成選中狀態的變更。

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
 
 `2.行為邏輯由控制層處理`

 - `termsCheckBox` 的可用狀態應根據業務邏輯進行控制，例如使用者是否已閱讀條款。這些業務邏輯應由 `SignUpViewController` 或 `SignUpActionHandler` 來管理。
 - 控制層應負責判斷何時啟用 `termsCheckBox`，而 `SignUpCheckBoxButton` 應保持專注於 UI 行為。
 
` 3.狀態控制方法的封裝`

 - 狀態控制相關的方法（如 `enableTermsCheckBoxAfterViewingTerms`、`setTermsCheckBoxEnabled`、`isTermsCheckBoxSelected` 等）被封裝在 SignUpView 中。
 - 這些方法提供了與 `termsCheckBox` 互動的接口，而不是在控制器中直接操作屬性，這樣可以：
    - 增強代碼的可讀性，使控制層的業務邏輯更加語義化。
    - 減少控制層和視圖層之間的耦合度，使代碼更具可維護性和重用性。
 
` 4.具體實作建議`

 - `SignUpViewController` 可以通過 `SignUpViewDelegate` 來監聽使用者的行為（如閱讀條款），然後決定是否啟用 `termsCheckBox`。
 - `SignUpCheckBoxButton` 可以提供` enableCheckBox(_ enabled: Bool) `這類方法來控制按鈕的狀態，但不直接包含邏輯來決定是否啟用它。

 */



// MARK: - 備份（已經完成確認框）
/*
import UIKit

/// 處理 SignUpViewController 相關 UI元件 佈局
class SignUpView: UIView {
    
    // MARK: - UI Elements
    
    let titleLabel = createLabel(text: "Sign up for an account", fontSize: 28, weight: .black, textColor: .deepGreen)
    let signUpLabel = createLabel(text: "Sign up with email", fontSize: 14, weight: .medium, textColor: .lightGray)
    
    let fullNameLabel = createLabel(text: "Full Name", fontSize: 14, weight: .medium, textColor: .darkGray)
    let fullNameTextField = createBottomLineTextField(placeholder: "Full Name", iconName: "person.fill")
    
    let emailLabel = createLabel(text: "Email", fontSize: 14, weight: .medium, textColor: .darkGray)
    let emailTextField = createBottomLineTextField(placeholder: "Email", iconName: "envelope")
    
    let passwordLabel = createLabel(text: "Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    let passwordTextField = createBottomLineTextField(placeholder: "Password", isSecure: true, textContentType: .newPassword)
    
    let confirmPasswordLabel = createLabel(text: "Confirm Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    let confirmPasswordTextField = createBottomLineTextField(placeholder: "Confirm Password", isSecure: true, textContentType: .newPassword)
    
    /// 確認框
    let termsCheckBox = createCheckBoxButton(title: " I agree to the terms")
    /// 註冊須知連結
    let termsButton = createAttributedButton(mainText: "", highlightedText: "Read the terms", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)

    let signUpButton = createFilledButton(title: "Sign Up", fontSize: 18, fontWeight: .black, textColor: .white)
    let separatorView = createSeparatorView()
    
    let googleLoginButton = createSocialButton(imageName: "google48", title: "Sign Up with Google", imageOffsetY: -7.0)
    let appleLoginButton = createSocialButton(imageName: "apple50", title: "Sign Up with Apple", imageOffsetY: -5.0)

    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        termsCheckBox.isEnabled = false  // 初始化的時候禁用「確認框」
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Private Methods
    
    private func setupLayout() {
        let fullNameStack = SignUpView.createLabelTextFieldStack(label: fullNameLabel, textField: fullNameTextField)
        let emailStack = SignUpView.createLabelTextFieldStack(label: emailLabel, textField: emailTextField)
        let passwordStack = SignUpView.createLabelTextFieldStack(label: passwordLabel, textField: passwordTextField)
        let confirmPasswordStack = SignUpView.createLabelTextFieldStack(label: confirmPasswordLabel, textField: confirmPasswordTextField)
        let termsStackView = createTermsStackView()
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            signUpLabel,
            fullNameStack,
            emailStack,
            passwordStack,
            confirmPasswordStack,
            termsStackView,
            signUpButton,
            separatorView,
            googleLoginButton,
            appleLoginButton
        ])
          
        stackView.axis = .vertical
        stackView.spacing = 13
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        setViewHeights()
    }

    /// 設置元件高度
    private func setViewHeights() {
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signUpLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        fullNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        googleLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        appleLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    /// 設置 「確認框」、「注意須知連結按鈕」
    private func createTermsStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [termsCheckBox, termsButton])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// Label 與 TedtField 的 StackView
    private static func createLabelTextFieldStack(label: UILabel, textField: UITextField) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// Label 設置
    private static func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor = .black) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 設置底線的 TextField
    private static func createBottomLineTextField(placeholder: String, isSecure: Bool = false, textContentType: UITextContentType? = nil, iconName: String? = nil) -> BottomLineTextField {
        let textField = BottomLineTextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.textContentType = textContentType
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        if let iconName = iconName {
            let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            let iconImage = UIImage(systemName: iconName, withConfiguration: configuration)
            let iconImageView = UIImageView(image: iconImage)
            
            iconImageView.tintColor = .gray
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            textField.rightView = iconImageView
            textField.rightViewMode = .always
            
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: 30),
                iconImageView.heightAnchor.constraint(equalToConstant: 22)
            ])
        }
        
        return textField
    }

    /// 設置自訂的顏色按鈕
    private static func createFilledButton(title: String, fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .bold, textColor: UIColor = .white) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        button.setTitleColor(textColor, for: .normal)
        button.styleFilledButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// 分隔線（Or SignUp with）
    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorStackView = UIStackView()
        separatorStackView.axis = .horizontal
        separatorStackView.alignment = .center
        separatorStackView.spacing = 3
        separatorStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let line1 = createLineView()
        let line2 = createLineView()
        let label = createSeparatorLabel(text: "Or Sign Up with")
        
        separatorStackView.addArrangedSubview(line1)
        separatorStackView.addArrangedSubview(label)
        separatorStackView.addArrangedSubview(line2)
        
        view.addSubview(separatorStackView)

        NSLayoutConstraint.activate([
            separatorStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    /// 搭配分格線專用的 Label
    private static func createSeparatorLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// 分格線
    private static func createLineView() -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 95).isActive = true
        return lineView
    }
    
    /// 與 Apple、google 按鈕外觀設置相關
    private static func createSocialButton(imageName: String, title: String, imageOffsetY: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true

        // 建立帶圖示、文字的 NSAttributedString
        let image = UIImage(named: imageName)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        let imageOffsetY: CGFloat = imageOffsetY
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 25, height: 25)

        let fullString = NSMutableAttributedString()
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: "  \(title)", attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]))

        button.setAttributedTitle(fullString, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// 設置密碼或確認密碼欄位的眼睛圖示
    func setPasswordOrConfirmPasswordTextFieldIcon(for textField: UITextField, target: Any?, action: Selector?) {
         let configuration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
         let eyeImage = UIImage(systemName: "eye", withConfiguration: configuration)
         let eyeButton = UIButton(type: .system)
         eyeButton.setImage(eyeImage, for: .normal)
         eyeButton.tintColor = .gray
         eyeButton.contentMode = .scaleAspectFit
         eyeButton.translatesAutoresizingMaskIntoConstraints = false
         textField.rightView = eyeButton
         textField.rightViewMode = .always
         
         guard let target = target, let action = action else { return }
         eyeButton.addTarget(target, action: action, for: .touchUpInside)
         
         NSLayoutConstraint.activate([
             eyeButton.widthAnchor.constraint(equalToConstant: 30),
             eyeButton.heightAnchor.constraint(equalToConstant: 22)
         ])
     }
    
    /// square 確認按鈕
    private static func createCheckBoxButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.tintColor = .gray
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    /// 文字型態按鈕
    private static func createAttributedButton(mainText: String, highlightedText: String, fontSize: CGFloat, mainTextColor: UIColor, highlightedTextColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: mainText, attributes: [
            .foregroundColor: mainTextColor,
            .font: UIFont.boldSystemFont(ofSize: fontSize)
        ])
        attributedTitle.append(NSAttributedString(string: highlightedText, attributes: [
            .foregroundColor: highlightedTextColor,
            .font: UIFont.boldSystemFont(ofSize: fontSize)
        ]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
*/


// MARK: - 處理佈局約束、封裝性。

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
    private let fullNameTextField = SignUpTextField(placeholder: "Full Name", rightIconName: "person.fill")
    
    /// 電子郵件標籤及輸入框
    private let emailLabel = SignUpLabel(text: "Email", fontSize: 14, weight: .medium, textColor: .darkGray)
    private let emailTextField = SignUpTextField(placeholder: "Email", rightIconName: "envelope")

    /// 密碼標籤及輸入框
    private let passwordLabel = SignUpLabel(text: "Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    private let passwordTextField = SignUpTextField(placeholder: "Password", rightIconName: "eye", isPasswordField: true)
    
    /// 確認密碼標籤及輸入框
    private let confirmPasswordLabel = SignUpLabel(text: "Confirm Password", fontSize: 14, weight: .medium, textColor: .darkGray)
    private let confirmPasswordTextField = SignUpTextField(placeholder: "Confirm Password", rightIconName: "eye", isPasswordField: true)
    
    /// 同意條款勾選框與按鈕
    private let termsCheckBox = SignUpCheckBoxButton(title: " I agree to the terms")
    private let termsButton = SignUpAttributedButton(mainText: "", highlightedText: "Read the terms", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)
    
    /// 註冊按鈕
    private let signUpButton = SignUpFilledButton(title: "Sign Up", textFont: .systemFont(ofSize: 18, weight: .black), textColor: .white, backgroundColor: .deepGreen)
    
    /// 分隔線與第三方登入按鈕
    private let separatorView = SignUpSeparatorView(text: "Or Sign Up with", textColor: .lightGray, lineColor: .lightGray)
    private let googleLoginButton = SignUpFilledButton(title: "Sign Up with Google", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "google48")
    private let appleLoginButton = SignUpFilledButton(title: "Sign Up with Apple", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "apple50")
    
    
    // MARK: - StackView
    
    /// 主垂直 StackView，用來排列主要的 UI 元素
    private let mainStackView = SignUpStackView(axis: .vertical, spacing: 15, alignment: .fill, distribution: .fill)
    
    /// Label 與 TextField 的垂直 StackView
    private let fullNameStackView = SignUpStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    private let emailStackView = SignUpStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    private let passwordStackView = SignUpStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    private let confirmPasswordStackView = SignUpStackView(axis: .vertical, spacing: 6, alignment: .fill, distribution: .fill)
    
    /// 排列 "我同意該條款" 和 "閱讀條款" 按鈕的水平 StackView，便於水平展示這兩個按鈕
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
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 20),
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
    
    // MARK: - Public Getters for UI Elements
    
    
    // MARK: Text Fields

    /// 獲取使用者輸入的全名
    /// - Returns: 使用者輸入的全名字串 (Full Name)，若無輸入則返回空字串
    func getFullName() -> String {
        return fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 獲取使用者輸入的電子郵件地址
    /// - Returns: 使用者輸入的電子郵件地址字串 (Email)，若無輸入則返回空字串
    func getEmail() -> String {
        return emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 獲取使用者輸入的密碼
    /// - Returns: 使用者輸入的密碼字串 (Password)，若無輸入則返回空字串
    func getPassword() -> String {
        return passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 獲取使用者輸入的確認密碼
    /// - Returns: 使用者輸入的確認密碼字串 (Confirm Password)，若無輸入則返回空字串
    func getConfirmPassword() -> String {
        return confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    // MARK: Buttons
    
    /// 提供註冊按鈕的公共存取方法
    /// - Returns: 註冊按鈕 (Sign Up Button)
    func getSignUpButton() -> UIButton {
        return signUpButton
    }
    
    /// 提供 Google 登入按鈕的公共存取方法
    /// - Returns: 使用 Google 登入的按鈕 (Google Sign Up Button)
    func getGoogleSignUpButton() -> UIButton {
        return googleLoginButton
    }
    
    /// 提供 Apple 登入按鈕的公共存取方法
    /// - Returns: 使用 Apple 登入的按鈕 (Apple Sign Up Button)
    func getAppleSignUpButton() -> UIButton {
        return appleLoginButton
    }
    
    /// 提供閱讀條款按鈕的公共存取方法
    /// - Returns: 閱讀條款按鈕 (Terms Button)
    func getTermsButton() -> UIButton {
        return termsButton
    }
    
    /// 提供「我同意條款」的勾選框按鈕的公共存取方法
    /// - Returns: 「我同意條款」勾選框按鈕 (Terms CheckBox Button)
    func getTermsCheckBox() -> UIButton {
        return termsCheckBox
    }
    
    // MARK: Terms CheckBox Methods
    
    /// 啟用「我同意條款」勾選框，使其可以被用戶選擇。
    /// - 注意：通常在用戶已閱讀並同意條款後，才會調用此方法來啟用該選項。
    func enableTermsCheckBox() {
        setTermsCheckBoxEnabled(true)
    }
    
    /// 設置「我同意條款」勾選框的啟用狀態
    /// - Parameter enabled: 設定勾選框是否可以被用戶操作 (true 表示啟用，false 表示禁用)
    func setTermsCheckBoxEnabled(_ enabled: Bool) {
        termsCheckBox.isEnabled = enabled
    }
    
    /// 檢查「我同意條款」勾選框的選中狀態
    /// - Returns: 布林值，表示勾選框當前是否被選中 (true 表示已選中，false 表示未選中)
    func isTermsCheckBoxSelected() -> Bool {
        return termsCheckBox.isSelected
    }
    
    /// 檢查「我同意條款」勾選框是否啟用
    /// - Returns: 布林值，表示勾選框當前是否可被操作 (true 表示可操作，false 表示不可操作)
    func isTermsCheckBoxEnabled() -> Bool {
        return termsCheckBox.isEnabled
    }
    
    /// 切換「我同意條款」勾選框的選中狀態
    /// - 根據當前狀態切換勾選框的選中與未選中狀態。
    /// - 如果目前是選中狀態，則取消選中；如果目前未選中，則設置為選中。
    /// - 無返回值
    func toggleTermsCheckBoxSelection() {
        termsCheckBox.isSelected.toggle()
    }
    
}
