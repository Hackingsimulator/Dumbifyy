//
//  ContentViewModel.swift
//  Todo-CoreData-LockScreen
//
//  Created by Kim Insub on 2022/10/11.
//

import CoreData
import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var userInput = ""
    @Published var todoList: [TodoEntity] = []
    @Published var doneTodoList: [TodoEntity] = []
    @Published var inProgressTodoList: [TodoEntity] = []
    @Published var showDuplicateAlert: Bool = false

    init() {
        getAllTodos()
    }

    // MARK: - View Interaction Functions
    func didSubmitTextField() {
        if !userInput.isEmpty {
            Task {
                await createTodo()
                clearUserinput()
                getAllTodos()
            }
        }
    }
    func doesTodoExist(title: String) -> Bool {
        return inProgressTodoList.contains {
            $0.title?.localizedCaseInsensitiveCompare(title) == .orderedSame
        }
    }


    func didTapTodo(todo: TodoEntity) {
        Task {
            await editTodo(todo: todo)
            getAllTodos()
        }
    }

    func didSwipeTodo(todo: TodoEntity) {
        Task {
            await deleteTodo(todo: todo)
            getAllTodos()
        }
    }

    func didTapXbutton() {
        clearUserinput()
    }
}

private extension MainViewModel {
    func getAllTodos() {
        let response = CoreDataManager.shared.getAllTodos()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.todoList = response
            withAnimation {
                self.inProgressTodoList = self.todoList.filter({ todo in
                    todo.hasDone == false
                })
                self.doneTodoList = self.todoList.filter({ todo in
                    todo.hasDone == true
                })
            }
        }
    }
    
    func createTodo() async {
        CoreDataManager.shared.createTodo(title: userInput)
    }

    func editTodo(todo: TodoEntity) async {
        CoreDataManager.shared.editTodo(todo: todo)
    }

    func deleteTodo(todo: TodoEntity) async {
        CoreDataManager.shared.deleteTodo(todo: todo)
    }

    func clearUserinput() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.userInput = ""
        }
    }
}
