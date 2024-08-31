//
//  SignUpViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

/*
 1. 在 SignUpViewController 中，設置全名、電子郵件和密碼，以及註冊須知。另外還有 google、apple 註冊部分
    
    * 使用 Google 或 Apple 進行註冊和登入時，通常無法直接獲取用戶的地址和電話等額外資訊。這些第三方登錄方式通常只提供用戶的基本資訊，如姓名和電子郵件。
    * 因此，採取以下做法：
        - 簡化註冊流程：在使用電子郵件註冊的部分，只要求用戶提供姓名、信箱和密碼。
        - 延遲收集詳細資訊：在用戶完成註冊或登錄後，由在「訂單視圖控制器」讓使用者填寫額外的詳細資訊（地址和電話）。
        - 藉此提高註冊率，同時確保在需要時獲取完整的用戶資訊！！

 */



// MARK: - 程式碼版本（註冊須知）
import UIKit

/// 註冊頁面
class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    private let signUpView = SignUpView()
    
    /// 追蹤使用者是否點擊了「註冊須知連結」
    private var didViewTerms = false
    
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = signUpView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpHideKeyboardOntap()
        setupActions()
    }
    
    
    // MARK: - Private Methods
    /// 設置 Action
    private func setupActions() {
        signUpView.signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        signUpView.setPasswordOrConfirmPasswordTextFieldIcon(for: signUpView.passwordTextField, target: self, action: #selector(togglePasswordVisibility))
        signUpView.setPasswordOrConfirmPasswordTextFieldIcon(for: signUpView.confirmPasswordTextField, target: self, action: #selector(toggleConfirmPasswordVisibility))
        
        signUpView.googleLoginButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        signUpView.appleLoginButton.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        
        signUpView.termsButton.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        signUpView.termsCheckBox.addTarget(self, action: #selector(termsCheckBoxTapped), for: .touchUpInside)
    }
    
    /// 註冊須知連結
    @objc private func termsButtonTapped() {
        if let url = URL(string: "https://www.starbucks.com.tw/stores/allevent/show.jspx?n=1016") {
            UIApplication.shared.open(url) { [weak self] success in
                if success {
                    self?.didViewTerms = true                        // 確認使用者點擊了連結
                    self?.signUpView.termsCheckBox.isEnabled = true   // 啟用「確認框」
                }
            }
        }
    }
    
    /// 確認框點擊
    @objc private func termsCheckBoxTapped() {
        guard didViewTerms else {
            signUpView.termsCheckBox.isSelected = false         // 使用者還沒點擊「註冊須知連結」，不允許勾選
            return
        }
        signUpView.termsCheckBox.isSelected.toggle()    // 切換選中狀態
    }

    /// 處理註冊按鈕點擊事件
    @objc private func signUpButtonTapped() {
        
        // 確認使用者有點擊「確認框」
        guard signUpView.termsCheckBox.isSelected else {
             AlertService.showAlert(withTitle: "錯誤", message: "請同意並閱讀註冊須知", inViewController: self)
             return
         }
        
        // 檢查 TextField 是否有輸入，並且不為空
        guard let email = signUpView.emailTextField.text, !email.isEmpty,
              let password = signUpView.passwordTextField.text, !password.isEmpty,
              let fullName = signUpView.fullNameTextField.text, !fullName.isEmpty,
              let confirmPassword = signUpView.confirmPasswordTextField.text, !confirmPassword.isEmpty
        else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫所有資料", inViewController: self)
            return
        }
        
        // 檢查電子郵件格式是否有效
        if !EmailSignInController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入有效的電子郵件地址，例如：example@example.com", inViewController: self)
            return
        }
          
        // 檢查密碼是否符合規範
        if !EmailSignInController.isPasswordValid(password) {
            AlertService.showAlert(withTitle: "錯誤", message: "密碼需至少包含8位字符，並包括至少一個小寫字母和一個特殊字符", inViewController: self)
            return
        }
       
        // 檢查兩次密碼是否相同
        if password != confirmPassword {
            AlertService.showAlert(withTitle: "錯誤", message: "兩次輸入的密碼不一致", inViewController: self)
            return
        }
   
        HUDManager.shared.showLoading(in: view, text: "Signing up...")
        // 調用 EmailSignInController 進行用戶註冊
        EmailSignInController.shared.registerUser(withEmail: email, password: password, fullName: fullName) { [weak self] result in
            DispatchQueue.main.async {
                HUDManager.shared.dismiss()
                switch result {
                case .success(_):
                    FirebaseController.shared.getCurrentUserDetails { userDetailsResult in
                        switch userDetailsResult {
                        case .success(let userDetails):
                            NavigationHelper.navigateToMainTabBar(from: self!, with: userDetails)   // 使用 NavigationHelper 導入到mainTabBarController
                        case .failure(let error):
                            AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                        }
                    }
                case .failure(let error):
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
        }
    }
    
    /// 處理Google登入
    @objc private func googleLoginButtonTapped() {
        // Google 登錄邏輯
    }
    
    /// 處理FB登入
    @objc private func appleLoginButtonTapped() {
        // Facebook 登錄邏輯
    }
    
    
    /// 切換密碼顯示狀態
     @objc private func togglePasswordVisibility() {
         signUpView.passwordTextField.isSecureTextEntry.toggle()
         let eyeImageName = signUpView.passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
         if let eyeButton = signUpView.passwordTextField.rightView as? UIButton {
             eyeButton.setImage(UIImage(systemName: eyeImageName), for: .normal)
         }
     }
     
     /// 切換確認密碼顯示狀態
     @objc private func toggleConfirmPasswordVisibility() {
         signUpView.confirmPasswordTextField.isSecureTextEntry.toggle()
         let eyeImageName = signUpView.confirmPasswordTextField.isSecureTextEntry ? "eye" : "eye.slash"
         if let eyeButton = signUpView.confirmPasswordTextField.rightView as? UIButton {
             eyeButton.setImage(UIImage(systemName: eyeImageName), for: .normal)
         }
     }

}








// MARK: - storyboard

/*
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
        
        ActivityIndicatorManager.shared.startLoading(on: view, backgroundColor: UIColor.black.withAlphaComponent(0.5)) // 啟動活動指示器
        
        // 調用 FirebaseController 進行用戶註冊
        FirebaseController.shared.registerUser(withEmail: email, password: password, fullName: fullName) { [weak self] result in
            DispatchQueue.main.async {
                ActivityIndicatorManager.shared.stopLoading()            // 停止活動指示器

                switch result {
                case .success(_):
                    FirebaseController.shared.getCurrentUserDetails { userDetailsResult in
                        switch userDetailsResult {
                        case .success(let userDetails):
                            NavigationHelper.navigateToMainTabBar(from: self!, with: userDetails)   // 使用 NavigationHelper 導入到mainTabBarController
                        case .failure(let error):
                            AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                        }
                    }
                case .failure(let error):
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
        }
        
    }

}
*/
