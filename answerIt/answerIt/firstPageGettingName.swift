//  firstPageGettingName.swift
//  answerIt
//  Created by admin on 2021/8/31.

import SwiftUI

struct firstPageGettingName: View {
    @EnvironmentObject var data:datauser
    @Environment(\.managedObjectContext) var moc
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    @State var nickName = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var twoSecond = 2
    @State var confirm = false
    
    @FetchRequest(entity: User.entity(), sortDescriptors: []) private var user:FetchedResults<User>
    
    var body: some View {
        ZStack{
            Color("cyan").ignoresSafeArea()
            firstRectangle(width: width, height: height)
            secondRectangle(width: width, height: height)
            thirdRectangle(width: width, height: height)
            
            
            circle(width: width, height: height)
                .offset(x: -width/5, y: -height/4)
            
            VStack{
                
                ZStack{
                    Rectangle()
                        .frame(width:width-40, height: width/1.5)
                        .foregroundColor(Color("red"))
                        .cornerRadius(25)
                        .shadow(radius:3)
                    
                    getNameView(width: width)
                        .environmentObject(data)
                        .environment(\.managedObjectContext, moc)
                    
                }
                
                
            }.frame(width: width, height: height)
        }
    }
}

struct firstPageGettingName_Previews: PreviewProvider {
    static var previews: some View {
        firstPageGettingName()
    }
}
struct firstRectangle:View{
    @State var width:CGFloat = 0
    @State var height:CGFloat = 0
    var body: some View{
        Rectangle()
            .foregroundColor(Color("yellow"))
            .frame(width: width, height: height/2)
            .cornerRadius(15)
            .rotationEffect(.init(degrees: 35))
            .offset(x: width/3.5, y: -height/1.5)
        
    }
}

struct secondRectangle: View {
    @State var width:CGFloat = 0
    @State var height:CGFloat = 0
    var body: some View {
        Rectangle()
            .foregroundColor(Color("purple"))
            .frame(width: width, height: width)
            .cornerRadius(15)
            .offset(x: width/9, y: height/1.8)
            .rotationEffect(.init(degrees: -45))
    }
}

struct thirdRectangle: View {
    @State var width:CGFloat = 0
    @State var height:CGFloat = 0
    var body: some View {
        Rectangle()
            .foregroundColor(Color("purple"))
            .frame(width: width, height: width)
            .cornerRadius(15)
            .offset(x: -width/3, y: height/1.8)
            .rotationEffect(.init(degrees: 45))
    }
}

struct circle: View {
    @State var width:CGFloat = 0
    @State var height:CGFloat = 0
    
    var body: some View {
        ZStack{
            Circle()
                .frame(width: width/2, height: width/2)
                .foregroundColor(.white)
                .opacity(0.2)
                .shadow(radius:2)
            
            Circle()
                .frame(width: width/3, height: width/3)
                .foregroundColor(.white)
                .opacity(0.2)
                .shadow(radius:2)
            
        }
    }
}

struct getNameView: View {
    @State var width:CGFloat = 0
    @State var confirm = false
    @State var show = false
    @State var nickName = ""
    @EnvironmentObject var data:datauser
    @Environment(\.managedObjectContext) var moc
    var body: some View {
        VStack{
            
            Text("ادخل اسمك المستعار ")
                .font(.custom("Almarai-Bold", size: 25))
                .padding(.top)
                .foregroundColor(Color("yellow"))
            
            ZStack{
                
                
                Rectangle()
                    .frame(width:show ? width-100:0, height:show ? 55:0, alignment: .leading)
                    .foregroundColor(Color.white)
                    .opacity(0.2)
                    .cornerRadius(10)
                
                
                TextField(". . . . .", text: $nickName)
                    
                    .frame(width:show ? width-100:0, height:show ? 75:0, alignment: .trailing)
                    .padding(.leading)
                    .font(.custom("Almarai-Bold", size: 20))
                    .background(Color("cyan"))
                    .cornerRadius(20)
                    .multilineTextAlignment(.center)
                
            }
            
            Spacer()
            
            Button(action: {
                confirm = true
                addNewUser()
            }, label: {
                Text("تأكيد")
                    .font(.custom("Almarai-Bold", size: 25))
                    .frame(width: width-140, height: 30, alignment: .center)
                    .padding(.vertical,10)
                    .padding(.horizontal,20)
                    .foregroundColor(Color(.white))
                    .background(Color("purple"))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .opacity(nickName.count == 0 ? 0.6:1)
            })
            .disabled(nickName.count == 0 ? true:false)
            .fullScreenCover(isPresented: $confirm, content: {
                secondPage().environmentObject(data)
                    .environment(\.managedObjectContext, moc)
            })
            .padding(.bottom)
            
        }
        .frame(width:width-40, height:width/1.5)
        .onAppear{
            show = true
        }
        .padding(.vertical)
    }
    
    func addNewUser(){
        let newUser = User(context: moc)
        newUser.userName = nickName
        newUser.registerDate = Date()
        do {
            try moc.save()
        }catch{
            print(error)
        }
    }
}
