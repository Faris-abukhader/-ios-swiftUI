//  secondPage.swift
//  answerIt
//  Created by admin on 2021/8/31.

import SwiftUI
import CoreData

struct secondPage: View {
    @EnvironmentObject var data:datauser
    @Environment(\.managedObjectContext) private var moc
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    @State var appear = false
    @State var start = false
    @FetchRequest(entity: LatestScore.entity(), sortDescriptors: []) private var latestScore:FetchedResults<LatestScore>
    @FetchRequest(entity: HighestScore.entity(), sortDescriptors: []) private var highestScore:FetchedResults<HighestScore>
    let playerManager = AudioPlayerManager.shared
    
    let timer  = Timer.TimerPublisher.init(interval: 1, runLoop: .main, mode: .common).autoconnect()
    @State var timeForUpdate = 2
    var body: some View {
        ZStack{
            Color("cyan").ignoresSafeArea()
            
            ZStack{
                
                firstRectangle(width: width, height: height)
                secondRectangle(width: width, height: height)
                thirdRectangle(width: width, height: height)
                circle(width: width, height: height)
                    .offset(x: -width/5, y: -height/4)
                
                startView(appear: $appear, width: width)
                    .offset(y: appear ? 0:height*2)
                    .rotation3DEffect(.degrees(appear ? 0:-45), axis: (x: 1, y: 0, z: 0))
                    .environmentObject(data)
                    .environment(\.managedObjectContext, moc)
                
            }
            
            
        }.onAppear{
            updateData()
            playSound()
            withAnimation(.easeInOut(duration: 1.5)){
                appear = true
            }
        }.onReceive(timer) { _ in
            updateData()
        }
    }
    
    func updateData(){
        if latestScore.count > 0 {
            if timeForUpdate > 0 {
                timeForUpdate-=1
                data.latestScore = Int(latestScore[0].score)
                data.heighestScore = Int(highestScore[0].score)
            }else {
                timer.upstream.connect().cancel()
                timeForUpdate = 2
            }
        }
    }
    
    func playSound() {
        let path = Bundle.main.path(forResource: "gameStartSound", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        playerManager.play(url: url)
        
        
    }
    
}

struct secondPage_Previews: PreviewProvider {
    static var previews: some View {
        secondPage()
    }
}

struct startView: View {
    @Binding var appear:Bool
    @State var width:CGFloat = 0
    @State var startGame = false
    @EnvironmentObject var data:datauser
    @Environment(\.managedObjectContext) private var moc
    
    let timer = Timer.TimerPublisher.init(interval: 1, runLoop: .main, mode: .common).autoconnect()
    
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: appear ? width-60:0, height: appear ? width/1:0)
                .foregroundColor(Color("lightBlue"))
                .cornerRadius(25)
            VStack{
                
                Spacer()
                
                Image("myLogo2")
                    .resizable()
                    .frame(width: 160, height: 160)
                
                Text("احزرها صح")
                    .font(.custom("Almarai-Bold", size: 20))
                    .foregroundColor(.white)
                    .flipsForRightToLeftLayoutDirection(true)
                
                
                
                Text(" \(data.hasScore ? "أعلى نتيجة \(data.heighestScore)":"") ")
                    .font(.custom("Almarai-ExtraBold", size: 30))
                    .flipsForRightToLeftLayoutDirection(true)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                
                
                Text("\(data.hasScore ? "آخر نتيجة \(data.score)":"العب الآن واحصل على اعلى نتيجة")")
                    .font(.custom("Almarai-ExtraBold", size:30))
                    .flipsForRightToLeftLayoutDirection(true)
                    .multilineTextAlignment(.center)
                
                
                
                Spacer()
                
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 1.5)){
                        startGame = true
                    }
                }, label: {
                    Text("ابدأ ")
                        .font(.custom("Almarai-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(.vertical,10)
                        .padding(.horizontal,60)
                        .background(Color.red)
                        .cornerRadius(15)
                        .padding(.bottom)
                })
                .fullScreenCover(isPresented: $startGame, content: {
                    ContentView(startGame: $startGame).environmentObject(data)
                        .environment(\.managedObjectContext, moc)
                })
                
                
                
            }
            .frame(width:width-60, height:width/1)
            
        }.onReceive(timer, perform: { _ in
            print(startGame)
            data.getData()
        })
    }
}
