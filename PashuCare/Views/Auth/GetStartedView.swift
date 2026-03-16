//
//  GetStartedView.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//


import SwiftUI

struct GetStartedView: View {

    @EnvironmentObject var router: NavigationRouter
    @State private var animateOut = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                    .scaleEffect(animateOut ? 0.92 : 1.0)
                    .opacity(animateOut ? 0.0 : 1.0)

                HStack(spacing: 6) {
                    Text("CattleCare")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)

                    Text("AI")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.green)
                }
                .scaleEffect(animateOut ? 0.96 : 1.0)
                .opacity(animateOut ? 0.0 : 1.0)

                Text("Smart Cattle Maintenance & Disease Prediction")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(animateOut ? 0.0 : 1.0)

                Spacer()
            }
            .animation(.easeInOut(duration: 0.55), value: animateOut)
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.easeInOut(duration: 0.55)) {
                    animateOut = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    router.push(.welcome) 
                }
            }
        }
    }
}
#Preview {
    GetStartedView()
}
