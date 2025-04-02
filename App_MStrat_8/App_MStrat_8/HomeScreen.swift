import SwiftUI

struct CategoryNameViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = CategoryNameViewController()
        return UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
}


struct HomeView: View {
    @State private var showCategoryView = false
    @State private var amount: String = ""
    @State private var waveOffset: CGFloat = 0.0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    
                    // Water Progress View
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 120, height: 120)
                        WaveView(offset: waveOffset)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        Text("200/2000")
                            .font(.headline)
                    }
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                            waveOffset = .pi * 2
                        }
                    }
                    
                    // Amount Input
                    HStack {
                        TextField("Enter Amount", text: $amount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Add") {}
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Remaining Allowance & Total Expense
                    HStack {
                        SummaryBox(title: "Remaining Allowance", amount: "Rs 3995", color: .green)
                        Divider()
                        SummaryBox(title: "Total Expense", amount: "Rs 1105", color: .red)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Expense Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Expense").font(.headline)
                            Spacer()
                            Button(action: {
                                showCategoryView.toggle()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                            .sheet(isPresented: $showCategoryView) {
                                CategoryNameViewControllerWrapper() // Open UIKit ViewController in SwiftUI
                            }
                        }
                        .padding(.bottom, 5)

                        // Expense Items
                        HStack {
                            ExpenseItem(category: "Rent", amount: "Rs 12000", icon: "house.fill")
                            ExpenseItem(category: "Shopping", amount: "Rs 100", icon: "cart.fill")
                         
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Badges Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Badges").font(.headline)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        // Badge Items
                        HStack {
                            BadgeItem(title: "Savings Star", imageName: "star.fill")
                            BadgeItem(title: "Budget Master", imageName: "crown.fill")
                            BadgeItem(title: "Expense Tracker", imageName: "chart.bar.fill")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .navigationBarItems(trailing:
                NavigationLink(destination: GoalViewControllerWrapper()) {
                    Image("icons8-wallet-100")
                        .resizable()
                        .frame(width: 34, height: 34)
                }
            )
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}

// Summary Box
struct SummaryBox: View {
    var title: String
    var amount: String
    var color: Color
    
    var body: some View {
        VStack {
            Text(title).font(.subheadline)
            Text(amount).font(.title3).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// Expense Item Box
struct ExpenseItem: View {
    var category: String
    var amount: String
    var icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon).font(.title)
            Text(category)
            Text(amount).font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// Badge Item Box
struct BadgeItem: View {
    var title: String
    var imageName: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.yellow)
            Text(title)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// Water Animation View
struct WaveView: View {
    var offset: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let path = Path { path in
                let waveHeight: CGFloat = 10
                let frequency = 4.0
                let step = size.width / CGFloat(frequency * 2)
                
                path.move(to: .zero)
                for i in stride(from: 0, to: size.width, by: step) {
                    let x = i
                    let y = sin(x / size.width * .pi * 2 + offset) * waveHeight + (size.height / 2)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.closeSubpath()
            }
            context.fill(path, with: .color(Color.blue.opacity(0.7)))
        }
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
