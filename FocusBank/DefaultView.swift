//
//  DefaultView.swift
//  FocusBank
//
//  Created by Luyang Wu on 11/12/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseFirestore
import FamilyControls
import DeviceActivity
import FamilyControls
import SwiftUI

struct DefaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var myText = "0"
    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.09, blue: 0.1)
            .ignoresSafeArea()
            VStack (alignment: .center) {
                HStack() {
                    Image("LongLogo_Wht")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 100, alignment: .leading)
//                        .background(Color.red)
                        .padding(.trailing, 20)
                    Button("Set to 15 coins") {
                        Task {
                            await resetCoinBalance()
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .accentColor(Color.white)
                    .frame(width: 125, height: 50, alignment: .center)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding(.leading, 100)
                }
                ZStack () {
                    Text(myText)
                        .accentColor(Color.white)
                }
                .frame(width: 400, height: 400)
                .background(Color.red)
                Button("Add 5 coins") {
                    Task {
                        await addTestCoins()
                    }
                }
                .accentColor(Color.black)
                .background(Color.green)
                .frame(width: 400, height: 100)
                HStack () {
                    Button("Open Spotify") {
                        openSpotify()
                    }
                    .accentColor(Color.white)
                    .background(Color.green)
                    .frame(width: 400, height: 100)
                }
            }
        }
        
    }
    
    
    private func openSpotify() {
            if let spotifyURL = URL(string: "spotify://") {
                if UIApplication.shared.canOpenURL(spotifyURL) {
                    UIApplication.shared.open(spotifyURL, options: [:]) { success in
                        if success {
                            print("Spotify opened successfully.")
                        } else {
                            print("Failed to open Spotify.")
                        }
                    }
                } else {
                    print("Spotify is not installed or URL scheme not available.")
                }
            } else {
                print("Invalid Spotify URL scheme.")
            }
        }
    
    private func resetCoinBalance() async {
        let docRef = db.collection("users").document(UIDevice.current.identifierForVendor!.uuidString)

        do {
          
            try await docRef.setData([
            "coinBalance": 15
            
          ])
        let documentSS = try await docRef.getDocument()
            if let documentData = documentSS.data(),
               let coinBalance = documentData["coinBalance"] as? Int { // Extract "coinBalance" field
                // Update myText with the new coin balance
                DispatchQueue.main.async {
                    myText = "Coin Balance: \(coinBalance)"
                }
            } else {
                print("Document does not exist or does not contain 'coinBalance'")
            }
        } catch {
          print("Error getting document: \(error)")
        }
    }
    
    private func addTestCoins() async {
        do {
            let docRef = db.collection("users").document(UIDevice.current.identifierForVendor!.uuidString)
            if let documentData = try await docRef.getDocument().data(),
               let coinBalance = documentData["coinBalance"] as? Int {
                try await docRef.setData(["coinBalance": coinBalance + 5])
                DispatchQueue.main.async {
                    myText = "Coin Balance: \(coinBalance)"
                }
            }
        } catch {
            print("Error updating coin balance: \(error)")
        }
                
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}


#Preview {
    DefaultView()
        .modelContainer(for: Item.self, inMemory: true)
}

//do {
//  let ref = try await db.collection("users").set(data: [
//    "first": "Ada",
//    "last": "Lovelace",
//    "born": 1815
//  ])
//  print("Document added with ID: \(ref.documentID)")
//} catch {
//  print("Error adding document: \(error)")
//}
