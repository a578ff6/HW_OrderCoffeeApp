//
//  SignUpViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit


/// 註冊頁面
class SignUpViewController: UIViewController {

    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        setUpHideKeyboardOntap()
        ActivityIndicatorManager.shared.activityIndicator(on: view)
    }
    
    
    /// 設置界面樣式
    func setUpElements() {
        fullNameTextField.styleTextField()
        emailTextField.styleTextField()
        passwordTextField.styleTextField()
        signUpButton.styleFilledButton()
    }
    
    
    /// 處理註冊按鈕
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        // 檢查 TextField 是否有輸入，並且不為空
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let fullName = fullNameTextField.text, !fullName.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫所有資料", inViewController: self)
            return
        }
        
        // 檢查電子郵件格式是否有效
        if !FirebaseController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入有效的電子郵件地址，例如：example@example.com", inViewController: self)
            return
        }
        
        // 檢查密碼是否符合規範
        if !FirebaseController.isPasswordValid(password) {
            AlertService.showAlert(withTitle: "錯誤", message: "密碼需至少包含8位字符，並包括至少一個小寫字母和一個特殊字符", inViewController: self)
            return
        }
        
        ActivityIndicatorManager.shared.startLoading()      // 啟動活動指示器
        
        // 調用 FirebaseController 進行用戶註冊
        FirebaseController.shared.registerUser(withEmail: email, password: password, fullName: fullName) { [weak self] result in
            DispatchQueue.main.async {
                
                ActivityIndicatorManager.shared.stopLoading()            // 停止活動指示器

                switch result {
                case .success(let user):
                    print("User \(user.user.email!) registered successfully")
                case .failure(let error):
                    print("Registration error: \(error.localizedDescription)")
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
            
        }
        
    }
    

}

