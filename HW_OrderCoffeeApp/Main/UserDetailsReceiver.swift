//
//  UserDetailsReceiver.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/15.
//

/*

 * UserDetailsReceiver
    - 這個協議用於定義視圖控制器應該實現的方法，以便接收和處理使用者資訊。
 
 *  方法 (receiveUserDetails(_:)):
    - 接收一個可選的 UserDetails 物件。這個物件包含使用者的詳細資訊，例如 uid、email、fullName 等。
    - 任何遵循 UserDetailsReceiver 協議的視圖控制器都需要實現這個方法。
    - 若 userDetails 為 nil，表示沒有可用的使用者資訊，視圖控制器可以根據這個狀況進行適當的處理，例如顯示預設資料或跳過某些操作。
 
 * 使用場景
    - 當 App 中的某個部分（ MainTabBarController）成功獲得用戶資訊後，會將這些資訊傳遞給其他需要這些資訊的視圖控制器。
    - 符合 UserDetailsReceiver 協議的視圖控制器實現 receiveUserDetails(_:) 方法，來處理接收到的用戶資訊並更新自身狀態。
 
 */


import Foundation

/// 用於接收使用者資訊的協議
///
/// 當需要將使用者資訊從一個視圖控制器傳遞到另一個視圖控制器時，
/// 遵循這個協議的視圖控制器可以實現 `receiveUserDetails(_:)` 方法來處理接收到的使用者資訊。
/// 用於在用戶登入或註冊成功後，將用戶資料傳遞給 App 中的其他視圖控制器。
protocol UserDetailsReceiver: AnyObject {
    
    /// 接收並處理使用者資訊的方法
    ///
    /// - Parameter userDetails: 包含使用者資訊的 `UserDetails` 物件。
    ///   如果是 `nil`，則表示沒有可用的使用者資訊。
    func receiveUserDetails(_ userDetails: UserDetails?)
}
