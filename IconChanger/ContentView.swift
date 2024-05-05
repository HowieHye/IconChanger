//
//  ContentView.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/4/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject var folderPermission = FolderPermission.shared
    @StateObject var iconManager = IconManager.shared
    @AppStorage("helperToolVersion") var helperToolVersion = 0
    
    var body: some View {
        if folderPermission.hasPermission {
            IconList()
                .task {
                    if helperToolVersion < Config.helperToolVersion {
                        if #available(macOS 13.0, *) {
                            try? await Task.sleep(until: .now + .seconds(1), clock: .suspending)
                        } else {
                            try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                        }

                        do {
                            try iconManager.installHelperTool()
                            helperToolVersion = Config.helperToolVersion
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
        } else {
            VStack {
                Text("We Need Access to /Applications")
                        .font(.largeTitle.bold())
                        .padding()

                VStack(alignment: .leading) {
                    Text("1. A dialog will appear requesting access to /Applications")
                    Text("2. Please choose /Applications and click OK")
//                    TODO: APP 管理的权限
                }
                        .multilineTextAlignment(.leading)

                Button("Request Access") {
                    folderPermission.check()
                }
                        .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension NSWorkspace {

    enum SystemServiceType: String {
        case privacy = "x-apple.systempreferences:com.apple.preference.security?Privacy"
        case camera = "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera"
        case microphone = "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
        case location = "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"
        case contacts = "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts"
        case calendars = "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
        case reminders = "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders"
        case photos = "x-apple.systempreferences:com.apple.preference.security?Privacy_Photos"
        case fullDisk = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
    }

    func openLocationService(for type: SystemServiceType) {
        let url = URL(string: type.rawValue)!
        NSWorkspace.shared.open(url)
    }
}
