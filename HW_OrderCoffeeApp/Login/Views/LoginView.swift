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
 - 因此，並不需要監聽每次的輸入變化來進行即時處理。

 `* 閉包監聽的適用場景：`
 
 - 當需要在使用者輸入的過程中即時驗證資料格式。
 - 例如即時驗證 email 格式是否正確，或即時更新 UI 的狀態（如啟用/禁用登入按鈕）時，可以使用 `emailTextChanged` 和 `passwordTextChanged` 的閉包監聽。

 ------------------------------------------
 `2. 封裝性與使用者界面交互的考量`

 `* 封裝性：`
 
 - `LoginView` 主要應該負責顯示與收集使用者輸入，不應包含過多的邏輯或即時處理需求。
 - 因此，使用 computed properties (`emailText` 和 `passwordText`) 可以更簡潔地提供輸入值，並保持 `LoginView` 的職責單一。

 `* 使用 computed properties 的好處：`
 
 - 更簡潔的存取方式：只需通過 `emailText` 和 `passwordText` 屬性即可獲取使用者的輸入。
 - 符合封裝性：`LoginView` 仍然只負責提供 UI 元件的顯示和使用者輸入，不會在不必要的地方增加複雜性。

 ------------------------------------------

 `3. 想法`

 - 如果當前不需要在使用者每次輸入時即時反應（例如格式驗證或 UI 更新），建議移除 `emailTextChanged` 和 `passwordTextChanged`，僅保留 computed properties (`emailText` 和 `passwordText`)。
 - 當未來有即時處理需求時，可以再重新添加這些監聽閉包。這樣的設計可以根據實際需求逐步增加邏輯的複雜度，而不是一開始就加入不必要的邏輯。
 */


// MARK: - LoginView 的封裝性與資料存取方法的重點筆記一（重要）
/**
 
 ## LoginView 的封裝性與資料存取方法的重點筆記

 根據需求與架構考量，考慮處理 `LoginView` 的資料存取。
 在這裡，比較了 Getter 方法與 Computed Properties 各自的優缺點。

 `1. Getter 方法 (getEmailText() 和 getPasswordText())`
 
 - 使用 Getter 方法來取得 `email` 和 `password`，能夠保持 `LoginView` 的封裝性，並且在需要時提供資料。
 - 這樣的設計符合單一職責原則，確保資料的取得有清楚的邏輯與控制。

 `* 優點：`
 
   - 明確的函式接口：外部只能通過特定的方法來取得資料，增加了安全性與控制性。
   - 易於維護：未來若要修改資料的取得邏輯，只需更改 Getter 方法即可。
   - 便於加入額外邏輯：可以在 Getter 中加入額外的邏輯，例如格式化、驗證等。

 `* 適用場景：`
   - 如果需要嚴格控制 `email` 和 `password` 的存取，並且希望在資料取得時有更多邏輯控制，這種方式是合適的。

 ------------------------------------------------------------
 
 `2. Computed Properties (emailText 和 passwordText)`
 
 - 使用 Computed Properties，可以讓外部像存取屬性一樣簡單地取得 `email` 和 `password`，同時保持資料是動態計算的，符合 Swift 的語法風格。

 `* 優點：`
 
   - 更簡潔的存取方式：不需要調用 Getter 方法，直接通過屬性存取。
   - Swift 語法風格：這種屬性存取方式更符合 Swift 語言的設計模式，使程式碼更自然易讀。
   - 保持封裝性：仍然能保持封裝性，沒有直接暴露 `UITextField`，只提供了其值。

 `* 適用場景：`
 
   - 當不需要過多控制資料取得的細節，並且希望簡化存取邏輯時，這種方式很適合。

 ------------------------------------------------------------

 `## 選擇`
 
 依據目前架構和處理邏輯，選擇哪一種方式主要取決於以下考量：

 `1. 職責分離：`

 - `LoginView` 應該負責 UI 的顯示與使用者操作的回應，而非過多邏輯處理。兩種方式都符合這樣的架構設計，因為它們只負責提供 `email` 和 `password` 的值。

 `2. 程式碼簡潔性與可維護性：`
 
 - 如果傾向於更簡潔且符合 Swift 風格的寫法，**Computed Properties** 會是一個更好的選擇。
 - 如果希望在資料取得時加入更多的控制，例如自動格式化或驗證，則 **Getter 方法** 更靈活且易於維護。

 ------------------------------------------------------------

 `## 總結`
 
 - `Computed Properties` 適合需要簡潔且快速取得資料的場景，並且符合 Swift 的現代化語法風格。
 - `Getter 方法` 則更適合需要增加額外處理邏輯的場景，例如自動格式化、資料驗證等，便於集中管理和日後擴展。

 ------------------------------------------------------------

 `## 使用例子`
 
 例如，若希望在取得 `email` 時自動去除前後的空格，可以在 Getter 方法中加入這樣的邏輯：

 ```swift
 func getEmail() -> String {
     return emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
 }
 ```

 這樣每次取得 `email` 時，值已經被格式化好，確保資料的一致性與正確性。
 */


// MARK: - LoginView 的封裝性與資料存取方法的重點筆記二（重要）
/**
 
 ## LoginView 的封裝性與資料存取方法的重點筆記二
 
 `* 使用 setter 方法 vs computed properties 來管理 UI 元件的選擇`

 - 當需要設置如 email 和 password 等 UI 元件的值時，可以考慮以下兩種方式：使用 setter 方法（例如 `setEmail(_:)` 和 `setPassword(_:)`），或使用 computed properties（例如 `emailText` 和 `passwordText`）來讀寫值。

 `1. 使用 setEmail(_:) 和 setPassword(_:) 方法`

 `* 優點：`
 
 - 單一責任原則：方法名稱明確，表示它們的功能是設置文本框的值，符合「單一責任原則」。
 - 更強的控制：可以在設置文本框值時加入驗證邏輯，或在設置值時觸發一些額外操作。
 - 封裝性：`emailTextField` 和 `passwordTextField` 可以保持私有，避免外部直接對文本框進行改動。

 `* 缺點：`
 
 - 代碼量增加：需要多寫一些 setter 方法，增加了類的代碼量。
 - 使用稍麻煩：需要調用 getter 屬性來獲取值，調用 setter 方法來設置值，而不是使用簡單的屬性。

 ------------------------------------------------------------

 `2. 使用 emailText 和 passwordText 的 computed properties`

 `* 優點：`
 
 - 簡潔：直接通過一個屬性可以同時讀取和設置文本框的值，代碼可讀性好。
 - 簡單使用：可以像普通屬性一樣使用，讀寫方便。

 `* 缺點：`
 
 - 降低控制能力：如果需要在設置值時加入額外的驗證邏輯，computed properties 可能會變得過於複雜。
 - 封裝犧牲：暴露 getter/setter，外部可以隨意設置文本框的值，可能會增加修改錯誤的風險。

 ------------------------------------------------------------

 `3. 想法`
 
 - 若需要更強的控制力（例如設置值時需要驗證或其他邏輯），建議使用 **setter 方法** (`setEmail(_:)` 和 `setPassword(_:)`)。這樣符合單一責任原則，也利於未來的擴展和維護。
 - 若追求簡潔性，且不需要額外的設置邏輯，可以選擇 **getter/setter 屬性** (`emailText` 和 `passwordText` 有 `get` 和 `set`)，代碼更簡單直觀。
 
 ------------------------------------------------------------

` 4. 總結`
 - 總結來說，如果需要設置邏輯更複雜，setter 方法會是更好的選擇；但如果只是單純的設置值，computed properties 會讓代碼更簡潔。
 - 無論選擇哪種方式，保持代碼風格一致是最重要的。統一使用 Computed Properties 或 Getter/Setter 方法，有助於減少出錯的機會，並提高代碼的可讀性和可維護性。
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
 
    - 將所有按鈕的行為移除，包括 `addTarget` 方法等。
    - 增加公開的 `getter` 方法，例如 `getLoginButton()`，讓外部能夠取得按鈕元件。
    
 `2. LoginActionHandler 設置：`
 
    - 創建 `LoginActionHandler` 類別，並提供初始化方法來設置 `LoginView` 和 `LoginViewDelegate`。
    - 在 `setupActions()` 中，透過 `LoginView` 的 `getter` 方法取得各按鈕，並添加按鈕點擊事件的處理邏輯。
    - 每個按鈕事件都透過 `delegate` 將事件回傳給控制器，保持 `LoginView` 與控制器的互動。

 `3. LoginViewController 設置：`
 
    - 在 `viewDidLoad()` 中初始化 `LoginActionHandler`，並將 `LoginView` 和 `LoginViewDelegate` 傳入，讓 `LoginActionHandler` 負責管理按鈕行為。

 ------------------------------------------------------------

 `* Summary（總結）`
 
    - 透過引入 `LoginActionHandler`，我們實現了責任分離與降低耦合度，讓 `LoginView` 專注於 UI，`LoginActionHandler` 專注於使用者行為管理。
    - 這樣的設計不僅改善了程式碼的清晰度與可讀性，也讓未來的維護和擴展變得更容易。
 */


// MARK: - LoginView 元件存取方式筆記
/**
 ## LoginView 元件存取方式筆記

 - 主要是我一開始的重構順序，將「按鈕行為」分離出 LoginView 是後面才執行。
 - 我一開始採用 private 然後使用 getter 的方式來處理 `TextField 的數值``、RememberMe按鈕狀態的`取得方式。
 - 是希望藉此強調封裝性，所以當我再處理「按鈕行為」分離 LoginView ，並設置到 LoginActionHandler時，才想到這樣子連按鈕也要進行，這樣就要設置多個 getter。
 - 就在猶豫要不要改回公開（public 或 internal）。不過最後還是繼續維持 private 搭配 getter 的方式，保持封裝性。
 
 ------------------------------------------------------------

 `* What`
 
 - 在 `LoginView` 中，我選擇使用 **getter 方法** 來取得各個按鈕，而不是將按鈕屬性從 `private` 修改為公開（`public` 或 `internal`）。
 - 這些按鈕包括 `loginButton`、`googleLoginButton`、`appleLoginButton` 等。

 ------------------------------------------------------------

 `* Why`
 
 `1. 資料封裝性（Encapsulation）：`
 
 - 保持 UI 元件的封裝性：
    - 將 UI 元件設置為 `private`，可以有效防止外部直接修改這些元件。這樣可以保護元件狀態，只允許必要的訪問操作來更改 UI，而不是讓外部有直接操縱的權限，從而避免不預期的改動。
   
 - 降低耦合度：
    - 使用 getter 可以確保只暴露必須的部分，讓 `LoginView` 元件與外部類別的耦合度降低。使用 getter 方法，可以保持 UI 元件的存取點統一且可控。
   
 `2.提高可維護性與可測試性：`
 
 - 可控的訪問途徑：
    - 通過 getter 取得按鈕時，可以進行額外處理或檢查，這樣未來如果需要對取得邏輯進行擴展或修改，可以集中修改 getter 方法，而不需要修改外部代碼。這提高了程式碼的可維護性。
  
 - 符合單一職責原則：
    - 按鈕的狀態管理及 UI 元件本身的操作由 `LoginView` 來管理，而行為管理則由 `LoginActionHandler` 負責，避免了直接暴露 UI 元件，這更符合單一職責原則。

 ------------------------------------------------------------

 `* How`
 
 `1. UI 元件保持 private：`
    - 在 `LoginView` 中，所有 UI 元件保持 `private`，避免直接從外部修改這些按鈕屬性。

 `2. 提供 getter 方法：`
    - 創建公開的 getter 方法，例如 `getLoginButton()`、`getGoogleLoginButton()` 等，讓外部的 `LoginActionHandler` 或其他類別可以安全地訪問這些按鈕。
    - 這些 getter 方法只提供讀取權限，從而保證 `LoginView` 中 UI 元件的封裝性不被破壞。

` 3. LoginActionHandler 的使用：`
    - 在 `LoginActionHandler` 中，透過呼叫 `LoginView` 的 getter 方法來設置按鈕的行為。
    - 例如 `view.getLoginButton().addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)`。

 ------------------------------------------------------------

 `* Summary（總結）`
 
 - 使用 getter 方法來取得按鈕而非將 UI 元件屬性公開，這樣的設計強化了 `LoginView` 的封裝性和可維護性。
 - 按鈕的管理僅由 `LoginView` 進行控制，其他邏輯如行為設定則由 `LoginActionHandler` 處理，保持了各類別的單一職責，符合良好的軟體設計原則。
 - 這不僅降低了系統的耦合度，還增加了未來的擴展與修改的靈活性，讓程式碼更易於理解和維護。
 */


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
    private let emailTextField = LoginTextField(placeholder: "Email", rightIconName: "envelope")
    
    /// 密碼輸入框，用於讓使用者輸入密碼
    private let passwordTextField = LoginTextField(placeholder: "Password", rightIconName: "eye", isPasswordField: true)
    
    /// "記住我" 選項按鈕，用於讓使用者選擇是否記住帳號密碼
    private let rememberMeButton = LoginCheckBoxButton(title: " Remember Me")
    
    /// "忘記密碼" 按鈕，當使用者忘記密碼時可以點擊
    private let forgotPasswordButton = LoginTextButton(title: "Forgot your password?", fontSize: 14, fontWeight: .medium, textColor: .gray)
    
    /// 登入按鈕，用於進行帳號登入
    private let loginButton = LoginFilledButton(title: "Login", textFont: .systemFont(ofSize: 18, weight: .black), textColor: .white, backgroundColor: .deepGreen)
    
    /// 分隔符號與提示文字視圖，用於顯示 "或繼續使用其他方式登入"
    private let separatorAndTextView = LoginSeparatorView(text: "Or continue with", textColor: .lightGray, lineColor: .lightGray)
    
    /// 使用 Google 登入的按鈕
    private let googleLoginButton = LoginFilledButton(title: "Login with Google", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "google48")
    
    /// 使用 Apple 登入的按鈕
    private let appleLoginButton = LoginFilledButton(title: "Login with Apple", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .black, backgroundColor: .lightWhiteGray.withAlphaComponent(0.8), imageName: "apple50")
    
    /// 前往註冊頁面的按鈕
    private let signUpButton = LoginAttributedButton(mainText: "Don't have an account? ", highlightedText: "Sign up", fontSize: 14, mainTextColor: .gray, highlightedTextColor: .deepGreen)
    
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
        mainScrollView.setupConstraints(in: self)       // 設置 mainScrollView 的約束，將它添加到 LoginView 中
        setupBackground()                               // 設置背景顏色
        setupMainStackView()                            // 設置主要的 StackView，包括所有的 UI 元素
        setViewHeights()                                // 設置各元件的高度
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置背景顏色
    private func setupBackground() {
        backgroundColor = .white
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
        // 設置主 StackView 的約束
        setupMainStackViewConstraints()
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
    

    // MARK: - Public Getters for UI Elements
    
    /// 提供登入按鈕的公共存取方法
    func getLoginButton() -> UIButton {
        return loginButton
    }

    /// 提供 Google 登入按鈕的公共存取方法
    func getGoogleLoginButton() -> UIButton {
        return googleLoginButton
    }

    /// 提供 Apple 登入按鈕的公共存取方法
    func getAppleLoginButton() -> UIButton {
        return appleLoginButton
    }

    /// 提供忘記密碼按鈕的公共存取方法
    func getForgotPasswordButton() -> UIButton {
        return forgotPasswordButton
    }

    /// 提供註冊按鈕的公共存取方法
    func getSignUpButton() -> UIButton {
        return signUpButton
    }

    /// 提供 "記住我" 按鈕的公共存取方法
    func getRememberMeButton() -> UIButton {
        return rememberMeButton
    }
    
    /// 獲取使用者輸入的 Email
    /// - Returns: Email 字串
    func getEmail() -> String {
        return emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 設置 Email 的值
    /// - Parameter email: 要設置的 Email 字串
    func setEmail(_ email: String) {
        emailTextField.text = email
    }
    
    /// 獲取使用者輸入的密碼
    /// - Returns: 密碼字串
    func getPassword() -> String {
        return passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// 設置密碼的值
    /// - Parameter password: 要設置的密碼字串
    func setPassword(_ password: String) {
        passwordTextField.text = password
    }
    
    /// 提供一個公共方法來設置記住我的按鈕狀態
    /// - Parameter isSelected: 是否選中
    func setRememberMeButtonSelected(_ isSelected: Bool) {
        rememberMeButton.isSelected = isSelected
    }
    
}
