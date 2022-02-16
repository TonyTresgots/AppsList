//
//  OrderView.swift
//  ForCuisine
//
//  Created by PHILIP LIM on 05/03/2020.
//  Copyright © 2020 Philip Lim. All rights reserved.
//

import SwiftUI

struct OrderView: View {
     @Environment(\.presentationMode) var presentationMode

    var body: some View {
    Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
        Text("Order customization coming soon! \n\n🥣🍽")
        .font(.largeTitle)
        .fontWeight(.heavy)
        .multilineTextAlignment(.center)
        .foregroundColor(Color("orange"))

        }
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}
