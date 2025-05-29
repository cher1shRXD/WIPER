import Foundation
import SwiftUI
import Photos
import PhotosUI

class PhotoViewModel: ObservableObject{
    @Published var currentIndex = 0
    @Published var isLoading = true
    @Published var photoItems: [PhotoItem] = []
    @AppStorage("startPoint") private var startPoint: Int?

    private let imageManager = PHImageManager.default()
    
    init() {
        if let idx = startPoint {
            currentIndex = idx
        }
        requestPhotosAccess()
    }
    
    func requestPhotosAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                self.isLoading = true
                if status == .authorized || status == .limited {
                    self.fetchPhotos()
                } else {
                    print("사진 접근 권한이 필요합니다.")
                }
            }
        }
    }
    
    func getImage(for asset: PHAsset, targetSize: CGSize = CGSize(width: 600, height: 600), completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    func keepCurrentPhoto() {
        guard currentIndex < self.photoItems.count else { return }
        moveToNextPhoto()
    }
    
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        DispatchQueue.main.async {
            self.photoItems = assets.objects(at: IndexSet(0..<assets.count)).map { PhotoItem(asset: $0) }
            self.isLoading = false
        }
    }

    func deleteCurrentPhoto() {
        guard currentIndex < self.photoItems.count else { return }
        PhotoStore.shared.deletedItems.append(self.photoItems[currentIndex])
        moveToNextPhoto()
    }
    
    func realDelete() {
        let assetsToDelete = PhotoStore.shared.deletedItems.map { $0.asset }
        if !assetsToDelete.isEmpty {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("삭제 완료")
                    } else {
                        print("삭제 실패: \(error?.localizedDescription ?? "알 수 없음")")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.startPoint = nil
                    PhotoStore.shared.deletedItems.removeAll()
                    self.photoItems.removeAll()
                }
                
                
            }
        } else {
            DispatchQueue.main.async {
                self.startPoint = nil
                PhotoStore.shared.deletedItems.removeAll()
                self.photoItems.removeAll()
            }
        }
        
        
        
    }
    
    
    private func moveToNextPhoto() {
        currentIndex += 1
        startPoint = currentIndex
        
        if currentIndex >= self.photoItems.count {
            realDelete()
        }
    }

}
