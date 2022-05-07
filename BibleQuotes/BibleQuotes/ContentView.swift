//
//  ContentView.swift
//  BibleQuotes
//
//  Created by user217575 on 5/7/22.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    let notificationCenter = UNUserNotificationCenter.current()
    
    var body: some View {
        NavigationView{
            List {
                NavigationLink(destination: BibleQuoteView(dailyOrRandom: "daily")) {
                    Text("Daily quote").font(.headline)
                }
                
                NavigationLink(destination: BibleQuoteView(dailyOrRandom: "random")) {
                    Text("Random quote").font(.headline)
                }
                
                NavigationLink(destination: SpecificQuoteView()) {
                    Text("Get desired quote").font(.headline)
                }
                
                NavigationLink(destination: LastQuoteView()) {
                    Text("See last saved quote").font(.headline)
                }
            }
            .navigationBarTitle("Daily Bible quotes", displayMode: .large)
        }
        .onAppear() {
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { permissionGranted, error in
                if (!permissionGranted) {
                    print("Permission denied")
                    
                }
            }
            
            notificationCenter.getNotificationSettings { (settings) in
                if(settings.authorizationStatus == .authorized){
                    let content = UNMutableNotificationContent()
                    content.title = "Need some inspiration?"
                    content.body = "A new daily Bible quote is waiting for you!"
                    content.sound = UNNotificationSound.default
                    
                    var dateComponents = DateComponents()
                    dateComponents.hour = 7
                    dateComponents.minute = 0
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let request =  UNNotificationRequest(identifier: "ID", content: content, trigger: trigger)
                    notificationCenter.add(request) { (error : Error?) in
                        if let theError = error {
                            print(theError.localizedDescription)
                        }
                    }
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .previewInterfaceOrientation(.portrait)    }
}
