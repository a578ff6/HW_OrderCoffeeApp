//
//  OrderManagerError.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/1.
//

// MARK: - 關於同時將訂單存取在「 /orders 集合」中，以及「用戶的子集合」中。
/*
 
 ## 思考重點：
    A. 在 /orders 集合中存取訂單：
        - orders 集合中的每個文件檔案代表一個訂單，包含 uid 來表示該訂單屬於哪個客戶。
        - 優點：
            - 方便店家全面去查看、處理所有訂單。
            - 更容易進行全局訂單分析和統計。
        - 缺點：
            - 需要額外的邏輯來根據用戶ID查詢特定用戶的訂單。
 
    B. 在每個客戶的子集合中取取訂單：
        - users 集合中的每個用戶有一個 orders 子集合，訂單存取在這個子集合中。
        - 優點：
            - 用戶可以方便查看和管理自己的訂單。
            - 資料結構夠符合用戶的使用邏輯。
        - 缺點：
            - 店家全局查看和處理所有訂單時，需要遍歷每個用戶的子集合，查詢較複雜。
 
    C. 綜合考量：
        - 同時將訂單存取在 /orders 集合中，以及用戶的子集合中。
 
 --------------------------------------------------------------------------
 
 1. 在資料庫中設置訂單結構：
        - 將訂單資料存取在用戶的訂單集合中，方便管理查詢。

 2. 提交訂單資訊：
        - 在用戶提交訂單時，將訂單資訊提交到 Firebase，並設置本地通知。
 
 3. 設置本地通知：
        - 再訂單提交成功後，根據準備時間設置本地通知，提醒用戶訂單準備完成。
 
 藉由上述方式，確保每個訂單都與特定用戶關聯到，並在訂單準備完成後通知用戶。
 */


// MARK: - 關於 重構後的 OrderManager 負責管理和提交訂單，包括`顧客資料`和`訂單項目`的整合。（重要）

/*
 
 &. 想法：
    - 由於最初在設計流程的時候，並沒有考慮到 OrderCustomerDetailsViewController，只想著「訂單飲品項目」搭配「註冊時的顧客資料」一起呈現在 OrderViewController 然後透過 OrderManager 上傳處理，也因此資料結構變得很雜亂。
    - 但隨著我將 OrderViewController 逐步完善後，我發現如果不讓使用者填寫資料的話，只透過註冊時的資料來運用，那摩對於資料的運用好像有點僵化。
    - 此外 OrderViewController 要讓顧客填寫資料，那麼過於集中UI元件，也會導致該視圖控制器的職責過於複雜模糊化。
    - 因此我才設置了 OrderCustomerDetailsViewController，也因此才衍伸出拆解重構 OrderManager、OrderItem 的問題：
        1. CustomerDetails、CustomerDetailsManager 的設置。（處理顧客詳細資料）
        2. OrderItem、OrderItemManager 的設置。（處理訂單飲品項目）
        3. 設置 Order 是用於記錄完整訂單的結構，包含了顧客的詳細資料、訂單中的所有飲品項目，以及訂單的建立時間和總金額。
 
 &. 關於 OrderManager 的定位改進部分：
    
    * 提交整個訂單應該由 OrderManager 處理，因為這涉及將顧客資料 (CustomerDetails) 和訂單項目 (OrderItem) 整合到一個訂單 (Order) 結構中，並完成提交過程。
 
    1. 是否保留 OrderManager：
        - OrderManager 可以專注於管理和處理整個訂單的提交過程，這樣可以將「飲品項目」和「顧客資料」的細節處理分離開來。保持清晰的職責劃分，不僅可以提高可維護性，還能使各個 Manager 專注於各自的功能，減少相互之間的耦合。

        （ OrderItemManager：負責管理訂單中的飲品項目。 ）
        （ CustomerDetailsManager：負責管理顧客的詳細資料。 ）
        （ OrderManager：負責管理和提交整體訂單，這包括 OrderItemManager 和 CustomerDetailsManager 的整合，並負責提交至 Firebase。）
 
    2. OrderCustomerSubmitCell 設置提交邏輯：
        - 在 OrderCustomerSubmitCell 的 onSubmitTapped 進行提交整個 Order 至 Firestore 的設計。
        - 通過這個按鈕點擊事件來觸發提交操作，只是在 onSubmitTapped 的回調裡，需要進行更進一步的邏輯處理，例如整合顧客資料和訂單項目，並將其提交至 Firebase。

    3. 提交邏輯應該設置在 OrderManager：
        - 提交整個訂單應該由 OrderManager 處理，因為這涉及將顧客資料 (CustomerDetails) 和訂單項目 (OrderItem) 整合到一個訂單 (Order) 結構中，並完成提交過程。
        - 這個職責屬於整體訂單的管理，而不應該分散到 CustomerDetailsManager 或 OrderItemManager。
        - 在 OrderManager 中調整 submitOrder() ，藉此可以從 OrderItemManager 獲取所有訂單項目，從 CustomerDetailsManager 獲取顧客詳細資料，然後組合成 Order 結構進行提交。

    4. 收取配送費用邏輯：
        - 關於外送的額外費用部分，可以在 OrderManager 中的 submitOrder() 方法進行處理。在提交之前，檢查顧客的取件方式，如果是外送服務，則在 totalAmount 上增加配送費用 (60元)。
 */

// MARK: - 重點筆記：

/*
 
 ## OrderManager 重點筆記
 
    * 負責管理訂單提交
 
        - OrderManager 的主要功能是負責將完整的訂單提交到 Firebase Firestore，確保顧客資料與訂單項目都被正確儲存。
 
    * 提交訂單流程
 
         - submitOrder()：
            1. 該方法負責整合顧客資料（CustomerDetails）和訂單項目（OrderItem），並生成一個完整的訂單（Order），然後將其儲存到 Firebase Firestore。
            2. 提交時檢查用戶是否登入，並利用 Order 生成所需的訂單資料。
 
    * Firestore 資料儲存
 
        - saveOrderData(orderData:for:) 負責將訂單資料儲存到 Firestore 中。會將訂單存放於兩個地方：
 
            1. 用戶個別的子集合（users/<userID>/orders），用於查詢該用戶的歷史訂單。
            2. 全局的 orders 集合，用於後台管理所有訂單。
 
        - 使用手動序列化的方式來準備 Firestore 存儲的字典 (orderDict)，並且將不必要的資料欄位（例如 description 和每個飲品的 prepTime）註解掉以減少存儲量。
 
    * 通知用戶取件時間
 
        - scheduleOrderReadyNotification(prepTime:)：安排一個本地通知，當訂單的準備時間完成後提醒用戶訂單已經準備好取件。
        - 通知包含標題、內容，並設定通知的觸發時間，根據準備時間計算。
 
    * 處理宅配費用邏輯
 
        - calculateTotalAmount(order:)：
 
            1. 在計算訂單總金額時，會依據取件方式（PickupMethod）判斷是否需要額外加上宅配費用（例如宅配服務費 60 元）。如果顧客選擇宅配服務，則會將該金額加到訂單總金額中。
            2. 設置 totalAmount 作為 Order 的一部分，在 submitOrder() 中手動計算總金額，並將額外的宅配費用加上去。這樣可以確保訂單中的金額是包括運費在內的準確金額。
 
    * 錯誤處理
 
        - 提交訂單的過程中使用 throws 來拋出錯誤，例如用戶未登入或儲存失敗。
        - OrderManagerError enum 提供錯誤類型，方便根據不同錯誤情況進行調試和處理。
 
    * 使用 OrderManager 提交訂單
 
        - OrderCustomerSubmitCell 中的提交按鈕 onSubmitTapped 回調會觸發 OrderManager.shared.submitOrder() 方法，完成訂單提交流程。
 
 
 ## 如何使用 OrderManager：
 
    - 當用戶在 OrderCustomerDetailsViewController 中填寫完所有資料，並點擊 "Submit Order" 按鈕時，可以使用 OrderManager 來提交訂單。
    - 確保 CustomerDetailsManager 和 OrderItemManager 都包含最新的顧客資料與訂單項目，然後透過 OrderManager 將這些資料整合並提交至 Firestore。
 */

// MARK: - 訂單結構與調整說明

/*
 
 ## Order 結構：
 
    1. 將 totalAmount 設置為屬性而非計算屬性：
        - 這是為了確保在建立訂單時計算出的總金額（包括宅配費用）能夠正確保存並直接使用。計算屬性無法保持額外添加的運費，因此需要手動計算並將金額存入屬性中。

 ## OrderManager：
 
    1. saveOrderData() 方法調整：
        - 手動序列化： 使用手動序列化訂單資料，以便靈活控制哪些資料應存入 Firestore 中。
        - 移除不必要的欄位： 將每個飲品的 description 和 prepTime 欄位註解掉，因為這些資料在歷史訂單中不需要顯示，這樣可以減少存儲資料量並提高讀取效率。
 */


// MARK: - 提交到 Firestore 錯誤原因及解決辦法筆記（重要）

/*
 
 ## 原先的寫法，提交後出現「FirebaseFirestore.FirestoreEncodingError」嘗試存儲的資料格式不符合 Firestore 的要求有關。即當結構中有無法被正確轉換為 Firestore 支援的格式時，就可能出現這個錯誤。
 
 /// 儲存訂單資料至 Firestore
 /// - Parameters:
 ///   - order: 訂單結構
 ///   - userID: 當前使用者
 private func saveOrderData(order: Order, for userID: String) async throws {
     let db = Firestore.firestore()
     let orderData = try JSONEncoder().encode(order)
     let orderDict = try JSONSerialization.jsonObject(with: orderData, options: []) as? [String: Any]
     
     /// 在用戶子集合中添加訂單
     try await db.collection("users").document(userID).collection("orders").addDocument(data: orderDict ?? [:])
     
     /// 在全局 orders 集合中添加訂單
     try await db.collection("orders").addDocument(data: orderDict ?? [:])
 }

 -----------------------------------------------------------------------------------------------------------------
 
 ## Firestore 提交錯誤原因：
    
    * UUID 不支援：
        - Firestore 僅支援有限的原生數據類型（如 String、Int、Double、Date 等），而 UUID 類型不是 Firestore 支援的類型，因此直接提交 UUID 會導致 FirestoreEncodingError 錯誤。
 
    * 自動編碼問題：
        - 使用 JSONEncoder 來將 Order 結構編碼成字典，這種方式會包含 Firestore 不支援的類型（如 UUID 和 URL），導致最終的字典無法被 Firestore 接受。

 ## 具體改動及原因：
 
    1. 手動序列化
        - 手動構建 Firestore 字典，並將 UUID 類型的屬性轉換為 String 格式，以確保其與 Firestore 支援的格式相匹配。

    2. UUID 轉換
        - 在構建 Firestore 的數據字典時，使用 .uuidString 將 UUID 轉換為 String：( "id": order.id.uuidString )
        - 這樣使得 Order 和 OrderItem 中的 id 都變為 Firestore 可接受的格式，解決了提交訂單失敗的問題。

    3. 其他類型轉換
        - 類似 URL 類型的字段，也需要在提交給 Firestore 前轉換為 String，例如使用 .absoluteString。

 ## 重點

    1. Firestore 僅支援特定數據類型：如 String、Int、Double、Bool、Date 等，其他類型（如 UUID 和 URL）需要轉換。
    2. 手動構建字典：確保所有數據字段都符合 Firestore 要求，避免 FirestoreEncodingError，從而順利提交訂單至 Firestore。
 
 */


// MARK: - 維持手動序列化的原因（重要）

/*

  - 調整 Order 中的 id 從 UUID 改成一個合適的類型，例如 String，確實可以使用 JSONEncoder 的方式來序列化，避免手動構建字典的麻煩。
    這樣做的好處是能夠簡化代碼和減少錯誤發生的機會，因為 JSONEncoder 可以自動完成序列化而不用手動構建數據結構。
    然而，還是要考慮 Firestore 特性和某些情況下的靈活性。
 
 ## 保持手動序列化的好處：

 1. 更高的靈活性：
 
    - 手動構建字典時，可以對提交的數據進行更細緻的控制。可以針對每個字段檢查和調整，以確保數據符合預期的格式。
    - 手動序列化能輕鬆地選擇哪些字段需要提交，哪些不需要，這樣可以避免在不必要的情況下將過多的數據提交到 Firestore。

 2. 數據格式一致性：
 
    - 手動序列化可以確保每個字段都使用 Firestore 支援的原生類型。
    - 例如，可以更精細地將 URL、UUID 等類型轉換成 String，這樣可以防止在自動序列化中出現不符合 Firestore 支援類型的數據而導致的錯誤。
 
 ## 自動序列化的優勢：

 1. 簡化代碼：
    
    - 使用 JSONEncoder 可以自動處理很多字段，省去手動構建字典的工作，使代碼更加簡潔。
    - 當 Order 結構改變時（例如新增或刪除某些屬性），不需要每次都修改手動構建的字典。
 
 ## 結論：
 
    - 如果 Order 結構相對穩定，不會頻繁改動，並且希望最大化程式碼的可讀性和可維護性，可以考慮使用自動序列化的方式，即使用 JSONEncoder。
    - 如果需要更靈活的控制，或者擔心 Firestore 在某些情況下對類型支持不足（例如日期、URL 等），那麼手動序列化會是更保險的選擇。
 
 */


// MARK: - createOrderDict 根據訂單明細視圖控制器的具體需求來決定哪些資料要保留（手動序列化）

/*
 
 ## 由於後續會設置「訂單明細視圖控制器」、「訂單歷史紀錄」等，並且考量到FireStore中的資料方便閱讀，因此做精簡調整。
 
 
 1. prepTime（在 orderItems 中）

    * 描述：
        - 目前有兩個與準備時間相關的欄位，一個是 orderItems 裡的 prepTime，另一個是整體的 totalPrepTime。
 
    * 調整：
        - 如果已經保存了 totalPrepTime，可以考慮移除每個訂單項目中的 prepTime，因為可以根據 orderItems 自行計算出來（除非需要展示每一項目的準備時間）。

 2. categoryId 和 subcategoryId
 
    * 描述：
        - 這兩個欄位用於標識飲品的類別和子類別。
 
    * 調整：
        - 如果在訂單明細中不打算展示飲品的類別資訊，那麼可以移除這些欄位，這樣可以減少存儲的資料量。
 
 3. totalAmount（在 orderItems 中）
 
    * 描述：
        - 每個 orderItem 中有 totalAmount，這是計算該飲品的總價。
 
    * 調整：
        - 如果能從 price 和 quantity 動態計算出來，那麼可以考慮移除 totalAmount 欄位。
 
 ## 總結：
 
 1 精簡存儲：
    - 刪除不必要的欄位可以有效地減少 Firestore 中的數據量，提高性能並減少存儲成本。
 
 2. 動態計算：
    - 可以動態計算的欄位，例如 totalAmount 和 prepTime，如果在使用中很少需要被直接查詢，可以考慮只保留總值，不存儲各個項目的細節。
 
 3. 用途決定保留：如果某些資料在 UI 顯示中不需要，或者能夠從其他資料中動態獲取，則可以考慮移除。
    - 可以根據訂單明細視圖控制器的具體需求來決定哪些資料要保留，哪些可以動態計算或完全不保留。最終，讓存儲的資料達到精簡、有效即可。
 
 */


// MARK: - 分析三種添加訂單到 Firestore 的方法：（重要）

/*
 
 - 起因於當初在設置的時候採用「方法一」的設置，發現在 Firestore 中，「用戶子集合」中的訂單和「全局 orders 集合」中的訂單的檔名（實際上是文件的 ID）是不同的。
   這是因為在 saveOrderData 方法中，你兩次使用 addDocument(data:) 方法，這會生成不同的文件 ID。
 
 * 為什麼文件名不一樣？
    - 當使用 addDocument(data:) 時，Firestore 會為每個新的文檔自動生成唯一的 ID。
    - 因此，當分別向「用戶子集合」和「全局 orders 集合」中添加相同的 orderDict 資料時，Firestore 為每個集合都生成了一個不同的文檔 ID，這是完全正常的操作。

  1. 不同集合中的文檔 ID 獨立管理：
        - Firestore 不會跨集合重複使用文檔 ID。因此，即使兩次添加相同的資料，它們會有不同的文檔 ID，因為它們屬於不同的集合。

  2. 不同的用途：
        - 用戶子集合： 用於跟蹤特定用戶的訂單記錄，每個用戶的訂單是存儲在這個用戶文檔下的 orders 子集合中。
        - 全局 orders 集合： 用於存儲 App 中所有的訂單，便於全局查詢和管理。
 
 -------------------------------------------------------------------------------------------------------------
 
 ## 這調整的過程中嘗試了三種方式：
 
 &. 方法一：使用不同的自動生成文檔 ID
 
 /// 在`用戶子集合`中添加訂單
 try await db.collection("users").document(userID).collection("orders").addDocument(data: orderDict)
 /// 在`全局 orders 集合`中添加訂單
 try await db.collection("orders").addDocument(data: orderDict)
 
 * 特點：
    - 每次添加訂單時，Firestore 會自動生成不同的文檔 ID。
    - 用戶子集合和全局 orders 集合中的文檔 ID 不一致。
 
 * 優點：
    - 簡單易用，不需要手動管理 ID。
    - 適合對訂單不做聯合查找的情況，文檔之間相互獨立。
 
 * 缺點：
    - 如果需要聯合查找或同步操作，因為文檔 ID 不一致，會使查詢過程更為複雜。
    - 難以保證訂單在兩個集合中的一致性。
 
 -------------------------------------------------------------------------------------------------------------

 &. 方法二：生成相同的文檔 ID，保持兩個集合一致
 
 /// 生成相同的文檔 ID
 let orderID = db.collection("orders").document().documentID
 /// 在`用戶子集合`中添加訂單，使用相同的文檔 ID
 try await db.collection("users").document(userID).collection("orders").document(orderID).setData(orderDict)
 /// 在`全局 orders 集合`中添加訂單，使用相同的文檔 ID
 try await db.collection("orders").document(orderID).setData(orderDict)
 
 * 特點：
    - 使用 Firestore 生成的相同文檔 ID，將訂單保存到用戶子集合和全局 orders 集合。
    - 保持兩個集合中訂單的 ID 一致。
 
 * 優點：
    - 保證訂單在兩個集合中的一致性，便於聯合查找和同步操作。
    - 文檔 ID 由 Firestore 自動生成，仍然保留了一定的靈活性。
 
 * 缺點：
    - 需要手動管理和同步兩個集合中的文檔 ID，增加了少量的管理成本。
 
 -------------------------------------------------------------------------------------------------------------

 &. 方法三：使用訂單的 UUID 作為文檔 ID
 
 /// 使用 order.id.uuidString 作為文檔 ID（將 UUID 轉為 String）
 let orderID = order.id.uuidString
 /// 在`用戶子集合`中添加訂單，使用相同的文檔 ID
 try await db.collection("users").document(userID).collection("orders").document(orderID).setData(orderDict)
 /// 在`全局 orders 集合`中添加訂單，使用相同的文檔 ID
 try await db.collection("orders").document(orderID).setData(orderDict)
 
 * 特點：
    - 使用 order.id 的 UUID 作為文檔 ID，確保用戶子集合和全局 orders 集合中的 ID 相同。
 
 * 優點：
    - 保證訂單在兩個集合中的一致性，便於查找和管理。
    - 使用 UUID 使得每個訂單的 ID 更具有唯一性和可追溯性，避免重複。
    - 可以在應用中控制訂單 ID 的生成和使用，增加靈活性。
 
 * 缺點：
    - 需要手動管理 UUID 作為文檔 ID，但這增加了控制和一致性。
 
 -------------------------------------------------------------------------------------------------------------

 &. 總結

    * 方法一 適合簡單使用、不需要同步操作的場景，因為它自動生成不同的 ID，實現起來非常方便。

    * 方法二 使用 Firestore 生成的相同文檔 ID，適合需要同步管理訂單、查找訂單的應用情況，具有良好的一致性。

    * 方法三 使用 order.id.uuidString 作為 ID，更具控制性和一致性，非常適合需要在應用中自己管理訂單 ID 的情況，便於對訂單進行聯合查找和追蹤。

    最終採用「方法三」更高的一致性和管理控制。它能確保在「用戶子集合」和「全局 orders 集合」中保持相同的文檔 ID，便於訂單查找和管理。
 */


// MARK: - 關於 OrderManager 中的 submitOrder 是否還需要進行顧客資料驗證：

/*
 
 - 原本「測試」階段的時候我是採用透過 CustomerDetailsManager 的 validateCustomerDetails 「驗證顧客資料是否已填寫必填項目，例如姓名、電話，以及若選擇 “宅配運送” 時需要填寫地址。」
 - 後來我改成用了按鈕啟用/禁用的方式來確保只有當顧客資料完整時，提交按鈕才會啟用。
 - 那麼在 OrderManager 中重複進行顧客資料驗證可能顯得冗餘。
 
 * 但是保留驗證也有其好處：

    1. 雙重驗證： 保留驗證可以在提交層次再多一層保護，以防按鈕狀態不小心錯誤地啟用或其他不可預期的狀況。這樣做能確保在任意情況下，提交的資料一定是完整的。
    2. 如果確信按鈕的邏輯足夠可靠，可以選擇移除 OrderManager 中的驗證，但這樣做會減少系統的防護層次。
 
 */

// MARK: - 提交整個訂單應該由 OrderManager 處理，因為這涉及將顧客資料 (CustomerDetails) 和訂單項目 (OrderItem) 整合到一個訂單 (Order) 結構中，並完成提交過程。
/*
import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

/// OrderManager 負責管理和提交訂單，包括`顧客資料`和`訂單項目`的整合。
class OrderManager {
    
    static let shared = OrderManager()
    
    // MARK: - Submit Order
    
    /// 提交訂單
    func submitOrder() async throws {
        guard let user = Auth.auth().currentUser else {
            throw OrderManagerError.orderRequestFailed
        }
        
        /// 獲取顧客資料
        guard let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() else {
            throw OrderManagerError.missingCustomerDetails
        }
        
        /// 驗證顧客資料（保留）
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        switch validationResult {
        case .failure(let error):
            throw error // 在這裡直接拋出驗證錯誤以阻止訂單提交
        case .success:
            break
        }
        
        /// 獲取訂單項目
        let orderItems = OrderItemManager.shared.orderItems
        if orderItems.isEmpty {
            throw OrderManagerError.noOrderItems
        }
        
        /// 計算總金額
        var totalAmount = orderItems.reduce(0) { $0 + $1.totalAmount }
        if customerDetails.pickupMethod == .homeDelivery {
            totalAmount += 60             // 外送服務費用
        }
        
        /// 建立訂單
        let order = Order(id: UUID(),
                          customerDetails: customerDetails,
                          orderItems: orderItems,
                          timestamp: Date(),
                          totalAmount: totalAmount)
        
        /// 提交訂單至 Firestore
        do {
            try await saveOrderData(order: order, for: user.uid)
            print("訂單提交成功")
            scheduleNotification(prepTime: calculateTotalPrepTime(orderItems: orderItems) * 60) // 轉換為秒
        } catch {
            throw OrderManagerError.firebaseError(error)
        }
        
    }
    
    // MARK: - Private Helper Methods

    /// 儲存訂單資料至 Firestore
    /// - Parameters:
    ///   - order: 訂單結構
    ///   - userID: 當前使用者
    private func saveOrderData(order: Order, for userID: String) async throws {
        
        let db = Firestore.firestore()
        /// 使用 order.id.uuidString 作為文檔 ID（ 將 UUID 轉為 String）
        let orderID = order.id.uuidString
        let orderDict = createOrderDict(from: order)
        
        /// 在`用戶子集合`中添加訂單，使用相同的文檔 ID
        try await db.collection("users").document(userID).collection("orders").document(orderID).setData(orderDict)
        
        /// 在`全局 orders 集合`中添加訂單，使用相同的文檔 ID
        try await db.collection("orders").document(orderID).setData(orderDict)
    }
    
    /// 將 Order 結構轉換為字典（考量到後續會設置一個呈現`訂單資料的明細`視圖控制器，來做調整。）
    /// - Parameter order: 訂單結構
    /// - Returns: 用於 Firestore 的字典
    private func createOrderDict(from order: Order) -> [String: Any] {
        return [
            "id": order.id.uuidString,  // （ 將 UUID 轉為 String）
            "customerDetails": [
                "fullName": order.customerDetails.fullName,
                "phoneNumber": order.customerDetails.phoneNumber,
                "pickupMethod": order.customerDetails.pickupMethod.rawValue,
                "address": order.customerDetails.address ?? "",
                "storeName": order.customerDetails.storeName ?? "",
                "notes": order.customerDetails.notes ?? ""
            ],
            "orderItems": order.orderItems.map { item in
                return [
                    "id": item.id.uuidString,
                    "drink": [
                        "name": item.drink.name,
                        "subName": item.drink.subName,
//                        "description": item.drink.description,
                        "imageUrl": item.drink.imageUrl.absoluteString,
//                        "prepTime": item.drink.prepTime
                    ],
                    "size": item.size,
                    "quantity": item.quantity,
//                    "prepTime": item.prepTime,        // 已經有 totalPrepTime，移除每個訂單項目中的 prepTime，因為可以根據 orderItems 自行計算出來。
//                    "totalAmount": item.totalAmount,  // 每個 orderItem 中有 totalAmount，這是計算該飲品的總價。（能從 price 和 quantity 動態計算出來，故移除）
                    "price": item.price,
//                    "categoryId": item.categoryId ?? "",
//                    "subcategoryId": item.subcategoryId ?? ""
                ]
            },
            "timestamp": order.timestamp,
            "totalAmount": order.totalAmount,
            "totalPrepTime": order.totalPrepTime
        ]
    }
    
    /// 計算訂單的總準備時間
    /// - Parameter orderItems: 訂單中的項目
    /// - Returns: 總準備時間（分鐘）
    private func calculateTotalPrepTime(orderItems: [OrderItem]) -> Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
    // MARK: - Local Notification

    /// 安排本地通知提醒用户訂單已經準備好
    /// - Parameter prepTime: 訂單準備時間（秒）
    private func scheduleNotification(prepTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Ready"
        content.body = "Your order is ready for pickup!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}

// MARK: - Error

/// 處理 Order 訂單錯誤相關訊息
enum OrderManagerError: Error, LocalizedError {
    case orderRequestFailed
    case missingCustomerDetails
    case noOrderItems
    case unknownError
    case firebaseError(Error)
    
    static func form(_ error: Error) -> OrderManagerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .orderRequestFailed:
            return NSLocalizedString("Order request failed.", comment: "Order request failed.")
        case .missingCustomerDetails:
            return NSLocalizedString("Customer details are missing.", comment: "Customer details are missing.")
        case .noOrderItems:
            return NSLocalizedString("No items in the order.", comment: "No items in the order.")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
*/

// MARK: - 提交整個訂單應該由 OrderManager 處理，因為這涉及將顧客資料 (CustomerDetails) 和訂單項目 (OrderItem) 整合到一個訂單 (Order) 結構中，並完成提交過程。（重構 submit）

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

/// OrderManager 負責管理和提交訂單，包括`顧客資料`和`訂單項目`的整合。
class OrderManager {
    
    static let shared = OrderManager()
    
    // MARK: - Submit Order
    
    /// 提交訂單
    func submitOrder() async throws {
        guard let user = Auth.auth().currentUser else {
            throw OrderManagerError.orderRequestFailed
        }
        
        // 1. 驗證顧客資料
        let customerDetails = try await validateCustomerDetails()
        // 2. 驗證訂單項目
        let orderItems = try validateOrderItems()
        // 3. 計算總金額
        let totalAmount = calculateTotalAmount(orderItems: orderItems, pickupMethod: customerDetails.pickupMethod)
        // 4. 創建訂單物件
        let order = createOrder(customerDetails: customerDetails, orderItems: orderItems, totalAmount: totalAmount)
        // 5. 提交訂單至 Firestore
        try await submitOrderToFirestore(order: order, userID: user.uid)
        // 6. 安排本地通知
        scheduleOrderReadyNotification(prepTime: calculateTotalPrepTime(orderItems: orderItems) * 60)
    }
    
    // MARK: - Helper Methods

    /// 獲取顧客資料，並驗證顧客資料
    private func validateCustomerDetails() async throws -> CustomerDetails {
        guard let customerDetails = CustomerDetailsManager.shared.getCustomerDetails() else {
            throw OrderManagerError.missingCustomerDetails
        }
        
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        switch validationResult {
        case .failure(let error):
            throw error
        case .success:
            return customerDetails
        }
    }
    
    /// 獲取訂單項目，並驗證訂單項目
    private func validateOrderItems() throws -> [OrderItem] {
        let orderItems = OrderItemManager.shared.orderItems
        if orderItems.isEmpty {
            throw OrderManagerError.noOrderItems
        }
        return orderItems
    }
    
    /// 計算訂單的總金額
    private func calculateTotalAmount(orderItems: [OrderItem], pickupMethod: PickupMethod) -> Int {
        var totalAmount = orderItems.reduce(0) { $0 + $1.totalAmount }
        if pickupMethod == .homeDelivery {
            totalAmount += 60 // 外送服務費用
        }
        return totalAmount
    }

    /// 創建訂單
    private func createOrder(customerDetails: CustomerDetails, orderItems: [OrderItem], totalAmount: Int) -> Order {
        return Order(id: UUID(),
                     customerDetails: customerDetails,
                     orderItems: orderItems,
                     timestamp: Date(),
                     totalAmount: totalAmount
        )
    }

    /// 提交訂單至 Firestore
    private func submitOrderToFirestore(order: Order, userID: String) async throws {
        do {
            try await saveOrderData(order: order, for: userID)
            print("訂單提交成功")
        } catch {
            throw OrderManagerError.firebaseError(error)
        }
    }
    
    // MARK: - Private Helper Methods

    /// 儲存訂單資料至 Firestore
    /// - Parameters:
    ///   - order: 訂單結構
    ///   - userID: 當前使用者
    private func saveOrderData(order: Order, for userID: String) async throws {
        
        let db = Firestore.firestore()
        /// 使用 order.id.uuidString 作為文檔 ID（ 將 UUID 轉為 String）
        let orderID = order.id.uuidString
        let orderDict = createOrderDict(from: order)
        
        /// 在`用戶子集合`中添加訂單，使用相同的文檔 ID
        try await db.collection("users").document(userID).collection("orders").document(orderID).setData(orderDict)
        
        /// 在`全局 orders 集合`中添加訂單，使用相同的文檔 ID
        try await db.collection("orders").document(orderID).setData(orderDict)
    }
    
    /// 將 Order 結構轉換為字典（考量到後續會設置一個呈現`訂單資料的明細`視圖控制器，來做調整。）
    /// - Parameter order: 訂單結構
    /// - Returns: 用於 Firestore 的字典
    private func createOrderDict(from order: Order) -> [String: Any] {
        return [
            "id": order.id.uuidString,  // （ 將 UUID 轉為 String）
            "customerDetails": [
                "fullName": order.customerDetails.fullName,
                "phoneNumber": order.customerDetails.phoneNumber,
                "pickupMethod": order.customerDetails.pickupMethod.rawValue,
                "address": order.customerDetails.address ?? "",
                "storeName": order.customerDetails.storeName ?? "",
                "notes": order.customerDetails.notes ?? ""
            ],
            "orderItems": order.orderItems.map { item in
                return [
                    "id": item.id.uuidString,
                    "drink": [
                        "name": item.drink.name,
                        "subName": item.drink.subName,
                        "imageUrl": item.drink.imageUrl.absoluteString,
                    ],
                    "size": item.size,
                    "quantity": item.quantity,
                    "price": item.price,
                ]
            },
            "timestamp": order.timestamp,
            "totalAmount": order.totalAmount,
            "totalPrepTime": order.totalPrepTime
        ]
    }
    
    /// 計算訂單的總準備時間
    /// - Parameter orderItems: 訂單中的項目
    /// - Returns: 總準備時間（分鐘）
    private func calculateTotalPrepTime(orderItems: [OrderItem]) -> Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
    // MARK: - Local Notification

    /// 安排本地通知提醒用户訂單已經準備好
    /// - Parameter prepTime: 訂單準備時間（秒）
    private func scheduleOrderReadyNotification(prepTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Ready"
        content.body = "Your order is ready for pickup!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

// MARK: - Error

/// 處理 Order 訂單錯誤相關訊息
enum OrderManagerError: Error, LocalizedError {
    case orderRequestFailed
    case missingCustomerDetails
    case noOrderItems
    case unknownError
    case firebaseError(Error)
    
    static func form(_ error: Error) -> OrderManagerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .orderRequestFailed:
            return NSLocalizedString("Order request failed.", comment: "Order request failed.")
        case .missingCustomerDetails:
            return NSLocalizedString("Customer details are missing.", comment: "Customer details are missing.")
        case .noOrderItems:
            return NSLocalizedString("No items in the order.", comment: "No items in the order.")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}




// MARK: - 新版（將所有訂單操作（添加、更新、移除等）集中在 OrderController 中管理）UUID & async/await
/*
import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

/// OrderController 負責管理當前的訂單列表（如增加、更新、刪除），管理當前的狀態。
class OrderController {
    
    static let shared = OrderController()
    
    // MARK: - Properties

    /// 當前訂單項目列表
    var orderItems: [OrderItem] = [] {
        didSet {
            print("訂單項目更新，當前訂單數量: \(orderItems.count)")
            NotificationCenter.default.post(name: .orderUpdatedNotification, object: nil)   // 當訂單變更時發送通知
        }
    }
    
    // MARK: - Order Management Methods
    
    /// 新增訂單項目
    /// - Parameters:
    ///   - drink: 選擇的飲品
    ///   - size: 飲品的尺寸
    ///   - quantity: 數量
    ///   - categoryId: 飲品所屬的類別 ID
    ///   - subcategoryId: 飲品所屬的子類別 ID
    func addOrderItem(drink: Drink, size: String, quantity: Int, categoryId: String?, subcategoryId: String?) {
        
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        print("為使用者 \(user.uid) 添加訂單項目")

        let prepTime = drink.prepTime   // 使用飲品的準備時間（分鐘）
        let timestamp = Date()      // 當前時間
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        let orderItem = OrderItem(drink: drink, size: size, quantity: quantity, prepTime: prepTime, totalAmount: totalAmount, price: price, categoryId: categoryId, subcategoryId: subcategoryId)
        
        orderItems.append(orderItem)
        print("添加訂單項目 ID: \(orderItem.id)")
    }
    
    /// 更新訂單中的訂單項目的尺寸&數量
    /// - Parameters:
    ///   - id: 訂單項目 ID
    ///   - size: 新的尺寸
    ///   - quantity: 新的數量
    func updateOrderItem(withID id: UUID, with size: String, and quantity: Int) {
        guard let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let drink = orderItems[index].drink
        let price = drink.sizes[size]?.price ?? 0
        let totalAmount = price * quantity
        
        orderItems[index].size = size
        orderItems[index].quantity = quantity
        orderItems[index].price = price
        orderItems[index].totalAmount = totalAmount
    }
    
    /// 清空訂單
    func clearOrder() {
        orderItems.removeAll()
    }
    
    /// 刪除特定訂單項目
    /// - Parameter id: 訂單項目 ID
    func removeOrderItem(withID id: UUID) {
        orderItems.removeAll { $0.id == id }
    }
    
    // MARK: - Submit Order

    /// 提交訂單
    /// - Parameter menuIDs: 訂單中飲品的菜單 ID 清單
    /// - Throws: 若提交失敗，則拋出錯誤
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws {
        guard let user = Auth.auth().currentUser else {
            throw OrderControllerError.orderRequestFailed
        }
        
        let orderData = buildOrderData(for: user.uid)
        
        do {
            try await saveOrderData(orderData: orderData, for: user.uid)
            // 安排通知
            scheduleNotification(prepTime: calculateTotalPrepTime() * 60) // 轉換為秒
        } catch {
            throw OrderControllerError.form(error)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// 構建訂單資料
    /// - Parameter userId: 當前的使用者
    /// - Returns: 包含訂單資訊的字典
    private func buildOrderData(for userId: String) -> [String: Any] {
        return [
            "uid": userId,
            "orderItems": orderItems.map { item in
                return [
                    "drink": [
                        "name": item.drink.name,
                        "subName": item.drink.subName,
                        "description": item.drink.description,
                        "imageUrl": item.drink.imageUrl.absoluteString,
                        "prepTime": item.drink.prepTime
                    ],
                    "size": item.size,
                    "quantity": item.quantity,
                    "prepTime": item.prepTime,
                    "totalAmount": item.totalAmount
                ]
            },
            "timestamp": Timestamp(date: Date())
        ]
    }
    
    /// 儲存訂單資料至 Firestore
    /// - Parameters:
    ///   - orderData: 訂單資料
    ///   - userID: 當前使用者
    private func saveOrderData(orderData: [String: Any], for userID: String) async throws {
        let db = Firestore.firestore()

        /// 在`用戶子集合`中添加訂單
        try await db.collection("users").document(userID).collection("orders").addDocument(data: orderData)

        /// 在`全局 orders 集合`中添加訂單
        try await db.collection("orders").addDocument(data: orderData)
    }
    
    // MARK: - Public Helper Methods

    /// 計算所有飲品的準備時間
    /// - Returns: 總準備時間（分鐘）
    func calculateTotalPrepTime() -> Int {
        return orderItems.reduce(0) { $0 + ($1.prepTime * $1.quantity) }
    }
    
    /// 計算訂單的總金額
    /// - Returns: 總金額
    func calculateTotalAmount() -> Int {
        return orderItems.reduce(0) { $0 + $1.totalAmount }
    }
    
    // MARK: - Local Notification

    /// 安排本地通知提醒用户訂單已經準備好
    /// - Parameter prepTime: 訂單準備時間（秒）
    private func scheduleNotification(prepTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Ready"
        content.body = "Your order is ready for pickup!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

// MARK: - Error

/// 處理Order訂單錯誤相關訊息
enum OrderControllerError: Error, LocalizedError {
    case orderRequestFailed
    case unknownError
    case firebaseError(Error)
    
    static func form(_ error: Error) -> OrderControllerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .orderRequestFailed:
            return NSLocalizedString("Order request failed.", comment: "Order request failed.")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
*/


// MARK: - 調整OrderItemManager

/*
import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications


class OrderManager {
    
    static let shared = OrderManager()
    
    // MARK: - Submit Order

    /*
    /// 提交訂單（需要調整？）
    /// - Parameter menuIDs: 訂單中飲品的菜單 ID 清單
    /// - Throws: 若提交失敗，則拋出錯誤
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws {
        guard let user = Auth.auth().currentUser else {
            throw OrderManagerError.orderRequestFailed
        }
        
        let orderData = buildOrderData(for: user.uid)
        
        do {
            try await saveOrderData(orderData: orderData, for: user.uid)
            // 安排通知
            scheduleNotification(prepTime: calculateTotalPrepTime() * 60) // 轉換為秒
        } catch {
            throw OrderManagerError.form(error)
        }
    }
     */
    
    // MARK: - Private Helper Methods
    
    /*
    /// 構建訂單資料（需要調整？）
    /// - Parameter userId: 當前的使用者
    /// - Returns: 包含訂單資訊的字典
    private func buildOrderData(for userId: String) -> [String: Any] {
        return [
            "uid": userId,
            "orderItems": orderItems.map { item in
                return [
                    "drink": [
                        "name": item.drink.name,
                        "subName": item.drink.subName,
                        "description": item.drink.description,
                        "imageUrl": item.drink.imageUrl.absoluteString,
                        "prepTime": item.drink.prepTime
                    ],
                    "size": item.size,
                    "quantity": item.quantity,
                    "prepTime": item.prepTime,
                    "totalAmount": item.totalAmount
                ]
            },
            "timestamp": Timestamp(date: Date())
        ]
    }
     */
    
    /// 儲存訂單資料至 Firestore（需要調整？）
    /// - Parameters:
    ///   - orderData: 訂單資料
    ///   - userID: 當前使用者
    private func saveOrderData(orderData: [String: Any], for userID: String) async throws {
        let db = Firestore.firestore()

        /// 在`用戶子集合`中添加訂單
        try await db.collection("users").document(userID).collection("orders").addDocument(data: orderData)

        /// 在`全局 orders 集合`中添加訂單
        try await db.collection("orders").addDocument(data: orderData)
    }
    
    // MARK: - Local Notification

    /// 安排本地通知提醒用户訂單已經準備好（需要調整？）
    /// - Parameter prepTime: 訂單準備時間（秒）
    private func scheduleNotification(prepTime: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Order Ready"
        content.body = "Your order is ready for pickup!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prepTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

// MARK: - Error

/// 處理Order訂單錯誤相關訊息
enum OrderManagerError: Error, LocalizedError {
    case orderRequestFailed
    case unknownError
    case firebaseError(Error)
    
    static func form(_ error: Error) -> OrderManagerError {
        return .firebaseError(error)
    }
    
    var errorDescription: String? {
        switch self {
        case .orderRequestFailed:
            return NSLocalizedString("Order request failed.", comment: "Order request failed.")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "An unknown error occurred.")
        case .firebaseError(let error):
            return error.localizedDescription
        }
    }
}
*/
