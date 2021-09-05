//  answerItApp.swift
//  answerIt
//  Created by admin on 2021/8/29.
import SwiftUI
@main
struct answerItApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var data = datauser()
    var body: some Scene {
        WindowGroup {
                        
            if isLaunchedFirstTime() {
                firstPageGettingName()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(data)

            }else {
                secondPage()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(data)

            }
            
            
        }
    }
    
    func isLaunchedFirstTime()->Bool{
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore{
            return false
        }else{
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            return true
       }
    }
}
