//
//  TabBarView1.swift
//  CustomTabBar
//
//  Created by Pratik on 14/10/22.
//

import SwiftUI
enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case home, game, apps, movie
    
    internal var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .game:
            return "gamecontroller.fill"
        case .apps:
            return "square.stack.3d.up.fill"
        case .movie:
            return "play.tv.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .game:
            return "Games"
        case .apps:
            return "Apps"
        case .movie:
            return "Movies"
        }
    }
    
    var color: Color {
        switch self {
        case .home:
            return .indigo
        case .game:
            return .pink
        case .apps:
            return .orange
        case .movie:
            return .teal
        }
    }
}
let backgroundColor = Color.init(white: 0.92)

struct TabBarView2: View {
    let bgColor: Color = .init(white: 0.9)
    
    var body: some View {
        ZStack {
            backgroundView
            
            TabsLayoutView()
                .frame(height: 90, alignment: .center)
                .clipped()
        }
        .frame(height: 90, alignment: .center)
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder private var backgroundView: some View {
        LinearGradient(colors: [.init(white: 0.9), .white], startPoint: .top, endPoint: .bottom)
            .mask {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(lineWidth: 6)
            }
        
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
}

fileprivate struct TabsLayoutView: View {
    @State var selectedTab: Tab = .home
    @Namespace var namespace
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            
            ForEach(Tab.allCases) { tab in
                TabButton(tab: tab, selectedTab: $selectedTab, namespace: namespace)
                    .frame(width: 55, height: 55, alignment: .center)
                
                Spacer(minLength: 0)
            }
        }
    }
    
    private struct TabButton: View {
        let tab: Tab
        @Binding var selectedTab: Tab
        var namespace: Namespace.ID
        
        var body: some View {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.3)) {
                    selectedTab = tab
                }
            } label: {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(
                                Color.white
                            )
                            .overlay(content: {
                                LinearGradient(colors: [.white.opacity(0.0001), tab.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                            })
                        
                            .matchedGeometryEffect(id: "Selected Tab", in: namespace)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? tab.color : .gray)
                        .scaleEffect(isSelected ? 1 : 0.9)
                        .animation(isSelected ? .spring(response: 0.5, dampingFraction: 0.3, blendDuration: 1) : .spring(), value: selectedTab)
                }
            }
        }
        
        private var isSelected: Bool {
            selectedTab == tab
        }
    }
}

struct TabBarView2_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView2()
    }
}
