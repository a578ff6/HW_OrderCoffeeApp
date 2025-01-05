//
//  CustomerDetailsManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/9.
//

/*
 
 ## CustomerDetailsManager 的設計思路：

    - CustomerDetailsManager 負責處理與顧客詳細資料 (CustomerDetails) 相關的業務邏輯，包含初始填充、驗證、更新及重置等操作。

 * 用途
    - CustomerDetailsManager 的主要職責是管理和提供顧客詳細資料 (CustomerDetails)，以便在生成訂單時能夠獲得準確且完整的顧客資訊。
    - 它還可以提供一些檢查方法，比如判斷 UserDetails 是否有足夠的資料可以使用。

 * 功能

    1. 欄位排他性處理：
        - CustomerDetailsManager 確保欄位之間的排他性，避免同時存在不符合邏輯的資料。例如，storeName 和 address 兩者不應同時存在，這樣可以避免取件方式的混淆。

    2. 從 UserDetails 填充資料：
        - 當第一次進入 OrderCustomerDetailsViewController 時，根據 UserDetails 填充初始資料，方便用戶後續進行訂單操作。
        - 只有在 customerDetails 為 nil 時才會從 UserDetails 中填充初始資料，這樣可以保留用戶修改後的資料，防止返回上一個視圖後再進入時資料被覆蓋。

    3. 資料重置：
        - 在用戶登出後，customerDetails 會被重置，以確保不會有殘留資料影響新用戶。
        - 當 orderItems 被清空時，也會自動重置 customerDetails，確保新的訂單流程從零開始。
 
    4. 資料驗證：
        - 提供 validateCustomerDetails() 方法來確保顧客資料的完整性，並在提交訂單前進行檢查，確保所有必要資訊已填寫。
 
 &. 與 FirebaseController 的關係：
    
    - FirebaseController 的 getCurrentUserDetails() 可以幫助 CustomerDetailsManager 獲取最新的 UserDetails 資料，這對於初始填入資料或同步資料是非常有幫助的。
    - 當加載 OrderCustomerDetailsViewController 時，使用 FirebaseController 通過 CustomerDetailsManager 獲取當前用戶資料並填入到 CustomerDetails 中，以提供準確的初始資料。
 
 &. 如何在 OrderCustomerDetailsViewController 中使用 CustomerDetailsManager：

    1. 初始填充資料：
        - 當 OrderCustomerDetailsViewController 第一次加載時，會透過 CustomerDetailsManager 從 UserDetails 中填充顧客資料。

    2. 保持資料一致：
        - 在 OrderCustomerDetailsViewController 完成資料填寫或修改後，將這些資料更新回 CustomerDetailsManager，以便後續提交訂單時能使用用戶最新的資料。
 
 &. 最後想法：

    - CustomerDetailsManager 應該主要負責管理和提供 CustomerDetails，而 OrderCustomerDetailsViewController 則專注於顯示和收集用戶的資料。
    - OrderCustomerDetailsViewController 則專注於顯示和收集資料，並通過 CustomerDetailsManager 來操作顧客詳細資料。
    - FirebaseController 的 getCurrentUserDetails() 方法對於初始資料獲取非常有幫助，在 OrderCustomerDetailsViewController 加載時通過 CustomerDetailsManager 使用它來填入初始的顧客資料。
    - 此外，在登出或清空訂單的情況下，透過重置 customerDetails 可以避免不必要的資料殘留，提供更好的用戶體驗和資料安全性。
 */


// MARK: - 設置 updatePickupMethod 的原因

/*
 
 ## updatePickupMethod 的設置，是為了確保顧客資料的變更都能及時同步至中央資料管理器 (CustomerDetailsManager)，並且方便集中管理顧客資料變更的邏輯。以下是設置的具體原因：

 1. 資料一致性

    - CustomerDetailsManager 作為顧客資料的中心管理器，負責維護顧客的所有資料，包括姓名、電話、取件方式、地址、備註等。
    - 當用戶在界面上更改取件方式（例如從「到店自取」改為「外送服務」），更新 CustomerDetailsManager 中的資料確保變更被正確反映，避免之後需要使用這些資料時（如提交訂單）資料不一致的問題。
 
 2. 維護和擴展的便利性

    - 使用 CustomerDetailsManager 的 updatePickupMethod 可以確保所有取件方式的變更都經過同一個地方進行。
    - 這樣如果未來需要對取件方式的變更進行額外的處理（例如驗證或額外的邏輯），可以在一個地方集中管理，減少重複程式碼並提高擴展性。
    - 例如，可能在未來需要在取件方式變更時觸發其他的操作，比如清空或重置某些資料，在 CustomerDetailsManager 中集中管理這些邏輯可以使得代碼更加可控。
 
 3. 跨界面傳遞資料

    - 如果用戶在 OrderPickupMethodCell 中更改取件方式，但卻不更新到 CustomerDetailsManager，那麼當其他的 view 或 controller 需要獲取顧客資料時，它們會得到舊的資料，而不是最新的資料。
    - 例如，OrderSubmit 時，需要根據 pickupMethod 來計算訂單金額（外送服務需加 $60），如果取件方式未更新到 CustomerDetailsManager，提交時可能會使用錯誤的金額。
 
 4. 總結
 
    - 在 CustomerDetailsManager 中設置 updatePickupMethod 是為了保持資料的一致性和便於管理。
    - 如果不設置這個方法，資料管理會變得更加分散且難以維護，增加了出錯的機會。
    - 通過統一的管理器來處理顧客資料，可以確保在整個 App 中，所有相關的資料更新都保持同步，提升代碼的整潔性和擴展性。
 
 */
 

// MARK: - 設計考量：外送服務費用的計算位置

/*
 
 ## 目前在設計上，有兩個主要方案來設置外送服務費用，分別是放在 OrderManager 的 submitOrder() 中，或放在 CustomerDetailsManager 的 updatePickupMethod() 中。以下是比較與重點建議。
 
 1. 在 OrderManager 的 submitOrder() 中設置外送服務費用（採用的）
 
    * 優點：

        - 集中管理： 所有與訂單計算、提交相關的邏輯都集中在 OrderManager，便於追蹤和維護。
        - 一致性： 外送費用只在訂單提交時進行計算，確保最終提交時的金額是最新且正確的。
    
    * 缺點：

        - 擴展性： 無法在 UI 上即時看到訂單金額（包括外送費），使用者在訂單提交前無法知道總費用。
        - 邏輯重複： 如果在其他地方需要重新計算訂單費用，這段邏輯可能需要多次重複。

 2. 在 CustomerDetailsManager 的 updatePickupMethod() 中設置外送服務費用
 
    * 優點：

        - 動態更新： 使用者在選擇外送服務時，外送費用可以即時反映在 UI 上，提升使用者體驗。
        - 責任分離： 顧客選擇取件方式的邏輯和對應的費用可以在一處集中處理。

    * 缺點：

        - 責任邊界模糊： 外送費用的計算本應該屬於訂單管理的一部分，但將其放在 CustomerDetailsManager 中可能導致職責模糊。
        - 多處更新風險： 如果之後外送費用的邏輯有所變更，可能需要更新多個地方，導致維護上的困難。
 
 3. 目前設計重點
 
    - 外送費用的計算是在 OrderManager 的 submitOrder() 中完成的，這意味著外送費用僅在訂單最終提交到 Firestore 時才會被加入。
    - UI 中不會即時反映外送費用，而是在按下提交按鈕後才會顯示。（因為在 OrderPickupMethodCell 當選擇 「外送服務」 會有 收費Label）
    - 不需要調整 CustomerDetailsManager 的 updatePickupMethod() 來處理外送費用，這樣可以保持資料結構簡單且減少不必要的複雜性。
 
 4. 比較與想法
 
    - 目前方式適合運費變化不大且需求較為簡單的情況，只在提交訂單時計算外送費用，減少了即時更新 UI 的負擔，便於維護。
    - 如果在 updatePickupMethod() 中設置運費，則可以即時顯示訂單的總金額變化，提高使用者的透明度，但也會帶來更多的開發與維護成本。
 
 5. 建議：
 
    - 如果不需要在 UI 中即時顯示外送費用，則保持目前的設計是簡潔且有效的。
    - 在訂單提交時計算費用不僅能簡化邏輯，也能減少維護工作量，因此不建議額外在 CustomerDetailsManager 中處理外送費用。
 */


// MARK: - CustomerDetailsManager 的設計以及在 OrderPickupMethodCell 中處理取件方式相關邏輯時的混亂，重構筆記。（重要）

/*
 ## 問題主要涉及到兩個方面：
    
        * CustomerDetailsManager 的設計以及在 OrderPickupMethodCell 中處理取件方式相關邏輯時的混亂。

 &. OrderPickupMethodCell 的混亂源於 CustomerDetailsManager 的設計不當。
 
    - 部分原因在於 CustomerDetailsManager 最初設計時沒有完善，導致在 OrderPickupMethodCell 中需要處理太多和顧客資料相關的邏輯。這裡有幾個具體的問題：
 
 1. 缺乏集中化管理顧客資料的責任：
    
    - CustomerDetailsManager 應該是唯一管理顧客資料變更的地方，這樣能保證資料在應用中各處都是一致的。
    - 但在原本實作中，很多顧客資料的更新直接在視圖中進行，這增加了視圖層的複雜性，特別是在 OrderPickupMethodCell 中，需要同時考慮更新顧客資料和處理 UI 的同步。

 2. 取件方式的切換與欄位同步：
 
    - 在切換取件方式時，如從「外送」變更為「到店取件」，原始邏輯中沒有很好地管理與同步 UI 和資料的狀態。
    - 這導致視圖層（OrderPickupMethodCell）需要額外的手動呼叫 storeTextFieldChanged() 以確保資料的同步，而這樣的設計是不太理想的。
    - 在更好的設計中，應該透過 CustomerDetailsManager 來集中管理取件方式的變更，以及相關資料欄位的清空和同步，而非在視圖層處理。

 3. 資料的更新通知不一致：
 
    - 在原始的設計中，有些欄位的變更通知是在 OrderPickupMethodCell 中手動執行（例如呼叫 storeTextFieldChanged()）。
    - 這樣會導致邏輯錯亂或是通知重複的問題。如果所有資料更新的邏輯都集中在 CustomerDetailsManager 中處理，視圖只負責顯示，這樣會更清晰且更容易管理。

 
 &. 問題主要集中在取件方式相關的邏輯，而與姓名、電話、備註無關？
 
    - 主要的問題集中在「取件方式」相關的邏輯，尤其是在切換取件方式時如何同步和清空不相關的欄位，而這些問題和姓名、電話、備註等欄位無直接關聯。
 
 1. 取件方式的邏輯：
  
    - 欄位的排他性：問題的真正核心在於「欄位之間的排他性」，而非取件方式的切換。具體來說，「storeName 和 address 兩者不應同時存在」，這樣的條件應由集中管理器處理。

 2. 姓名、電話、備註等欄位：
  
    - 這些欄位與取件方式的選擇無直接依賴關係。因此，在切換取件方式時，不需要對這些欄位進行任何額外的操作。
    - CustomerDetailsManager 可以集中處理這些欄位的更新，且這些欄位通常在初始化時填充，變更的頻率也相對較低。

 &. 改善的關鍵點

 1. 將資料更新集中到 CustomerDetailsManager：
   
    - 所有涉及顧客資料的更新（如姓名、電話、取件方式、地址、店家名稱等），都應該由 `CustomerDetailsManager` 來負責，這樣能保持邏輯清晰、易於維護，並減少視圖層的責任。

 2. 視圖層只負責顯示和事件通知：
    
    - OrderPickupMethodCell 應該只負責顯示 UI，並在用戶操作時通知資料的變更。例如當用戶點擊「選擇店家」按鈕時，OrderPickupMethodCell 只需通知控制器或管理器，而不應直接處理顧客資料的變更。
    - 這樣可以減少像手動呼叫 storeTextFieldChanged() 這種臨時修補的邏輯，改由更集中且一致的管理器處理資料變更。

 3. 取件方式變更的集中管理：
    
    - updatePickupMethod(_:) 應該在變更取件方式，並且其欄位有值的同時，檢查並清空不再適用的欄位。
    - 例如，當**storeName 被設定時**，應自動清空 address，反之亦然。這樣做的目的在於保證在每次資料更新時，欄位之間的邏輯不會發生衝突，例如取件店家與外送地址的資料不應同時存在。
    - 這些邏輯應該放在 `CustomerDetailsManager` 中，而不是分散在不同的視圖或回調中。
 
 4. 總結來說，在 OrderPickupMethodCell 的混亂是因為原本的設計中，資料變更的邏輯分散於多個層面，且視圖層過多負責資料的處理。
    而應該將顧客資料的所有更新責任集中在 `CustomerDetailsManager`，而視圖層專注於顯示和觸發用戶事件的回調，這樣能夠讓整個架構更具組織性，邏輯也更清晰。
 */


// MARK: - 重點筆記：取件方式與欄位清空邏輯（重要）

/*
 
 1. 最初的邏輯問題：過度依賴取件方式的切換
 
    * 原本的邏輯：
        - 當取件方式從「外送服務」切換到「到店取件」時，會根據「自身欄位是否有值」來清空另一個不相關的欄位。
        - 例如，若在「到店取件」模式下 storeName 欄位有值，才會清空「外送地址」的值。
        - 這種設計將問題的重點放在切換取件方式上，並且依賴當前模式欄位的有無值，使邏輯變得複雜且不直觀。
 
 2. 調整後的正確邏輯：聚焦於地址和店家名稱欄位本身

    * 新的重點：
        - 真正的關鍵在於「欄位之間的排他性」，而非取件方式的切換。
        - 具體來說，「取件方式」與清空欄位的邏輯無關，重點應該是「storeName 和 address 兩者不應同時存在」。
        - 因此，當**storeName 被設定時**，應自動清空 address；反之亦然。
 
 3. 新邏輯的實施：

    * 地址 (address) 被設定時：
        - 若填寫了「外送地址」，則應清空店家名稱 (storeName)，因為已經選擇了「外送服務」，不需要指定取件店家。
 
    * 店家名稱 (storeName) 被設定時：
        - 若選擇了「取件店家」，則應清空地址 (address)，因為已經選擇了「到店取件」，不需要提供外送地址。
 
    * 如此一來，邏輯簡化為只要一個欄位有值，就清空另一個欄位，使得整體邏輯更直觀、易於維護，也避免了不必要的複雜性。
 
 4. 改進後的優勢：

    * 簡化程式碼：不再需要在取件方式切換時進行複雜的條件判斷。
    * 提高一致性：只要「店家名稱」和「外送地址」是互斥的，就能確保資料狀態的一致性，減少錯誤的可能性。
    * 清晰明瞭：使用者的操作行為（如填寫地址或選擇店家）能直接驅動欄位清空邏輯，而不依賴取件方式的切換，提升了系統的直觀性。
 */


// MARK: - 更新 updatePickupMethod 取件方式的簡化原因（重要）

/*

 * 在原始設計中，updatePickupMethod 方法涉及清空不相關的欄位，但根據業務需求的變更，現在只需要更新取件方式，而不再處理互斥欄位的清空操作。因此這個方法得以大幅簡化，「只保留與取件方式更新」相關的邏輯。

 以下是 updatePickupMethod 方法的重點與簡化原因：

 1. 僅更新取件方式
    - 方法只負責更新 customerDetails 中的取件方式，不涉及其他欄位的變更。
    - 這樣的簡化使得方法的職責更加單一，符合**單一職責原則**（SRP），有助於可讀性與維護性。

 2. 移除清空欄位的邏輯
    - 原始方法在切換取件方式時會根據條件清空對應的地址或店家名稱，這種處理邏輯與取件方式更新耦合，導致方法過於複雜且難以維護。
    - 現在去除了這些額外的操作，避免了邏輯上的耦合，讓方法專注於更新取件方式。

 3. 集中邏輯於需要變更的部分
    - 更新後的邏輯簡化為只在 `customerDetails` 中修改取件方式並重新賦值，這樣的處理避免了多餘的操作，降低了錯誤的風險。

 4. 提高程式碼可測試性與可擴展性
    - 簡化之後，updatePickupMethod 方法變得更容易進行單元測試，因為它只處理一個變更，測試的覆蓋範圍更集中。
    - 如果未來需要新增其他取件方式或變更邏輯，也可以在不影響其他欄位的情況下輕鬆擴展。
*/


// MARK: - populateCustomerDetails 有條件地更新資料 （重要）

/*
 ## populateCustomerDetails 有條件地更新資料
 
 &. 問題背景
 
    - populateCustomerDetails(from:) 被用來初始化顧客詳細資料 (customerDetails)，主要目的是使用 Firebase 中的 userDetails 填充訂單表單中的各個欄位。
    - 這樣做有助於在用戶首次填寫表單時提供一些預設值，減少手動輸入的負擔。
    - 然而，在用戶進行表單填寫後，當他們離開視圖並重新返回時，原來的行為是每次都會透過 fetchAndPopulateUserDetails 從 userDetails 再次填充，這樣導致了用戶在第一次修改後的內容被覆蓋，無法保存最新的修改結果。
 
 &. 「有條件地更新資料」的邏輯
 
    - 只有在 customerDetails 為 nil 時 才進行填充，否則保持用戶已修改過的內容。
    - customerDetails 初次進入該視圖時會是 nil，因此會使用 userDetails 的值來填充初始資料。
    - 當用戶進行修改並離開視圖，再返回視圖時，customerDetails 已經有了用戶修改過的值，因此不會被覆蓋，而是保留用戶的更改。

 &. 為什麼這樣的方案有效？

    1. 初次填充，簡化用戶操作：
 
        - 當顧客第一次進入 OrderCustomerDetailsViewController 時，customerDetails 尚未被初始化 (nil)。因此需要從 userDetails 填充資料，這樣能自動填入姓名、電話等資料，簡化表單填寫的過程。
    
    2. 避免覆蓋用戶修改後的資料：
 
        - 一旦顧客填寫或修改了 customerDetails 中的資訊並離開該視圖，再次返回時，不會重新從 userDetails 中覆蓋資料，因為這時候 customerDetails 已經存在且有用戶修改的值。
        - 這種方式可以保留用戶修改後的資料，避免重複填寫和資料流失，提供更好的用戶體驗。
 
    3. 分「初始填充」與「持續修改」的行為：

        - 將「初始填充」只發生在 customerDetails 為 nil 的情況下，意味著只在需要給出預設值時執行。這樣可以區分「初次進入視圖」和「用戶後續進入視圖」的不同需求。
        - 對於後續的修改，可以通過其他方法（例如 updateStoredCustomerDetails()）來更新 customerDetails，從而確保用戶的修改被正確地保存和反映。
 
 &. 小結

    - 「有條件地更新資料」的方法是為了只在需要填充初始值時使用 userDetails，而不影響用戶在視圖中的修改。
    - 這樣可以確保用戶進入表單時有預設值，之後的修改也能得到保存，避免每次返回視圖時用戶資料被重置為初始值。
    - 這樣的設計能有效提升用戶體驗，減少重複的表單填寫，特別是在需要多次進出該表單的情境中，能顯著減少用戶的操作負擔。
 */

// MARK: - 新增 resetCustomerDetails（重要）

/*
 * 使用情境：

    - 清空所有訂單項目：當訂單完全被清空後，顧客資料也應該被重置，以保證數據狀態一致。
    - 登出帳號：當用戶登出帳號後，應重置顧客資料，以避免新登入的用戶看到前一個用戶的資料，確保數據安全。
 
 * 方法用途：

    - resetCustomerDetails() 方法負責清空顧客詳細資料 (customerDetails)，使其回到初始狀態。
    - 適合在用戶的資料流需要完全重置的情境中使用，例如登出帳號、清空訂單項目等。
 
 * 建議使用位置：

    - 可以在 OrderItemManager 中呼叫此方法，當所有訂單項目被清空時重置顧客資料。
    - 在登出帳號的相關邏輯中（例如 AuthManager 或 FirebaseController 的登出方法）呼叫此方法，以確保登出時清空顧客資料。
 */


// MARK: - 重構
// - 真正的關鍵在於「欄位之間的排他性」，而非取件方式的切換。具體來說，「取件方式」與清空欄位的邏輯無關，重點應該是「storeName 和 address 兩者不應同時存在」。
// - 登出後重置。
// - 第一次進入到OrderCustomerDetailsViewController時，是採用UserDetails填充。
// - 進入到OrderCustomerDetailsViewController後，回到上一個視圖後，再回到OrderCustomerDetailsViewController可以保持修改過的資料。
// - 清空orderItems時，會重置customDetails。 

import Foundation
import Firebase

/// 用於管理與驗證顧客資料
class CustomerDetailsManager {
    
    static let shared = CustomerDetailsManager()
    
    // MARK: - Properties
    
    var customerDetails: CustomerDetails?
    
    // MARK: - Methods

    /// 從 UserDetails 中填充初始的顧客資料
    /// - Parameter userDetails: 當前用戶的詳細資料
    ///
    /// 只有在 `customerDetails` 為 `nil` 時，才會從 `userDetails` （如姓名、電話等）來填充初始顧客資料。
    /// 這樣可以避免在返回視圖時覆蓋用戶已經修改過的內容，保持用戶的修改不被重置。
    func populateCustomerDetails(from userDetails: UserDetails) {
        if self.customerDetails == nil {
            self.customerDetails = CustomerDetails(
                fullName: userDetails.fullName,                     // 使用 UserDetails 填充顧客全名
                phoneNumber: userDetails.phoneNumber ?? "",         // 使用 UserDetails 填充電話號碼，若無則為空字串
                pickupMethod: .homeDelivery,                        // 默認取件方式為「外送服務」
                address: userDetails.address,                       // 使用 UserDetails 填充地址
                storeName: nil,                                     // 初始不填充取件店家名稱
                notes: nil                                          // 初始不填充備註
            )
        }
        // Print statements to observe population
        print("[CustomerDetailsManager]: Populating customer details:")
        print("[CustomerDetailsManager]: Full Name: \(self.customerDetails?.fullName ?? "No Full Name Set")")
        print("[CustomerDetailsManager]: Phone Number: \(self.customerDetails?.phoneNumber ?? "No Phone Number Set")")
        print("[CustomerDetailsManager]: Address: \(self.customerDetails?.address ?? "No Address Provided")")
        print("[CustomerDetailsManager]: Pickup Method: \(self.customerDetails?.pickupMethod.rawValue ?? "No Pickup Method Set")")
        print("[CustomerDetailsManager]: Store Name: \(self.customerDetails?.storeName ?? "No Store Name Set")")
        print("[CustomerDetailsManager]: Note: \(self.customerDetails?.notes ?? "No Notes")")
    }
    
    /// 更新顧客詳細資料（包括姓名、電話、地址、店家名稱、備註）
    /// - Parameters:
    ///   - fullName: 新的顧客姓名
    ///   - phoneNumber: 新的顧客電話號碼
    ///   - address: 新的配送地址（設定此值時，會清空店家名稱）
    ///   - storeName: 新的取件店家名稱（設定此值時，會清空配送地址）
    ///   - notes: 額外備註
    ///
    /// 此方法用於更新當前顧客的詳細資料，以保持資料的最新狀態。
    /// 需要注意的是，當「地址」有值時，會自動清空「店家名稱」；而當「店家名稱」有值時，則會清空「地址」。
    /// 這樣的設計是為了確保顧客的配送方式和取件方式不互相衝突。
    func updateStoredCustomerDetails(fullName: String? = nil, phoneNumber: String? = nil, address: String? = nil, storeName: String? = nil, notes: String? = nil) {
        guard var details = customerDetails else {
            print("[CustomerDetailsManager]: 尚未初始化")
            return
        }

        if let fullName = fullName {
            details.fullName = fullName
            print("[CustomerDetailsManager]: 已更新姓名：\(fullName)")
        }
        if let phoneNumber = phoneNumber {
            details.phoneNumber = phoneNumber
            print("[CustomerDetailsManager]: 已更新電話號碼：\(phoneNumber)")
        }
        if let address = address {
            details.address = address
            details.storeName = nil // 當地址有值時，清空店家名稱
            print("[CustomerDetailsManager]: 已更新地址：\(address)，並清空店家名稱")
        }
        if let storeName = storeName {
            details.storeName = storeName
            details.address = nil // 當店家名稱有值時，清空地址
            print("[CustomerDetailsManager]: 已更新店家名稱：\(storeName)，並清空地址")
        }
        if let notes = notes {
            details.notes = notes
            print("[CustomerDetailsManager]: 已更新備註內容：\(notes)")
        }

        customerDetails = details
        print("[CustomerDetailsManager]: 已更新: \(customerDetails.debugDescription)")
    }

    /// 更新取件方式
    /// - Parameter method: 更新的取件方式（`外送服務`或`到店取件`）
    func updatePickupMethod(_ method: PickupMethod) {
        guard var details = customerDetails else { return }
        details.pickupMethod = method
        print("[CustomerDetailsManager]: 已更新取件方式：\(method.rawValue)")
        self.customerDetails = details
    }

    /// 驗證顧客資料是否完整
    /// - Returns: 若資料完整返回 .success，否則返回具體的錯誤原因
    ///
    /// 驗證顧客資料是否已填寫必填項目，例如姓名、電話，以及若選擇 `外送服務`時需要填寫地址。
    func validateCustomerDetails() -> ValidationResult {
        guard let details = customerDetails else {
            return .failure(.missingDetails)
        }
        
        // 確保姓名和電話都有填寫
        if details.fullName.isEmpty {
            return .failure(.missingFullName)
        }
        if details.phoneNumber.isEmpty {
            return .failure(.missingPhoneNumber)
        }
        // 如果選擇宅配運送，需驗證地址是否有填寫
        if details.pickupMethod == .homeDelivery && (details.address?.isEmpty ?? true) {
            return .failure(.missingAddress)
        }
        // 如果選擇到店取件，需驗證店家名稱是否有填寫
        if details.pickupMethod == .inStore && (details.storeName?.isEmpty ?? true) {
            return .failure(.missingStoreName)
        }
        
        return .success
    }
    
    /// 獲取當前的顧客詳細資料
    /// - Returns: 顧客詳細資料
    ///
    /// 此方法用於從 manager 中取得當前的顧客詳細資料。
    func getCustomerDetails() -> CustomerDetails? {
        return customerDetails
    }
    
    /// 重置顧客詳細資料，
    /// - 通常在以下情況下調用：
    ///   1. 用戶需要完全重新開始訂單流程時，例如清空所有訂單項目後。
    ///   2. 用戶登出帳號時，以確保新用戶登入時不會殘留之前的顧客資料。
    func resetCustomerDetails() {
        customerDetails = nil
        print("[CustomerDetailsManager]: 已被重置")
    }

}

// MARK: - Enum Definitions

/// 顧客資料驗證錯誤的 enum
enum ValidationResult: Equatable {
    case success
    case failure(ValidationError)
}

/// 顧客資料驗證錯誤類型
enum ValidationError: String, Error, Equatable {
    case missingDetails = "顧客詳細資料缺失"
    case missingFullName = "顧客姓名未填寫"
    case missingPhoneNumber = "顧客電話號碼未填寫"
    case missingAddress = "宅配運送需要填寫配送地址"
    case missingStoreName = "到店取件需要選擇店家"
}
