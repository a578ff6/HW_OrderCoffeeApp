//
//  SearchManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// MARK: - SearchManager 筆記
/**
 
 ## SearchManager 筆記
 
 `1.設計目的`
 
 - `SearchManager` 是飲品搜尋功能的核心，負責根據本地快取的飲品資料進行關鍵字搜尋。
 - 將`搜尋`和`資料加載`分開，`SearchManager` 只關注資料過濾與搜尋，而資料的加載與快取由 `SearchDrinkDataLoader` 和 `SearchCacheManager` 分別負責。
 
 ------------------------------------------------------------------

 `2. 職責分配`
 
 - `searchCacheManager`：負責管理和提供本地飲品資料快取，減少 Firebase 的請求次數，確保搜尋能夠快速響應。
 - `searchDrinks(with:)`：根據搜尋關鍵字從快取中加載符合的飲品資料，並進行過濾。
 - `filterDrinks(_:with:)`：根據用戶輸入的關鍵字對本地飲品資料進行過濾。
 
 ------------------------------------------------------------------

 `3. 快取機制`
 
 - `searchCacheManager` 用於管理飲品資料的快取，包括檢查快取的有效性和獲取有效的資料。
 - 在 `searchDrinks(with:) `中，`SearchManager` 首先使用 `searchCacheManager` 確定是否有有效的快取，如果快取無效，則會提示用戶等待資料加載完成。
 
 ------------------------------------------------------------------

 `4. 搜尋資料的流程`
 
 `* searchDrinks(with:)`
 - 該方法負責根據給定的搜尋關鍵字，使用本地快取資料進行過濾。
 - 如果本地快取的飲品資料不可用，會拋出錯誤，提示使用者資料尚未準備好，這樣避免了對 Firebase 的頻繁請求。
 
 `* filterDrinks(_:with:)（私有方法）`
 - 負責根據使用者的關鍵字，過濾已經快取的飲品資料。
 - 過濾的範圍包括飲品名稱 (name) 和副名稱 (subName)，確保搜尋結果即時反應用戶的需求。
 
 ------------------------------------------------------------------
 
 `5. 資料過濾的設計`
 
 - `filterDrinks(_:with:)`：負責根據搜尋關鍵字對飲品資料進行過濾，確保搜尋結果能夠即時反應用戶的輸入。
 - 在搜尋時，優先使用已加載的快取資料，並對其進行過濾。
 - 過濾邏輯包括飲品名稱和副名稱，確保搜尋結果準確符合用戶的需求。
 
 ------------------------------------------------------------------

 `6. 職責分離`
 
 - `SearchManager`：負責提供搜尋功能，僅依賴於本地快取的飲品資料進行搜尋，這樣避免頻繁訪問 Firebase 資料庫，提升搜尋效率。
 - `SearchDrinkDataLoader`：負責從 Firebase 加載和更新飲品資料，並將最新資料存入快取，以供 SearchManager 使用。
 - `SearchCacheManager`：負責管理快取的有效性，包括存儲、更新以及是否需要重新加載的檢查。
 - `SearchDrinkDataService`：負責與 Firebase 進行交互，從遠端獲取飲品資料。它提供從 Firebase 加載類別、子類別和飲品的底層數據交互服務，確保資料加載的可靠性和正確性，並使資料操作與業務邏輯分離。
 
 ------------------------------------------------------------------

 `7. 總結`
 
 `* 職責分離：`
    - SearchManager、SearchDrinkDataLoader、SearchCacheManager、SearchDrinkDataService 四者之間分工明確，各司其職，符合單一職責原則。
    - `SearchManager`：專注於資料的搜尋和過濾，不再處理 Firebase 資料的加載。
    - `SearchDrinkDataLoader`：負責資料的加載和快取更新，確保在應用啟動或資料無效時進行更新。
    - `SearchCacheManager`：管理本地快取的有效性，包括資料存取與過期檢查，減少重複的 Firebase 請求。
    - `SearchDrinkDataService`：處理所有 Firebase 資料存取的具體細節，避免直接在其他管理器中實作數據存取操作，增強代碼的可維護性。
 
 `* 快取機制的應用：`
    - 使用 `searchCacheManager` 來管理資料的有效性，避免頻繁的 Firebase 請求，提升應用效能。
    - `SearchDrinkDataLoader` 在應用啟動時加載資料，確保搜尋時有可用資料，並通過 SearchCacheManager 管理快取。
 */


// MARK: - Search 功能模組重點整理筆記（重要）
/**

 ## Search 功能模組重點整理筆記
 
 `1. SearchManager`
 
 `* 設計目的`
    - 提供飲品搜尋功能，負責根據使用者輸入的關鍵字從本地快取中搜尋飲品。
    - 通過依賴`本地快取`進行搜尋，提升搜尋速度，減少對 Firebase 的頻繁請求。

 `* 職責`
    - `搜尋飲品 (searchDrinks(with:))`：根據關鍵字進行搜尋，優先使用快取資料，避免頻繁訪問 Firebase。
    - `資料過濾 (filterDrinks(_:with:))`：對於已快取的飲品資料進行過濾，確保搜尋結果即時反應用戶的需求。

 `* 與其他模組的互動`
    - 從 `SearchCacheManager` 獲取本地快取資料進行搜尋操作。
    - 不涉及 Firebase 直接交互，所有 Firebase 加載工作由 `SearchDrinkDataLoader` 處理。

 ------------------------------------------------------------------
 
 `2. SearchDrinkDataLoader`
 
 `* 設計目的`
    - 負責在應用啟動時或快取無效時從 Firebase 加載飲品資料並更新快取，以確保本地有最新的飲品資料可供搜尋和展示使用。

 `* 職責`
    - `資料加載 (loadOrRefreshDrinksData())`：在應用啟動時加載飲品資料，並將其存入快取，避免初次使用搜尋功能時資料缺失。

 `* 與其他模組的互動`
    - 通過 `SearchDrinkDataService` 從 Firebase 加載資料。
    - 使用 `SearchCacheManager` 來管理快取資料的存儲與更新。

 ------------------------------------------------------------------

 
 `3. SearchCacheManager`
 
 `* 設計目的`
    - 負責管理飲品資料的快取，包括存儲、更新和有效性檢查，以減少不必要的 Firebase 請求，提升應用效能。

 `* 職責`
    - `快取管理 (cachedDrinks)`：存儲飲品資料，用於減少頻繁的網路請求。
    - `資料存取 (getCachedDrinks(), cacheDrinks(_:))`：提供本地快取資料的存取，並更新快取資料。

 `* 與其他模組的互動`
    - 被 `SearchManager` 用來進行資料的搜尋。
    - 被 `SearchDrinkDataLoader` 用來決定是否需要重新加載 Firebase 資料，並在需要時更新快取。

 ------------------------------------------------------------------
 
 `4. SearchDrinkDataService`
 
 `* 設計目的`
    - 與 Firebase Firestore 進行交互，負責從 Firebase 中加載飲品相關資料，包括類別、子類別及飲品詳細資訊。

 `* 職責`
 
 - `資料加載`：
   - `類別 (fetchSearchCategories())`：加載所有類別，支援飲品分類展示及後續資料加載。
   - `子類別 (fetchSearchSubcategories(for:))`：根據類別 ID 加載其下的子類別，用於進一步篩選。
   - `飲品資料 (fetchSearchDrinks(for:, subcategoryId:))`：加載指定子類別下的飲品資料，並轉換為 `SearchResult`。

 `* 與其他模組的互動`
    - 為 `SearchDrinkDataLoader` 提供資料加載的支持。
    - 不與 `SearchManager` 和 `SearchCacheManager` 直接交互，專注於 Firebase 資料存取。

 ------------------------------------------------------------------

 `5. 模組間的關係和互動總結`
 
    1. `SearchManager`：只負責資料的搜尋和過濾，確保功能的單一性。
    2. `SearchDrinkDataLoader`：負責從 Firebase 加載飲品資料並更新快取，在應用啟動時和快取失效時使用。
    3. `SearchCacheManager`：負責快取的有效性檢查及管理，避免 Firebase 的頻繁請求。
    4. `SearchDrinkDataService`：負責所有的 Firebase 資料交互，提供飲品資料加載的支持。

 ------------------------------------------------------------------

 `6. 重點結論`
 
 - 這四個模組之間的分工非常明確，依賴彼此的輸出和職責，保持單一責任原則。
 - `職責分離`：
   - `SearchManager` 不直接訪問 Firebase，而是依賴快取資料進行搜尋。
   - `SearchDrinkDataLoader` 專注於資料的預加載和更新，不處理搜尋邏輯。
   - `SearchCacheManager` 集中管理資料的快取和有效性檢查，確保資料的即時性和準確性。
   - `SearchDrinkDataService` 專門負責從 Firebase 加載飲品相關的資料，保持數據層與應用邏輯的分離。
   
 - `快取機制的優勢`：
   - 透過 `SearchCacheManager` 的快取設計，減少了重複的 Firebase 請求次數。
   - 這樣的快取機制確保了應用在資料查詢時的速度，同時避免在網絡不穩定時影響用戶體驗。
 */


// MARK: - 重構筆記：SearchManager 與 SearchDrinkDataLoader（重要）
/**
 
 ## 重構筆記 - SearchManager 與 SearchDrinkDataLoader

 - 在原本的架構中，`SearchManager` 負責加載 Firebase Firestore 中的所有飲品資料、提供搜尋功能以及管理本地快取。
 - 但經過重構後，部分職責被分配到了類別 `SearchDrinkDataLoader` 中，以下是本次重構的重點與改變：

 ------------------------------------------------------------------

 `1. 重構動機`
 
 - `簡化 SearchManager 的職責`：
    - 原本的 SearchManager 負責飲品資料加載和搜尋功能，職責範圍較大且責任不單一，導致類別相對臃腫且難以維護。
 
 - `職責單一化`：
    - 將 飲品資料的預加載和快取 職責移至 `SearchDrinkDataLoader`，使 `SearchManager` 更專注於搜尋相關的邏輯，提升可讀性和維護性。

 ------------------------------------------------------------------

` 2. SearchDrinkDataLoader 的主要職責`
 
 - `資料預加載`：
    - `SearchDrinkDataLoader` 在應用啟動時從 Firebase 預加載飲品資料，確保應用運行時有足夠的數據可以快速進行查詢，這樣可以顯著減少對 Firebase 的多次請求。
 
 - `快取管理`：
    - 透過 `SearchCacheManager` 來管理資料的快取，避免每次搜尋時重新從遠端加載，提升應用的效能。
 
 ------------------------------------------------------------------

 `3. 使用 shared 單例模式`
 
 - `SearchDrinkDataLoader` 被設計成單例 (shared)，這是因為 資料預加載 和 快取管理 是全局需要且應用啟動時執行的唯一操作。
 - 因此，單例模式有助於確保只存在一個實例來負責預加載操作，減少多次實例化的資源浪費，並確保所有地方都使用相同的快取數據。
 
 ------------------------------------------------------------------

 `4. 重構後的主要變化`
 
 - `分離飲品加載與搜尋邏輯`：
    - `SearchManager`：現在專注於搜尋相關的功能，根據關鍵字從快取中過濾飲品資料，簡化了其職責。
    - `SearchDrinkDataLoader`：負責應用啟動時的資料預加載與快取管理，確保資料在快取有效時可以直接使用，提升效能。
 
 ------------------------------------------------------------------

 `5. loadOrRefreshDrinksData() 方法`
 
 - 在 `AppDelegate` 中調用` SearchDrinkDataLoader.shared.loadOrRefreshDrinksData() `來預加載飲品資料。
 - `快取邏輯`：如果快取無效（資料不存在或過期），則從 Firebase 重新加載資料並更新快取；如果快取有效，則直接使用現有的快取資料。
 
 ------------------------------------------------------------------

 `6. 重構`
 
 - `職責劃分更清晰`：每個類別的職責變得更單一，SearchManager 只負責處理搜尋邏輯，而 SearchDrinkDataLoader 專注於資料加載。
 - `提升維護性`：當資料加載方式或快取策略需要改變時，只需調整 SearchDrinkDataLoader，不會影響搜尋邏輯部分，降低耦合性。
 - `減少重複加載`：透過 SearchDrinkDataLoader 和快取管理器，減少每次搜尋時都從 Firebase 加載資料的需求，顯著提升效能。
 */


// MARK: - Firestore 查詢方法選擇：方案一（本地端篩選）與方案二（後端查詢）的對比與想法（重要）
/**
 
 ## Firestore 查詢方法選擇：方案一（本地端篩選）與方案二（後端查詢）的對比與想法

 `* 概述`
 
 -  https://reurl.cc/xpZDjL
 - 目前 Firebase 資料庫中有 `name`（中文）和 `subName`（英文）的欄位。查詢需要考慮中文和英文的搜索需求。
 - Firestore 的原生查詢功能存在「模糊匹配」和「部分關鍵字查詢」的限制，因此需要選擇適合的查詢方案。
 - 本來我是採用「後端查詢」，但經過「搜尋測試」以及目前的飲品資料量，現階段我決定採用「本地端篩選」來做折衷方案（由於現在是免費仔）。
 
 
 `### Cloud Firestore 搜尋擴展`

 - 在 Cloud Firestore 中，搜尋的靈活性受到一些限制。
 - 例如，官方提供的擴展服務（如` Search Firestore with Algolia` 或 `Stream Firestore to BigQuer`y）需要付費，因為它們涉及到第三方的增強功能來實現更強大的搜尋和數據分析。
 - 由於我是免費使用者，這些擴展並不適用。因此，需要在 "`本地端進行篩選`" 和 "`後端查詢`" 之間做出選擇。以下是兩種方法的詳細比較。
 - https://reurl.cc/eG5yMM
 
` * 付費擴展`
    - Firestore 提供的擴展服務（如 `Search Firestore with Algolia` 或 `Stream Firestore to BigQuery`）需要付費，提供更強大的搜尋和數據分析能力，但目前由於我是免費使用者，因此這些擴展並不適用。
 
 `* 免費使用者的選擇`
    - 作為免費使用者，在「本地端進行篩選」和「後端查詢」之間進行取捨。
    - 本地端進行篩選 可以提供更靈活的查詢邏輯，但會增加 Firebase 讀取次數和本地處理負擔。
    - 後端查詢 可以減少傳輸資料量，節省成本，但查詢靈活性會受到限制，只能進行前綴匹配查詢。
 
 
 `### 查詢方案`
 
 `方案一： 本地端篩選（一次性加載所有資料後進行篩選）`

 `* 方法描述：`
    - 將資料（飲品資料）一次性地從 Firestore 讀取到本地端，然後在本地進行篩選和處理。

 `* 優點：`
    -  `靈活的搜尋邏輯`：可以使用自定義邏輯來篩選資料，支持模糊查詢（不論關鍵字在字串中的位置）、大小寫不敏感、對多語言欄位進行不同處理等。
    -  `複合條件的篩選`：可以一次性對多個條件進行操作，這在本地處理起來相對簡單。
 
 `* 缺點：`
    - `效能問題`：當資料量變大時，每次從 Firestore 加載大量資料到本地，會導致查詢速度變慢，並且增加網路流量，對使用者的體驗來說可能不理想。
    - `成本考量`：Firestore 按照讀取次數計費，當每次都讀取整個集合時，資料量變大後成本也會隨之增加。即使當前在免費配額內，資料量增長可能會超出免費配額。

 `方案二： 後端查詢（使用 Firestore 原生條件查詢）`

 `* 方法描述：`
    - 使用 Firestore 的查詢條件來在後端進行資料過濾，只返回符合條件的資料。

 `* 優點：`
    - `效能優化`：僅返回符合條件的部分資料，減少資料傳輸量，提升查詢速度。
    - `節省成本`：只讀取符合條件的部分資料，總體的讀取次數和資料量都相對減少，可以節省 Firebase 的使用成本。
 
 `* 缺點：`
    - `查詢限制`
        - 需要建立複合索引來支持對 `name` 和 `subName` 的查詢，且 Firebase 對複合查詢有一些限制（例如最多只能設置 10 個 `where` 條件）。
        - Firestore 的查詢只能支持前綴匹配，無法找到名稱中間包含關鍵字的資料。例如，查詢 "Coffee" 只能找到 "Coffee Frappuccino"，無法找到名稱包含 "Coffee" 的其他飲品。
    - `靈活性不足`
        - 依賴 Firestore 提供的查詢操作符，無法實現更靈活的過濾邏輯。
    - `多語言支持困難`
        - 當欄位 `name` 是中文，`subName` 是英文時，查詢條件無法同時滿足不同語言的查詢需求。
 
  `### 方案選擇`

 - `小資料量且需要靈活搜尋時`：
    - 選擇方案一，使用本地端篩選，享受靈活的篩選優勢，例如多語言支持、模糊匹配等。但隨著資料量增大，可能會面臨效能問題。

 - `資料量較大且需要提升查詢效能時`：
    - 選擇方案二，使用後端查詢方式，但要接受 Firestore 的查詢限制，特別是只支持前綴匹配的情況。這樣可以提高查詢效能並節省成本。
 
 `### 綜合考量`
 
 - 在實際應用中，如果應用程式在初期資料量不大，且對流量和成本的預算充足，可以使用方案一，享受靈活的篩選優勢。
 - 而隨著資料量增長，建議逐漸過渡到方案二，以確保效能和成本的平衡，並且可使用複合索引來進一步優化查詢速度。
 -  當應用規模增大且需要更好的搜尋體驗時，可以考慮使用付費擴展（如 `Algolia`）來解決 Firestore 搜尋的局限性。
 */


// MARK: - 本地端、後端查詢的程式碼：
/*
 `## 方案一`
 private func fetchSearchDrinks(for categoryId: String, subcategoryId: String, from db: Firestore, keyword: String) async throws -> [SearchResult] {
     let drinksSnapshot = try await db.collection("Categories")
         .document(categoryId)
         .collection("Subcategories")
         .document(subcategoryId)
         .collection("Drinks")
         .getDocuments()
     
     /// 將每個 `Drink` 轉換為 `SearchResult` 物件
     /// 對結果進行篩選，根據 `name` 或 `subName` 是否包含搜尋關鍵字
     return drinksSnapshot.documents.compactMap { document in
         do {
             var searchResult = try document.data(as: SearchResult.self)
             if searchResult.name.lowercased().contains(keyword.lowercased()) ||
                searchResult.subName.lowercased().contains(keyword.lowercased()) {
                 searchResult.categoryId = categoryId
                 searchResult.subcategoryId = subcategoryId
                 searchResult.drinkId = document.documentID
                 return searchResult
             } else {
                 return nil
             }
         } catch {
             print("Error decoding drink document: \(error)")
             return nil
         }
     }
 }
 
 
 `## 方案二`
 
 /// 加載指定 Subcategory 下的所有符合關鍵字的 Drinks 並返回 `SearchResult` 陣列
 /// - Parameters:
 ///   - categoryId: 類別的 ID
 ///   - subcategoryId: 子類別的 ID
 ///   - db: Firestore 資料庫實例
 ///   - keyword: 搜尋關鍵字
 /// - Returns: 符合條件的飲品資料的 `[SearchResult]` 陣列
 private func fetchSearchDrinks(for categoryId: String, subcategoryId: String, from db: Firestore, keyword: String) async throws -> [SearchResult] {
     
     /// 用來儲存最終結果
     var allDrinks: [SearchResult] = []
     
     /// 查詢 `name` 欄位符合的結果並轉換為 `SearchResult`
     let drinksByName = try await queryDrinks(in: db, categoryId: categoryId, subcategoryId: subcategoryId, field: "name", keyword: keyword)
     allDrinks.append(contentsOf: drinksByName)
     
     /// 查詢 `subName` 欄位符合的結果並轉換為 `SearchResult`
     let drinksBySubName = try await queryDrinks(in: db, categoryId: categoryId, subcategoryId: subcategoryId, field: "subName", keyword: keyword)
     allDrinks.append(contentsOf: drinksBySubName)
             
     /// 去除重複項目 (若某些飲品在 `name` 和 `subName` 中同時符合條件)
     let uniqueDrinks = Array(Set(allDrinks))
     return uniqueDrinks
 }
 
 /// 查詢指定欄位符合關鍵字的飲品資料
 /// - Parameters:
 ///   - db: Firestore 資料庫實例
 ///   - categoryId: 類別的 ID
 ///   - subcategoryId: 子類別的 ID
 ///   - field: 要查詢的欄位名稱 (`name` 或 `subName`)
 ///   - keyword: 搜尋關鍵字
 /// - Returns: 對應飲品資料的 `[SearchResult]` 陣列
 private func queryDrinks(in db: Firestore, categoryId: String, subcategoryId: String, field: String, keyword: String) async throws -> [SearchResult] {
     let drinksSnapshot = try await db.collection("Categories")
         .document(categoryId)
         .collection("Subcategories")
         .document(subcategoryId)
         .collection("Drinks")
         .whereField(field, isGreaterThanOrEqualTo: keyword)
         .whereField(field, isLessThanOrEqualTo: keyword + "\u{f8ff}")
         .getDocuments()
     
     return drinksSnapshot.documents.compactMap { document in
         do {
             var searchResult = try document.data(as: SearchResult.self)
             searchResult.categoryId = categoryId
             searchResult.subcategoryId = subcategoryId
             searchResult.drinkId = document.documentID
             return searchResult
         } catch {
             print("Error decoding drink document: \(error)")
             return nil
         }
     }
 }
 */


// MARK: - 本地端篩選的運作方式（重要）

/**
 ## 本地端篩選的運作方式

 關於本地端篩選，指的是在 Firebase Firestore 讀取數據之後，在本地端進行進一步的數據處理和過濾操作。具體來說，流程如下：

 `1. 讀取所有數據`：
    - 首先，從 Firestore 中加載整個集合的所有資料，例如飲品資料。這一步會涉及到 Firestore 的網路請求。

 `2. 在本地篩選數據`：
    - 加載到所有數據後，這些數據會存儲在本地內存中，接下來根據使用者輸入的關鍵字在本地端進行篩選。
    - 這種篩選邏輯可以很靈活，例如支持部分匹配、模糊搜尋、大小寫不敏感匹配等。

 `### 成本考量與快取機制`

 - `Firestore 計費基於讀取次數`：
    - 每次發出查詢請求時，Firestore 都會計算一次讀取。
    - 如果每次搜尋都從 Firestore 獲取整個集合，當數據量增大且使用者搜尋頻繁時，這會導致讀取次數快速累加，進而增加成本。

 - `快取的角色`：
    - Firestore 提供本地快取功能。
    - 首次查詢時，數據會從網絡讀取並存儲在本地快取中，如果後續數據未發生變化，Firestore 可以直接從本地快取中返回查詢結果，這樣就不需要每次都重新從網絡讀取。
    - 但如果數據更新頻繁，或快取被清除，則仍然需要發出新的網路請求。

` ### 本地端篩選的優劣勢`

 - `優勢`：
   - 搜尋靈活度高，可以進行自定義的模糊查詢。
   - 如果資料變動不大且快取有效，後續搜尋可以從快取中進行，減少網絡請求。

 - `劣勢`：
   - 初次讀取數據需要從 Firestore 獲取完整集合，這會增加網絡流量，特別是在資料量很大的情況下。
   - 當數據頻繁更新且無法利用快取時，每次搜尋都需要重新發出網絡請求，增加成本和延遲。
 */


// MARK: - 筆記：首次搜尋較慢，後續搜尋較快的原因及解決方式（重要）

/**
 ## 筆記：首次搜尋較慢，後續搜尋較快的原因及解決方式
 
 `* 背景說明：搜尋方式的改進與新挑戰`
 
 - 為了更好地優化搜尋效率，我選擇使用本地搜尋（即在本地端對已加載的資料進行篩選），而非每次搜尋時都向後端查詢。(`如前所述Firebase搜尋的限制`)
 - 這樣的改進可以顯著提升搜尋效率，降低對後端請求的頻率。但在此過程中，我遇到了首次搜尋時資料呈現較慢的問題。
 - 因此，我開始探索如何通過`預加載資料`來解決首次搜尋的延遲問題，以確保在使用者進行搜尋前資料已經準備好。
 - 並考慮在不同階段進行資料預加載的方式，如「`首次進入搜尋視圖時`」或「`應用啟動時`」加載資料，以及在「`使用者登入後`」進行加載。
 
 `* 問題分析：為什麼首次搜尋會比較慢？`
 
 `1.首次搜尋需要從 Firebase Firestore 載入大量資料：`

 - 當用戶首次進行搜尋時， App 需要從 Firebase Firestore 中獲取所有飲品資料。
 - Firebase Firestore 是基於遠端的資料庫服務，數據載入需要經過網路傳輸，因此相比於本地的讀取速度會慢很多。
 - 這種首次資料的遠端請求增加了搜尋延遲。
 
 `2.後續搜尋使用快取：`

 - 在首次載入所有飲品資料之後，這些資料會被存儲在本地的快取（例如變數 cachedDrinks）中。
 - 在後續搜尋時，只需要從快取中篩選資料，這是本地操作，速度非常快，不需要再次進行遠端請求。
 - 因此，後續搜尋的速度會明顯比首次快。
 
 `* 解決方式`
 
` 1.引入本地快取`

 - 使用本地快取來儲存載入過的資料。
 - 在首次從 Firestore 取得資料後，將這些資料存入本地變數 `cachedDrinks` 中。
 - 後續的搜尋直接使用本地快取資料進行過濾，避免重複訪問遠端資料庫。
 - 這樣可以顯著提升後續搜尋的速度，因為不再需要每次都通過網絡請求取得資料。
 
 `2.預加載資料`

 - `在進入搜尋視圖時進行資料加載`：
    - 在用戶第一次進入搜尋視圖時觸發資料加載，而非等到用戶輸入搜尋字串後再載入資料。
    - 這樣可以在用戶實際進行搜尋之前，提前將資料加載完畢，從而減少首次搜尋的延遲。
    - 這可以在 viewWillAppear 或 viewDidLoad 方法中調用 loadAllDrinksIfNeeded() 來完成。
    - 但如果網路較慢，而同時使用者在進行搜尋時，可能導致資料產生沒那麼快。
    -  實際測試下來，由於我在「搜尋視圖加載」時設置了 HUD（Loading 指示器）來顯示資料加載狀態，但操作上給人的感覺不太順手，因此決定先取消此方案。
 
 - `在 App 啟動時進行資料加載`：（採用的方式）
    - 在應用啟動時便嘗試加載所有需要的飲品資料，並快取到內存中。
    - 這樣可以在用戶進入搜尋畫面或開始搜尋之前，提前將資料加載完畢，從而減少首次搜尋的延遲。
    - 雖然這可能會略微增加應用的啟動時間，但確保搜尋功能使用時的順暢度和體驗。

 - `在使用者登入後進行資料加載：`
    - 由於 App 包含三種登入方式及註冊流程，因此另一個考量是在使用者成功登入後才進行資料加載。
    - 這樣做的優點是減少應用啟動的負擔，並且當用戶登入後，資料才會進行快取。這樣可以確保只有在需要使用資料的情況下才進行加載，避免過多的初始化負擔。
    - 這樣的選擇適合於資料量適中，且不希望影響應用啟動速度的情況。
 
 `* 適合的加載時機選擇`
 
 `1.App 啟動時加載：`
    - 適合資料變動較小、資料量有限的情況，可以在應用啟動階段進行預加載，這樣確保資料在使用前已經準備好。
    -  當品資料量約在 70 筆左右時，這種方式是合適的，可以在啟動時完成預加載。
 
 `2.登入後加載：`
    - 在應用啟動後，等待用戶成功登入後再進行資料加載，這樣可以減少應用啟動時的負擔。
    - 此方式特別適合需要多種登入流程的應用場景，因為可以根據用戶的實際需求來決定是否進行資料預加載。
 
 `3.首次進入搜尋頁面時加載：`(選擇不採用)
    - 適合資料量較大、啟動時間敏感的應用，這樣可以減少應用啟動的負擔。
    - 在目前情況下，由於資料量適中且希望提高初次搜尋的體驗，因此改為「應用啟動時加載」。
 
 `## 補充筆記：記錄其他部分`
 
 `1.快取有效期設置`
    - 在目前的解決方案中，為快取設置了一小時的有效期（cacheValidityDuration），這樣可以在確保資料不過時的同時減少 Firebase 的請求次數。
    - `快取有效期的設計考量`：
        - `資料變化頻繁`：可以考慮縮短快取的有效期，或者加入自動偵測資料變更的機制，以保持資料的即時性。
        - `資料幾乎不變`：可以適當延長快取時間，減少 Firebase 請求次數，進一步提升應用效能。
 
 `2.網絡請求的減少與成本優化`
    - Firebase Firestore 是基於請求次數計費的，因此通過設置快取來減少對 Firebase 的頻繁請求，不僅可以提高效能，也能降低使用成本。
    - 這樣的設計不僅優化了性能，也考慮到了實際運行時的運營成本。
 
 `3.單例模式的使用（如果使用啟動App時才需要）`
    - SearchManager 以 static let shared = SearchManager() 的形式作為單例模式進行設置，確保所有地方使用同一個實例，並在應用啟動時即開始加載資料。
    - `使用單例模式的設計優點`：
        - 在整個應用中共享資料快取，避免多個相同類型的資料管理器重複加載和處理資料，提高資源利用效率。
 
 `4.如果是採用「在應用啟動時進行資料加載」設計優點：`
    - 在 App 啟動時即預加載資料可以提高使用者體驗，避免進入搜尋頁面時出現長時間的加載等待。
    - 可以考慮在 App 啟動過程中顯示一個初始的加載指示器，使得使用者更直觀地知道應用正在準備資料，減少因等待時間導致的疑惑或焦躁。
 
` 5.如果是採用「在進入搜尋視圖時進行資料加載」的使用者體驗優化`
    - 預加載的目的之一是提高使用者體驗，減少等待時間。
    - 在進入搜尋頁面時提前加載資料，可以讓使用者感覺應用反應更加靈敏。
    - 另外，考慮在載入資料時給用戶展示一個加載指示器（loading indicator），以明確告訴用戶應用正在處理資料，避免用戶感到卡頓或無反應。
 
 `6.異步處理與錯誤處理`
    - 由於資料加載是異步的，因此處理過程中可能遇到網絡問題、Firebase 請求失敗等。
    - 錯誤處理策略：
        - 使用 catch 來捕捉異常並顯示錯誤信息，以便用戶了解目前的狀況。
        - 進一步優化可加入重試機制，或者在網絡錯誤時顯示提示，提醒用戶檢查網絡連接或稍後重試。
 */


// MARK: - 針對原本 SearchManager 的調整方向（重要）
/**
 
 ## 針對原本 SearchManager 的調整方向
 
 `* 原本的設計流程：`
 
 - 原本是「`search`」的過程主動會去判斷「飲品快取資料」是否有效，如果「無效」就自動進行加載，這會使得使用者困惑，因為不會曉得發生什麼事，以及是否成功。
 - 因此當飲品資料快取加載無效時，將主導權給使用者。
 
 `* 調整方向`
 
 `1.將搜尋功能與資料加載分離`

 - 搜尋功能只依賴於快取的資料，避免在搜尋過程中主動加載資料。這樣可以提升搜尋速度並減少對伺服器的壓力。
 
 `* 改進方向：`
 
 - 在應用啟動時使用 AppDelegate 預加載資料，將飲品資料存入快取。
 - 在 SearchManager 的 searchDrinks 方法中，如果快取中的飲品資料無效，返回空結果並顯示「資料尚未準備好」的提示，而不是主動加載資料。
 - 提供給用戶一個「`手動重新加載`」的選項來控制何時進行資料加載。
 
 ------------------------------------------------------------------

 `2.集中資料加載邏輯，避免重複處理`

 - `SearchDrinkDataLoader`的`loadOrRefreshDrinksData`集中化資料加載的意圖，但可以進一步改進以更清晰地將資料加載和搜尋功能分開。
 
 `* 改進方向：`
 
 - `集中處理資料加載`：只有在`應用啟動`或`用戶手動觸發`時才執行資料加載，減少資料加載的複雜度。
 - 在 `SearchDrinkDataLoader`的`loadOrRefreshDrinksData` 中處理所有資料加載的邏輯，並避免在搜尋時處理加載失敗的情況。資料加載應該是一個獨立的流程。
 
 ------------------------------------------------------------------

`3.提供資料不可用的處理方式`

 - 在 `SearchViewController` 中，在 `didUpdateSearchText` 中加入資料狀態檢查，如果資料尚未準備好，則顯示提示。
 - 當用戶嘗試進行搜尋時，如果資料不可用，應顯示「資料尚未準備好」的提示，並建議用戶稍候或手動重新加載。
 
 ------------------------------------------------------------------

` 4.調整筆記的重點`

 `* 改進方向：`
 
 - 強調「`資料加載的集中化`」和「`資料狀態的明確檢查`」。
 - 在搜尋時，只能使用快取資料，使整體的資料狀態更加一致且可控。
 
 ------------------------------------------------------------------
 
 `5.更新後的流程`
 
 `* App 啟動時：`

 - 在 AppDelegate 或首次進入相關頁面時，觸發資料加載，將飲品資料存入快取。
 - 使用 SearchCacheManager 檢查資料是否有效，如果無效，顯示提示並讓用戶決定是否重新加載。
 
 `* 用戶搜尋時：`

 - 用戶在 UISearchController 中輸入關鍵字。
 - 在 `SearchManager` 中調用 `searchDrinks` 方法，先檢查資料狀態。
    - 如果資料不可用，顯示提示，並不進行加載。
    - 如果資料已加載，則使用快取中的資料進行搜尋並返回結果。

 `* 更新後的優勢`
 
 - `使用者體驗一致性`： 用戶在進行搜尋操作時，資料已準備好，因此搜尋速度快，體驗更佳。
 - `減少伺服器負擔`： 通過集中化管理資料加載，減少不必要的 Firebase 請求，降低伺服器壓力。
 */


// MARK: - 顯示訊息通知用戶（重要）
/**

 ## 顯示訊息通知用戶
 
 關於「顯示訊息通知用戶」的部分，以下有兩種建議：

 `1. 顯示 Alert 提示用戶`
 
    - 使用 `UIAlertController` 顯示一個提示，當資料不可用時告知用戶「目前資料無法使用」。
    - 可以設置一個「重新嘗試」的按鈕，讓用戶手動觸發資料重新加載。
 
 `* 優點：`
 
    - 使用 Alert 可以讓用戶在第一時間注意到資料不可用的狀況。
    - 不會佔用畫面其他區域，有比較集中的注意力。

 ------

 `2. 顯示 UI 元件讓用戶點擊`
 
    - 直接在搜尋界面上顯示一個按鈕（例如「重新加載」按鈕）或者一段描述訊息，當資料不可用時提示用戶。
    - 這樣的設計可以讓用戶有更直接的操作體驗，並且可以控制何時重新嘗試加載。

 `* 優點：`
 
    - 使用 UI 元件（例如按鈕）可保持用戶交互的流暢性。
    - 更具彈性，用戶可以自主決定何時進行重試。

 `* 建議`
 
    - 第二種方式，即在 UI 上顯示按鈕的方式。
    - 這樣的設計會讓使用者有更多的控制權，而且可以更好地融入整體的 UI 交互流。
    - 例如在資料不可用的狀態下，顯示一個「重新加載資料」的按鈕，按鈕上可以設置重試次數限制，這樣可以防止用戶無意中進行過多次重試，導致不必要的資源浪費。
    - 可以在 `SearchView` 中加入一個 `retryButton`，當快取不可用時，顯示此按鈕。
    - 並且透過類似 `updateView(for:)` 的方法去更新當前的狀態，例如在 `noResults` 狀態下顯示該按鈕。
 
 ------

 `3. 額外想法：`
 
    1. 當「快取資料無效」時，輸入搜尋文字時會出現「訊息告知需要點擊ＵＩ元件去重試加載快取資料」相關訊息。
    2.當「快取資料無效時」，出現「UI」元件在畫面上讓使用者點擊，重載的過程中會有HUD出現。
 
 */


// MARK: - 重構_使用「快取存取」方式（添加飲品加載邏輯）_ 啟動 App。 & 單一職責 & 移除自動載入飲品資料

import UIKit
import Firebase

/// `SearchManager` 負責提供飲品搜尋功能，根據本地快取的飲品資料進行關鍵字搜尋。
///
/// 通過使用快取來提升搜尋速度並減少對 Firebase 的請求次數。
class SearchManager {
    
    // MARK: - Properties
        
    /// 搜尋快取管理器，用於獲取本地快取飲品資料
    private let searchCacheManager = SearchCacheManager.shared
    
    // MARK: - Public Methods
    
    /// 根據搜尋字串從本地快取加載符合的飲品資料並轉換成 `SearchResult` 陣列
    ///
    /// - Parameter keyword: 搜尋關鍵字
    /// - Returns: 符合條件的 `[SearchResult]` 陣列
    /// - 使用本地快取進行搜尋，以提高速度並減少對 Firebase 的請求次數。
    /// - 如果資料尚未加載，會提示使用者等待資料準備好後再進行搜尋。
    func searchDrinks(with keyword: String) async throws -> [SearchResult] {
        
        guard let cachedDrinks = searchCacheManager.getCachedDrinks() else {
            print("[SearchManager]：資料尚未準備好，請稍候")
            throw NSError(domain: "com.example.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "資料尚未準備好，請稍候"])
        }
        
        // 使用本地快取進行搜尋操作
        print("[SearchManager]：使用本地快取資料進行搜尋")
        return filterDrinks(cachedDrinks, with: keyword)
    }

    // MARK: - Private Methods

    /// 對飲品資料進行過濾
    ///
    /// - Parameters:
    ///   - drinks: 所有飲品資料
    ///   - keyword: 搜尋關鍵字
    /// - Returns: 符合條件的 `[SearchResult]` 陣列
    private func filterDrinks(_ drinks: [SearchResult], with keyword: String) -> [SearchResult] {
        let filteredDrinks = drinks.filter { drink in
            drink.name.lowercased().contains(keyword.lowercased()) ||
            drink.subName.lowercased().contains(keyword.lowercased())
        }
        return filteredDrinks
    }
    
}




// MARK: - SearchManager 重點筆記（重構前）
/**
 ## SearchManager 重點筆記
 
 `1. What`

 * SearchManager 提供了兩個主要功能：

    - `加載所有飲品資料 (loadAllDrinksIfNeeded)`：從 Firebase Firestore 加載所有飲品資料，並將其轉換為 SearchResult 陣列，並存入本地快取。
    - `搜尋飲品 (searchDrinks)`：根據關鍵字從已加載的飲品資料中過濾符合條件的飲品。

 * 包含的輔助方法：
 
    - `fetchSearchCategories`：從 Firestore 加載所有的類別。
    - `fetchSearchSubcategories`：從 Firestore 加載指定類別下的所有子類別。
    - `loadDrinks`：從 Firestore 加載子類別下所有的飲品，並轉換為 SearchResult。
    - `loadDrinksForSubcategories`：遍歷每個子類別，並加載子類別下的所有飲品資料。
 
 `2. Why`
 
 * `鉗套資料結構的需求`：
    - 由於 Firebase Firestore 中的資料結構是「鉗套」式的（`即資料層級包含多層嵌套，如 Categories -> Subcategories -> Drinks`），因此需要逐層展開才能正確讀取和整理出所有的飲品資料。每一層都必須被逐步地加載和遍歷，這樣才能獲取所有飲品資料。
 
 * `提高可讀性`：
    - 將 `loadAllDrinksIfNeeded` 的加載邏輯拆分為多個輔助方法，可以減少嵌套，讓主流程更加清晰。每個輔助方法各司其職，集中處理某個具體的加載任務。
 
 * `重用性`：
    - 拆分成輔助方法後，這些方法可以在其他場景中被重用。例如，如果只想獲取特定類別下的所有子類別，可以直接調用 `fetchSearchSubcategories` 方法。
 
 * `減少耦合`：
    - 輔助方法的拆分也減少了 `loadAllDrinksIfNeeded` 和具體 Firestore 查詢邏輯之間的耦合，使得代碼更加模組化，更容易維護和測試。

 * `提高使用者體驗`：
    - `首次進入搜尋頁面再進行資料加載`：
        - 當使用者第一次進入搜尋頁面時觸發資料加載，而`非應用啟動`時直接加載。這樣可以減少應用啟動時的等待時間，並且在用戶準備進行搜尋時，提前將資料加載完畢，提升使用者體驗。
 
 `3. How`
 
 `* 主方法 (loadAllDrinksIfNeeded)：`
    - `檢查快取是否有效`：透過 `shouldUseCachedData` 方法檢查快取是否存在且有效，若有效則直接返回。
    - `加載資料並更新快取`：若快取無效，則調用 `loadAndCacheAllDrinks` 方法從 Firebase 加載資料，並更新快取和最後加載時間。
 
`* 輔助方法：`
    - `fetchSearchCategories`、`fetchSearchSubcategories`、`loadDrinks` 都是與 `Firestore` 進行查詢交互的具體實現。
    - `loadDrinksForSubcategories` 則負責遍歷所有子類別，並加載每個子類別的飲品資料。
 
 * `錯誤處理`：
    - 在轉換 Drink 為 SearchResult 時，使用了 do-catch 來捕獲解析錯誤，並打印錯誤訊息，這樣即使個別文檔解析失敗，也不會中斷整體加載流程。
 
` 4. 使用「快取存取」方式（添加飲品加載邏輯）_ 首次進入搜尋視圖進行資料加載`
 
 `* 流程說明：`
    - 在使用者第一次進入搜尋頁面時，調用 `loadAllDrinksIfNeeded() `方法進行資料加載。這樣可以有效減少應用啟動時的負擔，並在使用者有可能進行搜尋前準備好資料。
 
 `* 活動指示器的使用：`
    - 由於加載過程可能需要較長時間，因此建議在資料加載時顯示活動指示器（例如 UIActivityIndicatorView），以向使用者明確顯示應用正在處理資料，減少使用者的等待焦慮。
 */


// MARK: - 重構前_使用「快取存取」方式（添加飲品加載邏輯）_ 啟動 App。
/*
import UIKit
import Firebase

/// `SearchManager` 負責加載 Firebase Firestore 中所有飲品資料並提供搜尋功能。
class SearchManager {
    
    // MARK: - Properties

    /// 本地快取，用於存儲飲品資料，減少 Firebase 請求次數
    private var cachedDrinks: [SearchResult]?
    
    /// 最後一次加載資料的時間
    private var lastFetchTime: Date?
    
    /// 資料快取有效期， 1 小時
    private let cacheValidityDuration: TimeInterval = 60 * 60
    
    /// 單例模式
    static let shared = SearchManager()
    
    // MARK: - Public Methods

    /// 加載所有飲品資料並存入快取（如果需要）
    /// - 當本地快取不存在或已過期時，從 Firebase 加載資料並更新快取
    func loadAllDrinksIfNeeded() async throws {
        if shouldLoadAllDrinks() {
            try await loadAndCacheAllDrinks()
        } else {
            print("快取有效，無需重新加載飲品資料")
        }
    }
    
    /// 根據搜尋字串從本地快取或 Firebase 加載符合的飲品資料並轉換成 `SearchResult` 陣列
    /// - Parameter keyword: 搜尋關鍵字
    /// - Returns: 轉換完成的 `[SearchResult]` 陣列
    func searchDrinks(with keyword: String) async throws -> [SearchResult] {
        // 如果沒有加載過飲品資料，先加載
        if cachedDrinks == nil {
            print("未加載飲品資料，先進行加載")
            try await loadAllDrinksIfNeeded()
        }
    
        // 使用快取進行搜尋
        guard let cachedDrinks = cachedDrinks else {
            print("快取資料不可用，請重試")
            return []
        }
        
        print("使用本地快取資料進行搜尋")
        return filterDrinks(cachedDrinks, with: keyword)
    }
    
    // MARK: - Private Helper Methods
    
    /// 檢查是否需要加載所有飲品資料
    /// - Returns: 如果需要加載資料，返回 `true`，否則返回 `false`
    private func shouldLoadAllDrinks() -> Bool {
        if let lastFetchTime = lastFetchTime, cachedDrinks != nil {
            let timeSinceLastFetch = Date().timeIntervalSince(lastFetchTime)
            return timeSinceLastFetch >= cacheValidityDuration
        }
        return true
    }

    /// 從 Firebase 加載所有飲品並存入快取
    private func loadAndCacheAllDrinks() async throws {
        print("開始加載飲品資料...")
        let allDrinks = try await loadAllDrinksFromFirestore()
        self.cachedDrinks = allDrinks
        self.lastFetchTime = Date()
        print("已從 Firebase 加載所有飲品資料並存入快取，共 \(allDrinks.count) 筆資料")
    }
    
    /// 從 Firebase 加載所有飲品資料
    /// - Returns: 所有飲品的 `SearchResult` 陣列
    private func loadAllDrinksFromFirestore() async throws -> [SearchResult] {
        let db = Firestore.firestore()
        var allDrinks: [SearchResult] = []

        // 加載所有 Categories 並遍歷每個 Category
        let categoriesSnapshot = try await fetchSearchCategories(from: db)
        for categoryDocument in categoriesSnapshot.documents {
            let categoryId = categoryDocument.documentID
            let subcategoriesSnapshot = try await fetchSearchSubcategories(for: categoryId, from: db)
            let drinksForSubcategories = try await loadDrinksForSubcategories(subcategoriesSnapshot, categoryId: categoryId, from: db)
            allDrinks.append(contentsOf: drinksForSubcategories)
        }
        
        return allDrinks
    }
    
    /// 對飲品資料進行過濾
    /// - Parameters:
    ///   - drinks: 所有飲品資料
    ///   - keyword: 搜尋關鍵字
    /// - Returns: 符合條件的 `[SearchResult]` 陣列
    private func filterDrinks(_ drinks: [SearchResult], with keyword: String) -> [SearchResult] {
        let filteredDrinks = drinks.filter { drink in
            drink.name.lowercased().contains(keyword.lowercased()) ||
            drink.subName.lowercased().contains(keyword.lowercased())
        }
        return filteredDrinks
    }

    // MARK: - Firebase Helper Methods
    
    /// 加載所有類別（Categories）
    /// - Parameter db: Firestore 資料庫實例
    /// - Returns: 類別 (Categories) 的 `QuerySnapshot`
    private func fetchSearchCategories(from db: Firestore) async throws -> QuerySnapshot {
        return try await db.collection("Categories").getDocuments()
    }
    
    /// 加載指定 Category 下的所有 Subcategories
    /// - Parameters:
    ///   - categoryId: 類別的 ID
    ///   - db: Firestore 資料庫實例
    /// - Returns: 子類別 (Subcategories) 的 `QuerySnapshot`
    private func fetchSearchSubcategories(for categoryId: String, from db: Firestore) async throws -> QuerySnapshot {
         return try await db.collection("Categories")
             .document(categoryId)
             .collection("Subcategories")
             .getDocuments()
     }
    
    /// 加載所有 Subcategories 下的 Drinks 並返回 SearchResult 陣列
    /// - Parameters:
    ///   - subcategoriesSnapshot: 子類別 (Subcategories) 的 `QuerySnapshot`
    ///   - categoryId: 類別的 ID
    ///   - db: Firestore 資料庫實例
    /// - Returns: 飲品資料的 `[SearchResult]` 陣列
    private func loadDrinksForSubcategories(_ subcategoriesSnapshot: QuerySnapshot, categoryId: String, from db: Firestore) async throws -> [SearchResult] {
        var allDrinks: [SearchResult] = []
        for subcategoryDocument in subcategoriesSnapshot.documents {
            let subcategoryId = subcategoryDocument.documentID
            let drinks = try await fetchSearchDrinks(for: categoryId, subcategoryId: subcategoryId, from: db)
            allDrinks.append(contentsOf: drinks)
        }
        return allDrinks
    }
    
    /// 加載指定子類別下的所有飲品資料
    /// - Parameters:
    ///   - categoryId: 類別的 ID
    ///   - subcategoryId: 子類別的 ID
    ///   - db: Firestore 資料庫實例
    /// - Returns: 飲品資料的 `[SearchResult]` 陣列
    private func fetchSearchDrinks(for categoryId: String, subcategoryId: String, from db: Firestore) async throws -> [SearchResult] {
        let drinksSnapshot = try await db.collection("Categories")
            .document(categoryId)
            .collection("Subcategories")
            .document(subcategoryId)
            .collection("Drinks")
            .getDocuments()
        
        print("正在處理 Drinks 資料 (Category: \(categoryId), Subcategory: \(subcategoryId))，共 \(drinksSnapshot.documents.count) 筆")

        /// 將每個 `Drink` 轉換為 `SearchResult` 物件
        return drinksSnapshot.documents.compactMap { document in
            do {
                var searchResult = try document.data(as: SearchResult.self)
                searchResult.categoryId = categoryId
                searchResult.subcategoryId = subcategoryId
                searchResult.drinkId = document.documentID
                return searchResult
            } catch {
                print("Error decoding drink document: \(error)")
                return nil
            }
        }
    }

}
*/
