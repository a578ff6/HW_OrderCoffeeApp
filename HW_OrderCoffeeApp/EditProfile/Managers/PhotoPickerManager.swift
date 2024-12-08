//
//  PhotoPickerManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/22.
//


// MARK: - 筆記：PhotoPickerManager
/**
 
 ## 筆記：PhotoPickerManager
 
 `* What`
 
 `1.核心功能：`

 - 支持用戶從「相簿」選取照片或「使用相機」拍攝照片。
 - 通過回調返回選取或拍攝的圖片，便於在控制器中處理。
 
 `2.模組職責：`

 - `選項表單`：顯示選擇方式（相簿或相機）。
 - `照片選擇器`：調用 `PHPickerViewController` 顯示相簿選擇界面。
 - `相機功能`：調用 `UIImagePickerController` 顯示相機界面。
 
 `3.錯誤處理：`

 - 當裝置不支持相機時，顯示提示。
 - 當用戶取消選擇或未選取有效圖片時，回傳 nil。
 
 ---------------------------
 
 `* Why`
 
 `1.提升代碼模組化：`

 - 將照片選擇邏輯從控制器分離，提高代碼的清晰度和可復用性。
 
 `2.統一錯誤處理：`

 - 確保裝置功能限制（如無相機）或操作失敗（如無效選取）時用戶能獲得明確的反饋。
 
 `3.簡化控制器：`

 - 控制器只需調用 presentPhotoOptions 並處理返回的圖片，減少不必要的業務邏輯。
 
 ---------------------------

 `* How`
 
 `1.初始化與依附：`

 - 初始化時，綁定需要顯示照片選擇界面的 UIViewController。
 
 `2.使用流程：`

 - 調用 `presentPhotoOptions` 方法，顯示選項表單。
 - 用戶選擇「相簿」或「相機」後，對應的界面被顯示。
 - 選擇或拍攝完成後，通過回調返回圖片。
 
 `3.內部邏輯：`

 - `相簿選擇`：使用 PHPickerViewController 獲取用戶選擇的圖片。
 - `相機拍攝`：使用 UIImagePickerController 拍攝照片。
 - `回調處理`：圖片選擇或拍攝完成後，通過閉包傳回。
 
 ---------------------------

 `* 總結`

 1.`PhotoPickerManager` 透過 `presentPhotoOptions() `方法顯示照片選擇選項，包括從相簿選擇及使用相機拍攝。
 2.`presentPhotoOptionsSheet() `方法使用 `UIAlertController` 來讓用戶選擇從相簿或相機獲取照片。
 3.`presentCamera() `方法負責顯示相機視圖，檢查裝置是否支援相機，如果不支援則顯示警告。
 4.`presentPhotoPicker()` 方法顯示照片選擇器，允許用戶從相簿中挑選照片。
 5.當用戶完成照片選擇或拍攝後，透過 `PHPickerViewControllerDelegate` 和 `UIImagePickerControllerDelegate` 將圖片回傳給 `completion` 回調函數，供外部使用。
 */




import UIKit
import PhotosUI

/// `PhotoPickerManager` 負責處理用戶的照片選擇行為，支持以下功能：
/// - 從「相簿」選擇圖片。
/// - 使用「相機」拍攝照片。
/// - 提供回調函數返回選取或拍攝的圖片。
/// - 容錯處理：當裝置不支持相機或圖片選取過程中出錯時，提供相應的提示。
class PhotoPickerManager: NSObject {
    
    // MARK: - Properties
    
    /// 父視圖控制器，負責呈現照片選擇器和相機。
    private weak var viewController: UIViewController?
    
    /// 當用戶選擇或拍攝照片後的回調，返回選中的圖片
    private var completion: ((UIImage?) -> Void)?
    
    // MARK: - Initializer
    
    /// 初始化方法，設置需要依附的視圖控制器
    /// - Parameter viewController: 父視圖控制器，用於顯示相簿選擇或相機
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Public Methods
    
    /// 顯示照片選擇器選項，包括從相簿選擇或使用相機拍攝
    /// - Parameter completion: 回調函數，當選擇或拍攝照片後調用並返回選中的圖片
    func presentPhotoOptions(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        presentPhotoOptionsSheet()
    }
    
    // MARK: - Private Methods

    /// 顯示選項表單，讓用戶選擇從相簿選取或拍攝照片
    private func presentPhotoOptionsSheet() {
        let alert = UIAlertController(title: "選擇照片", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "從相簿選擇", style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))
        
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
            self.presentCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        viewController?.present(alert, animated: true, completion: nil)
    }
    
    /// 顯示相機，讓用戶拍攝照片
    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            AlertService.showAlert(withTitle: "警告", message: "您的裝置不支援相機", inViewController: viewController!)
            return
        }
        
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.delegate = self
        viewController?.present(camera, animated: true, completion: nil)
    }

    /// 顯示照片選擇器，允許用戶從相簿中選擇照片
    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController?.present(picker, animated: true, completion: nil)
    }
    
}

// MARK: - PHPickerViewControllerDelegate
extension PhotoPickerManager: PHPickerViewControllerDelegate {
    
    /// 當用戶完成照片選擇時調用，處理選擇的圖片
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
            completion?(nil)
            return
        }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            DispatchQueue.main.async {
                if let selectedImage = image as? UIImage {
                    self?.completion?(selectedImage)
                } else {
                    self?.completion?(nil)
                }
            }
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension PhotoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 當用戶完成拍攝或選擇照片時調用，處理拍攝的圖片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        completion?(image)
    }
    
    /// 當用戶取消拍攝或選擇照片時調用
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


