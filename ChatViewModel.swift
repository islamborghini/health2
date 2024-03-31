import SwiftUI
import Combine

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var isUser: Bool
}

class Chatbot {
    var cancellables: Set<AnyCancellable> = []
    
    func reply(to message: String, completion: @escaping (String) -> Void) {
        // Simulate network request to OpenAI API
        requestReplyFromOpenAI(for: message) { response in
            completion(response)
        }
    }
    
    private func requestReplyFromOpenAI(for message: String, completion: @escaping (String) -> Void) {
        // This is a placeholder for actual API request logic
        // In a real scenario, you would make an HTTP request to the OpenAI API here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulating network delay
            let reply = "This is a simulated reply for: \(message)"
            completion(reply)
        }
    }
}

struct ChatViewModel: View {
    @State private var messages: [Message] = []
    @State private var inputMessage = ""
    let chatbot = Chatbot()
    
    var body: some View {
        VStack {
            List(messages) { message in
                Text(message.content)
                    .padding(8)
                    .background(message.isUser ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(5)
                    .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
            }
            
            HStack {
                TextField("Enter your message", text: $inputMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                
                Button(action: sendMessage) {
                    Text("Send")
                }
                .padding(8)
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(5)
            }
            .padding()
        }
    }
    
    func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        let userMessage = Message(content: inputMessage, isUser: true)
        messages.append(userMessage)
        
        chatbot.reply(to: inputMessage) { botReply in
            let botMessage = Message(content: botReply, isUser: false)
            DispatchQueue.main.async {
                self.messages.append(botMessage)
            }
        }
        
        inputMessage = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatViewModel()
    }
}
