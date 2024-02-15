//
//  UploadWithEscaping.swift
//  DownloadWithEscaping
//
//  Created by Mallik, Sudip on 2/13/24.
//

import SwiftUI

struct ToDoResponseModel: Identifiable, Codable {
  var userId: Int
  var id: Int?
  var title: String
  var completed: Bool
}

class UploadWithEscapingViewModel: ObservableObject {
  @Published var toDoResponseArray: [ToDoResponseModel] = []
  
  init() {
    getData()
  }
  
  func getData() {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else { return }
    guard let jsonData = getJsonData(source: "local") else { return }
    guard let postRequest = setRequestData(url: url, jsonData: jsonData) else { return }
    
    URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
      guard
        let data = data,
        error == nil,
        let response = response as? HTTPURLResponse,
        response.statusCode >= 200 && response.statusCode < 300 else {
        return
      }
      print(data)
      guard let toDoResponse = try? JSONDecoder().decode(ToDoResponseModel.self, from: data) else {
        print("Error encountered during decoding data.")
        return
      }
      DispatchQueue.main.async { [weak self] in
        self?.toDoResponseArray.append(toDoResponse)
      }
    }.resume()
  }
  
  func getJsonData(source: String) -> Data? {
    var userData: Data? = nil
    if source == "file" {
      guard let sourcesUrl = Bundle.main.url(forResource: "firstUser", withExtension: "json") else {
        fatalError("Could't locate the data file.")
      }
      guard let fileData = try? Data(contentsOf: sourcesUrl) else {
        fatalError("Could't convert user data.")
      }
      userData = fileData
    } else {
      let newToDoItem = ToDoResponseModel(userId: 300, id: 1, title: "Urgent task number 2", completed: false)
      guard let localData = try? JSONEncoder().encode(newToDoItem) else {
        fatalError("Could't initialize the data model.")
      }
      userData = localData
    }
    return userData
  }
}

func setRequestData(url: URL, jsonData: Data) -> URLRequest? {
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Accept")
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  request.httpBody = jsonData
  return request
}

struct UploadWithEscaping: View {
  @StateObject var vm = UploadWithEscapingViewModel()
  var body: some View {
    List {
      ForEach(vm.toDoResponseArray) { post in
        Text("User ID: \(post.id ?? 99)")
        VStack(alignment: .leading) {
          Text("ID: \(post.userId)")
          Text("Title: \(post.title)")
          Text("Completed: \(post.completed.description)")
        }
      }
    }
  }
}

#Preview {
    UploadWithEscaping( )
}
