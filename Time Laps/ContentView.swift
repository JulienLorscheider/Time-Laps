//
//  ContentView.swift
//  Time Laps
//
//  Created by Julien on 12/12/2023.
//

import SwiftUI
import AVFoundation
import AudioToolbox

struct ContentView: View {
    @State private var selectedTime = TimeInterval(600)
    @State private var timeRemaining = TimeInterval(600)
    @State private var timerActive = false
    @State private var timer: Timer?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var currentQuote = ""
    @State private var journalEntries: [JournalEntry] = []
    @State private var showJournal = false
    @State private var showingNamingView = false
    @State private var timerStartTime: Date?

    let backgroundColor: Color = Color(#colorLiteral(red: 0.1254901961, green: 0.2980392157, blue: 0.4901960784, alpha: 1))
    let foregroundColor: Color = Color(#colorLiteral(red: 0.9333333333, green: 0.9098039216, blue: 0.6666666667, alpha: 1))
    let motivationalQuotes = [
        "Votre avenir est créé par ce que vous faites aujourd'hui, pas demain.",
        "Ne rêvez pas votre vie, vivez vos rêves.",
        "Le secret pour aller de l'avant est de commencer.",
        "L'échec est le fondement de la réussite.",
    ]

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Time Laps")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(foregroundColor)

                if !timerActive {
                    // Vue de la page d'accueil
                    homeView
                } else {
                    TimerView(timeRemaining: timeRemaining, currentQuote: currentQuote, backgroundColor: backgroundColor, foregroundColor: foregroundColor)
                        .transition(.scale)
                }
            }
        }
        .onChange(of: journalEntries) { _ in
            print("Journal entries updated")
        }
        .sheet(isPresented: $showingNamingView) {
            NamingView(isPresented: $showingNamingView, journalEntries: $journalEntries, duration: selectedTime - timeRemaining, startTime: timerStartTime ?? Date())
        }
        .onAppear {
            requestNotificationPermission()
        }
    }

    // Vue de la page d'accueil
    var homeView: some View {
        VStack {
            Picker("Durée", selection: $selectedTime) {
                Text("5 minutes").tag(TimeInterval(300))
                Text("10 minutes").tag(TimeInterval(600))
                Text("15 minutes").tag(TimeInterval(900))
            }
            .pickerStyle(WheelPickerStyle())
            .background(RoundedRectangle(cornerRadius: 25).fill(foregroundColor).shadow(radius: 5))
            .padding(.horizontal, 20)
            
            Button(action: {
                withAnimation {
                    startTimer()
                }
            }) {
                Text("Démarrer le minuteur")
                    .font(.headline)
                    .foregroundColor(backgroundColor)
                    .padding()
                    .frame(width: 202, height: 60)
                    .background(foregroundColor)
                    .cornerRadius(30)
                    .shadow(radius: 5)
            }
            .padding()
            
            Button(action: {
                self.showJournal.toggle()
            }) {
                HStack {
                    Image(systemName: "book.fill") // Icône stylée
                    Text("Voir le Journal")
                        .fontWeight(.semibold)
                }
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(40)
                .shadow(radius: 5)
            }
            .padding()
            .sheet(isPresented: $showJournal) {
                JournalView(entries: $journalEntries)
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Autorisation accordée")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Retournez à votre session de travail"
        content.body = "Votre minuteur est toujours actif. Restez concentré !"
        content.sound = UNNotificationSound.default

        // Définissez le délai après lequel la notification doit être envoyée, par exemple, après 5 minutes.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)

        // Créez la requête
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Ajoutez la requête au centre de notification
        UNUserNotificationCenter.current().add(request)
    }
    
    func startTimer() {
        selectRandomQuote()
        timeRemaining = selectedTime
        timerStartTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.playSound()
            }
        }
        timerActive = true
    }
    
    func stopTimer() {
        showingNamingView = true

        timer?.invalidate()
        timer = nil
        timerActive = false
    }
    
    func playSound() {
        let systemSoundID: SystemSoundID = 1304
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    func selectRandomQuote() {
        currentQuote = motivationalQuotes.randomElement() ?? "Restez motivé !"
    }
}

// Vue du Minuteur
struct TimerView: View {
    var timeRemaining: TimeInterval
    var currentQuote: String
    var backgroundColor: Color
    var foregroundColor: Color

    var body: some View {
        VStack {
            Text(timeString(time: timeRemaining))
                .font(.system(size: 65, weight: .medium, design: .rounded))
                .foregroundColor(foregroundColor)
                .fixedSize()
                .frame(width: 200, height: 200, alignment: .center)
                .background(backgroundColor)
                .cornerRadius(100)
                .shadow(radius: 10)
                .padding()

            Text(currentQuote)
                .font(.headline)
                .foregroundColor(foregroundColor)
                .padding()
                .multilineTextAlignment(.center)
        }
    }

    // Fonction pour formater le temps restant
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.device)
            .previewDevice("iPhone 8")
            .previewInterfaceOrientation(.portrait)
    }
}
