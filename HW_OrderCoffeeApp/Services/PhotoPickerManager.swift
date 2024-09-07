//
//  PhotoPickerManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/22.
//

/*
 A. 使用 PHPickerViewController 和 UIImagePickerController 來處理用戶的照片選擇或拍攝照片。
 
    1. 處理照片選擇邏輯：
        - 使用 PHPickerViewController 來讓用戶從相簿中選擇照片。
        - 使用 UIImagePickerController 來讓用戶使用相機拍攝照片（如果設備支持）。
        - 在選擇或拍攝照片後，將圖片傳回 UserProfileViewController 以便後續處理。
    
    2. 錯誤處理與用戶體驗：
        - 如果設備不支持相機或用戶未授權訪問相機，顯示適當的警告信息。
        - 在照片選擇或拍攝過程中顯示活動指示器，提升用戶體驗。
    
    3.  照片上傳等網路操作：
        * 當進行照片上傳或資料保存等涉及網路的異步操作時，應在 EditProfileViewController 等處啟動活動指示器（如 HUDManager ），以便用戶知道操作正在進行。
            - 當用戶在 EditProfileViewController 中選擇完照片並開始上傳時，顯示活動指示器。
            - 在上傳完成或失敗後，停止活動指示器，並根據結果顯示相應的訊息。
 
        *  與照片選擇無關：
            - 照片選擇本身不需要任何活動指示器，因為它只涉及本地的相簿或相機操作，且是即時的，不涉及耗時的網路處理。
 */

import UIKit
import PhotosUI

/// `PhotoPickerManager` 用於處理照片的選擇和上傳管理。
/// 它支持從「相簿選擇圖片」以及「使用相機拍攝照片」。
class PhotoPickerManager: NSObject, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    private weak var viewController: UIViewController?
    private var completion: ((UIImage?) -> Void)?
    
    // MARK: - Initializer
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Public Methods

    /// 顯示選擇照片的選項，包括從相簿選擇或使用相機拍攝
    /// - Parameter completion: 回調函數，當選擇或拍攝照片後調用並返回選中的圖片
    func presentPhotoOptions(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
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
    
    // MARK: - Private Methods

    /// 顯示相機，允許用戶拍攝照片
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

// MARK: - UIImagePickerControllerDelegate
extension PhotoPickerManager: UIImagePickerControllerDelegate {
    
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
