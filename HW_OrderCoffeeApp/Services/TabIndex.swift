//
//  TabIndex.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/3.
//


// MARK: - TabIndex 使用及其重要性
/**

 ## 重點筆記：TabIndex 使用及其重要性

 - 主要因為我添加Search頁面時，並且將`Search`、`Order`的`TabItem`位置設置做調整，導致我在添加`badge`以及離開 `OrderConfirmationViewController` 時，導致錯亂。
 - 因此設置 TabIndex 來統一管理。
 
 ------------------------------------

 `* What`
 
 - `TabIndex` 是一個用於定義主選單中每個 Tab 的索引位置的枚舉（`enum`），它提供了一個統一的方式來標識應用中的各個 Tab 頁面。
 - 這樣做的目的是為了讓代碼中對於 Tab 頁面的引用更加一致和清晰。例如：
 
 - `.menu` 代表飲品分類頁面。
 - `.search` 代表搜尋頁面。
 - `.order` 代表訂單頁面。
 - `.userProfile` 代表用戶個人資料頁面。

 ------------------------------------
 
 `* Why`

 `1. 解決不直觀的索引問題：`
 
 - 在沒有使用 `TabIndex` 前，通常需要用數字索引來訪問特定的 Tab，例如：
 
 ```swift
 tabBarController.selectedIndex = 2  // 設置到第三個 Tab，即訂單頁面
 ```
 
 - 這樣的做法存在以下問題：
 
 - 可讀性差：單純的數字 `[2]` 並不能清晰地表達它代表的是哪個頁面，讓代碼的理解變得困難。
 - 容易出錯：如果 Tab 順序改變，所有涉及該索引的地方都必須一一手動修改，非常容易出錯。

` 2. 增強可讀性與維護性`
 
 - 使用 `TabIndex`，代碼變得更加直觀和可讀。例如：
 
 ```swift
 tabBarController.selectedIndex = TabIndex.order.rawValue
 
 ```
 
 - 這樣的代碼不但明確指出切換到 "訂單" 頁面，而且在需要修改 Tab 順序時，只需修改 `TabIndex`，不必手動遍歷所有使用整數索引的位置，大大減少了維護成本。

 `3. 統一管理，便於擴展`
 
 - 所有的 Tab 索引都集中在 `TabIndex` 中統一管理，讓代碼中涉及 Tab 的部分更加集中、統一，使得未來如果有新增 Tab 或修改順序的需求，可以輕鬆調整。

 ------------------------------------

 `* How`

 `1. 定義 TabIndex 枚舉`
 
 - 首先在項目中新建一個 `TabIndex.swift` 文件，並定義 `TabIndex` 枚舉，這個枚舉包含應用中每個 Tab 的位置。

 `2. 在 MainTabBarController 中使用 TabIndex`
 
 - 在 `MainTabBarController` 或其他需要訪問 `UITabBarController` 的地方，使用 `TabIndex` 來設定和訪問各個 Tab：
 
 ```swift
 // 切換至 "訂單" 頁面
 tabBarController.selectedIndex = TabIndex.order.rawValue
 
 ```
 
 - 這樣的寫法能夠增強代碼的可讀性，使得其他開發者或自己在未來維護時更加清楚每個索引所代表的頁面。

 ------------------------------------

 `* 好處`

 - 增強可讀性：相比直接使用數字索引，`TabIndex` 明確標識了每個 Tab 是什麼頁面，讓代碼更易於理解。
 - 降低維護成本：如果未來需要改變 Tab 的順序，只需要更新 `TabIndex` 中的定義即可，不需要遍歷整個代碼去查找和修改每個索引。
 - 統一性和一致性：在應用的各個地方統一使用 `TabIndex`，可以確保代碼的一致性，避免不同地方使用不同的索引方式造成混亂。

 ------------------------------------
 
 `* 未使用 TabIndex 時的問題`

 - 數字索引混亂：
    - `tabBarController.selectedIndex = 2`，這樣的數字索引既不直觀，也不具備明確的語意，容易讓代碼讀者（包括自己）感到困惑。
    - 尤其是代碼量增多時，難以分辨這些索引具體代表哪個頁面。
 
 - 維護成本高：
    - 如果修改了 Tab 的順序，所有引用到這些索引的地方都需要逐一手動修改，這不僅麻煩，而且增加了出錯的機會。
 
 - 代碼重複：
    - 多處使用硬編碼索引值，導致代碼中存在重複邏輯，難以統一管理和調整。

 */


import Foundation

/// `TabIndex` 用於定義主選單中每個 Tab 的索引位置，以便在各個視圖控制器中可以一致地使用
enum TabIndex: Int {
    case menu = 0         // 主選單（飲品分類）
    case search           // 搜尋頁面
    case order            // 訂單頁面
    case userProfile      // 用戶個人資料頁面
}
