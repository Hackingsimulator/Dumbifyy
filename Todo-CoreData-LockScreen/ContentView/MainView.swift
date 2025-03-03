//
//  ContentView.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import SwiftUI
import WidgetKit

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var viewModel = MainViewModel()
    var body: some View {
            List {
                addTodoSection
                inProgressTodoListSection
            }
            .onChange(of: scenePhase, perform: { newValue in
                WidgetCenter.shared.reloadAllTimelines()
            })
            .onOpenURL { url in
                print(url)
                handleURL(url)
            }
            .background(Color.black)
            .listStyle(GroupedListStyle())
            .environment(\.colorScheme, .dark)
            .alert("Duplicate Item", isPresented: $viewModel.showDuplicateAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("This item already exists in your to-do list.")
                    }
        }
    private func handleURL(_ url: URL) {
        guard url.scheme == "todo" else {
            return
        }
        
        if url.host == "todo" {
            if url.pathComponents.count > 1 {
                let appName = url.pathComponents[1]
                openApp(appName)
            }
        } else {
           print("fail")
        }
        
    }
    
    private func openApp(_ appName: String) {
        let urlString = getURLString(for: appName)
        print(urlString)
        if let appURL = URL(string: urlString) {
            print("trying")
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        }
    }
    
    private func getURLString(for appName: String) -> String {
        return AppLinks[appName] ?? ""
    }
}

private extension MainView {
    var addTodoSection: some View {
        Section("Add") {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Enter", text: $viewModel.userInput) {
                        viewModel.didSubmitTextField()
                    }
                    Spacer()
                    Image(systemName: "x.circle")
                        .onTapGesture {
                            viewModel.didTapXbutton()
                        }
                        .opacity(0.6)
                        .font(.subheadline)
                }
                
                // Show filtered AppLinks keys only when typing
                if !viewModel.userInput.isEmpty {
                    ForEach(Array(AppLinks.keys).filter {
                        $0.localizedCaseInsensitiveContains(viewModel.userInput)
                    }, id: \.self) { key in
                        HStack(spacing: 4) {
                            Text(key)
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    // Check for duplicates
                                    if !viewModel.doesTodoExist(title: key) {
                                        viewModel.userInput = key
                                        viewModel.didSubmitTextField()
                                    } else {
                                        viewModel.showDuplicateAlert = true
                                    }
                                }
                        }
                    }
                }

            }
        }
    }

   var inProgressTodoListSection: some View {
       Section("Apps in the widget") {
           ForEach(viewModel.inProgressTodoList, id: \.self) { todo in
               HStack(spacing: 4) {
                   Text(todo.title ?? "")
               }
               .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                   Button {
                       withAnimation {
                           viewModel.didSwipeTodo(todo: todo)
                       }
                   } label: {
                       Image(systemName: "trash")
                   }
                   .tint(.red)
               }
           }
       }
   }
   var doneTodoListSection: some View {
       Section("Done") {
           ForEach(viewModel.doneTodoList, id: \.self) { todo in
               HStack(spacing: 4) {
                   Button {
                       withAnimation {
                           viewModel.didTapTodo(todo: todo)
                       }
                   } label: {
                       Image(systemName: "checkmark.square")
                           .font(.caption)
                   }
                   Text(todo.title ?? "")
                       .strikethrough()
               }

               .opacity(0.6)
               .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                   Button {
                       withAnimation {
                           viewModel.didSwipeTodo(todo: todo)
                       }
                   } label: {
                       Image(systemName: "trash")
                   }
                   .tint(.red)
               }
           }
       }
   }
}
#Preview(){
    MainView()
}
