//
//  PhotoStore.swift
//  Wiper
//
//  Created by cher1shRXD on 5/29/25.
//
import Foundation
import Photos

struct PhotoItem: Identifiable {
    let id = UUID()
    let asset: PHAsset
}

class PhotoStore {
    static let shared = PhotoStore()
    var deletedItems: [PhotoItem] = []
    private init() {}
}
