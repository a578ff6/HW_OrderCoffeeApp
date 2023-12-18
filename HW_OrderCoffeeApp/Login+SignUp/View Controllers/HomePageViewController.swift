//
//  HomePageViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit


/// 登入、註冊頁面
class HomePageViewController: UIViewController {

    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    
    /// 設置 UI 元件的樣式
    func setUpElements() {
        loginButton.styleFilledButton()
        signUpButton.styleFilledButton()
    }
    

}
