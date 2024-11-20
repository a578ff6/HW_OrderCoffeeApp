//
//  SearchManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/11/15.
//

// MARK: - SearchManager 的筆記(重構後)
/**
 
 ## SearchManager 的筆記
 
 `1. 設計目的`

 - `SearchManager`
    - 是飲品搜尋功能的核心，負責處理所有搜尋相關的邏輯，包括從` Firebase 加載飲品資料`、`管理快取`以及`根據關鍵字進行資料過濾`。
 
 - `SearchDrinkDataService`
    - 負責從 Firebase 加載各層級的飲品資料，並提供底層的數據交互服務。
    - 為 SearchManager 提供所需的飲品數據，避免讓 SearchManager 負責太多的 Firebase 操作，保持代碼的職責單一性。
 
 - `searchCacheManager`
    - 負責管理快取機制，減少資料加載的重複工作，確保用戶體驗流暢。
    - 它在 SearchManager 請求資料時，先檢查是否存在有效快取，以決定是否需要重新從 Firebase 獲取資料。
 
 `2. 職責分配`

 - `searchDrinkDataService`：負責與 Firebase 之間的資料存取，提供從資料庫加載資料的功能，這些資料包括 "`Categories`"（類別）、"`Subcategories`"（子類別）和 "`Drinks`"（飲品）。
 - `searchCacheManager`：管理飲品資料的快取，包括存儲和更新快取，降低 Firebase 的請求次數以提升效能。
 - `loadAllDrinksIfNeeded()`：檢查是否需要加載飲品資料，如果快取有效則不進行加載。
 - `searchDrinks(with:)`：根據搜尋關鍵字進行資料過濾，優先使用本地快取。
 
 `3. 快取機制`

 - `searchCacheManager` 用於管理飲品資料的快取，當快取資料過期或者不可用時，`SearchManager` 會重新從 Firebase 加載資料並更新快取，確保資料的準確性和有效性。
 
 - `searchCacheManager 的具體職責包括`：
    - `快取資料的管理`：`cachedDrinks` 用於存儲飲品資料，`lastFetchTime` 用於追蹤最後一次加載資料的時間。
    - `快取有效性判斷`：`shouldReloadData() `檢查是否需要重新加載資料，而 `getCachedDrinks() `會根據快取是否有效來決定返回快取資料或重新加載。
 
 -  這樣的快取設計既能減少資料庫的請求次數，又能確保用戶獲取最新的資料。
 
 `4. Firebase 加載資料的流程`

 - `loadAllDrinksFromFirebase()`
    -  這是 SearchManager 中加載所有飲品資料的主方法，負責遍歷 Firebase 中所有類別 (`Categories`) 並從每個子類別 (`Subcategories`) 中逐層加載飲品資料 (`Drinks`)。
    -  該方法依賴於 `searchDrinkDataService` 來進行資料加載，以便將資料存取的細節與業務邏輯分離，增強代碼的可讀性和可維護性。
    - 使得 Firebase 的資料加載部分從 SearchManager 中抽離，實現了更清晰的分層。
 
 - `loadDrinksForSubcategories()`
    - 作為 `loadAllDrinksFromFirebase()`的輔助方法，專門用於從指定的子類別中加載所有飲品資料。
    - 它的職責是更細緻地處理每個子類別的飲品資料加載，從而與主加載流程 (`loadAllDrinksFromFirebase()`) 形成層層遞進的結構。
 
 `5. 層級關係和責任分離`
 
 - `loadAllDrinksFromFirebase()` 是整個資料加載的入口，負責管理所有類別和子類別的遍歷。
 - `loadDrinksForSubcategories() `則是對某一類別下所有子類別中的飲品資料進行加載，形成了層層深入的資料加載結構。
 - 這種層級分工使得邏輯更為清晰，每個方法專注於一層的資料加載，大大提升了可讀性和代碼的維護性。
 
 `6. 資料過濾的設計`

 - `filterDrinks(_:with:)`：負責根據搜尋關鍵字對飲品資料進行過濾，確保搜尋結果能夠即時反應用戶的輸入。
 - 在搜尋時，優先使用已加載的快取資料，並對其進行過濾。
 - 過濾邏輯包括飲品名稱 (name) 和副名稱 (subName)，確保搜尋結果能夠即時反應使用者的需求。
 
 `7. 總結`
 
 - `職責分離`：`SearchManager` 利用多層方法和多個管理器 (`searchDrinkDataService`、`searchCacheManager`)，將搜尋邏輯、資料加載、快取管理等功能區分開來，使每個部分各司其職，符合單一職責原則。
 - `層級設計`：加載資料的過程從類別到子類別，再到具體飲品，是層層遞進的邏輯結構，增強代碼的模組化，提升可維護性。
 - `快取機制的應用`：有效利用 `searchCacheManager` 來減少重複的 Firebase 請求，並通過基於時間的有效期檢查來平衡資料新鮮度與效能，這樣既能減少資料庫的負擔，又能提供更好的用戶體驗。
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
 private func loadDrinks(for categoryId: String, subcategoryId: String, from db: Firestore, keyword: String) async throws -> [SearchResult] {
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
 private func loadDrinks(for categoryId: String, subcategoryId: String, from db: Firestore, keyword: String) async throws -> [SearchResult] {
     
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


// MARK: - 重構_使用「快取存取」方式（添加飲品加載邏輯）_ 啟動 App。

import UIKit
import Firebase

/// `SearchManager` 負責加載 Firebase Firestore 中所有飲品資料並提供搜尋功能
class SearchManager {
    
    // MARK: - Properties
    
    /// 飲品資料服務，用於從 Firebase 加載飲品相關的資料
    private let searchDrinkDataService = SearchDrinkDataService()
    
    /// 搜尋快取管理器，用於快取飲品資料，減少 Firebase 請求次數
    private let searchCacheManager = SearchCacheManager()
    
    /// 單例模式
    static let shared = SearchManager()
    
    // MARK: - Public Methods
    
    /// 加載所有飲品資料並存入快取（如果需要）
    /// - 當本地快取不存在或已過期時，從 Firebase 加載資料並更新快取
    func loadAllDrinksIfNeeded() async throws {
        print("開始加載飲品資料...")
        if searchCacheManager.shouldReloadData() {
            let drinks = try await loadAllDrinksFromFirebase()
            searchCacheManager.cacheDrinks(drinks)
            print("已從 Firebase 加載所有飲品資料並存入快取，共 \(drinks.count) 筆資料")
        } else {
            print("快取有效，無需重新加載飲品資料")
        }
    }
    
    /// 根據搜尋字串從本地快取或 Firebase 加載符合的飲品資料並轉換成 `SearchResult` 陣列
    /// - Parameter keyword: 搜尋關鍵字
    /// - Returns: 轉換完成的 `[SearchResult]` 陣列
    func searchDrinks(with keyword: String) async throws -> [SearchResult] {
        
        // 如果有快取資料，直接使用快取資料進行搜尋
        if let cachedDrinks = searchCacheManager.getCachedDrinks() {
            print("使用本地快取資料進行搜尋")
            return filterDrinks(cachedDrinks, with: keyword)
        } else {
            // 如果沒有快取資料，先加載所有飲品資料
            try await loadAllDrinksIfNeeded()
            guard let cachedDrinks = searchCacheManager.getCachedDrinks() else {
                print("快取資料不可用，請重試")
                return []
            }
            print("使用本地快取資料進行搜尋")
            return filterDrinks(cachedDrinks, with: keyword)
        }
    }
    
    // MARK: - Private Methods
    
    /// 從 Firebase 加載所有飲品資料
    /// - Returns: 所有飲品的 `SearchResult` 陣列
    private func loadAllDrinksFromFirebase() async throws -> [SearchResult] {
        var allDrinks: [SearchResult] = []
        
        // 加載所有 Categories 並遍歷每個 Category
        let categoriesSnapshot = try await searchDrinkDataService.loadCategories()
        for categoryDocument in categoriesSnapshot.documents {
            let categoryId = categoryDocument.documentID
            let subcategoriesSnapshot = try await searchDrinkDataService.loadSubcategories(for: categoryId)
            let drinksForSubcategories = try await loadDrinksForSubcategories(subcategoriesSnapshot, categoryId: categoryId)
            allDrinks.append(contentsOf: drinksForSubcategories)
        }
        
        return allDrinks
    }
    
    /// 加載所有子類別下的飲品並返回 `SearchResult` 陣列
    /// - Parameters:
    ///   - subcategoriesSnapshot: 子類別 (Subcategories) 的 `QuerySnapshot`
    ///   - categoryId: 類別的 ID
    /// - Returns: 飲品資料的 `[SearchResult]` 陣列
    private func loadDrinksForSubcategories(_ subcategoriesSnapshot: QuerySnapshot, categoryId: String) async throws -> [SearchResult] {
        var allDrinks: [SearchResult] = []
        for subcategoryDocument in subcategoriesSnapshot.documents {
            let subcategoryId = subcategoryDocument.documentID
            let drinks = try await searchDrinkDataService.loadDrinks(for: categoryId, subcategoryId: subcategoryId)
            allDrinks.append(contentsOf: drinks)
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
    
}




// MARK: - SearchManager 重點筆記（重構前）
/**
 ## SearchManager 重點筆記
 
 `1. What`

 * SearchManager 提供了兩個主要功能：

    - `加載所有飲品資料 (loadAllDrinksIfNeeded)`：從 Firebase Firestore 加載所有飲品資料，並將其轉換為 SearchResult 陣列，並存入本地快取。
    - `搜尋飲品 (searchDrinks)`：根據關鍵字從已加載的飲品資料中過濾符合條件的飲品。

 * 包含的輔助方法：
 
    - `loadCategories`：從 Firestore 加載所有的類別。
    - `loadSubcategories`：從 Firestore 加載指定類別下的所有子類別。
    - `loadDrinks`：從 Firestore 加載子類別下所有的飲品，並轉換為 SearchResult。
    - `loadDrinksForSubcategories`：遍歷每個子類別，並加載子類別下的所有飲品資料。
 
 `2. Why`
 
 * `鉗套資料結構的需求`：
    - 由於 Firebase Firestore 中的資料結構是「鉗套」式的（`即資料層級包含多層嵌套，如 Categories -> Subcategories -> Drinks`），因此需要逐層展開才能正確讀取和整理出所有的飲品資料。每一層都必須被逐步地加載和遍歷，這樣才能獲取所有飲品資料。
 
 * `提高可讀性`：
    - 將 `loadAllDrinksIfNeeded` 的加載邏輯拆分為多個輔助方法，可以減少嵌套，讓主流程更加清晰。每個輔助方法各司其職，集中處理某個具體的加載任務。
 
 * `重用性`：
    - 拆分成輔助方法後，這些方法可以在其他場景中被重用。例如，如果只想獲取特定類別下的所有子類別，可以直接調用 `loadSubcategories` 方法。
 
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
    - `loadCategories`、`loadSubcategories`、`loadDrinks` 都是與 `Firestore` 進行查詢交互的具體實現。
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
        let categoriesSnapshot = try await loadCategories(from: db)
        for categoryDocument in categoriesSnapshot.documents {
            let categoryId = categoryDocument.documentID
            let subcategoriesSnapshot = try await loadSubcategories(for: categoryId, from: db)
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
    private func loadCategories(from db: Firestore) async throws -> QuerySnapshot {
        return try await db.collection("Categories").getDocuments()
    }
    
    /// 加載指定 Category 下的所有 Subcategories
    /// - Parameters:
    ///   - categoryId: 類別的 ID
    ///   - db: Firestore 資料庫實例
    /// - Returns: 子類別 (Subcategories) 的 `QuerySnapshot`
    private func loadSubcategories(for categoryId: String, from db: Firestore) async throws -> QuerySnapshot {
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
            let drinks = try await loadDrinks(for: categoryId, subcategoryId: subcategoryId, from: db)
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
    private func loadDrinks(for categoryId: String, subcategoryId: String, from db: Firestore) async throws -> [SearchResult] {
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
