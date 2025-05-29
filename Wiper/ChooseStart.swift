//
//  ChooseStart.swift
//  wiper
//
//  Created by cher1shRXD on 5/28/25.
//

import SwiftUI
import SwiftUIMasonry

struct ChooseStart: View {
    @StateObject private var viewModel = PhotoViewModel()
    
    var body: some View {
        VStack(spacing: 4){
            HStack {
                Text("WIPER")
                    .font(.system(size: 32, weight: .black))
                Spacer()
            }
            ScrollView(showsIndicators: false){
                
                HStack {
                    Text("시작 지점을 선택해주세요.")
                        
                    Spacer()
                }
                
                if viewModel.isLoading || viewModel.photoItems.isEmpty {
                    ProgressView()
                }
                
                Masonry(.vertical, lines: 3, spacing: 4){
                    ForEach(Array(viewModel.photoItems.enumerated()), id: \.element.id) { idx, item in
                        let asset = item.asset
                        Button {
                            UserDefaults.standard.set(idx, forKey: "startPoint")
                        } label: {
                            AssetImage(asset: asset)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 160)
                
            }
        }
        .padding(.horizontal)
    }
}
