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
    @State var loadingAnimation: Bool = false
    @State var loadingAnimation2: Bool = false
    @State var checkAnimation: Bool = false
    @State var appCoins = [0,0,0]
    @State var audioPlayer: AVAudioPlayer?
    
    let appIconSize = CGFloat(70)
   
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
                        .padding(.trailing, 55)
                    Button("Set to 0 coins") {
                        Task {
                            await resetCoinBalance()
                        }
                        playSound(file: "ResetCoins")
                    }
                    .aspectRatio(contentMode: .fit)
                    .accentColor(Color.white)
                    .frame(width: 125, height: 50, alignment: .center)
                    .background(Color.gray)
                    .cornerRadius(10)
                    Button("+") {
                        Task {
                            await addCoins(amount: 1)
                        }
                        updateC()
                        playSound(file: "AddCoin")
    //                .onAppear {
    //                    checkAuthorizationStatus()
    //                    checkBiometricSupport()
                    }
                    .font(.system(size: 18))
                    .accentColor(Color.white)
                    .frame(width: 35, height: 50, alignment: .center)
                    .background(Color.gray)
                    .cornerRadius(10)
                }
                ZStack () {
                    Button(action: {
                        playSound(file: "TapHourglass")
                        withAnimation(Animation
                                .easeOut(duration: 0.5)
                        ) {
                            checkAnimation.toggle()
                        } completion: {
                            withAnimation(Animation
                                    .easeIn(duration: 0.5)
                                    .delay(1)
                            ) {
                                checkAnimation.toggle()
                            }
                        }
                    }) {
                        Image(myCoins > 15 ? "Most" : String(myCoins))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                    }
                    .buttonStyle(NoPressEffectButtonStyle())
                    .frame(width: 400, height: 400)
                    Text(myCoins == -1 ? "Loading..." : (String(myCoins) + " Coins"))
                        .font(.system(size: 34,
                                      weight: .bold,
                                      design: .serif
                                     ))
                        .italic()
                        .kerning(2)
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                                .opacity(0.2)
                                .frame(width: 200, height: 70, alignment: .center)
                        )
                        .opacity(checkAnimation ? 1.0 : 0.0)
                }
                .frame(width: 400, height: 400)
                HStack () {
                    VStack {
                        Button(action: {
                            if (appCoins[0] > 0) {
                                openApp(link: "instagram://")
                            } else {
                                playSound(file: "Error")
                            }
                        }) {
                            Image(appCoins[0] > 0 ? "IG" : "IG_Locked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: appIconSize, height: appIconSize)
                                .clipShape(RoundedRectangle(cornerRadius: appIconSize * 0.2377))
                        }
                        .frame(width: 120, height: appIconSize)
                        Text("Instagram")
                            .font(.system(size: appIconSize / 5))
                            .foregroundColor(Color.white)
                        Button(action: {
                            if (myCoins > 0) {
                                playSound(file: "UseCoin")
                                appCoins[0] = appCoins[0] + 1
                                Task {
                                    await addCoins(amount: -1)
                                }
                            } else {
                                playSound(file: "Error")
                            }
                        }) {
                            
                            Image("CoinInsert")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 60)
                        }
                        .frame(width: 100, height: 60)
                    }
                    VStack () {
                        Button(action: {
                            if (appCoins[0] > 0) {
                                openApp(link: "spotify://")
                            } else {
                                playSound(file: "Error")
                            }
                        }) {
                            Image(appCoins[1] > 0 ? "SFY" : "SFY_Locked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: appIconSize, height: appIconSize)
                                .clipShape(RoundedRectangle(cornerRadius: appIconSize * 0.2377))
                        }
                        .frame(width: 120, height: appIconSize)
                        Text("Spotify")
                            .font(.system(size: appIconSize / 5))
                            .foregroundColor(Color.white)
                        Button(action: {
                            if (myCoins > 0) {
                                playSound(file: "UseCoin")
                                appCoins[1] = appCoins[1] + 1
                                Task {
                                    await addCoins(amount: -1)
                                }
                            } else {
                                playSound(file: "Error")
                            }
                        }) {
                            
                            Image("CoinInsert")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 60)
                        }
                        .frame(width: 100, height: 60)
                    }
                }
            }
            ZStack () {
                Rectangle()
                    .fill(Color.black)
                    .opacity(loadingAnimation2 ? 0.0 : 1.0)
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2000, height: 1000)
                    .overlay(
                        VStack () {
                            Image("LongLogo_Wht")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 400, height: 180, alignment: .center)
                            Text("Loading...")
                                .padding(.top, 20)
                                .font(.system(size: 30,
                                              weight: .light
                                             ))
                                .foregroundColor(Color.white)
                                .kerning(4)
                                .padding(.bottom, 60)
                        }
                        
                    )
                    .opacity(loadingAnimation ? 0.0 : 1.0)
                    .onAppear {
                        updateC()
                        loadingAnimation = false
                        loadingAnimation2 = false
                        withAnimation(Animation.linear(duration: 0.4).delay(3)) {
                            loadingAnimation.toggle()
                        } completion: {
                            withAnimation(Animation.linear(duration: 0.2).delay(0.2)) {
                                loadingAnimation2.toggle()
                            }
                        }
                    }
            }
        }
    }
    
    
    private func openApp(link: String) {
            if let spotifyURL = URL(string: link) {
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
    
    private func openIG() {
            if let spotifyURL = URL(string: "instagram://") {
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
               let coinBalance = documentData["coinBalance"] as? Int {
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
    
    private func addCoins(amount: Int) async {
        do {
            let docRef = db.collection("users").document(UIDevice.current.identifierForVendor!.uuidString)
            
            if let documentData = try await docRef.getDocument().data(),
               let coinBalance = documentData["coinBalance"] as? Int {
                let newBalance = coinBalance + amount
                try await docRef.setData(["coinBalance": newBalance])
                DispatchQueue.main.async {
                    myCoins = newBalance
                }
            }
        } catch {
            print("Error updating coin balance: \(error)")
        }
    }
    
    private func updateC() {
        _ = Task {
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
            } else {
                print("Document does not exist or missing 'coinBalance'")
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
    
    private func playSound(file: String) {
        guard let soundURL = Bundle.main.url(forResource: file, withExtension: "mp3") else {
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

struct NoPressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 1.0 : 1.0) // No change in opacity
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
