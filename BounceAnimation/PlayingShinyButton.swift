//
//  PlayingShinyButton.swift
//  BounceAnimation
//
//  Created by 0000 on 4/23/25.
//

import SwiftUI

struct PlayingShinyButton: View {
    @State var buttonIsPressed: Bool = false
    
    var body: some View {
        ZStack {
            Color(buttonIsPressed ? .red : .blue)
            
//            Button {
//                buttonIsPressed.toggle()
//            } label: {
//                Circle()
//                    .fill(.ultraThinMaterial)
//                    .blur(radius: 50, opaque: false)
//                    .frame(width: 345, height: 345)
//                    .overlay(content: {
//                        Circle().stroke(lineWidth: 5).fill(.gray)
//                    })
//                    .background {
//                        MeshGradientView(t: 0)
//                            .clipShape(Circle())
//                    }
//                    .contentShape(Circle())
//            }
            Button {
                buttonIsPressed.toggle()
            } label: {
                Text("Bounce!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 345, height: 345)
                                .background(
                                    // ① 시간에 따라 끊임없이 업데이트되는 뷰
                                    TimelineView(.animation) { context in
                                        // 0~360° 사이를 10초 주기로 반복
                                        let seconds = context.date.timeIntervalSinceReferenceDate
                                        let angle = Angle.degrees((seconds.truncatingRemainder(dividingBy: 10)) * 36)

                                        // ② 무지개색이 원 중심을 축으로 회전하는 그라디언트
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                .red, .orange, .yellow, .green, .blue, .purple, .red
                                            ]),
                                            center: .center,
                                            angle: angle
                                        )
                                        .blur(radius: 20)  // ③ 부드러운 블러
                                    }
                                )
                                .clipShape(Circle()) // ④ 원으로 자르기
                                .contentShape(Circle())

            }
        }
    }
}

#Preview {
    PlayingShinyButton()
}
