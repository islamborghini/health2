import SwiftUI

struct ContentView: View {
//let chatViewModel = ChatViewModel() // Create an instance of ChatViewModel
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome")
                    .font(.system(size: 36))
                    .padding()
                Text("Wellth")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
                Button("Sign In", action: signUp)
                    .padding()
                Button("Login", action: login)
                    .padding()
                NavigationLink(destination: ChatViewModel()) {
                    Text("Show Detail").padding()
                }
                NavigationLink(destination: HealthManagerView()) {
                    Text("Your Current Data").padding()
                }
                // NavigationLink(destination: Chatbot(viewModel: chatViewModel)) {
                //     Text("Chatbot")
            }
            .padding()
        }}
        
    
    
    func signUp() {
        print("Sign up action")
    }
    
    func login() {
        print("Log in action")
    }
}
