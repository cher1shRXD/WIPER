//
//  SplashView.swift
//  wiper
//
//  Created by cher1shRXD on 5/28/25.
//
import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("WIPER")
                .font(.system(size: 36, weight: .black))
            ProgressView()
            Spacer()
        }
    }
}
