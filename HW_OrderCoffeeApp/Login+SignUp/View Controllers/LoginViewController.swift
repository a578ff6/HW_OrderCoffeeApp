//
//  LoginViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit

/// 登入介面
class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        setUpHideKeyboardOntap()
        ActivityIndicatorManager.shared.activityIndicator(on: view)
    }
    
    
    /// 設置 UI 元件的樣式
    func setUpElements() {
        emailTextField.styleTextField()
        passwordTextField.styleTextField()
        loginButton.styleFilledButton()
    }
    
    
    /// 處理登入按鈕點擊事件
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // 確保電子郵件和密碼輸入不為空
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
            return
        }
        
        ActivityIndicatorManager.shared.startLoading()  // 啟動活動指示器
        
        FirebaseController.shared.loginUser(withEmail: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                
                ActivityIndicatorManager.shared.stopLoading()               // 停止活動指示器

                switch result {
                case .success(let user):
                    // 登入成功，進行後續處理
                    print("User \(user.user.email!) logged in successfully")
                case .failure(let error):
                    // 登入失敗，顯示錯誤信息
                    print("Login error: \(error.localizedDescription)")
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
            

        }
        
        
    }
    
}


