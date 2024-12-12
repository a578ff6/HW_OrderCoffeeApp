//
//  LoginView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/17.
//

/**
 A. 佈局部分：
    * titleLabel.topAnchor 使用 view.safeAreaLayoutGuide.topAnchor 而不是 view.topAnchor 。是為了確保在所有設備上（尤其是帶有瀏海的設備）都有一致的佈局。
    
    * Safe Area：
        - 避免被遮擋： safeAreaLayoutGuide 確保視圖的內容不會被系統 UI 元件（狀態欄、NavigationBar、工具欄、瀏海）遮擋。
 
    * 適應不同的設備：
        - 尤其是 iPhone X 及後續機種引入了瀏海。safeAreaLayoutGuide 動態調整，使內容區域適應遮些變化，而 topAnchor 是固定的，可能會導致內容被系統願見覆蓋。
*/

// MARK: - LoginView 元件設計重點筆記（重要）
/**

 ## LoginView 元件設計重點筆記
 
 - 主要UI元件比較多，原先 LoginView 過於臃腫，導致可讀性變差。
 - 先嘗試以前常用的 Factory method寫法試著進行整理，但對於一些較複雜的設計「separatorAndTextView」使用claee做到更好的封裝化。
 - 再加上我有設計 BottomLineTextField 繼承 UITextField，想說統一寫法風格，也藉此比較好閱讀。
 - 所以我後來改成使用繼承的方式來處理。

 --------------------------------------------
 
 `* 設計模式選擇：Factory 模式 vs 繼承方式`

 `1. 使用 Factory 模式的優點`
 
 - `集中管理元件創建邏輯`：
   - 將元件的創建集中管理於 Factory 類別中（如 `LoginLabelFactory` 和 `LoginButtonFactory`），使得每次創建元件時只需調用相應的方法，代碼保持簡潔且易於維護。
   - 例如，需要修改所有 `Label` 的字體大小，只需要在 Factory 方法中進行一次更改即可，所有引用該方法的地方會同步更新。

 - `高重用性與靈活性`：
   - Factory 方法允許通過不同參數來控制元件的外觀和行為，如文本、顏色或字體等，能快速創建風格一致但參數不同的元件。
   - Factory 方法避免了針對每一種變化創建新類別的麻煩，提高了代碼的可重用性和靈活性。

 - `職責劃分清晰`：
   - Factory 類別負責元件的創建和初始化，`LoginView` 負責布局邏輯，這樣能讓代碼職責更加單一，增加可讀性和可維護性。

 --------------------------------------------

 `2. 使用繼承的考量`
 
 - `降低 LoginView 的肥大`：
   - 將元件的創建和配置從 `LoginView` 中抽出來，改為自訂的類別，如 `LoginTextField`、`LoginButton` 等，以減少 `LoginView` 的代碼複雜度和責任範圍，使其更專注於佈局。

 - `高一致性`：
   - 通過自訂類別（例如 `LoginStackView`、`LoginTextField`），這些元件可以有一致的設置和行為，確保在整個應用中保持統一的風格。繼承的方式能自然地封裝元件的屬性，讓使用這些元件變得簡單明瞭。

 - `減少重複代碼`：
   - Factory 方法雖然靈活，但每次使用時都需要手動傳入參數。相較於此，繼承的方式可以預設好這些屬性，開發者只需實例化對應的類別即可，減少重複設定相同參數的情況。

 - `提高重用性與可維護性`：
   - 自訂元件類別可以在不同的視圖控制器中重用，例如，`LoginTextField` 可以被任何其他需要底線樣式的輸入框的界面重用。
   - 當需要修改這些元件的樣式或行為時，只需在類別中進行修改，整個應用中使用的地方都會隨之更新。

 --------------------------------------------

` 3. Factory vs. 繼承 - 何時選擇哪一種？`
 
 - `選擇 Factory 模式：`
   - 當元件屬性需要高度定制化，且樣式和邏輯變化多樣時，使用 Factory 模式更適合。工廠方法可以根據不同參數創建多種風格的一致元件。
   - Factory 模式的優勢在於能靈活地設置元件的外觀屬性，並保持創建邏輯的集中性和一致性。

 - `選擇繼承方式：`
   - 當元件的屬性較為固定，且需要封裝特定邏輯和行為時，使用繼承更加合適。繼承能使元件的設置集中在一個類別中，且能簡化元件的使用過程。
   - 如果目的是降低 `LoginView` 的代碼量，並讓元件設置統一且不重複，繼承方式比 Factory 更能達成這個目標。例如，你可以創建一個 `LoginScrollView` 或 `LoginStackView`，這樣只需要簡單的初始化即可，不用每次手動配置參數。

 --------------------------------------------

 `4. LoginSeparatorView 的設計選擇 - 一個典型例子（重要）`

 `* Why 使用繼承代替 Factory：`
 
 - LoginSeparatorView 是一個由多個子元件（兩條橫線和一個文本標籤）組成的視圖，擁有較為複雜的組合邏輯。
 - 使用類別繼承方式來封裝這些元件能讓它們的創建和組合邏輯更加集中，讓代碼更加具可讀性，並且符合單一職責原則。
 - 相較於 Factory 方法，繼承方式能更好地封裝這些元件之間的依賴關係，且能方便地在不同情境下進行複用。
 - 例如，如果有一天需要改變 LoginSeparatorView 的樣式（如改變橫線顏色或增加動畫效果），只需在這個類別中進行修改，所有引用該視圖的地方會自動更新，提升了可維護性。

 --------------------------------------------

 `5. Factory 和繼承混用的設計建議`
 
` * 維持 Factory 模式和繼承混用的設計：`

 - 在目前設計中，對於需要高定制化的元件可以繼續使用 Factory 方法，而對於固定風格且多次重用的元件，建議改用繼承來減少代碼量和複雜度。
 - 對於像 LoginSeparatorView 這樣包含多個元件的組合視圖，使用類別更能達到封裝和可維護的目的，而不會因多次傳參數而使代碼變得難以閱讀。
 
 `* 統一風格並降低 LoginView 的肥大：`

 - 將視圖元件（如 LoginTextField、LoginLabel、LoginStackView）拆分成獨立類別，可以降低 LoginView 的複雜度，讓它更專注於管理整體佈局，符合 "單一責任原則"。
 - 使用自訂類別來繼承 UIKit 元件（例如 LoginScrollView），確保一致的樣式和簡化配置，這樣可以讓代碼更加清晰並且易於維護。
 
 --------------------------------------------

` 6. 最終結論`
 
 - 繼承方式比 Factory 更適合目前需求，尤其是希望降低 LoginView 的肥大並統一風格的情況下。
 - 通過將元件的創建邏輯封裝到各自的類別中，可以讓代碼更加簡潔，減少重複，並且使得 LoginView 的責任更加單一。
 - Factory 方法仍然有其優勢，適合用於需要高度靈活的元件創建情境，而繼承方式適合在元件風格固定且需要簡化創建過程時使用。
 - `保持靈活選擇`：兩者結合使用，根據具體元件的特性選擇最合適的方式，這樣可以達到最優化的代碼結構和風格統一目標。
 */
 

// MARK: - 設置 UIScrollView 的採用
/**
 
 ## 設置 UIScrollView 的採用
 
 `What: 設置 UIScrollView`

 - 在 LoginView 中，設置了 `UIScrollView` 來包覆所有的 UI 元件。這些元件包括標籤、輸入框、按鈕等。
 - 因為這些元件可能會超過螢幕的可視範圍，尤其在較小的裝置上，因此需要滾動的支援來讓所有內容都可以被完整地呈現。

 --------------------------------------------

 `Why: 為何使用 UIScrollView`

 `1. UIView 本身沒有滾動功能：`

 - `UIView` 是靜態的顯示元件，本身無法提供滾動功能，當畫面上的內容過多時，會導致部分元件無法顯示出來。

 `2. 元件過多且不規則：`
 
 - 在 `LoginView` 中，有不同種類的 UI 元件，這些元件不是以重複的列表形式排列，而是單一佈局，包含多個標籤、輸入欄位、按鈕等。
 - 如果不使用滾動，這些元件在小螢幕裝置上會被截斷或者與其他元件重疊，影響使用者體驗。

 `3. 適應不同裝置尺寸：`
 
 - 為了讓這些 UI 元件能在各種不同尺寸的裝置上都能完整顯示，使用 `UIScrollView` 提供滾動功能是一個合適的解決方案。
 - 這樣，無論裝置的螢幕大小如何，使用者都可以滾動以查看所有內容。

 --------------------------------------------

 `How: 如何設置 UIScrollView`

 1. 將 UIScrollView 包含在主視圖中：

 - 在 `LoginView` 中，首先新增一個 `UIScrollView`，並將其加到主視圖中。然後再將所有的 UI 元件放入 `UIScrollView` 中。

 2. 配置 Auto Layout：
 
 - 為了確保 `UIScrollView` 能正確顯示所有內容，需要設定 `UIScrollView` 的 Auto Layout 約束，並確保內容的高度與 `UIScrollView` 能夠適應，讓它可以垂直或水平滾動，根據元件的配置來調整。

 3. 設置 StackView 作為 UIScrollView 的子視圖\：
 
 - 將主要的 UI 元件組合在一個 `UIStackView` 中，再把 `UIStackView` 放到 `UIScrollView` 內。這樣可以更容易管理和維護視圖佈局，同時保持清晰、整潔的結構。
 */


// MARK: - 使用 `setCustomSpacing(_:after:)` 為 StackView 元素設置自定義間距
/**
 
 ## 使用 `setCustomSpacing(_:after:)` 為 StackView 元素設置自定義間距

 `* 說明`
 
 - `UIStackView` 提供了一個方便的方法 `setCustomSpacing(_:after:)`，可以在特定的元素之後設置自定義的間距。
 - 這可以用來控制某些元素之間的空間，而不影響 `stackView` 中的其他元素。

 --------------------------------------------

 `* 使用方式`
 
 - 例如，在 `mainStackView` 中的 `signUpButton` 之前的元素 `otherLoginOptionsStackView` 設置較大的間距：

 ```swift
 // 為 signUpButton 前的元素（即 otherLoginOptionsStackView）設置較大的間距
 mainStackView.setCustomSpacing(30, after: otherLoginOptionsStackView)
 ```

 --------------------------------------------

 `* 適用情境`
 
 - 當 `stackView` 中的某些元素需要特殊的間距調整，而不希望改變整個 `stackView` 的 `spacing` 設定時，`setCustomSpacing(_:after:)` 是最佳的解決方案。
 - 保持其他元素的默認間距不變，但對個別視圖做細微調整，使得佈局更加靈活。

 --------------------------------------------

 `* 注意事項`
 
 - `setCustomSpacing` 只能對 `stackView` 中已經添加的 `arrangedSubview` 使用。
 - 它可以提高佈局的可讀性和靈活性，而不需要使用額外的「空白視圖」(spacer view) 來實現同樣的效果。`（重要）`

 --------------------------------------------

 `* 優點`
 
 - `簡單易用`：不需要額外的視圖來增加間距，直接在現有的元素之間設置即可。
 - `增強可讀性`：代碼更直觀，避免額外的視圖影響佈局的清晰度。
 */


// MARK: - 使用 UIButton.Configuration` 和 `setTitle` / `setTitleColor` 的差異進行分析（重要）

/**

 ## 使用 UIButton.Configuration` 和 `setTitle` / `setTitleColor` 的差異進行分析（重要）
 
 `* What:`
 
 - 在使用 `UIButton.Configuration` 設置按鈕（如 `forgotPasswordButton`）時，發現按鈕在 `UIStackView` 中無法對齊，並且會有多餘的空白間距。
 - 使用 Debug View Hierarchy 發現，可能是按鈕的系統背景層導致了不必要的間距。
 - 此外，當嘗試使用 `distribution: .fillEqually` 時，文字按鈕的文字被壓縮成兩行，顯示效果不理想。

 `* Why:`
 
 - `UIButton.Configuration` 是 iOS 15 引入的按鈕配置方式，帶來了更多的自動化調整和內建屬性，包括按鈕的邊距和內部內容的大小計算。這些屬性會影響按鈕在 Stack View 中的顯示，使得按鈕間的間距難以精確控制。
 - `UIButton.Configuration` 會根據內容自動設置內邊距，這些邊距可能導致在 `UIStackView` 中無法精確控制間距，進而影響對齊效果。

 `* How:`
 
 - 改用 `setTitle` 和 `setTitleColor` 的直接控制方式，避免使用 `UIButton.Configuration`，這樣就可以完全控制按鈕的文字、顏色、字體，以及避免額外的邊距設置，從而解決按鈕在 `UIStackView` 中對齊不準確的問題。

 -----------------------------------------------------
 
 ## 解決方案：`setTitle` 和 `setTitleColor` 的直接控制
 
 `* What:`
 
 - 使用 `setTitle` 和 `setTitleColor` 方法直接設置按鈕的標題和顏色，並通過 `titleLabel?.font` 設置文字的字體。
 - 這樣可以完全避免按鈕的自動邊距和內部配置導致的額外空間。

 `* Why:`
 
 - `setTitle` 和 `setTitleColor` 方式提供更細粒度的控制，沒有多餘的內建屬性和邊距，能夠更好地適應 `UIStackView` 中的佈局需求。
 - 這樣的方式非常直觀且簡單，沒有自動調整行為，確保按鈕的大小由內容決定，而不會受到額外配置的影響。

 `* How:`
 
 - 使用以下方法來創建按鈕，並直接設置標題、顏色和字體：
   ```swift
   private static func createTextButton(title: String, fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, textColor: UIColor = .black) -> UIButton {
       let button = UIButton(type: .system)
       button.setTitle(title, for: .normal)
       button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
       button.setTitleColor(textColor, for: .normal)
       button.translatesAutoresizingMaskIntoConstraints = false
       return button
   }
   ```
 -----------------------------------------------------

 ## UIButton.Configuration 的自動調整行為
 
 `* What:`
 
 - `UIButton.Configuration` 是 iOS 15 引入的新設置按鈕外觀的方式，旨在提供更高層次的配置，減少手動設置按鈕屬性的複雜性。

 `* Why:`
 
 - 使用 `UIButton.Configuration` 時，系統會自動為按鈕設置一些內部屬性，包括內邊距、字體和顏色等。
 - 這些自動調整行為使按鈕更具靈活性，但在精確控制佈局時可能會引入多餘的空間，使得按鈕在 `UIStackView` 中的對齊受到影響。

 `* How:`
 
 - 若仍希望使用 `UIButton.Configuration`，可以通過手動調整配置來減少不必要的自動調整。例如：
   - 使用 `.contentInsets = .zero` 來移除預設的內邊距。
   - 使用 `titleTextAttributesTransformer` 來調整字體屬性。

   ```swift
   private static func createTextButtonUsingConfiguration(title: String, fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, textColor: UIColor = .black) -> UIButton {
       let button = UIButton(type: .system)
       var config = UIButton.Configuration.plain()
       config.title = title
       config.baseForegroundColor = textColor
       config.contentInsets = .zero  // 移除內邊距
       config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
           var updated = incoming
           updated.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
           return updated
       }
       button.configuration = config
       button.translatesAutoresizingMaskIntoConstraints = false
       return button
   }
   ```
 -----------------------------------------------------

 ## 比較與總結
 
` 1. UIButton.Configuration  的優點：`
 
    - 更現代化的配置方式，特別是在 iOS 15 及以上的環境中，能方便地設置按鈕的多種屬性。
    - 適合需要統一按鈕風格的場景。

 `2. setTitle 和 setTitleColor 的優點：`
 
    - 更加直觀和簡單的設置方式，適合需要精確控制按鈕樣式和佈局的場景。
    - 沒有多餘的自動調整行為，確保按鈕的樣式完全由開發者決定。

 `3. 建議：`
 
    - 如果需要統一樣式，且對按鈕的佈局要求不高，使用 `UIButton.Configuration` 是較好的選擇。
    - 如果需要精確控制按鈕的外觀和間距，尤其是處理佈局精確的場景，如在 `UIStackView` 中，建議使用 `setTitle` 和 `setTitleColor` 等直接設置方式。
 */


// MARK: - LoginView: email 和 password 處理方式筆記
/**
 
 ## LoginView: email 和 password 處理方式筆記

 `1. 是否需要使用 emailTextChanged 和 passwordTextChanged 的閉包監聽？`

 `* 當前的情況：`

 - 在 `LoginViewController` 中，主要的操作是通過按鈕點擊來觸發登入流程，而不是依賴於使用者每次輸入變化。
 - 因此，LoginView 不需要使用 emailTextChanged 和 passwordTextChanged 這類閉包監聽來即時回傳使用者輸入。

 `* 為什麼不使用閉包監聽？`
 
 `1.行為邏輯的簡化：`
 
 - 當用戶輸入時，無需即時反應（如格式驗證或 UI 狀態更新）。
 - 登入的核心邏輯在按鈕點擊後執行，無需過早處理輸入變化。
 
 `2.避免不必要的複雜性：`
 
 - 添加閉包監聽會引入更多依賴和回呼，增加 LoginView 的複雜性。
 - 現階段並無需求，即時監聽輸入只會增加不必要的邏輯。

 `* 閉包監聽的適用場景：`
 
 `1.即時輸入驗證：`
 
 - 例如檢查 email 是否符合格式，並即時顯示錯誤提示。
 
 `2.動態 UI 更新：`
 
 - 根據使用者輸入動態啟用/禁用按鈕（如當 email 與 password 都非空時才啟用登入按鈕）。

 ------------------------------------------
 
 `2. 封裝性與使用者界面交互的考量`

 `* 封裝性：`
 
 - `LoginView` 主要應該負責顯示與收集使用者輸入，不應包含過多的邏輯或即時處理需求。
 -  提供 email 和 password 的 computed properties（計算屬性），讓 LoginViewController 能快速取得輸入值，而不直接暴露 UI 元件。

 `* 使用 computed properties 的好處：`
 
 - 更簡潔的存取方式：只需通過 `emailText` 和 `passwordText` 屬性即可獲取使用者的輸入。
 - 符合封裝性：`LoginView` 仍然只負責提供 UI 元件的顯示和使用者輸入，不會在不必要的地方增加複雜性。

 ------------------------------------------

 `3. 想法`
 
` * 當前處理方式：`

 - 移除閉包監聽，僅使用 `computed properties` 提供 `email` 和 `password`，符合當前需求，並保持設計簡潔。
 
 `* 封裝與職責分離：`

 - LoginView 負責 UI 和輸入的封裝，LoginActionHandler 與 LoginViewController 負責行為邏輯，清晰劃分各類別職責。
 
 `* 漸進式設計：`

 - 根據當前需求保持簡潔設計，未來若有即時輸入驗證或 UI 更新需求，再逐步引入閉包監聽以擴展功能，避免過度設計或增加不必要的複雜度。
 
 */


// MARK: - LoginView 與 LoginActionHandler 職責改善筆記（重要）
/**
 
 ## LoginView 與 LoginActionHandler 職責改善筆記

 `* What`
 
 - 對於 `LoginView`，我將按鈕的行為部分抽離出來，並使用 `LoginActionHandler` 來負責所有的使用者行為。
 - 這樣的重構使得 `LoginView` 專注於 UI 元素的佈局，提升了整體的結構清晰度與責任分離。

 ------------------------------------------------------------

 `* Why`
 
 - 責任分離：將按鈕的行為和操作邏輯從 `LoginView` 中移除，讓 `LoginView` 僅負責畫面佈局與 UI 設置，實現單一職責原則（SRP）。
 - 降低耦合度：通過使用 `LoginActionHandler` 來管理按鈕行為，避免 UI 元素與行為邏輯過度耦合，使程式碼更具維護性和可測試性。
 - 避免強引用循環：透過弱引用 (`weak var`) 來指向 `LoginView` 和 `LoginViewDelegate`，避免因互相引用而造成的記憶體洩漏。

 ------------------------------------------------------------

 `* How`
 
 `1. LoginView 設置改動：`
 
 - `移除按鈕的行為邏輯：`
    - 將按鈕的 addTarget 方法移除，改由 `LoginActionHandler` 添加行為。
 
 - `提供 getter 方法：`
    - 為按鈕提供 `private(set) `存取控制，必要時使用公開的 getter 方法讓外部類別安全訪問。
 
 -----
    
 `2. LoginActionHandler 設置：`
 
 - `集中管理按鈕行為：`
    - 在 LoginActionHandler 中，使用 LoginView 的 getter 方法或 private(set) 的屬性來獲取按鈕，並統一添加行為邏輯。
 
 - `透過 delegate 將按鈕事件通知到控制器：`
 
 ```swift
 view.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
 ```
 
 - `初始化：`
    - 在 `setupActions()` 方法中，完成所有按鈕行為的綁定。
 
 -----
 
 `3. LoginViewController 設置：`
 
    - 在 `viewDidLoad()` 中初始化 `LoginActionHandler`，並將 `LoginView` 和 `LoginViewDelegate` 傳入，讓 `LoginActionHandler` 負責管理按鈕行為。

 ------------------------------------------------------------

 `* Summary（總結）`
 
    - 透過引入 `LoginActionHandler`，實現了責任分離與降低耦合度，讓 `LoginView` 專注於 UI，`LoginActionHandler` 專注於使用者行為管理。
    - 這樣的設計不僅改善了程式碼的清晰度與可讀性，也讓未來的維護和擴展變得更容易。
 */


// MARK: - LoginView 元件存取方式筆記
/**
 ## LoginView 元件存取方式筆記

 * 重構背景
 
 1. 一開始設計 LoginView 時，所有元件屬性均設為 private，並透過 getter 方法提供外部存取。
 2. 隨後進行了「按鈕行為分離」的重構，將按鈕行為設置的邏輯轉移到 LoginActionHandler，這讓按鈕需要被外部類別訪問以綁定行為。
 3.在決定按鈕的存取方式時，考量過以下選項：
 
 - 公開按鈕屬性（例如設為 public 或 internal）。
 - 維持封裝性，僅透過 private(set) 或 getter 方法提供存取。
 - 經過權衡後，選擇了使用 private(set) 與少量 getter 的方式，保持封裝性和低耦合設計。
 
 ------------------------------------------------------------

 `* What`
 
 1.在 LoginView 中，所有按鈕和 UI 元件預設為 private，僅在必要時使用 `private(set)` 或 `getter` 方法 提供外部存取。
 
 2.使用了 private(set) 修飾的按鈕包括：
 
 - loginButton
 - googleLoginButton
 - appleLoginButton
 - forgotPasswordButton
 - signUpButton
 
 3.同時，透過公開的 getter 和 func 方法，提供對重要狀態的安全存取，例如：
 
 - email、password 為公開的唯讀屬性。
 - 提供 setEmail(_:) 與 setPassword(_:) 方法以更新輸入框的內容。
 - 提供 setRememberMeButtonSelected(_:) 以控制按鈕選中狀態。
 
 ------------------------------------------------------------

 `* Why`
 
 `1. 強化封裝性`
 
 - 避免直接操縱 UI 元件狀態：
    - 所有按鈕和輸入框設置為 private 或 private(set)，確保 UI 元件的狀態變更只能由 LoginView 控制，避免外部直接干預元件的行為。
 
 - 降低耦合度：
    - 僅暴露必要的訪問接口，例如 getter 和 func 方法，確保外部類別與 LoginView 的耦合降到最低，便於未來進行修改或重構。
 
 `2. 提高可維護性`
 
 - 集中修改邏輯：
    - 當需要對按鈕的存取邏輯進行修改時，只需更新 LoginView 中的 getter 方法，而無需修改外部類別的代碼，確保程式碼易於維護。
 
 - 符合單一職責原則，UI 元件的管理和行為設置被明確區分：
    - LoginView 專注於管理按鈕的狀態和顯示。
    - LoginActionHandler 負責處理行為邏輯，例如綁定按鈕行為。
 
 `3. 易於擴展`
 
 - 如果未來需要對按鈕的狀態訪問進行額外處理，例如加入額外檢查或統一日誌記錄，這些邏輯可以集中在 getter 或 func 方法中，減少重複代碼。

 ------------------------------------------------------------

 `* How`
 
 `1. 使用 private(set) 管理按鈕存取`
 
 - 對於需要被外部訪問的按鈕，使用 private(set)，例如：
 -  這樣可以保證按鈕屬性僅能由 LoginView 修改，但外部類別仍然可以安全訪問這些按鈕以設置行為。

 ```swift
 private(set) var loginButton = LoginFilledButton(title: "Login", ...)
 ```
 
 ------
 
 `2. 提供公開的 getter 和 func 方法`
 
 - `公開的唯讀屬性`：
    - 提供 email 和 password 作為公開的唯讀屬性，簡化外部的存取：
 
 ```swift
 var email: String {
     emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
 }
 ```
 
 - `提供公開的操作方法`：
    - 提供方法更新輸入框的內容或按鈕狀態，確保對元件的變更只能透過明確的操作完成：
 
 ```swift
 func setEmail(_ email: String) {
     emailTextField.text = email
 }

 func setRememberMeButtonSelected(_ isSelected: Bool) {
     rememberMeButton.isSelected = isSelected
 }
 ```
 
 ------

 `3. 在 LoginActionHandler 中使用按鈕`
 
 - 在 `LoginActionHandler` 中，透過 `private(set)` 提供的按鈕存取設置行為，例如：
 ```swift
 view.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
```

 ------------------------------------------------------------

 `* Summary（總結）`

 - 維持按鈕屬性為 `private` 或 `private(set)，`僅透過 getter 或 func 方法提供存取，是一種強調封裝性與低耦合的設計方式。
 - 此設計不僅符合單一職責原則，還能提高程式碼的可維護性和擴展性。
 - `LoginView` 負責 UI 元件的狀態與顯示，`LoginActionHandler` 負責按鈕行為的邏輯綁定， 兩者分工明確，有助於構建高內聚低耦合的程式架構。
 
 */


// MARK: - (v)
import UIKit

/// `LoginView` 是登入頁面的主要視圖，負責佈局所有登入相關的 UI 元素
/// - 包含標籤、輸入框、按鈕等視圖，用於引導使用者登入或註冊
class LoginView: UIView {
    
    // MARK: - UI Elements
    
    /// 應用程式的 logo
    private let logoImageView = LoginCustomImageView(imageName: "starbucksLogo2")
    
    /// 登入標題標籤
    private let titleLabel = LoginLabel(text: "Log in to your account", fontSize: 28, weight: .black, textColor: .deepGreen)
    
    /// 提示使用者使用 Email 登入的標籤
    private let signInLabel = LoginLabel(text: "Sign in with email", fontSize: 14, weight: .medium, textColor: .lightGray)
    
    /// Email 輸入框，用於讓使用者輸入電子郵件
    private let emailTextField = LoginTextField(placeholder: "Email", rightIconName: "envelope", isPasswordField: false, fieldType: .email)
    
    /// 密碼輸入框，用於讓使用者輸入密碼
    private let passwordTextField = LoginTextField(placeholder: "Password", rightIconName: "eye", isPasswordField: true, fieldType: .password)
    
    /// "記住我" 選項按鈕，用於讓使用者選擇是否記住帳號密碼
    private(set) var rememberMeButton = LoginCheckBoxButton(title: " Remember Me")
    
    /// "忘記密碼" 按鈕，當使用者忘記密碼時可以點擊
    private(set) var forgotPasswordButton = LoginTextButton(title: "Forgot your password?", fontSize: 14, fontWeight: .medium, textColor: .gray)
    
    /// 登入按鈕，用於進行帳號登入
    private(set) var loginButton = LoginFilledButton(title: "Login", textFont: .systemFont(ofSize: 18, weight: .black), textColor: .white, backgroundColor: .deepGreen)
    
    /// 分隔符號與提示文字視圖，用於顯示 "或繼續使用其他方式登入"
    private let separatorAndTextView = LoginSeparatorView(text: "Or continue with", textColor: .lightGray, lineColor: .lightGray)
    
    /// 使用 Google 登入的按鈕
    private(set) var googleLoginButton = LoginFilledButton(title: "Login with Google", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "google48")
    
    /// 使用 Apple 登入的按鈕
    private(set) var appleLoginButton = LoginFilledButton(title: "Login with Apple", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "apple50")
    
    /// 前往註冊頁面的按鈕
    private(set) var signUpButton = LoginAttributedButton(mainText: "Don't have an account? ", highlightedText: "Sign up", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)
    
    // MARK: - StackView
    
    /// 主垂直 StackView，用來排列主要的 UI 元素
    private let mainStackView = LoginStackView(axis: .vertical, spacing: 15, alignment: .fill, distribution: .fill)
    
    /// 排列 "記住我" 和 "忘記密碼" 按鈕的水平 StackView，便於水平展示這兩個按鈕
    private let rememberAndForgotStackView = LoginStackView(axis: .horizontal, spacing: 0, alignment: .fill, distribution: .equalSpacing)
    
    // MARK: - ScrollView
    
    /// ScrollView 用來包裹所有 StackView，支援畫面滾動，特別是在鍵盤顯示時仍能滾動
    private let mainScrollView = LoginScrollView()
    
    // MARK: - Initializers
    
    /// 初始化方法，配置 LoginView 的基本佈局和元件
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()                              // 設置 mainScrollView
        setupMainStackView()                           // 設置主要的 StackView，包括所有的 UI 元素
        setupMainStackViewConstraints()                // 設置主 StackView 的約束
        setViewHeights()                               // 設置各元件的高度
        setupBackground()                              // 設置背景顏色
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置 ScrollView
    private func setupScrollView() {
        mainScrollView.setupConstraints(in: self) // 將 scrollView 加入 SignUpView 並設置其約束
    }
    
    /// 設置主 StackView，包含所有主要的 UI 元件，並加入到 mainScrollView 中
    private func setupMainStackView() {
        
        // 將 "記住我" 和 "忘記密碼" 的按鈕添加到水平 StackView 中
        rememberAndForgotStackView.addArrangedSubview(rememberMeButton)
        rememberAndForgotStackView.addArrangedSubview(forgotPasswordButton)
        
        // 將所有元素按順序添加到主 StackView 中
        mainStackView.addArrangedSubview(logoImageView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(signInLabel)
        mainStackView.addArrangedSubview(emailTextField)
        mainStackView.addArrangedSubview(passwordTextField)
        mainStackView.addArrangedSubview(rememberAndForgotStackView)
        mainStackView.addArrangedSubview(loginButton)
        mainStackView.addArrangedSubview(separatorAndTextView)
        mainStackView.addArrangedSubview(googleLoginButton)
        mainStackView.addArrangedSubview(appleLoginButton)
        mainStackView.addArrangedSubview(signUpButton)
        
        // 為 signUpButton 前的元素（即 appleLoginButton）設置較大的間距
        mainStackView.setCustomSpacing(30, after: appleLoginButton)
        
        // 將 mainStackView 設置到 mainScrollView
        mainScrollView.addSubview(mainStackView)
    }
    
    /// 設置 mainStackView 的約束條件
    private func setupMainStackViewConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 30),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -30),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -60)
        ])
    }
    
    /// 設置各元件的高度
    private func setViewHeights() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            signInLabel.heightAnchor.constraint(equalToConstant: 20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            separatorAndTextView.heightAnchor.constraint(equalToConstant: 30),
            loginButton.heightAnchor.constraint(equalToConstant: 55),
            googleLoginButton.heightAnchor.constraint(equalToConstant: 55),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    /// 設置背景顏色
    private func setupBackground() {
        backgroundColor = .white
    }
    
    // MARK: - Public Getters and Setters (公開的存取方法)
    
    /// 取得 Email 輸入框的值
    var email: String {
        emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 取得密碼輸入框的值
    var password: String {
        passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 設定 Email 輸入框的值
    /// - Parameter email: 要設置的 Email 字串
    func setEmail(_ email: String) {
        emailTextField.text = email
    }
    
    /// 設定密碼輸入框的值
    /// - Parameter password: 要設置的密碼字串
    func setPassword(_ password: String) {
        passwordTextField.text = password
    }
    
    /// 設置 "記住我" 按鈕的選中狀態
    /// - Parameter isSelected: 是否選中
    func setRememberMeButtonSelected(_ isSelected: Bool) {
        rememberMeButton.isSelected = isSelected
    }
    
}
