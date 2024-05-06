//
//  AboutView.swift
//  IconChanger
//
//  Created by Hugh on 2024/5/6.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image("IconChanger")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .shadow(radius: 10)
            Text("IconChanger")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text("Simply change your app's icon on macOS. Just a click.")
                .multilineTextAlignment(.center)
            Text("Created by [underthestars-zhy](https://github.com/underthestars-zhy)")
            Text("Modified by [HowieHye](https://github.com/HowieHye)")
        }
        .padding()
        .animation(.easeInOut, value: 1)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
