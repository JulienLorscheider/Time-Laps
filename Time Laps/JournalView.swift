//
//  JournalView.swift
//  Time Laps
//
//  Created by Julien on 12/12/2023.
//

import SwiftUI

struct JournalView: View {
    @Binding var entries: [JournalEntry]
    @State private var pinnedEntries: [Date] = []
    
    private var pinnedEntriesSorted: [JournalEntry] {
        entries.filter { pinnedEntries.contains($0.date) }
               .sorted { $0.startTime > $1.startTime }
    }

    private var unpinnedEntriesSorted: [JournalEntry] {
        entries.filter { !pinnedEntries.contains($0.date) }
               .sorted { $0.startTime > $1.startTime }
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                withAnimation {
                    emptyJournalView
                }
            } else {
                List {
                    Text("Historique des Sessions")
                        .font(.largeTitle)
                        .padding()
                    // Section pour les éléments épinglés
                    if !pinnedEntriesSorted.isEmpty {
                        Text("Épinglés")
                            .font(.title2)
                            .padding(.leading)
                        ForEach(pinnedEntriesSorted, id: \.date) { entry in
                            journalEntryView(entry)
                        }
                    }

                    if !unpinnedEntriesSorted.isEmpty {
                        // Section pour les éléments non épinglés
                        Text("Non Épinglés")
                            .font(.title2)
                            .padding(.leading)
                        ForEach(unpinnedEntriesSorted, id: \.date) { entry in
                            journalEntryView(entry)
                        }
                    }
                }
            }
        }
    }
    
    private func journalEntryView(_ entry: JournalEntry) -> some View {
        VStack(alignment: .leading) {
            Text(entry.name.isEmpty ? "Session sans nom" : entry.name)
                .font(.headline)
            Text("Date: \(entry.date, formatter: dateFormatter)")
            Text("Heure de démarrage: \(entry.startTime, formatter: timeFormatter)")
            Text("Durée: \(timeString(time: entry.duration))")
            Divider()
        }
        .padding()
        .shadow(radius: 3)
        .scaleEffect(0.95)
        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .trailing)))
        .animation(.default, value: pinnedEntries)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    deleteEntry(entry)
                }
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                togglePin(entry)
            } label: {
                Label(pinnedEntries.contains(entry.date) ? "Détacher" : "Épingler", systemImage: "pin")
            }
        }
    }

    private var emptyJournalView: some View {
        VStack {
            Image(systemName: "book.closed.fill") // Une icône représentative
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.gray)
            Text("Aucune session de minuteur enregistrée")
                .font(.title)
            Text("Vos sessions de minuteur apparaîtront ici. Commencez à utiliser le chronomètre pour voir vos progrès.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .transition(.opacity)
    }

    private var journalListView: some View {
        List {
            ForEach(entries, id: \.date) { entry in
                VStack(alignment: .leading) {
                    Text(entry.name.isEmpty ? "Session sans nom" : entry.name)
                        .font(.headline)
                    Text("Date: \(entry.date, formatter: dateFormatter)")
                    Text("Heure de démarrage: \(entry.startTime, formatter: timeFormatter)")
                    Text("Durée: \(timeString(time: entry.duration))")
                    Divider()
                }
                .padding()
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteEntry(entry)
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        togglePin(entry)
                    } label: {
                        Label(pinnedEntries.contains(entry.date) ? "Détacher" : "Épingler", systemImage: "pin")
                    }
                }
            }
        }
    }

    private func deleteEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.date == entry.date }) {
            let entryToRemove = entries[index]
            withAnimation {
                entries.removeAll { $0.date == entryToRemove.date }
            }
        }
    }

    private func togglePin(_ entry: JournalEntry) {
        if let index = pinnedEntries.firstIndex(of: entry.date) {
            withAnimation {
                pinnedEntries.remove(at: index)
                self.entries = self.entries.sorted { $0.date > $1.date }
            }
        } else {
            withAnimation {
                pinnedEntries.append(entry.date)
                self.entries = self.entries.sorted { $0.date > $1.date }
            }
        }
    }

    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct JournalEntry: Equatable {
    let date: Date
    let duration: TimeInterval
    var name: String
    var startTime: Date
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
}()

struct JournalView_Previews: PreviewProvider {
    @State static var sampleEntries = [
        JournalEntry(date: Date(), duration: 3600, name: "Session d'étude", startTime: Date()),
        JournalEntry(date: Date().addingTimeInterval(-86400), duration: 1800, name: "Session de travail", startTime: Date())
    ]

    static var previews: some View {
        JournalView(entries: $sampleEntries)
    }
}
