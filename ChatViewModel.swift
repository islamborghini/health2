import SwiftUI

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var isUser: Bool
}

struct ChatViewModel: View {
    @State private var messages: [Message] = []
    @State private var inputMessage = ""
    @State private var apiKey = "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" // You should securely manage this API key
    
    init() {
            // Create the default message
            let defaultMessageContent = "My sleep: 11,68 hours, my steps in last 3 days: 0,0,376"
            // Set the input message to the default content
            _inputMessage = State(initialValue: defaultMessageContent)
            
            // Add the default message as the first message in the chat from the system/bot
            let defaultMessage = Message(content: defaultMessageContent, isUser: false)
            _messages = State(initialValue: [defaultMessage])
        }
    
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

        requestReplyFromOpenAI(for: inputMessage) { reply in
            DispatchQueue.main.async {
                let botMessage = Message(content: reply, isUser: false)
                self.messages.append(botMessage)
            }
        }

        inputMessage = ""
    }

    private func requestReplyFromOpenAI(for message: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": message]
            ] as [[String: Any]]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            completion("Error serializing request body.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network request failed: \(String(describing: error))")
                completion("Network request failed.")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "Invalid response data"
                    print("Failed to parse response: \(responseString)")
                    completion("Failed to parse response.")
                }
            } catch {
                print("Failed to parse response: \(error)")
                completion("Failed to parse response.")
            }
        }

        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatViewModel()
    }
}
