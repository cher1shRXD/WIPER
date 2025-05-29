import SwiftUI
import Photos
import PhotosUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoViewModel()
    @AppStorage("startPoint") private var startPoint: Int?
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.photoItems.isEmpty {
                SplashView()
            } else {
                if startPoint == nil {
                    ChooseStart()
                } else {
                    WipeView()
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isLoading)
    }
}
