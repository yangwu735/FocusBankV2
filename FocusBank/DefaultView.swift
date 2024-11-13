//
//  DefaultView.swift
//  FocusBank
//
//  Created by Luyang Wu on 11/12/24.
//

import SwiftUI
import SwiftData
import FirebaseCore

struct DefaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var myText = "not clicked"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.small)
                .foregroundColor(.accentColor)
            Text("HI GUYS!!!")
            Text(myText)
            Button(action: displayText) {
                Text("What's up?")
            }
            
        }
        .padding()
        
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    
    private func displayText() {
        if (myText == "CLICKED!!") {
            myText = "not clicked!!"
        } else {
            myText = "CLICKED!!"
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
