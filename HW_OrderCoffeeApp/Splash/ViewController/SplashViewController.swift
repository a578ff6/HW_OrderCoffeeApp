//
//  SplashViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2025/2/3.
//


// MARK: - SplashViewController 筆記
/**
 
 ## SplashViewController 筆記
 
 `* What`
 
 - `SplashViewController` 是應用程式的 **啟動畫面控制器**，負責顯示 `SplashView` 並控制動畫播放。
 - 它的主要職責是 **顯示動畫並在播放結束後執行畫面切換邏輯**，確保應用啟動時有流暢的過渡體驗。

 - 在專案中，`SplashViewController` 負責：
 
    - 設定 `SplashView` 作為主視圖，確保 UI 與邏輯分離。
    - 觸發 Lottie 動畫播放，並在播放完畢後切換至主畫面。
    - 透過 `SplashViewModel` 執行畫面切換，避免 `ViewController` 直接處理 `rootViewController` 變更，保持單一職責。

 -------

 `* Why`
 
 - 若不使用 `SplashViewController`，啟動畫面邏輯可能會與其他業務邏輯混合在 `AppDelegate` 或 `SceneDelegate` 中，影響可讀性與可維護性。
 - 透過 `SplashViewController`，可以獲得以下優勢：

 1. 符合單一職責原則（SRP）
 
    - `SplashViewController` **只專注於啟動畫面的動畫播放與畫面切換**，不負責 UI 細節或應用層邏輯。
    - `SplashView` **專門負責 UI 顯示**，`SplashViewModel` 負責 `rootViewController` 切換，確保 MVC 架構清晰。

 2. 提升可讀性與可維護性
 
    - `SplashViewController` 不直接控制動畫，而是呼叫 `SplashView.playAnimation()` 來播放動畫。
    - `SplashViewModel` 負責 `rootViewController` 的切換，未來若有登入流程或其他變更，只需修改 `ViewModel`。

 3. 提升可測試性
 
    - `SplashViewController` 只需要測試 **動畫觸發與畫面切換邏輯**，而 UI 測試可由 `SplashView` 單獨負責。
    - **避免 `SceneDelegate` 直接處理 `rootViewController` 變更**，確保程式碼更模組化。

 4. 符合 iOS UIKit 設計模式
 
    - `SplashViewController` 作為 `UIViewController`，負責 **管理視圖與用戶互動**，符合 UIKit 設計原則。
    - 透過 `loadView()` 設定 `SplashView`，讓 UI 變更更獨立。

 -------

 `* How`

 1.`SplashViewController` 設定 `SplashView` 作為主視圖
 
    - `loadView()` 會將 `SplashView` 設為 `SplashViewController` 的主視圖，確保 `ViewController` 內不直接處理 UI。

     ```swift
     import UIKit

     class SplashViewController: UIViewController {
         
         /// `SplashViewModel` 負責處理畫面切換邏輯
         private let splashViewModel = SplashViewModel()
         
         /// `SplashView` 負責 UI 顯示與動畫播放
         private let splashView = SplashView()
         
         /// 設定 `SplashView` 作為主視圖
         override func loadView() {
             self.view = splashView
         }
         
         /// `viewDidLoad()` 觸發動畫播放
         override func viewDidLoad() {
             super.viewDidLoad()
             playAnimation()
         }
         
         /// 觸發 `SplashView` 的動畫播放，並在動畫結束後切換至主畫面
         private func playAnimation() {
             splashView.playAnimation { [weak self] in
                 self?.splashViewModel.switchToMainApp()
             }
         }
     }
     ```

 ---

 2.`SplashViewModel` 處理畫面切換邏輯
 
    - 在動畫播放完成後，`SplashViewModel` 透過 `SceneDelegate` 切換 `rootViewController`。

     ```swift
     class SplashViewModel {
         func switchToMainApp() {
             guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                 return
             }
             
             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let homeVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.homePageViewController)
             let navigationController = UINavigationController(rootViewController: homeVC)
             
             sceneDelegate.switchToViewController(navigationController)
         }
     }
     ```

 ---

 3. `SplashView` 專門負責 UI 與動畫
 
    - 為了讓 `SplashViewController` 更輕量化，Lottie 動畫與 UI 設定都封裝在 `SplashView`。

     ```swift
     class SplashView: UIView {
         
         private let starbucksAnimationView = LottieAnimationView(name: "StarbucksSplashAnimation")
         
         override init(frame: CGRect) {
             super.init(frame: frame)
             setupView()
             setupConstraints()
         }
         
         required init?(coder: NSCoder) {
             super.init(coder: coder)
             fatalError("init(coder:) has not been implemented")
         }
         
         private func setupView() {
             backgroundColor = .deepGreen
             starbucksAnimationView.contentMode = .scaleAspectFit
             starbucksAnimationView.loopMode = .playOnce
             starbucksAnimationView.animationSpeed = 1.0
             
             addSubview(starbucksAnimationView)
             starbucksAnimationView.translatesAutoresizingMaskIntoConstraints = false
         }
         
         private func setupConstraints() {
             NSLayoutConstraint.activate([
                 starbucksAnimationView.centerXAnchor.constraint(equalTo: centerXAnchor),
                 starbucksAnimationView.centerYAnchor.constraint(equalTo: centerYAnchor),
                 starbucksAnimationView.widthAnchor.constraint(equalToConstant: 280),
                 starbucksAnimationView.heightAnchor.constraint(equalToConstant: 280)
             ])
         }
         
         func playAnimation(completion: @escaping () -> Void) {
             starbucksAnimationView.play { finished in
                 if finished {
                     completion()
                 }
             }
         }
     }
     ```

 -------

` * 總結`
 
 1.`SplashViewController` 負責顯示動畫與畫面切換，但不直接處理 UI。
 2. 符合 MVC 架構，讓 `SplashView` 處理 UI，`SplashViewModel` 負責轉場。
 3. 提升可讀性與可維護性，讓 `SplashViewController` 更精簡。
 4. 更好的可測試性，動畫邏輯與 UI 測試分離，提高測試覆蓋率。

 這樣的架構讓 `SplashViewController`、`SplashViewModel` 和 `SplashView` 各司其職。
 */



// MARK: - (v)

import UIKit

/// `SplashViewController` 負責管理啟動畫面邏輯
///
/// - 主要職責是顯示 `SplashView`，並在動畫播放完畢後執行轉場邏輯。
/// - 透過 `SplashViewModel` 來切換 `rootViewController`，避免 `ViewController` 直接處理畫面轉換。
/// - 使用 `loadView()` 設定 `SplashView` 作為主視圖。
class SplashViewController: UIViewController {
    
    // MARK: - UI Components

    /// `SplashViewModel` 負責處理畫面切換邏輯
    private let splashViewModel = SplashViewModel()
    
    /// `SplashView` 負責 UI 顯示與動畫播放
    private let splashView = SplashView()
    
    // MARK: - Lifecycle Methods

    /// 設定 `SplashView` 作為主視圖
    override func loadView() {
        self.view = splashView
    }
    
    /// `viewDidLoad()` 觸發動畫播放
    override func viewDidLoad() {
        super.viewDidLoad()
        playAnimation()
    }
    
    // MARK: - Private Method
    
    /// 觸發 `SplashView` 的動畫播放，並在動畫結束後切換至主畫面
    private func playAnimation() {
        splashView.playAnimation { [weak self] in
            self?.splashViewModel.switchToMainApp()
        }
    }
    
}
