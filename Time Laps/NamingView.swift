//
//  NamingView.swift
//  Time Laps
//
//  Created by Julien on 12/12/2023.
//

import SwiftUI

struct NamingView: View {
    @Binding var isPresented: Bool
    @Binding var journalEntries: [JournalEntry]
    @State private var tempName = ""
    var duration: TimeInterval
    var startTime: Date

    var body: some View {
        VStack {
            Text("Donnez un nom à votre session de minuteur")
                .font(.headline)

            TextField("Nom du Minuteur", text: $tempName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Enregistrer") {
                journalEntries.append(JournalEntry(date: Date(), duration: duration, name: tempName, startTime: startTime))
                isPresented = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct NamingView_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var journalEntries: [JournalEntry] = []

    static var previews: some View {
        NamingView(isPresented: $isPresented, journalEntries: $journalEntries, duration: 600, startTime: Date())
    }
}
