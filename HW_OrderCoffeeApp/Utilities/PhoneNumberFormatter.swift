//
//  PhoneNumberFormatter.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/7.
//

// MARK: - 關於「電話號碼」的格式存取跟使用問題
/**
 
 ## 關於「電話號碼」的格式存取跟使用問題：
 
 1. 為何要將 Firebase 的電話改用純數字，而不要使用到特殊符號？
 
    - 一開始我在 Cloud Firestore 中存取電話的格式為 02-2345-6789。
    - 我的預想是會建立一個按鈕，可以藉此撥打電話號碼。
    - 才意識到撥打電話時不能有 '-' 特殊符號，一開始有去設置處理，但覺得有點多此一舉，因此就將資料庫的電話格式改為 0223456789。
    - 只有在前端畫面顯示的時候才會有 '-' 特殊符號，撥打時則直接使用 Cloud Firestore 沒有特殊符號的電話格式。
 
 * 簡單存取：
   - 電話號碼存成純數字（例如 `"0282839371"`）可以讓程式更簡單地進行數字處理或比較，例如判斷電話號碼是否相同。
 
 * 格式化顯示：
   - 這樣的設計讓資料保持一致，無論在資料庫中或後端都是簡單的數字格式。而在前端顯示時，可以依需求加上適合的格式（例如加上「-」），提高彈性。
 
 * 減少錯誤：
   - 如果直接在資料庫中儲存不同格式的電話號碼，容易在使用者輸入、資料處理等步驟中發生錯誤。因此，保持純數字格式儲存可以減少不同格式造成的潛在問題。

 2. 關於電話號碼格式
 
    - 接續的問題是，台灣區碼問題，雖然說不會輸入全部「星巴克」門市資料，但考量到「實際」層面問題，還是建立處理區碼的邏輯。
 
 * 台灣市話區碼：
   - 台灣的市話區碼不只包含 `02`，還有 `03、037、04、049、05、06、07、08、089、082、0826、0836` 等多種區碼。
 
 * 格式化顯示：
   - 在存取 Firebase 時，可以將電話號碼儲存為純數字，但在前端顯示時，可以依需求加上分隔符號，例如 `02-8283-9371`，讓用戶更容易閱讀。
 
 * 撥打電話處理：
   - 在撥打電話時，電話號碼需要保持純數字格式，以便透過 `tel://` 協議進行撥打。
   - 例如，也因為改成純數字，因此從資料庫中取出的電話號碼。所以不用在經過 `replacingOccurrences(of:)` 進行去除所有非數字字符後再使用。
 */


//MARK: - 關於 formatPhoneNumber 的處理。
/**
 
 ##  關於 formatPhoneNumber 的處理
 
 * 參考: https://reurl.cc/pvkZVd
 
 * 問題
    - 台灣電話號碼格式多樣，且區碼長度（2、3、4位）和號碼總長（9或10位）不一致，單純的條件判斷容易造成 - 錯誤分隔。
    - 某些地區（如離島）使用不同長度的區碼，導致無法統一格式化，例如 0836 開頭的號碼需要特殊處理。
 
 * 解決方式
    - 因為利用正規表達式有效區分區碼和主號碼，並針對主號碼的長度進行條件格式化，以滿足不同地區的格式需求，避免了區碼和號碼錯誤分段的情況。
    - 使用正規表達式解析：使用 NSRegularExpression 和模式 ^(0836|0826|082|089|08|07|06|05|049|04|037|03|02)(\d+)$，只匹配有效的台灣區碼開頭，並將區碼和號碼分開。
        
        1. ^(0836|0826|082|089|08|07|06|05|049|04|037|03|02)： 匹配台灣常見的區碼，避免處理不相關的格式。
        2. (\d+)$： 將區碼以後的部分視為主號碼，無論其長度為7或8位。
 
 * 分組擷取：
    - 若符合格式，透過 regex.firstMatch 方法擷取 areaCode 和 mainNumber 兩部分：

        1. areaCode：為符合的台灣地區區碼。
        2. mainNumber：區碼後的主號碼。
 
 * 動態格式化主號碼長度：
    - 若主號碼為 8位數：格式化為 XXXX-XXXX。
    - 若主號碼為 7位數或更短：格式化為 區碼-號碼，僅以單一 - 分隔，避免多餘的分段。
 
 * 備選方案：
    - 當無法匹配到正確格式時（如非有效區碼），直接返回原始號碼，避免錯誤分隔。
 */


// MARK: - PhoneNumberFormatter 筆記
/**
 
 ## PhoneNumberFormatter 筆記

 `* What`
 
 - `PhoneNumberFormatter` 是一個工具類別，專門用於格式化電話號碼。其主要功能是將台灣常見的電話號碼轉換為標準的格式，提升電話號碼的可讀性與一致性。

 - 輸入格式：
   - 包含區碼與號碼，例如 `0223456789`、`089123456`。
 
 - 輸出格式：
   - 若主號碼為 **8 位數**：格式化為 `XXXX-XXXX`，例如 `0223456789` → `02-2345-6789`。
   - 若主號碼為 **7 位數或更短**：格式化為 `區碼-號碼`，例如 `0223456` → `02-23456`。

 ------------

 `* Why`
 
 `1. 提升可讀性：`
 
    - 格式化後的電話號碼更容易辨識，減少誤讀的可能性。
    - 特別是長號碼（如 8 位數）分段顯示，有助於快速理解。
    
 `2. 統一格式：`
 
    - 確保電話號碼在 UI 或報表中以一致的方式呈現，避免手動處理錯誤。
    
 `3. 可重用性：`
 
    - 將電話號碼格式化邏輯集中於工具類別，方便在多個模組中使用。

 `4. 易於擴展：`
 
    - 若未來需要支持其他地區的格式，可以在此基礎上擴展。

 ------------

 `* How`

 `- 主要邏輯：`
 
 `1. 使用正則表達式來解析電話號碼的區碼與主號碼：`
 
    - **正則表達式**：`^(0836|0826|082|089|08|07|06|05|049|04|037|03|02)(\d+)$`
      - 捕捉有效的台灣區碼（如 `02`, `07`, `08` 等）。
      - 剩餘部分作為主號碼。
    - 成功匹配後，提取區碼與主號碼。

 `2. 根據主號碼長度進行格式化：`
 
    - 若主號碼為 **8 位數**，分為 `XXXX-XXXX`。
    - 若主號碼為 **7 位數或更短**，格式化為 `區碼-號碼`。

 ---
 
 `- 方法細節：`

 1. `formatForTaiwan` ：
    - 總入口，負責組織邏輯。
    - 調用 `extractPhoneNumberComponents` 方法提取區碼與主號碼。
    - 調用 `formatPhoneNumber` 方法進行格式化。

 2. `extractPhoneNumberComponents` ：
    - 解析輸入的電話號碼並提取區碼與主號碼。
    - 若無法匹配，返回 `nil`。

 3. `formatPhoneNumber` ：
    - 根據主號碼的長度選擇適合的格式化方式。

 ------------

` * 程式範例：`

 ```swift
 let phoneNumber = "0223456789"
 let formattedNumber = PhoneNumberFormatter.formatForTaiwan(phoneNumber)
 // 輸出: "02-2345-6789"

 let shortPhoneNumber = "0223456"
 let formattedShortNumber = PhoneNumberFormatter.formatForTaiwan(shortPhoneNumber)
 // 輸出: "02-23456"

 ```
 */


import Foundation

/// 負責格式化電話號碼的工具類別
class PhoneNumberFormatter {
    
    /// 格式化電話號碼為台灣常見格式
    ///
    /// - Parameter phoneNumber: 原始電話號碼
    /// - Returns: 格式化後的電話號碼
    static func formatForTaiwan(_ phoneNumber: String) -> String {
        guard let (areaCode, mainNumber) = extractPhoneNumberComponents(from: phoneNumber) else {
            return phoneNumber  // 若無法解析，返回原始號碼
        }
        
        // 根據主號碼長度調整格式
        return formatPhoneNumber(areaCode: areaCode, mainNumber: mainNumber)
    }
    
    // MARK: - Private Method
    
    /// 從電話號碼中提取區碼與主號碼
    ///
    /// - Parameter phoneNumber: 原始電話號碼
    /// - Returns: 區碼與主號碼的元組
    private static func extractPhoneNumberComponents(from phoneNumber: String) -> (areaCode: String, mainNumber: String)? {
        let pattern = #"^(0836|0826|082|089|08|07|06|05|049|04|037|03|02)(\d+)$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: phoneNumber, options: [], range: NSRange(location: 0, length: phoneNumber.count)) else {
            return nil
        }
        
        let areaCodeRange = match.range(at: 1)
        let mainNumberRange = match.range(at: 2)
        
        guard let areaCode = Range(areaCodeRange, in: phoneNumber),
              let mainNumber = Range(mainNumberRange, in: phoneNumber) else {
            return nil
        }
        
        return (String(phoneNumber[areaCode]), String(phoneNumber[mainNumber]))
    }
    
    /// 格式化區碼與主號碼為台灣常見格式
    ///
    /// - Parameters:
    ///   - areaCode: 區碼
    ///   - mainNumber: 主號碼
    /// - Returns: 格式化後的電話號碼
    private static func formatPhoneNumber(areaCode: String, mainNumber: String) -> String {
        if mainNumber.count == 8 {
            return "\(areaCode)-\(mainNumber.prefix(4))-\(mainNumber.suffix(4))" // 8碼情況：分成4-4格式
        } else {
            return "\(areaCode)-\(mainNumber)"                             // 7碼或更短情況：顯示為完整號碼
        }
    }
    
}
