//
//  SettingView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/28.
//  Modified by seril on 2023/7/25.
//

import SwiftUI
import Cocoa

struct SettingsView: View {
    var body: some View {
        TabView {
            ApplicationSettingsView()
                    .tabItem {
                        Label("Applications", systemImage: "app")
                    }
            APISettingsView()
                .tabItem {
                    Label("API", systemImage: "bolt")
                }
        }
                .padding()
                .frame(width: 500, height: 400)
    }
}

#Preview {
    SettingsView()
}
