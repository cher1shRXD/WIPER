//
//  WipeView.swift
//  wiper
//
//  Created by cher1shRXD on 5/28/25.
//

import SwiftUI

struct WipeView: View {
    @StateObject private var viewModel = PhotoViewModel()
    @State var isProcessing: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("WIPER")
                    .font(.system(size: 32, weight: .black))
                Spacer()
            }
            
            Spacer(minLength: 8)
            
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("사진을 불러오는 중...")
                        .font(.title3)
                }
                .padding(40)
            } else if viewModel.photoItems.count - viewModel.currentIndex == 0 {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("모든 사진을 정리했어요!")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .padding()
            } else {
                if viewModel.currentIndex < viewModel.photoItems.count {
                    SwipePhotoCard(
                        item: viewModel.photoItems[viewModel.currentIndex],
                        getImage: viewModel.getImage,
                        onSwiped: { direction in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if direction == .left {
                                    viewModel.keepCurrentPhoto()
                                } else {
                                    viewModel.deleteCurrentPhoto()
                                }
                            }
                        },
                        isInteractive: true
                    )
                    .id(viewModel.photoItems[viewModel.currentIndex].id)
                }
            }
            
            Spacer(minLength: 8)
            
            HStack{
                Text("남은 사진: \(viewModel.photoItems.count - viewModel.currentIndex)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            
            Button{
                isProcessing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.realDelete()
                }
            } label: {
                HStack{
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("그만하기")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
            
        }
        .padding(.horizontal)
    }
}
