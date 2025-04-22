//
//  Playing.swift
//  BounceAnimation
//
//  Created by 0000 on 4/23/25.
//

/*
 
 ripple modifier는 attached된 뷰의 raster layer를 기준으로 처리해서 뷰를 반환한다.
 즉, 스크린 상의 픽셀의 final 색상 정보를 읽는 게 아니다.
 
 
 Shader는 ripple을 적용할 뷰의 좌표계를 기준으로 origin을 처리함.
 onTapGesture에서 action 클로져 파라미터에 넘겨주는 터치 CGPoint를 @State var origin에 업데이트할 때, 좌표계의 매칭이 중요함.
 onTapGesture에서 get하는 터치 CGPoint의 coordinateSpace를 매칭시켜야 한다.
 만약 onTapGesture가 attached된 뷰와 ripple을 적용시킬 뷰가 다르고, 서로 다른 coordinateSpace를 사용할 경우, .onTapGesture(coordinateSpace: .local)로 action에 넘겨주면 터치 지점과 파동의 진원이 매칭되지 않는다.
 
 
 */



import SwiftUI

struct Playing: View {
    @State var trigger: Int = 0
    @State var isTap: Bool = false
    @State var origin: CGPoint = .zero
    
    
    var body: some View {
        ZStack {
            VStack {
                ForEach(0..<10, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.red)
                }
            }
//            .offset(y:300)
//            .offset(y:300)
//            .ignoresSafeArea(.all)
            .coordinateSpace(name: "rippleHere")
            .modifier(RippleEffect(at: origin, trigger: trigger))
//            .ignoresSafeArea(.all)



            
//            Rectangle()
//                .frame(width: origin.x, height: origin.y)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                .ignoresSafeArea()
            
            Rectangle()
                .fill(isTap ? Color.red : Color.blue)
                .opacity(0.2)
                .frame(width: 300, height: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .ignoresSafeArea(.all)
//                .modifier(RippleEffect(at: origin, trigger: trigger))
//                .contentShape(Rectangle())
                .onTapGesture(coordinateSpace: .named("rippleHere")) { location in
                    origin = location
                    trigger += 1
                    print(location)
                }
            
        }
    }
}

#Preview {
    Playing()
}
