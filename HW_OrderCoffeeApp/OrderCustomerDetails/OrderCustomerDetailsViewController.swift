//
//  OrderCustomerDetailsViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/8.
//

import UIKit

/// 該頁面會提供填寫顧客的姓名、電話、取件方式、備註欄等資料。
class OrderCustomerDetailsViewController: UIViewController {

    // MARK: - Properties

    /// 用於存放訂單資料
    var orderItems: [OrderItem] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("接收到的訂單項目數量：\(orderItems.count)")  // 確認傳遞的資料是否正確
    }

}
