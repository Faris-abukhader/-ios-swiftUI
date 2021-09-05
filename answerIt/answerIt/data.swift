//  data.swift
//  answerIt
//  Created by admin on 2021/8/29.
import Foundation
import CoreData
import SwiftUI

class datauser:ObservableObject{
    @Published var answerIndex = 0
    @Published var questionIndex = 0
    @Published var score = 0
    @Published var heighestScore = 0
    @Published var latestScore = 0
    @Published var isCorrectAnswer = false
    @Published var showBonusView = false
    @Published var rotationDegree = 0
    @Published var chosedAnswerIndex = 0
    @Published var to:CGFloat = 0
    @Published var start = false
    @Published var isGameOver = false
    @Published var questions = [questionStructure]()
    @Published var secondQuestionsArray = [questionStructure]()
    @Published var username = ""
    @Published var hasScore = false
    
    init(){
        
        getData()
        
        getQuestions()
    }
    
    func getData(){
        let persistenceController = PersistenceController.shared.container.viewContext
        
        let firstFetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "LatestScore")
        let secondFetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "HighestScore")
        do {
            let firstFetchReturn = try persistenceController.fetch(firstFetchRequest)
            let secondFetchReturn = try persistenceController.fetch(secondFetchRequest)
            if firstFetchReturn.count > 0 {
                hasScore = true
                let newNotice = firstFetchReturn[0] as! LatestScore
                latestScore = Int(newNotice.score)
                let newHighestRecord = secondFetchReturn[0] as! HighestScore
                heighestScore = Int(newHighestRecord.score)
            }else{
                hasScore = false
            }
        }catch{
            print(error.localizedDescription)
        }
        
    }
    
    func getQuestions(){
        guard let path = Bundle.main.url(forResource: "answerIt", withExtension: "JSON")else{return}
        
        do {
            let data = try Data(contentsOf: path)
            let fetchedData = try JSONDecoder().decode([questionStructure].self, from: data)
            self.questions = fetchedData.shuffled()
            
        } catch {
            print(error)
        }
    }
    
    struct questionStructure:Decodable{
        var question:String
        var correctAnswer:String
        var answers:[String]
    }
    
    func getUsername(){
        let moc = PersistenceController.shared.container.viewContext
        let f:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "User")
        do {
            let fetchReturn = try moc.fetch(f)
            let username = fetchReturn[0] as! User
            if let TheuserName = username.userName {
                self.username = TheuserName
                
                
            }else{return}
        }catch{
            print(error.localizedDescription)
        }
    }
}
