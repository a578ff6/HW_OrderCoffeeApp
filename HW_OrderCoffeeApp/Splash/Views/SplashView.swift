//
//  SplashView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/4.
//

// MARK: - SplashView 筆記
/**
 
 ## SplashView 筆記
 
 `* What`
 
 - `SplashView` 是一個專門負責顯示 **啟動畫面動畫** 的 `UIView`。
 - 它封裝了 **UI 設定與動畫播放邏輯**，讓 `SplashViewController` **不需要直接管理 UI**。

 - 在專案中，`SplashView` 的主要角色是：
 
    - 顯示 Lottie 動畫，確保啟動畫面體驗流暢。
    - 封裝 UI 設定與動畫播放邏輯，避免 `SplashViewController` 變得過於肥大。
    - 提供 `playAnimation(completion:)` 方法，讓 `SplashViewController` 能夠在動畫結束後執行後續動作（例如切換至 `HomePageViewController`）。

 ---------

 `* Why`
 
 - 在 `SplashViewController` 內直接管理 Lottie 動畫與 UI 佈局雖然可行，但這會導致 ViewController 承擔過多責任，影響可讀性與可維護性。

 1. 符合單一職責原則（SRP）
 
    - `SplashViewController` **應該專注於動畫的控制與業務邏輯**，而 `SplashView` 則專門負責 UI。
    - 將 UI 相關的邏輯獨立於 `UIView`，讓 `ViewController` 保持精簡，符合 MVC 架構設計。

 2. 提升可讀性與可維護性
 
    - 當 UI 變更時，只需要修改 `SplashView`，而不影響 `SplashViewController`。
    - `SplashViewController` 只負責調用 `playAnimation(completion:)`，減少不必要的 UI 設定代碼。

 3. 提升可測試性
 
    - `SplashViewController` 只需要測試 **動畫控制與轉場邏輯**，不需要關心 UI。
    - `SplashView` 可獨立測試 **Lottie 動畫的顯示與約束設定**，確保 UI 正確。

 ---------

 `* How`

 1. `SplashViewController` 如何使用 `SplashView`
 
    - 在 `SplashViewController` 內，透過 `loadView()` 來設定 `SplashView` 作為主要畫面，並觸發動畫播放。

     ```swift
     import UIKit

     class SplashViewController: UIViewController {
         
         private let splashView = SplashView()
         
         override func loadView() {
             self.view = splashView
         }
         
         override func viewDidLoad() {
             super.viewDidLoad()
             playAnimation()
         }
         
         private func playAnimation() {
             splashView.playAnimation { [weak self] in
                 self?.navigateToMainApp()
             }
         }
         
         /// `navigateToMainApp` 負責畫面轉場，通知 `SceneDelegate`
         private func navigateToMainApp() {
             guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                 return
             }
             sceneDelegate.switchToHomePageNavigation()
         }
         
     }
     ```

 ---------

 `* 總結`
 
 1.`SplashView` 讓 `SplashViewController` 更輕量化，不再需要直接處理 UI 設定。
 2. 符合單一職責原則（SRP），`SplashViewController` 負責邏輯，`SplashView` 負責 UI。
 3. 提高可測試性，可以獨立測試 `SplashView` 的 UI 佈局與動畫行為。
 4. 更好的可擴展性，未來如果要更改動畫或 UI，只需修改 `SplashView`，不影響 `SplashViewController`。

 */




// MARK: - (v)

import UIKit
import Lottie

/// SplashView
///
/// - 是啟動畫面專用的視圖，負責顯示 Lottie 動畫。
/// - 它封裝了 UI 設定與動畫播放邏輯，確保 SplashViewController 只專注於業務邏輯與動畫控制。
class SplashView: UIView {

    
    // MARK: - UI Elements

    /// `LottieAnimationView` 負責播放啟動畫面動畫
    private let starbucksAnimationView = LottieAnimationView(name: "StarbucksSplashAnimation")
    
    
    // MARK: - Initializers

    /// 自定義初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup Methods

    /// 設定視圖的基本屬性與動畫參數
    private func setupView() {
        backgroundColor = .deepGreen
        starbucksAnimationView.contentMode = .scaleAspectFit
        starbucksAnimationView.loopMode = .playOnce
        starbucksAnimationView.animationSpeed = 1.0
        
        addSubview(starbucksAnimationView)
        starbucksAnimationView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// 設定 `LottieAnimationView` 的 Auto Layout 約束，使動畫置中顯示
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            starbucksAnimationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            starbucksAnimationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            starbucksAnimationView.widthAnchor.constraint(equalToConstant: 280),
            starbucksAnimationView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    
    // MARK: - Public Method

    /// 播放 Lottie 動畫，並在動畫播放結束後執行回調
    ///
    /// - Parameter completion: 動畫播放結束時執行的閉包
    func playAnimation(completion: @escaping () -> Void) {
        starbucksAnimationView.play { finished in
            if finished {
                completion()
            }
        }
    }

}
