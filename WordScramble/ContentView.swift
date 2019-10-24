//
//  ContentView.swift
//  WordScramble
//
//  Created by Yes on 22.10.2019.
//  Copyright © 2019 Yes. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading: Text("Your score is \(score)"), trailing:
                Button(action: startGame) {
                    Text("Start Game")
                        .fontWeight(.bold)
                }
                .padding(8)
                .border(Color(red: 1.0, green: 0.3, blue: 0.5).opacity(0.5), width: 1.5)
                .foregroundColor(.init(red: 1.0, green: 0.3, blue: 0.5))
            )
                .background(Color(red: 0.5, green: 0.5, blue: 0.5).opacity(0.1))
            .onAppear(perform: startGame)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text(errorTitle),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isRootWord(word: answer) else {
            wordError(title: "Word is a root word", message: "Use another word")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That is not real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        self.calculateScore(word: answer)
        newWord = ""
    }
    
    func startGame() {
        score = 0
        usedWords = []
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Couldn't load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        if (word.count < 3) {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
                
        return misspelledRange.location == NSNotFound
    }
    
    func isRootWord(word: String) -> Bool {
        return word != rootWord
    }
    
    func calculateScore(word: String) {
        if word.utf16.count > 3 {
            score += usedWords.count > 10 ? 4 : 2
            return
        } else {
            score += 1
        }
        
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
