//
//  LoginViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

/*
 A.實現用戶登入、註冊後跳轉到其他視圖：
    * 設置 RootViewController：
        - 常用的方式，特別是在登入、註冊成功後。確保登入前的ViewController（登入、註冊頁面）不再存在於「ViewController堆棧」中，從而避免用戶通過Navigation返回到這些頁面。
        - 優點：
        - 確保App的狀態一致性。
        - 使用者無法通過Navigation回到登入、註冊頁面。
        - 適合用於MainNavigation的切換，像是從登入頁面到App的主頁面。
 
    * 使用 NavigationController：
        -如果App的結構是基於NavigtaionController，那麼可以通過push、modalPresent展示新的ViewController。不過這種發誓通常用於在同一個 「Navigation堆棧」中添加新的 ViewController，而不是替換整個 RootViewController。
        - 優點：
        - 間單直接，適用於非 RootViewController 的跳轉。
        - 在同一個「Navigation堆棧」中管理 ViewController。
 
    * 選擇的方式：
        - 設置 RootViewController 方式，特別是在登入、註冊成功後。
        - 原因：
            - 清除「Navigation堆棧」中不需要的 ViewController ，確保App的一致性。
            - 更適合用於主視圖的切換，例如登入、註冊頁面到App主頁面。
            - 只有在特定的場境下（EX：在同一個「Navigation堆棧」中添加新的 ViewController ），使用 NavigationController 進行視圖跳轉才會更適合。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 B. 處理「Remember Me」按鈕的流程：
    * 當用戶點擊 "Remember Me" 按鈕時，會將當前的電子郵件和密碼存儲到 Keychain 中。
 
    * 先檢查TextField是否有填寫：
        - 原本如果用戶先點擊 "Remember Me" 按鈕再輸入帳號密碼，那麼之前的空數據或錯誤的數據就會被存儲。
        - 因此我後來改成：用戶點擊 "Remember Me" 按鈕後檢查當前的電子郵件和密碼是否已經填寫好。如果未填寫好，提示用戶先完成輸入。
 
    * Remember Me 按鈕的邏輯和 loginButtonTapped 的關聯性：
        - Remember Me 按鈕的作用是在用戶選中時記住電子郵件和密碼，而 loginButtonTapped 則是在用戶點擊登錄按鈕後執行登錄操作。
 
    * 工作流程（確保這個流程的關鍵在於順序的控制和條件的檢查。）：
        - 用戶輸入電子郵件和密碼。
        -  用戶點擊 Remember Me 按鈕（可選）。
        -  用戶點擊 Login 按鈕，執行登錄操作。
        -  如果用戶選中了 Remember Me，則會將電子郵件和密碼存儲到 Keychain 中。
        -  在下一次 App 啟動時，如果檢測到 Remember Me 被選中，則自動填充電子郵件和密碼。

 
 ---------------------------------------- ---------------------------------------- ----------------------------------------

 C. googleLoginButtonTapped：
    * Google 登入或註冊成功後會調用 signInWithGoogle 。
 
    * 在 signInWithGoogle 成功後，會使用 Firebase 的憑證登入，並在 authResult 成功後調用 FirebaseController.shared.getCurrentUserDetails 獲取用戶的資訊。
   
    * 在獲取用戶資訊時：
        - 如果用戶數據存在（成功獲取用戶資訊），則會進入到主界面，並傳遞 userDetails。
        - 如果用戶數據不存在（獲取用戶資訊失敗），顯示錯誤資訊。）
 
    * 藉此確保在用戶首次通過 Google 登入、註冊時，正確存取用戶資訊，並在之後每次登入時能夠正確獲取用戶資訊，而不會重複建立或覆蓋已有資訊。
        -  GoogleSignInController：負責處理所有 Google 登入相關的邏輯。
        -  FirebaseController：負責處理 Firebase 認證和使用者資料相關的邏輯。
        -  這樣的設計可以讓 GoogleSignInController 專注於 Google 登入，而 FirebaseController 則負責處理從 Firebase 獲取用戶資訊的邏輯。
 
 ---------------------------------------- ---------------------------------------- ----------------------------------------
 
 C_1. Google 登入流程：
    * 點擊 Google 登入按鈕：
        - 觸發 googleLoginButtonTapped。
    
    * 調用 GoogleSignInController 進行 Google 登入：
        - 在 googleLoginButtonTapped 中，調用 GoogleSignInController.shared.signInWithGoogle ，傳入目前的視圖控制器（presentingViewController）和一個完成的回調。
        - GoogleSignInController 負責處理 Google 登入邏輯。
    
    * Google登入介面：
        - GoogleSignInController 調用 GIDSignIn.sharedInstance.signIn(withPresenting:)，顯示 Google 登入介面，用戶可以選擇或輸入 Google 帳號進行登入。

    * 獲取 Google 登入結果：
        - 用戶完成登入後，Google 登入介面結束，GoogleSignInController 的完成回調被調用。
        - 如果登入成功 Google 返回用戶資訊、身份驗證Token。
 
    * 使用 Google 憑證登入 Firebase：
        - GoogleSignInController 使用 GoogleAuthProvider.credential(withIDToken:accessToken:) 建立一個 Firebase 憑證。
        - 使用 Auth.auth().signIn(with:) 將 Google 憑證傳遞給 Firebase 進行身份驗證。
 
    * 處理 Firebase 登入結果：
        - 如果 Firebase 登入成功，將調用完成回調，並傳遞 AuthDataResult 對象。
        - 在 googleLoginButtonTapped 的回調中，根據結果更新 UI。

    * 獲取用戶詳細資訊：
        - 如果登入成功，調用 FirebaseController.shared.getCurrentUserDetails 從 Firestore 獲取當前用戶的詳細資訊。
    
    * 更新 UI：
        - 根據獲取的用戶詳細資訊，調用 NavigationHelper.navigateToMainTabBar ，導航到主介面。
 */

// MARK: - 原版storyboard
/*
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
        
        ActivityIndicatorManager.shared.activityIndicator(on: view, backgroundColor: UIColor.black.withAlphaComponent(0.5))
    }
    
    
    /// 設置 UI 樣式
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
                case .success(_):
                    FirebaseController.shared.getCurrentUserDetails { userDetailsResult in
                        switch userDetailsResult {
                        case .success(let userDetails):
                            NavigationHelper.navigateToMainTabBar(from: self!, with: userDetails)   // 使用 NavigationHelper 登入成功後進入到 mainTabBarController
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



// MARK: - 視圖佈局分離版本
import UIKit
import FirebaseAuth


/// 登入介面
class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private let loginView = LoginView()
    
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpHideKeyboardOntap()
        setupActions()
        loadRememberedUser()
    }
    
    
    /// 設置 Action
    private func setupActions() {
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginView.googleLoginButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        loginView.appleLoginButton.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        loginView.rememberMeButton.addTarget(self, action: #selector(rememberMeButtonTapped(_:)), for: .touchUpInside)
        loginView.forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginView.setPasswordTextFieldIcon(target: self, action: #selector(togglePasswordVisibility))
    }

    // MARK: - 處理一般登入
    /// 處理登入按鈕點擊事件
    @objc private func loginButtonTapped() {
        // 確保電子郵件和密碼輸入不為空
        guard let email = loginView.emailTextField.text, !email.isEmpty,
              let password = loginView.passwordTextField.text, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請輸入電子郵件和密碼", inViewController: self)
            return
        }
        
        ActivityIndicatorManager.shared.startLoading(on: view, backgroundColor: UIColor.black.withAlphaComponent(0.5)) // 啟動活動指示器
        FirebaseController.shared.loginUser(withEmail: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                ActivityIndicatorManager.shared.stopLoading()               // 停止活動指示器
                switch result {
                case .success(_):
                    FirebaseController.shared.getCurrentUserDetails { userDetailsResult in
                        switch userDetailsResult {
                        case .success(let userDetails):
                            NavigationHelper.navigateToMainTabBar(from: self!, with: userDetails)   // 使用 NavigationHelper 登入成功後進入到 mainTabBarController
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
 
    
    // MARK: - 處理Google登入
    @objc private func googleLoginButtonTapped() {
        
        ActivityIndicatorManager.shared.startLoading(on: view, backgroundColor: UIColor.black.withAlphaComponent(0.5))

        GoogleSignInController.shared.signInWithGoogle(presentingViewController: self) { [weak self] result in
            DispatchQueue.main.async {
                ActivityIndicatorManager.shared.stopLoading()
                switch result {
                case .success(let authResult):
                    FirebaseController.shared.getCurrentUserDetails { userDetailsResult in
                        switch userDetailsResult {
                        case .success(let userDetails):                         // 登入成功，導航到主要頁面。
                            NavigationHelper.navigateToMainTabBar(from: self!, with: userDetails)
                            print(userDetails)
                        case .failure(let error):                              // 獲取使用者資訊失敗。
                            AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                        }
                    }
                    
                case .failure(let error):                                       // Google登入失敗
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
        }
    }
 
    
    // MARK: - 處理Apple登入
    @objc private func appleLoginButtonTapped() {
        ActivityIndicatorManager.shared.startLoading(on: view, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        
        AppleSignInController.shared.signInWithApple(presentingViewController: self) { [weak self] result in
            DispatchQueue.main.async {
                ActivityIndicatorManager.shared.stopLoading()
                switch result {
                case .success(let authResult):
                    FirebaseController.shared.getCurrentUserDetails { userDetailsResult in
                        switch userDetailsResult {
                        case .success(let userDetails):
                            NavigationHelper.navigateToMainTabBar(from: self!, with: userDetails)
                            print(userDetails)
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
    
    
    // MARK: - Private Methods

    /// 電子郵件和密碼保存到 Keychain
    @objc private func rememberMeButtonTapped(_ sender: UIButton) {
        guard let email = loginView.emailTextField.text, !email.isEmpty,
              let password = loginView.passwordTextField.text, !password.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請先輸入電子郵件和密碼", inViewController: self, completion: nil)
            return
        }
        
        sender.isSelected.toggle()
        UserDefaults.standard.set(sender.isSelected, forKey: "RememberMe")              // Save the user's selection to UserDefaults or other storage
        
        if sender.isSelected {
            if let email = loginView.emailTextField.text, let password = loginView.passwordTextField.text {
                KeychainManager.save(key: "userEmail", data: Data(email.utf8))
                KeychainManager.save(key: "userPassword", data: Data(password.utf8))
            }
        } else {
            KeychainManager.delete(key: "userEmail")
            KeychainManager.delete(key: "userPassword")
        }
    }
    
    /// 在 App 啟動時存取加載存取的用戶資訊
    private func loadRememberedUser() {
        if let remembered = UserDefaults.standard.value(forKey: "RememberMe") as? Bool, remembered {
            loginView.rememberMeButton.isSelected = true
            if let emailData = KeychainManager.load(key: "userEmail"), let passwordData = KeychainManager.load(key: "userPassword") {
                loginView.emailTextField.text = String(data: emailData, encoding: .utf8)
                loginView.passwordTextField.text = String(data: passwordData, encoding: .utf8)
            }
        }
    }
    
    /// 跳轉到 ForgotPasswordViewController
    @objc private func forgotPasswordButtonTapped() {
        NavigationHelper.navigateToForgotPassword(from: self)
    }
    
    
    /// 跳轉到 SignUpViewController
    @objc private func signUpButtonTapped() {
        NavigationHelper.navigateToSignUp(from: self)
    }
    
    /// 切換密碼顯示狀態
    @objc private func togglePasswordVisibility() {
        loginView.passwordTextField.isSecureTextEntry.toggle()
        let eyeImageName = loginView.passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        if let eyeButton = loginView.passwordTextField.rightView as? UIButton {
            eyeButton.setImage(UIImage(systemName: eyeImageName), for: .normal)
        }
    }
    
}




