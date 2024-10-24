//
//  ForgotPasswordViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//


// MARK: - 整理
/*
import UIKit

/// 忘記密碼頁面
class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Properties
    private let forgotPasswordView = ForgotPasswordView()
    

    // MARK: - Lifecycle Methods
    override func loadView() {
        view = forgotPasswordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpHideKeyboardOntap()
        setupCloseButton()
        setupActions()
    }
    
    // MARK: - Setup Methods
    
    /// 設置導航欄的關閉按鈕
    private func setupCloseButton() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    /// 設置 重置密碼按鈕 和 回到 Login 頁面 按鈕的動作
    private func setupActions() {
        forgotPasswordView.resetPasswordButton.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .touchUpInside)
        forgotPasswordView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    // MARK: - Action Methods

    /// 處理重置密碼按鈕點擊
    @objc func resetPasswordButtonTapped() {
        // 確保電子郵件輸入不為空
        guard let email = forgotPasswordView.emailTextField.text, !email.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫您的信箱", inViewController: self)
            return
        }
        
        // 檢查電子郵件格式是否有效
        if !EmailSignInController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "無效的電子郵件格式", inViewController: self)
            return
        }
        
        HUDManager.shared.showLoading(text: "Sending...")
        // 使用 EmailSignInController 發送密碼重置郵件
        EmailSignInController.shared.resetPassword(forEmail: email) { [weak self] result in
            DispatchQueue.main.async {
                HUDManager.shared.dismiss()
                switch result {
                case .success():
                    // 發送成功，顯示成功訊息
                    print("Password reset email sent successfully")
                    AlertService.showAlert(withTitle: "通知", message: "如果您的信箱已註冊，我們將發送密碼重置郵件給您。", inViewController: self!) {
                        // 關閉模態視圖控制器
                        self?.dismiss(animated: true, completion: nil)
                    }
                case .failure(let error):
                    // 發送失敗，顯示錯誤信息
                    print("Error sending password reset email: \(error.localizedDescription)")
                    AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self!)
                }
            }
            
        }
    }
    
    /// 跳轉回到 LoginViewController
    @objc private func loginButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 處理關閉按鈕點擊事件
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}
*/


// MARK: - 整理（async/await）

import UIKit

/// 忘記密碼頁面
class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Properties
    private let forgotPasswordView = ForgotPasswordView()
    

    // MARK: - Lifecycle Methods
    override func loadView() {
        view = forgotPasswordView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCloseButton()
        setupActions()
    }
    
    // MARK: - Setup Methods
    
    /// 設置導航欄的關閉按鈕
    private func setupCloseButton() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    /// 設置 重置密碼按鈕 和 回到 Login 頁面 按鈕的動作
    private func setupActions() {
        forgotPasswordView.resetPasswordButton.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .touchUpInside)
        forgotPasswordView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    // MARK: - Action Methods
    
    /// 處理重置密碼按鈕點擊
    @objc func resetPasswordButtonTapped() {
        Task {
            // 確保電子郵件輸入不為空
            guard let email = forgotPasswordView.emailTextField.text, !email.isEmpty else {
                AlertService.showAlert(withTitle: "錯誤", message: "請填寫您的信箱", inViewController: self)
                return
            }
            
            // 檢查電子郵件格式是否有效
            if !EmailSignInController.isEmailvalid(email) {
                AlertService.showAlert(withTitle: "錯誤", message: "無效的電子郵件格式", inViewController: self)
                return
            }
            
            HUDManager.shared.showLoading(text: "Sending...")
            do {
                // 使用 EmailSignInController 發送密碼重置郵件
                try await EmailSignInController.shared.resetPassword(forEmail: email)
                
                // 發送成功，顯示成功訊息
                print("Password reset email sent successfully")
                AlertService.showAlert(withTitle: "通知", message: "如果您的信箱已註冊，我們將發送密碼重置郵件給您。", inViewController: self) {
                    // 關閉模態視圖控制器
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                // 發送失敗，顯示錯誤信息
                print("Error sending password reset email: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "錯誤", message: error.localizedDescription, inViewController: self)
            }
            
            HUDManager.shared.dismiss()
        }
    }
    
    /// 跳轉回到 LoginViewController
    @objc private func loginButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 處理關閉按鈕點擊事件
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}
