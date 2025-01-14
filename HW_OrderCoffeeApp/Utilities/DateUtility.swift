//
//  DateUtility.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/1/8.
//

// MARK: - 關於 「地區時間」轉換：
/**
 ### 重點筆記

 * `關於 "Today's Opening Hours: 營業時間未提供" 的問題：`
 
    - 雖然已經在 Cloud Firestore 設定好營業時間了。但因為我是設置「星期一、星期二」，而非「Monday等」。
    - print("Today's Opening Hours: \(todayHours)") 出現 「Today's Opening Hours: 營業時間未提供」。
 
 * `問題原因：`
 
   - 出現「營業時間未提供」是因為在尋找今天的營業時間時，無法匹配到相應的資料。
   - 這與 DateFormatter 設定的地區 (Locale) 有關，或是與 dateFormat 格式不正確導致日期轉換錯誤。
 
 - `解決方式：`
 
   - 確保 DateFormatter 使用正確的地區（台灣應設為 "zh_TW"）。
   - 使用與 Firebase 資料中的日期鍵值相符的格式，例如 Firebase 中使用「星期一、星期二」，那 DateFormatter 應設為「EEEE」並設定為台灣的語系。
 */


// MARK: - DateUtility 筆記
/**
 
 ## DateUtility 筆記

 ---

 `* What`
 
 - `DateUtility` 是一個專門用於處理日期相關邏輯的工具類，提供便捷的方法來獲取和操作日期資訊。

 - `核心功能：`
 
 1. 取得指定日期的星期名稱：
 
    - 預設為今天的日期，回傳對應的星期名稱（如 "星期一"、"星期二"）。
    - 支援傳入自定日期進行查詢。
 
 2.格式化日期：
 
    - 提供日期轉換為自訂格式的功能，預設格式為 yyyy/MM/dd HH:mm。

 - `設計特點：`
 
 - 使用靜態方法，避免實例化，簡化操作。
 - 支援繁體中文（`zh_TW`）的星期格式。

 ----------

 `* Why`
 
 1. 簡化日期處理邏輯：
 
    - 提供一個集中的方法來處理日期轉換和格式化，避免在其他模組中重複編寫日期相關邏輯。

 2. 提升可讀性與可維護性：
 
    - 將日期格式化邏輯集中管理，讓代碼結構更清晰，方便調整和擴展。

 3. 本地化支持：
 
    - 預設地區為繁體中文（`zh_TW`），確保回傳的星期名稱符合本地使用習慣。

 4. 易於測試：
 
    - 通過傳入不同的日期進行測試，驗證功能正確性，避免時間依賴性帶來的測試困難。

 ----------

 `* How`

 1. 設計邏輯：
 
 - 使用 `DateFormatter` 處理日期格式化和星期名稱生成。
 - 設定地區為繁體中文（`zh_TW`），確保回傳格式正確。
 - 預設日期為當天，允許傳入其他日期進行查詢。

 ----

 2. 方法詳細：
 
 ```swift
 /// 取得指定日期的星期名稱（預設為今天）
 ///
 /// - Parameter date: 指定日期（預設為今天）
 /// - Returns: 星期名稱（如 "星期一"）
 static func getWeekday(for date: Date = Date()) -> String {
     let formatter = DateFormatter()
     formatter.locale = Locale(identifier: "zh_TW")  // 設定地區
     formatter.dateFormat = "EEEE"                   // 格式為星期幾
     return formatter.string(from: date)
 }
 
 /// 格式化日期為指定格式
 /// - Parameters:
 ///   - date: 要格式化的日期
 ///   - format: 日期格式，預設為 "yyyy/MM/dd HH:mm"
 /// - Returns: 格式化後的日期字串
 static func formatDate(_ date: Date, format: String = "yyyy/MM/dd HH:mm") -> String {
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = format
     return dateFormatter.string(from: date)
 }
 ```

 ----
 
 3. 使用範例：
 
 ```swift
 // 使用預設值，取得今天的星期名稱
 let todayWeekday = DateUtility.getWeekday()
 print(todayWeekday)  // Output: "星期五"（例如，今天是星期五）

 // 查詢指定日期的星期名稱
 let specificDate = Date(timeIntervalSince1970: 1630483200) // 2021-09-01
 let weekdayForSpecificDate = DateUtility.getWeekday(for: specificDate)
 print(weekdayForSpecificDate)  // Output: "星期三"
 
 // 格式化今天的日期
 let formattedToday = DateUtility.formatDate(Date())
 print(formattedToday)  // Output: "2025/01/08 12:34"（示例格式）

 // 格式化指定日期
 let formattedSpecificDate = DateUtility.formatDate(specificDate, format: "MM/dd/yyyy")
 print(formattedSpecificDate)  // Output: "09/01/2021"
 ```

 ----------

 `* 優化效益`

 1. 提升效率：簡化日期相關邏輯的處理。
 2. 降低重複性：避免多處出現重複的日期格式化邏輯。
 3. 靈活性強：支持多地區、格式的擴展（未來可通過參數支持不同的地區和格式需求）。

 */


import Foundation

/// 日期工具類，用於處理日期相關的邏輯
struct DateUtility {
    
    /// 取得指定日期的星期名稱（預設為今天）
    ///
    /// - Parameter date: 指定日期（預設為今天）
    /// - Returns: 星期名稱（如 "星期一"）
    static func getWeekday(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")  // 設定地區
        formatter.dateFormat = "EEEE"                   // 格式為星期幾
        return formatter.string(from: date)
    }
    
    /// 格式化日期為指定格式
    /// - Parameters:
    ///   - date: 要格式化的日期
    ///   - format: 日期格式，預設為 "yyyy/MM/dd HH:mm"
    /// - Returns: 格式化後的日期字串
    static func formatDate(_ date: Date, formate: String = "yyyy/MM/dd HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        return dateFormatter.string(from: date)
    }
    
}
