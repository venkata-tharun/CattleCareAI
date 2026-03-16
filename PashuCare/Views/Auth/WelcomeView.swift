//
//  WelcomeView.swift
//  PashuCare
//
//  Created by SAIL on 27/02/26.
//


import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // MARK: - Logo in Hex
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 260)
                .foregroundColor(Color.green)

            Spacer().frame(height: 16)

            // MARK: - Title
            Text("Welcome to")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)

            Text("CattleCare AI")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.green)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 18)

            // MARK: - Subtitle
            Text("Manage your farm efficiently with AI-\npowered disease detection and smart\ntracking")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(.systemGray))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 28)

            Spacer()

            // MARK: - Buttons
            VStack(spacing: 16) {

                Button {
                    router.push(.login)
                } label: {
                    Text("Login")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }

                Button {
                    router.push(.createaccount)
                } label: {
                    Text("Create Account")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(.label))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color.green.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 18)

            // MARK: - Version
            Text("Version 1.0.0")
                .font(.system(size: 14))
                .foregroundColor(Color(.systemGray3))
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    WelcomeView()
}
