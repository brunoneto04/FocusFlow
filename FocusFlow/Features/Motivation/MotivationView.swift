import SwiftUI

// MARK: - Main View

/// Main view for displaying motivational quotes from ZenQuotes API
struct MotivationView: View {
    @StateObject private var viewModel = MotivationViewModel()
    @State private var showingFavorites = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var animateGlow = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient matching app theme
            OnboardingTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Animated glow background
            MotivationGlowBackground(isAnimating: animateGlow)
            
            VStack(spacing: 0) {
                // Main quote card
                quoteCardSection
                    .padding(.top, 20)
                
                // Action buttons
                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
        }
        .navigationTitle("Motivation")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFavorites = true
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
            Button("Retry") {
                Task {
                    await viewModel.fetchNewQuote()
                }
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onAppear {
            animateGlow = true
        }
    }
    
    // MARK: - Quote Card Section
    
    private var quoteCardSection: some View {
        ZStack {
            if viewModel.isLoading && viewModel.currentQuote.id == MotivationQuote.fallback.id {
                loadingView
            } else {
                quoteCard(viewModel.currentQuote)
                    .offset(x: cardOffset)
                    .rotationEffect(.degrees(cardRotation))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                cardOffset = value.translation.width
                                cardRotation = Double(value.translation.width / 20)
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 100
                                
                                if value.translation.width > threshold {
                                    // Swiped right - next quote
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        cardOffset = 500
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        viewModel.nextQuote()
                                        cardOffset = -500
                                        cardRotation = 0
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            cardOffset = 0
                                        }
                                    }
                                } else if value.translation.width < -threshold {
                                    // Swiped left - previous quote
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        cardOffset = -500
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        viewModel.previousQuote()
                                        cardOffset = 500
                                        cardRotation = 0
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            cardOffset = 0
                                        }
                                    }
                                } else {
                                    // Return to center
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        cardOffset = 0
                                        cardRotation = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
    
    private func quoteCard(_ quote: MotivationQuote) -> some View {
        VStack(spacing: 24) {
            // Quote icon with gradient
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 50))
                .foregroundStyle(OnboardingTheme.iconGradient)
                .padding(.top, 8)
            
            Spacer()
            
            // Quote content
            Text(quote.content)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .lineSpacing(4)
            
            // Author
            HStack(spacing: 4) {
                Text("—")
                    .foregroundColor(.secondary)
                Text(quote.author)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            Spacer()
            
            // Favorite button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleFavorite()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isCurrentQuoteFavorited() ? "heart.fill" : "heart")
                    Text(viewModel.isCurrentQuoteFavorited() ? "Favorited" : "Add to Favorites")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(viewModel.isCurrentQuoteFavorited() ? .accentColor : .secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(viewModel.isCurrentQuoteFavorited() 
                              ? Color.accentColor.opacity(0.15)
                              : Color(.systemGray6))
                )
            }
            .padding(.bottom, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                .fill(OnboardingTheme.cardBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                )
        )
        .shadow(color: OnboardingTheme.shadow, radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Previous button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    viewModel.previousQuote()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.canNavigatePrevious ? .primary : .secondary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(OnboardingTheme.cardBackground(for: colorScheme))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                            )
                    )
                    .shadow(color: OnboardingTheme.shadow, radius: 8, x: 0, y: 4)
            }
            .disabled(!viewModel.canNavigatePrevious)
            
            Spacer()
            
            // Refresh button
            Button {
                Task {
                    await viewModel.fetchNewQuote()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(OnboardingTheme.accentGradient)
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(
                            viewModel.isLoading 
                                ? .linear(duration: 1).repeatForever(autoreverses: false) 
                                : .default, 
                            value: viewModel.isLoading
                        )
                }
            }
            .disabled(viewModel.isLoading)
            
            Spacer()
            
            // Next button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    viewModel.nextQuote()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(OnboardingTheme.cardBackground(for: colorScheme))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                            )
                    )
                    .shadow(color: OnboardingTheme.shadow, radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentColor)
            Text("Loading inspiration...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                .fill(OnboardingTheme.cardBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                )
        )
        .shadow(color: OnboardingTheme.shadow, radius: 20, x: 0, y: 10)
    }
}

// MARK: - Glow Background

struct MotivationGlowBackground: View {
    let isAnimating: Bool
    @State private var offset: CGFloat = -200
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.accentColor.opacity(0.15),
                            Color.accentColor.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: offset, y: -200)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.1),
                            Color.purple.opacity(0.03),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: -offset * 0.8, y: 250)
                .blur(radius: 50)
        }
        .onAppear {
            if isAnimating {
                withAnimation(OnboardingAnimation.glow) {
                    offset = 200
                }
            }
        }
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @ObservedObject var viewModel: MotivationViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            // Background gradient
            OnboardingTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Animated glow
            MotivationGlowBackground(isAnimating: animateGlow)
            
            Group {
                if viewModel.favoriteQuotes.isEmpty {
                    emptyFavoritesView
                } else {
                    favoritesList
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            animateGlow = true
        }
    }
    
    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.favoriteQuotes) { quote in
                    FavoriteQuoteCard(quote: quote, viewModel: viewModel, colorScheme: colorScheme)
                }
            }
            .padding(20)
        }
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(OnboardingTheme.iconGradient)
            
            Text("No favorites yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Tap the heart icon on quotes you love to save them here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Favorite Quote Card

struct FavoriteQuoteCard: View {
    let quote: MotivationQuote
    @ObservedObject var viewModel: MotivationViewModel
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Quote content
            Text(quote.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            // Author and action
            HStack {
                Text("— \(quote.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.removeFavorite(quote)
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                .fill(OnboardingTheme.cardBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                )
        )
        .shadow(color: OnboardingTheme.shadow, radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview

#if DEBUG
struct MotivationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MotivationView()
        }
        .preferredColorScheme(.dark)
        
        NavigationView {
            MotivationView()
        }
        .preferredColorScheme(.light)
    }
}
#endif
