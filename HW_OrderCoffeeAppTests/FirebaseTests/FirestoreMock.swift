//
//  FirestoreMock.swift
//  HW_OrderCoffeeAppTests
//
//  Created by 曹家瑋 on 2024/8/13.
//

import Firebase

// MARK: - 用來模擬 Firestore 的文檔讀取行為
class FirestoreMock {
    var shouldReturnError = false       // 用來控制是否應該返回錯誤
    var documentData: [String: Any]?    // 模擬的文檔數據

    
    // 模擬獲取文檔的方法
    func getDocument(completion: @escaping (DocumentSnapshotMock?, Error?) -> Void) {
        if shouldReturnError {
            // 如果 shouldReturnError 為 true，返回一個模擬的錯誤
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            completion(nil, error)
        } else {
            // 否則返回一個模擬的文檔對象
            let document = DocumentSnapshotMock(data: documentData)
            completion(document, nil)
        }
    }
}


// MARK: - 用來模擬 Firestore 返回的文檔數據
class DocumentSnapshotMock {
    private let mockData: [String: Any]?        // 模擬的文檔數據
    
    var data: [String: Any]? {
        return mockData
    }
    
    init(data: [String: Any]?) {
        self.mockData = data
    }
}
