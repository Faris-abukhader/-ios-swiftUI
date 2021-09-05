//  ContentView.swift
//  answerIt
//  Created by admin on 2021/8/29.

import SwiftUI
import CoreData
import AVFoundation
struct ContentView: View {
    @Binding var startGame:Bool
    @Environment(\.managedObjectContext) private var moc
    @EnvironmentObject var data:datauser
    @State private var  width = UIScreen.main.bounds.width
    @State private var  height = UIScreen.main.bounds.height
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var count = 0
    @State private var appear = false
    @State private var threeSec = 3
    @State private var isFirstLoop = true
    
    @State var twoSec = 2
    @State var showBonusView = false
    
    @FetchRequest(entity: LatestScore.entity(), sortDescriptors: []) private var latestScore:FetchedResults<LatestScore>
    @FetchRequest(entity: HighestScore.entity(), sortDescriptors: []) private var highestScore:FetchedResults<HighestScore>
    
    
    let playerManager = AudioPlayerManager.shared
    
    
    var body: some View {
        ZStack{
            Color("lightRed").ignoresSafeArea()
            
            
            VStack{
                
                
                headerTitle()
                    .offset(y: appear ? 0:-height)
                    .animation(.easeOut(duration:2))
                
                
                ZStack{
                    bonusView(amount: 2)
                        .offset(y:showBonusView ? 0:-35)
                        .offset(x: appear ? 0:width)
                        .animation(.easeOut(duration:2))
                    
                    questionBonusView(amount: 1)
                        .offset(y:showBonusView ? 0:-35)
                        .offset(x: appear ? 0:-width)
                        .animation(.easeOut(duration:2))
                    
                    
                    analyzedBar(appear: $appear,width: $width,score: $data.score,questionsNum: $data.questionIndex)
                        .environmentObject(data)
                        .offset(x: appear ? 0:-width)
                        .offset(x: appear ? 0:width)
                        .animation(.easeOut(duration:2))
                    
                }
                
                circleCounter(to: $data.to, count: $count)
                    .scaleEffect(appear ? 1:0.1)
                    .animation(.easeOut(duration: 2))
                    .environmentObject(data)
                
                
                
                questionView(question: $data.questions[0].question, width: $width)
                    .scaleEffect(appear ? 1:0.1)
                    .animation(.easeOut(duration: 2))
                
                
                choicesView(width: $width, answerOne: $data.questions[0].answers[0], answerTwo: $data.questions[0].answers[1], answerThree: $data.questions[0].answers[2], answerFour: $data.questions[0].answers[3],correctAnswer:$data.questions[0].correctAnswer)
                    .offset(x: appear ? 0:-width)
                    .offset(x: appear ? 0:width)
                    .animation(.default)
                
                
                
                
            }.background(Color(.clear))
            .blur(radius: data.isGameOver ? 20:0)
            
            if data.isGameOver {
                gameOver(width: $width,height: $height)
                    .environmentObject(data)
                
            }
            
            if threeSec > 0 {
                beginingCountDown(width: $width, height: $height, second: $threeSec)
                
            }
            
            
            // MARK: - onReceive
        }.onReceive(timer){ _ in
            
            
            beginingViewController()
            
            ViewController()
            
            bounsViewController()
            
            
            
        }.onAppear{
            withAnimation(.default){
                appear = true
            }
            
        }
        
    }
    
    func bounsViewController(){
        if showBonusView && twoSec > 0 {
            twoSec-=1
            if twoSec == 1{
                playSound()
            }
        }else{
            showBonusView = false
            twoSec = 2
        }
    }
    
    func beginingViewController(){
        if threeSec > 0 {
            threeSec-=1
        }else if isFirstLoop {
            data.start = true
            threeSec = -1
            isFirstLoop = false
        }
    }
    
    // MARK: - viewController
    func ViewController(){
        
        if data.start {
            playCountDownSound()
            if count < 10 {
                count+=1
                withAnimation(.default){
                    data.to += CGFloat(count)/50
                }
            }else{
                
                // here every loop we will delete the question from main array and add it to second array so the user if he wanna try for second time the questions which he said will not be exist again untile he finished all the question at first array
                
                removeAndAddQuestion()
                
                
                data.start = false
                count = 0
                withAnimation(.default){
                    data.to = 0
                }
                if !data.isCorrectAnswer {
                    data.isGameOver = true
                    let score = data.score
                    updateScore(score: score)
                }
                
                
                
            }
        }else {
            
            
            if data.isCorrectAnswer && data.questionIndex+1 < data.questions.count {
                data.start = true
                count = 0
                withAnimation(.default){
                    data.chosedAnswerIndex = 0
                    data.to = 0
                    data.questionIndex += 1
                    data.score+=2
                    showBonusView = true
                    data.rotationDegree += 360
                    data.isCorrectAnswer = false
                    let score = data.score
                    updateScore(score: score)
                    
                }
            }
        }
        
    }
    
    func updateScore(score:Int){
        if latestScore.count == 0 {
            let newHighestScore = HighestScore(context:moc)
            newHighestScore.score = Int16(score)
            
            let newLatestScore = LatestScore(context:moc)
            newLatestScore.score = Int16(score)
            
            do {
                try moc.save()
            }catch{
                print(error)
            }
        }else{
            let newLatestScore = latestScore[0] as NSManagedObject
            newLatestScore.setValue(score, forKey: "score")
            do{
                try moc.save()
            }catch{
                print(error)
            }
            
            for scores in highestScore {
                if (score) > scores.score {
                    let newHighestScore = scores as NSManagedObject
                    newHighestScore.setValue(score, forKey: "score")
                    
                    do{
                        try moc.save()
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    
    func playSound() {
        let path = Bundle.main.path(forResource: "coinsSound", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        playerManager.play(url: url)
        
    }
    
    
    
    func playCountDownSound() {
        let path = Bundle.main.path(forResource: "countDown", ofType: "mov")
        let url = URL(fileURLWithPath: path!)
        playerManager.play(url: url)
        
    }
    
    func removeAndAddQuestion(){
        data.secondQuestionsArray.append(data.questions[0])
        data.questions.remove(at: 0)
        
        if data.questions.count == 0 {
            data.questions = data.secondQuestionsArray
            data.secondQuestionsArray.removeAll()
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    @State var start = true
    static var previews: some View {
        ContentView(startGame: .constant(true)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


// MARK: - begining CountDown

struct beginingCountDown:View{
    @Binding var width:CGFloat
    @Binding var height:CGFloat
    @Binding var second:Int
    
    var body: some View{
        ZStack{
            withAnimation(.easeInOut){
                Text("\(second)")
                    .font(.custom("", size: 100))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
        }.frame(width: width, height: height+20)
        .background(Color.black.opacity(0.5))
    }
}

// MARK: - gameOver
struct gameOver:View{
    @Binding var width:CGFloat
    @Binding var height:CGFloat
    @State var appear = false
    @State var goBack = false
    @EnvironmentObject var data:datauser
    @Environment(\.presentationMode) var presentationMode
    let playerManager = AudioPlayerManager.shared
    @Environment(\.managedObjectContext) private var moc
    
    var body: some View{
        ZStack{
            
            VStack{
                Spacer()
                Text("لقد حصلت على \(data.score) نقطة")
                    .font(.custom("Almarai-Bold", size: 30))
                    .scaleEffect(appear ? 1:0.2)
                    .animation(.default)
                    .foregroundColor(Color("light"))
                    .shadow(radius:3)
                
                
                HStack{
                    
                    Spacer()
                    
                    withAnimation(.easeInOut(duration: 2)){
                        Button(action: {
                            startAgain()
                            
                        }, label: {
                            
                            Text("مره أخرى")
                                .foregroundColor(.black)
                                .font(.custom("Almarai-Bold", size: 20))
                                .padding(.vertical,10)
                                .padding(.horizontal,20)
                                .background(Color("light"))
                                .cornerRadius(20)
                                .scaleEffect(appear ? 1:0.2)
                            
                        })
                    }
                    
                    
                    Spacer()
                    
                    withAnimation(.easeInOut(duration: 2)){
                        Button(action: {
                            withAnimation(.easeInOut(duration:2)){
                                presentationMode.wrappedValue.dismiss()
                                data.start = false
                                data.to = 0
                                data.questionIndex = 0
                                data.chosedAnswerIndex = 0
                                data.score = 0
                                data.isCorrectAnswer = false
                                data.isGameOver = false
                            }
                            
                        }, label: {
                            Text("رجوع")
                                .foregroundColor(.black)
                                .font(.custom("Almarai-Bold", size: 20))
                                .padding(.vertical,10)
                                .padding(.horizontal,20)
                                .background(Color("green"))
                                .cornerRadius(20)
                                .scaleEffect(appear ? 1:0.2)
                            
                        })
                    }
                    
                    Spacer()
                    
                    
                    
                }.padding(.vertical,40)
                Spacer()
                
            }
        }
        .frame(width: width, height: height+20)
        .ignoresSafeArea()
        .onAppear{
            appear = true
            playGameOverSound()
        }
    }
    
    
    func startAgain(){
        data.start = true
        data.to = 0
        data.score = 0
        data.questionIndex = 0
        data.chosedAnswerIndex = 0
        data.isCorrectAnswer = false
        data.isGameOver = false
    }
    
    
    func playGameOverSound() {
        let path = Bundle.main.path(forResource: "gameOverSound", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        playerManager.play(url: url)
        
    }
    
}


// MARK: - circleCounter
struct circleCounter: View {
    @Binding var to:CGFloat
    @Binding var count:Int
    var body: some View {
        ZStack{
            
            ZStack{
                
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.white,style:StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .padding(.bottom)
                
                Circle()
                    .trim(from: 0, to: to)
                    .stroke(getColor(),style:StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .padding(.bottom)
                
            }.rotationEffect(.init(degrees: -90))
            
            Text("\(10-count)")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .font(.largeTitle)
                .offset(x: -5)
        }.padding(.vertical,40)
    }
    func getColor()->Color{
        withAnimation{
            switch count {
            case 0...7:
                return .green
            case 8...10:
                return .red
            default:
                return .green
            }
        }
    }
    
}
// MARK: - headerTitle

struct headerTitle: View {
    var body: some View {
        Text("احزرها صح")
            .font(.custom("Almarai-ExtraBold", size: 40))
            .foregroundColor(.white)
    }
}

// MARK: - analyzedBar
struct analyzedBar: View {
    @Binding var appear:Bool
    @Binding var width:CGFloat
    @Binding var score:Int
    @Binding var questionsNum:Int
    @EnvironmentObject var data:datauser
    var body: some View {
        HStack{
            HStack{
                ZStack{
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                        .shadow(radius: 3)
                    
                    
                    Text("\(data.isGameOver ?  0:questionsNum)")
                        .foregroundColor(.white)
                        .font(.custom("Almarai-ExtraBold", size: 20))
                    
                    
                    
                }.padding(.leading,30)
                Text("سؤال")
                    .foregroundColor(.white)
                    .font(.custom("Almarai-Bold", size: 20))
            }.offset(x: appear ? 0:-width)
            Spacer()
            
            HStack{
                Text("نقطة")
                    .foregroundColor(.white)
                    .font(.custom("Almarai-Bold", size: 20))
                
                
                ZStack{
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                        .shadow(radius: 3)
                    
                    
                    Text("\(data.isGameOver ?  0:score)")
                        .foregroundColor(.white)
                        .font(.custom("Almarai-ExtraBold", size: 20))
                    
                }.padding(.trailing,30)
            }.offset(x: appear ? 0:width)
            
            
        }
    }
}

// MARK: - choicesView
struct choicesView: View {
    @Binding var width:CGFloat
    @Binding var answerOne:String
    @Binding var answerTwo:String
    @Binding var answerThree:String
    @Binding var answerFour:String
    @Binding var correctAnswer:String
    @EnvironmentObject var data:datauser
    let playerManager = AudioPlayerManager.shared
    @State var appear = false
    var body: some View {
        HStack{
            VStack(alignment:.leading){
                Button(action: {
                    data.chosedAnswerIndex = 1
                    if answerOne == correctAnswer {
                        data.isCorrectAnswer = true
                    }else{
                        data.isCorrectAnswer = false
                    }
                    playClickSound()
                }, label: {
                    Text("\(answerOne)")
                        .font(.custom("Almarai-Bold", size: 15))
                        .foregroundColor(.white)
                        .frame(width: width/2 - 20, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(data.chosedAnswerIndex == 1 ? Color("yellow"):Color("blue"))
                        .cornerRadius(20)
                        .shadow(radius:1)
                    
                })
                .padding(.bottom)
                
                Button(action: {
                    data.chosedAnswerIndex = 2
                    if answerTwo == correctAnswer {
                        data.isCorrectAnswer = true
                    }else{
                        data.isCorrectAnswer = false
                    }
                    playClickSound()
                    
                }, label: {
                    Text("\(answerTwo)")
                        .font(.custom("Almarai-Bold", size: 15))
                        .foregroundColor(.white)
                        .frame(width: width/2 - 20, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(data.chosedAnswerIndex == 2 ? Color("yellow"):Color("blue"))
                        .cornerRadius(20)
                        .shadow(radius:1)
                    
                })
                
            }.padding(.leading)
            .offset(x: appear ? 0:-width)
            
            Spacer()
            
            VStack(alignment:.leading){
                Button(action: {
                    data.chosedAnswerIndex = 3
                    if answerThree == correctAnswer {
                        data.isCorrectAnswer = true
                    }else{
                        data.isCorrectAnswer = false
                    }
                    playClickSound()
                    
                }, label: {
                    Text("\(answerThree)")
                        .font(.custom("Almarai-Bold", size: 15))
                        .foregroundColor(.white)
                        .frame(width: width/2 - 20, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(data.chosedAnswerIndex == 3 ? Color("yellow"):Color("blue"))
                        .cornerRadius(20)
                        .shadow(radius:1)
                    
                    
                })
                .padding(.bottom)
                
                
                Button(action: {
                    data.chosedAnswerIndex = 4
                    if answerFour == correctAnswer {
                        data.isCorrectAnswer = true
                    }else{
                        data.isCorrectAnswer = false
                    }
                    playClickSound()
                    
                }, label: {
                    Text("\(answerFour)")
                        .font(.custom("Almarai-Bold", size: 15))
                        .foregroundColor(.white)
                        .frame(width: width/2 - 20, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(data.chosedAnswerIndex == 4 ? Color("yellow"):Color("blue"))
                        .cornerRadius(20)
                        .shadow(radius:1)
                    
                    
                })
                
            }.padding(.trailing)
            .offset(x: appear ? 0:width)
            
            
        }.padding(.vertical)
        .onAppear{
            withAnimation(.default){
                appear = true
            }
        }
    }
    func playClickSound() {
        let path = Bundle.main.path(forResource: "clickSound", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        playerManager.play(url: url)
        
    }
}


// MARK: - questionView
struct questionView: View {
    @Binding var question:String
    @Binding var width:CGFloat
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: width-40, height: width-150)
                .foregroundColor(Color("purple"))
                .cornerRadius(20)
            
            
            
            Text(question)
                .frame(width: width-80, height: width-200, alignment: .center)
                .foregroundColor(.white)
                .font(.custom("Almarai-Bold", size: 20))
                .animation(.easeInOut)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
    }
}

// MARK: - bonusView
struct bonusView: View {
    @State var amount:Int = 0
    @EnvironmentObject var data:datauser
    var body: some View {
        HStack{
            Spacer()
            
            Text("+\(amount)")
                .fontWeight(.bold)
                .padding(.trailing,40)
                .foregroundColor(.white)
        }
        .offset(y:35)
    }
}

// MARK: - questionBonusView
struct questionBonusView: View {
    @State var amount:Int = 0
    @EnvironmentObject var data:datauser
    var body: some View {
        HStack{
            
            Text("+\(amount)")
                .fontWeight(.bold)
                .padding(.leading,40)
                .foregroundColor(.white)
            
            Spacer()
        }
        .offset(y:35)
    }
}

struct test:View{
    @Binding var name:String
    var body: some View{
        VStack{
            Text("hi")
        }.onAppear{
            name = "fares"
        }
    }
}
