//
//  GoogleSignInController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/20.
//

/*
 
 當初最一開始的寫法只有處理登入部分，沒注意到因為登入與註冊在這部分是一樣的概念，所以必須存取用戶資料到 userDetails 裡面。導致找不到使用者資料。
 那這樣每次登入就等於再次註冊嗎？那這樣會不會影響到使用者的資料呢？
 
 
 1. 原先的寫法只處理了登入部分，沒注意到對於 Google 登入，註冊和登入實際上是使用相同的邏輯。
    * 由於 Google 登入後，Firebase 會自動建立用戶帳號，因此需要確保在首次登入時將用戶資料存取到 Firestore 中，這樣在之後獲取用戶資料時就不會出現「User data not found」。
    * 已經使用了 merge: true，代表在用戶每次登入時，新的用戶資料會被合併到現有的資料中，而不是整個覆蓋。因此，這不會影響到用戶的現有資料，除非明確的在 setData 中覆蓋。
 
 2. 結論：
    * 登入、註冊基本上是相同的邏輯。
    * 需要確保在首次登入時將用戶資料存取到 Firestore 中。
    * 使用 merge: true 可以防止每次登入覆蓋現有的用戶資料。
    * 這樣就能確保用戶資料在首次登入時被正確存取，並且不會在每次登入時被覆蓋，從而不會影響用戶的現有資料。
 */



import UIKit
import Firebase
import GoogleSignIn

/// 處理 Google 相關部分
class GoogleSignInController {
    
    static let shared = GoogleSignInController()
    
    /// 使用google 登入 或 註冊
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "GoogleSignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google sign-in failed."])))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let authResult = authResult {
                    self.storeGoogleUserData(authResult: authResult) { result in
                        switch result {
                        case .success:
                            completion(.success(authResult))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    
    /// 存取 Google 使用者資料
    private func storeGoogleUserData(authResult: AuthDataResult, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let user = authResult.user
        let userRef = db.collection("users").document(user.uid)
        
        userRef.setData([
            "uid": user.uid,
            "email": user.email ?? "",
            "fullName": user.displayName ?? ""
        ], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
}



