//
//  LeadersView.swift
//  NBA
//
//  Created by Ali Earp on 16/05/2024.
//

import SwiftUI

struct LeadersView: View {
    @State var view: String = "Season"
    
    init() {
        UISegmentedControl.appearance().backgroundColor = UIColor.systemGray5
    }
    
    var body: some View {
        ZStack {
            SeasonLeadersView()
                .opacity(view == "Season" ? 1 : 0)
            
            AllTimeLeadersView()
                .opacity(view == "All Time" ? 1 : 0)
        }
        .navigationTitle("\(view) Leaders")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            viewPicker
        }
    }
    
    var viewPicker: some View {
        Picker("", selection: $view) {
            Text("Season")
                .tag("Season")
            
            Text("All Time")
                .tag("All Time")
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

#Preview {
    NavigationStack {
        LeadersView()
    }
}
