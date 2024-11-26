//
//  HomePageView.swift.
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/26.
//

// MARK: - 重構 `HomePageView` 筆記：`required init?(coder:)` 的使用與應用情境

/**

 ## 重構 `HomePageView` 筆記：`required init?(coder:)` 的使用與應用情境

 - https://reurl.cc/04Dkko  (從程式生成 view controller 時搭配自訂的 init 傳資料)
 - https://reurl.cc/ge8NNz (防止絕技失傳的 required initializer)
 
 `1. What 是什麼？`
 
 - `required init?(coder:)` 是用來初始化從 Storyboard 或 XIB 加載的 UIView 初始化方法。
 - 當透過 Interface Builder（如 Storyboard）來建立 UIView 時，系統會呼叫這個方法來解碼並載入視圖。
 - 而在我的情況下，`HomePageView` 是由程式碼動態生成的，並不會直接透過 Storyboard 加載。

 `2. Why 為什麼？`
 
 - 因為是在程式碼中自行生成 `HomePageView`，所以其實不需要 `required init?(coder:)` 的實作。
 - 這個初始化方法是專門用於當我們希望 UIView 從 Storyboard 中加載時才需要的。
 - 如果 `HomePageView` 僅僅由程式碼創建並添加到 `HomePageViewController` 中，那麼 `required init?(coder:)` 並不會被用到。因此可以選擇不實作或使用 `fatalError` 來提醒這個初始化方式不適用於這個類別。

 ----------------------------------------------------------------
 
` 3. When 何時需要在 required init?(coder:) 設置？`

 - 在某些情境下，需要在 `required init?(coder:)` 中進行設定，以確保 UIView 在使用 Storyboard 加載時能正常初始化：

 `*. 從 Storyboard 或 XIB 加載時：`
 
 - 如果在 Storyboard 中拉`出一個 UIView`，並且將這個 UIView 的 "Class" 設定為 `HomePageView`，那麼這個視圖就是透過 Storyboard 加載的。
 - 在這種情況下，系統會自動呼叫 `required init?(coder:)` 來初始化 `HomePageView`。因此需要在這個方法中進行相關設定（例如：呼叫 `setupSubviews()`），確保視圖能正確顯示程式碼生成的子視圖。

 `*. 需要保持 UI 一致性時：`
 
 - 當一個 UIView 可能既會透過程式碼初始化，也可能透過 Storyboard 加載時，為了確保 UI 一致，必須在 `required init?(coder:)` 中設置與程式碼初始化相同的初始化邏輯。
 - 例如：可能希望不論是從 Storyboard 還是程式碼建立，這個視圖都包含一些特定的子視圖或樣式設定。

 `*. 未來可能支援 Storyboard 加載時：`
    
 - 當認為未來專案有可能會使用 Storyboard 來加載目前由程式碼生成的視圖時，可以考慮在 `required init?(coder:)` 中進行設定。這樣可以在需要變更成 Storyboard 加載的時候減少重構的麻煩。

 ----------------------------------------------------------------

 `4. How 如何做？`
 
 - 對於 `HomePageView`，因為你是通過程式碼生成並添加到 `HomePageViewController` 中，因此有以下兩種方式來實作：

 `方式一：使用 fatalError`
 
 - 如果確定 `HomePageView` 不會從 Storyboard 或 XIB 加載，則可以選擇在 `required init?(coder:)` 中加上 `fatalError`，這樣可以保證當有人嘗試用 Storyboard 加載時，程式會直接崩潰並提醒這是不被支援的方式。

 ```swift
 override init(frame: CGRect) {
     super.init(frame: frame)
     setupSubviews() // 設定子視圖
 }

 required init?(coder: NSCoder) {
     super.init(coder: coder)
     fatalError("init(coder:) has not been implemented")
 }
 ```

 `方式二：不加 fatalError，但保持簡單`
 
 - 也可以選擇實作 `required init?(coder:)`，但不執行任何 `setupSubviews()`。這樣是為了避免如果未來需要修改成可以支援 Storyboard 加載時，這個方法還是存在的，但這取決於專案未來的需求。

 ```swift
 override init(frame: CGRect) {
     super.init(frame: frame)
     setupSubviews() // 設定子視圖
 }

 required init?(coder: NSCoder) {
     super.init(coder: coder)
     // 不執行 setupSubviews()，因為目前不支援 Storyboard 加載
 }
 ```
 ----------------------------------------------------------------

 `5. 何時選擇哪種方式？`
 
 - `方式一`：如果非常確定 `HomePageView` 不會從 Storyboard 加載，那麼使用 `fatalError` 是更安全的做法，這樣可以在有人誤用時立即報錯。
 - `方式二`：如果覺得將來有可能會讓 `HomePageView` 支援從 Storyboard 加載，那麼保留 `required init?(coder:)`，但不進行初始化，是一種比較保險的方式。

 ----------------------------------------------------------------

 `6. 小結`
 
 - 當確定 UIView 會被從 Storyboard 加載時（例如在 Storyboard 中拉出一個 UIView 並將其類別設置為自定義的 `HomePageView`），必須在 `required init?(coder:)` 中進行初始化設置，以確保所有 UI 一致。
 - 而如果 UIView 只會從程式碼生成，則可以在 `required init?(coder:)` 中使用 `fatalError` 來避免誤用的情況。
 */


// MARK: - UI 元件與 `UIStackView` 的佈局和約束處理筆記
/**
 
 ## UI 元件與 `UIStackView` 的佈局和約束處理筆記

 `1. UI 元件與 `UIStackView` 的約束衝突處理順序`

 `* What 是什麼？`
 
 - 當將 UI 元件（例如 UIButton）添加到 `UIStackView` 中時，`UIStackView` 會自動管理它的子視圖的尺寸和間距，包括高度和寬度等相關屬性。
 - 因此，如果在子視圖本身（例如 UIButton）上直接設置固定的高度或寬度，可能會與 `UIStackView` 的內部佈局邏輯發生衝突，導致不預期的行為，甚至 UI 顯示異常。

 ----------------------------------------------------------------

 `Why 為什麼會發生衝突？`
 
 - `UIStackView 自動管理`：`UIStackView` 會根據設定的 `axis`、`alignment`、`distribution` 等屬性自動調整它的子視圖。因此，若在子視圖本身設置固定高度或寬度，這些約束可能與 `UIStackView` 的自動管理邏輯相互衝突。
 - `衝突的情境`：當在 `createButton` 等 Factory Method 中直接設置固定高度，`UIStackView` 可能會試圖根據其配置來重新調整按鈕大小，從而導致 `Auto Layout` 警告或顯示不正確的行為。

 ----------------------------------------------------------------

 `How 如何避免約束衝突？`
 
 - `在 setupSubviews() 中設置高度`：
   - 不要直接在 Factory Method 中設置高度限制。
   - 將高度的設置延後到 `setupSubviews()` 方法中，當元件已經被加入到 `UIStackView` 之後，才針對其具體設置高度，這樣可以更好地管理和控制。
   
   ```swift
   private func setupSubviews() {
       // 將按鈕加入 StackView
       buttonsStackView.addArrangedSubview(loginButton)
       buttonsStackView.addArrangedSubview(signUpButton)

       // 將 StackView 加入主視圖
       addSubview(buttonsStackView)

       // 設置 StackView 的 Auto Layout
       NSLayoutConstraint.activate([
           buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
           buttonsStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
           buttonsStackView.widthAnchor.constraint(equalToConstant: 200)
       ])

       // 設置每個按鈕的高度
       NSLayoutConstraint.activate([
           loginButton.heightAnchor.constraint(equalToConstant: 50),
           signUpButton.heightAnchor.constraint(equalToConstant: 50)
       ])
   }
   ```
 
 - `依賴 `UIStackView` 自身的屬性來處理：`
   - 使用 `UIStackView` 的 `distribution` 和 `spacing` 來處理子視圖的間距和大小，例如 `.fillEqually` 可以讓每個子視圖的大小自動相等。

 ----------------------------------------------------------------

 `2. 在不同螢幕大小下的佈局選擇`
 
 `*. 依賴 UIStackView 的 distribution 和 spacing（更具自適應性）`
 
    `- 優勢：`
      - 提供自適應佈局，能夠根據螢幕大小自動調整子視圖的大小和間距。
      - 減少手動設置的複雜性，並且在不同螢幕之間保持一致的比例和佈局。
      - 這樣的佈局方式可以確保 UI 在所有裝置上都能適應，提供更好的使用體驗。
 
    `- 適合的情境：`
      - 當 UI 元件的大小需要根據螢幕的不同自動調整時。
      - 希望 UI 在大、小螢幕之間保持比例一致，而不是固定大小。
   
    `- 示例：`
      ```swift
      let buttonsStackView = UIStackView(arrangedSubviews: [loginButton, signUpButton])
      buttonsStackView.axis = .vertical
      buttonsStackView.spacing = 20
      buttonsStackView.alignment = .center
      buttonsStackView.distribution = .fillEqually
      ```

 `*. 在 setupSubviews() 中設置固定高度（精確控制）`
 
    `- 優勢：`
      - 可以精確控制每個元件的尺寸，使得它們在不同裝置上保持一致的大小。
      - 當某些 UI 元件（例如按鈕）需要在所有裝置上看起來一致時，手動設置固定高度是更可預測的選擇。
 
    `- 缺點：`
      - 缺少自適應性，當螢幕較小時可能會導致 UI 元件過於擁擠，無法充分利用空間。
 
    `- 適合的情境：`
      - 需要 UI 元件在各種裝置上保持一致高度，不考慮螢幕大小變化時。

 ----------------------------------------------------------------

 `3.如何選擇合適的佈局方法？`
 
 - `優先考慮自適應性佈局`：在大多數情況下，尤其是面對多種裝置時，使用 `UIStackView` 的 `distribution` 和 `spacing` 來實現自適應佈局是最佳選擇，這樣可以確保 UI 在不同螢幕尺寸間的兼容性和一致性。
 - `精確控制時使用固定高度`：在某些需要精確控制視覺呈現的場景（例如：品牌按鈕必須保持相同的大小），可以考慮設置固定高度，但需要注意這樣可能會影響自適應性。

 ----------------------------------------------------------------

 `4. 綜合小結`
 
 - `避免與 UIStackView 的約束衝突`：
   - 避免在 Factory Method 中直接設置子視圖的高度或寬度。
   - 在 `setupSubviews()` 中設置高度，可以確保 `UIStackView` 已經將子視圖正確加入後，再進行額外的調整。
   
 - `在不同裝置上設計彈性佈局：`
   - 使用 `UIStackView` 的 `distribution` 和 `spacing`，可以保證子視圖根據不同的螢幕大小自動調整。
   - 固定高度適合在對 UI 一致性要求高、需要精確控制的情境中使用，但需考慮小螢幕可能會影響顯示效果。
 */


// MARK: - HomePageView 重點筆記

/**

 ## HomePageView 重點筆記

` 1. 背景設置`
 
    - 使用 `setupBackground()` 設置背景色為 `.deepGreen`，確保整個視圖保持一致的顏色。
    - 在自定義的視圖中設置背景色即可，不需要在其控制器（`HomePageViewController`）中再額外設定。

 `2. Logo 圖片視圖`
 
    - 使用 `createImageView()` 建立 `logoImageView`，保持可讀性及重用性。
    - `logoImageView` 設置為 `centerYAnchor` 向上偏移 50 點，以確保 Logo 視覺上更加接近畫面上半部。
    - 保持 `logoImageView` 的比例（長寬一致），並根據父視圖寬度的 75% 設定其大小，確保在不同裝置上適應性良好。

 `3. 按鈕的設置`
 
    - 使用`createButton()` 建立 `loginButton` 和 `signUpButton`，設定字體、背景顏色、文字顏色等屬性，以簡化代碼且便於重用。
    - 將按鈕放入 `buttonsStackView` 中，以便於管理按鈕的排列與對齊，並保持垂直方向上按鈕之間的間距一致（18 點）。
    - 設定每個按鈕的高度為 55 點，以確保在所有裝置上的一致性。

 `4. 按鈕的點擊事件`
 
    - 使用 `setupActions()` 為按鈕添加點擊事件處理器，並透過委託（`delegate`）將事件通知給 `HomePageViewController`。
    - `delegate` 的設置可以讓 `HomePageView` 與控制器分離，增強代碼的模組化和重用性。

 `5. 佈局設置`
 
    - `logoImageView` 和 `buttonsStackView` 的 Auto Layout 是分開設置的，以便分別控制 Logo 和按鈕的佈局。
    - `buttonsStackView` 固定於畫面底部（距離安全區域底部 25 點），且水平方向上距離安全區域邊緣 30 點，保持適當的留白。
 */

import UIKit

/// HomePageView: 主畫面視圖，包含 Logo 以及登入和註冊按鈕
class HomePageView: UIView {
    
    // MARK: - Properties
    
    /// 委託，用來通知 HomePageViewController 發生的事件
    weak var delegate: HomePageViewDelegate?
    
    /// 星巴克 Logo 圖片視圖
    private let logoImageView = HomePageView.createImageView(imageName: "starbucksLogo", contentMode: .scaleAspectFit)

    /// 建立登入按鈕
    private let loginButton = HomePageView.createButton(title: "Login", font: UIFont.systemFont(ofSize: 22, weight: .black), backgroundColor: .deepGreen, titleColor: .deepBrown)
    
    /// 建立註冊按鈕
    private let signUpButton = HomePageView.createButton(title: "Sign Up", font: UIFont.systemFont(ofSize: 22, weight: .black), backgroundColor: .deepGreen, titleColor: .deepBrown)
    
    /// 用來排列按鈕的垂直 StackView
    private let buttonsStackView = HomePageView.createStackView(axis: .vertical, spacing: 18, alignment: .fill, distribution: .fill)
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    /// 初始化視圖，包含背景色、Logo、按鈕等組件的配置
    private func setupView() {
        setupBackground()
        setupLogoImageView()
        setupButtonsStackView()
        setupActions()
    }

    /// 設置背景色為深綠色，保持與品牌風格一致
    private func setupBackground() {
        backgroundColor = .deepGreen
    }
    
    /// 設置` Logo 圖片視圖`，並放置於`畫面中央上方`
    private func setupLogoImageView() {
        addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),  // 中心向上偏移 50 點
            logoImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)       // 保持長寬比一致
        ])
    }
    
    /// 設置`按鈕 StackView`，並放置於`畫面底部`
    private func setupButtonsStackView() {
        buttonsStackView.addArrangedSubview(loginButton)
        buttonsStackView.addArrangedSubview(signUpButton)
        addSubview(buttonsStackView)
        
        // 設定 Buttons StackView 的 Auto Layout
        NSLayoutConstraint.activate([
            buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -25),
            buttonsStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            buttonsStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30)
        ])
        
        // 設置按鈕的高度為 55 點
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 55),
            signUpButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    /// 設置按鈕的點擊事件，透過委託將事件通知給控制器
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    /// 登入按鈕被點擊，通知委託
    @objc private func loginButtonTapped() {
        delegate?.didTapLoginButton()
    }
    
    /// 註冊按鈕被點擊，通知委託
    @objc private func signUpButtonTapped() {
        delegate?.didTapSignUpButton()
    }
    
    // MARK: - Factory Method
    
    /// 建立 UIImageView，設定圖片名稱及顯示模式
    private static func createImageView(imageName: String, contentMode: UIView.ContentMode) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = contentMode
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    /// 建立按鈕，並設置其樣式和外觀，包括標題、字體、背景色、邊框等屬性
    private static func createButton(title: String, font: UIFont, backgroundColor: UIColor, titleColor: UIColor) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = titleColor
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置邊框屬性
        button.layer.borderColor = UIColor.deepBrown.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }
    
    /// 建立 UIStackView，設定排列方向、間距、對齊方式和分佈方式
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
}
