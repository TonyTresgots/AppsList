//
//  ContentView.swift
//  KababCloudKit
//
//  Created by PHILIP LIM on 22/02/2020.
//  Copyright © 2020 Philip Lim. All rights reserved.
//
import Foundation
import Combine
import SwiftUI
import ARKit
import SceneKit
import RealityKit
import SceneKit.ModelIO

// Set ObservableObject for two views - Highlights and Menu
// Need to update the SceneDelegate.swift file to include the ViewOption as ObservableObject

class ViewOption: ObservableObject {
    let objectWillChange = PassthroughSubject<ViewOption,Never>()
    
    var currentPage: String = "highlights" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}


struct ContentView: View {
    // The is the main logic for deciding which view to present
    @EnvironmentObject var viewOption: ViewOption
    
    var body: some View {
        HStack  {
            if viewOption.currentPage == "highlights" {
                HighlightView()
                    .transition(.scale)
            } else if viewOption.currentPage == "menu" {
                MenuView()
                    .transition(.scale)
            } else if viewOption.currentPage == "order" {
                OrderView()
                    .transition(.scale)
            }
        }
    }
}

struct HighlightView: View {
    
    @EnvironmentObject var viewOption: ViewOption
    var dishes = dishesData
    
    
    var body: some View {
        ScrollView {
            HStack (alignment: .top ) {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("Specialities", comment: ""))
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text(NSLocalizedString("Our recommendations", comment: ""))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.leading, 26)
            .padding(.bottom, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(dishes) { dish in
                        if dish.frontpage == true {
                            
                            GeometryReader { geometry in
                                
                                DishView(dish: dish)
                                    .rotation3DEffect(Angle(degrees: Double(
                                        (geometry.frame(in: .global).minX - 30) / -30
                                    )), axis: (x: 0, y: 10, z: 0))
                            }
                        }
                    }
                    .frame(width: 366, height: UIScreen.main.bounds.height+200)
                    .padding(.horizontal, 6)
                    Spacer()
                }
            }
        }
        .background(Color("background1"))
    }
}


struct DishView : View {
    @State var isActive = false
    @State private var show_modal: Bool = false
    @EnvironmentObject var viewOption: ViewOption
    
    var dish = Dish(name: "", image: "dishkababbeef", cuisine: "Persian",
                    course: "Main",
                    ingredients: "meat", allergicContent: "milk", description: " ", price: 12, story: " ", restaurant: "Soraya Tea House", usdzModel: "chicken_meal", frontpage: true)
    
    var body: some View {
        return VStack {
            ZStack {
                Image(dish.image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .blur(radius: dish.usdzModel == nil ? 0 : 20)
                    .cornerRadius(20)
                    .padding(1)
                
                if dish.usdzModel != nil {
                    
                    ScenekitView(dishUsdzFile: dish.usdzModel).frame(width: 366)
                    
                    NavigationLink(
                        destination: ARKitWorldView(meal: dish),
                        isActive: $isActive,
                        label: { Button(action: { self.isActive = true }, label: { Image("AR-icon").resizable().frame(width: 36, height: 36).padding(.top, 220).isHidden(dish.usdzModel == nil ? true : false, remove: dish.usdzModel == nil ? true : false) }) }).foregroundColor(Color("orange"))
                }
            }
            
            Text(dish.cuisine)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(3)
            Text(dish.name)
                .font(.system(.title, design: .rounded))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(3)
            Text(dish.story)
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.bottom, 3)
            Text(dish.ingredients)
                .font(.system(.body, design: .monospaced))
                .kerning(0.6)
                .foregroundColor(.gray)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .lineLimit(6)
                .padding(3)
            Text(dish.allergicContent)
                .kerning(0.6)
                .foregroundColor(.gray)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .background(Color.yellow)
                .lineLimit(2)
                .padding(.top, 3)
                .padding(.bottom, 20)
            Text(dish.description)
                .font(.system(.body, design: .rounded))
                .lineLimit(100)
                .lineSpacing(3)
                .frame(width: UIScreen.main.bounds.width-36)
            
            
            Spacer()
            
            if self.viewOption.currentPage == "highlights" {
                Button(action: {self.viewOption.currentPage = "menu"}) {
                    Text(NSLocalizedString("See Full Menu", comment: ""))
                        .foregroundColor(.black)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 12)
                        .background(Color("orange"))
                        .animation(.default)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) }}
            else {
                Button(action: {self.show_modal = true}) {
                    Text(NSLocalizedString("Ready to Order", comment: ""))
                        .foregroundColor(.black)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 12)
                        .background(Color("orange"))
                        .animation(.default)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .sheet(isPresented: self.$show_modal) {
                            OrderView()
                    }
                }
            }
        }
        .shadow(color: Color(hue: 0.077, saturation: 0.501, brightness: 0.788, opacity: 0.4), radius: 9, x: 0, y: 6)
    }
    
}

struct ScenekitView : UIViewRepresentable {
    
    var dishUsdzFile : String?
    
    func makeUIView(context: Context) -> SCNView {
        
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        
        scnView.isUserInteractionEnabled = true
        
        if let url = Bundle.main.url(forResource: "art.scnassets/\(dishUsdzFile ?? "")", withExtension: "usdz") {
            
            var scene = SCNScene()
            
            DispatchQueue.global(qos: .userInteractive).async {
                print("We're on a global concurrent queue!")
                let mdlAsset = MDLAsset(url: url)
                mdlAsset.loadTextures()
                scene = SCNScene(mdlAsset: mdlAsset)
                
                var objectDish = SCNNode()
                
                for item in scene.rootNode.childNodes {
                    if item.name != nil {
                        if item.name == self.dishUsdzFile {
                            objectDish = item
                        }
                    }
                }
                
                let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.01 * Double.pi), z: 0, duration: 0.1))
                objectDish.runAction(rotate)
                
                scnView.scene = scene
            }
            
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            scene.rootNode.addChildNode(cameraNode)
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
            scene.rootNode.addChildNode(lightNode)
            
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = .ambient
            ambientLightNode.light!.color = UIColor.darkGray
            scene.rootNode.addChildNode(ambientLightNode)
            
            scnView.scene = scene
            
            scnView.allowsCameraControl = true
            
            scnView.autoenablesDefaultLighting = true
        } else {
            scnView.scene = SCNScene()
        }
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        //           guard let url = Bundle.main.url(forResource: "art.scnassets/\(dishUsdzFile)", withExtension: "usdz") else { fatalError() }
        

        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewOption())
    }
}
