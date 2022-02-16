//
//  MenuView.swift
//  KababCloudKit
//
//  Created by PHILIP LIM on 01/03/2020.
//  Copyright © 2020 Philip Lim. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    var dishes: [Dish] = dishesData
    @EnvironmentObject var viewOption: ViewOption
    @State private var show_modal: Bool = false
    @State private var opacity = 1.0
    @State private var courseIndex = 0
    @State private var orderDishIngradients = false
    @State private var courses = [NSLocalizedString("Starter", comment: ""), NSLocalizedString("Main", comment: ""), NSLocalizedString("Dessert", comment: "")]
    
    var dishcourse: [Dish] {
        dishes.filter { $0.course == courses[courseIndex] } 
    }
    
    var body: some View {
        ScrollView {
            HStack (alignment: .top ) {
                ZStack  {
                    Button(action:  {
                        withAnimation(.linear(duration: 6)) {
                            self.opacity -= 0.5
                        }; do {self.viewOption.currentPage = "highlights"}
                    } ) {
                        Image(systemName: "house.fill")
                            .foregroundColor(Color("orange"))
                    }
                    .frame(width: 36, height: 36)
                    .background(Color.init(hue: 0.1, saturation: 0.3, brightness: 0.97))
                    .clipShape(Circle())
                    .padding().offset(x: UIScreen.main.bounds.width/2-40, y: -24)
                    
                    
                    VStack (alignment: .leading) {
                        Text("Soraya Tea House")
                            .font(.title)
                            .fontWeight(.heavy)
                        Text(NSLocalizedString("Full menu", comment: ""))
                            .foregroundColor(.gray)
                        
                        Picker(selection: $courseIndex, label: Text("Text")) {
                            ForEach(0..<courses.count) { index in
                                Text(self.courses[index]).tag(index)
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                            .frame(width: UIScreen.main.bounds.width-40)
                            .background(Color("orange"))
                            .cornerRadius(9.5)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(dishcourse) { dish in
                        GeometryReader { geometry in
                            DishView(dish: dish)
                                .rotation3DEffect(Angle(degrees: Double(
                                    (geometry.frame(in: .global).minX - 30) / -30
                                )), axis: (x: 0, y: 10, z: 0))
                        }
                    }
                    .frame(width: 366, height: UIScreen.main.bounds.height)
                    .padding(.horizontal, 16)
                    Spacer()
                }
            }
        }
        .background(Color("background1"))
    }
}


struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView().environmentObject(ViewOption())
    }
}
