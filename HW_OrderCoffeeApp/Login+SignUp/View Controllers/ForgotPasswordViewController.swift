//
//  ForgotPasswordViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit

/// 忘記密碼頁面
class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        setUpHideKeyboardOntap()
        ActivityIndicatorManager.shared.activityIndicator(on: view)
    }
    
    
    /// 設置 UI 元件的樣式
    func setUpElements() {
        emailTextField.styleTextField()
        resetPasswordButton.styleFilledButton()
    }
    
    
    /// 處理重置密碼按鈕點擊
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        // 確保電子郵件輸入不為空
        guard let email = emailTextField.text, !email.isEmpty else {
            AlertService.showAlert(withTitle: "錯誤", message: "請填寫您的信箱", inViewController: self)
            return
        }
        
        // 檢查電子郵件格式是否有效
        if !FirebaseController.isEmailvalid(email) {
            AlertService.showAlert(withTitle: "錯誤", message: "無效的電子郵件格式", inViewController: self)
            return
        }
        
        ActivityIndicatorManager.shared.startLoading()      // 啟動活動指示器
        
        // 使用 FirebaseController 發送密碼重置郵件
        FirebaseController.shared.resetPassword(forEmail: email) { [weak self] result in
            DispatchQueue.main.async {
                
                ActivityIndicatorManager.shared.stopLoading()            // 停止活動指示器
                
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
    

    

}
