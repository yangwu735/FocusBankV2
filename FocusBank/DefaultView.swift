//
//  DefaultView.swift
//  FocusBank
//
//  Created by Luyang Wu on 11/12/24.
//

import SwiftUI
import SwiftData
import AVFoundation
import FirebaseCore
import FirebaseFirestore
import FamilyControls
import LocalAuthentication
import DeviceActivity
import FamilyControls
import SwiftUI

struct DefaultView: View {
    @Environment(\.modelContext) private var modelContext
    let db = Firestore.firestore()
    @State var myCoins = -1
    @State var isAnimated: Bool = false
    @State var zoomed: Bool = false
    @State var audioPlayer: AVAudioPlayer?
    
   
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
                        .padding(.trailing, 90)
                        .onAppear {
                            updateC()
                        }
                    Button("Set to 0 coins") {
                        Task {
                            await resetCoinBalance()
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .accentColor(Color.white)
                    .frame(width: 125, height: 50, alignment: .center)
                    .background(Color.gray)
                    .cornerRadius(10)
                }
                ZStack () {
                    Image(myCoins > 15 ? "Most" : String(myCoins))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                    Text(myCoins == -1 ? "Loading..." : (String(myCoins) + " Coins"))
                        .font(.system(size: 40,
                                      weight: .bold,
                                      design: .serif
                                     ))
                        .italic()
                        .kerning(2)
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                                .opacity(0.2)
                                .frame(width: 200, height: 70, alignment: .center)
                        )
//                    AnimatedImage(name: "AddCoinAnim") // Name of your GIF file
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200) // Adjust size as needed
//                        .opacity(isAnimated ? 1.0 : 0.0)
//                    Image("bkgd")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width:200, height: 200)
                }
                .frame(width: 400, height: 400)
                Button("Add a coin") {
                    Task {
                        await addTestCoins()
                    }
                    playCoinSound()
//                    withAnimation(
//                        Animation
//                            .easeInOut(duration: 2.0)
//                    ) {
//                        isAnimated.toggle()
//                    }
                }
//                .onAppear {
//                    checkAuthorizationStatus()
//                    checkBiometricSupport()
//                }
                .accentColor(Color.white)
                .frame(width: 125, height: 50, alignment: .center)
                .background(Color.green)
                .cornerRadius(10)
                HStack () {
                    Button("Open Spotify") {
                        openSpotify()
                    }
                    .accentColor(Color.white)
                    .background(Color.green)
                    .frame(width: 400, height: 100)
                }
            }
            Rectangle()
                .fill(Color.black)
                .frame(width: 1000, height: 2000)
                .ignoresSafeArea()
                .opacity(isAnimated ? 1.0 : 0.0)
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
            "coinBalance": 0
          ])
        let documentSS = try await docRef.getDocument()
            if let documentData = documentSS.data(),
               let coinBalance = documentData["coinBalance"] as? Int { // Extract "coinBalance" field
                // Update myText with the new coin balance
                DispatchQueue.main.async {
                    myCoins = coinBalance
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
                try await docRef.setData(["coinBalance": coinBalance + 1])
                DispatchQueue.main.async {
                    myCoins = coinBalance
                }
            }
        } catch {
            print("Error updating coin balance: \(error)")
        }
    }
    
    private func updateC() {
        let task = Task {
            await updateCoins()
        }
    }
    
    private func updateCoins() async {
        do {
            let docRef = db.collection("users").document(UIDevice.current.identifierForVendor!.uuidString)
            if let documentData = try await docRef.getDocument().data(),
               let coinBalance = documentData["coinBalance"] as? Int {
                DispatchQueue.main.async {
                    myCoins = coinBalance
                }
            }
        } catch {
            print("Error updating coin balance: \(error)")
        }
    }

   
    private func requestScreenTimeAuthorization() async {
        let member = FamilyControlsMember.individual

        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: member)
            DispatchQueue.main.async {
                print("Screen Time authorization granted.")
            }
        } catch {
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
    private func checkAuthorizationStatus() {
        let status = AuthorizationCenter.shared.authorizationStatus

        switch status {
        case .notDetermined:
            print("Authorization not determined.")
        case .denied:
            print("Authorization denied.")
        case .approved:
            print("Authorization approved.")
        @unknown default:
            print("Unknown authorization status.")
        }
    }

    
    private func checkBiometricSupport() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if context.biometryType == .faceID {
                print("Device supports Face ID.")
            } else if context.biometryType == .touchID {
                print("Device supports Touch ID.")
            } else {
                print("No specific biometric support.")
            }
        } else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    private func playCoinSound() {
        guard let soundURL = Bundle.main.url(forResource: "CoinSFX", withExtension: "mp3") else {
            print("Sound file not found!")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
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
