//
//  ViewExtensions.swift
//
//  Created by Pedro Cavaleiro on 30/04/2020.
//  Copyright © 2020 Pedro Cavaleiro. All rights reserved.
//
//  Description
//  This file contains some extensions to SwiftUI views that I find usefull
//

import SwiftUI

public extension View {

    // Allows to create a condition to modify a component
    // It's not possible (at least with this code) to use multiple ifs
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> TupleView<(Self?, Content?)> {
        if conditional {
            return TupleView((nil, content(self)))
        } else {
            return TupleView((self, nil))
        }
    }
    
    // Allows to execute a function based on a condition, usefull when you want to run a peice of code
    // when a state changes and you want to re check the status
    func `funcIf`(_ conditional: Bool, action: @escaping (()->())) -> (Self?) {
        action()
        return self
    }
    
    // Allows to execute code when the state of the view changes
    func `exec`(action: @escaping (() -> ())) -> (Self?) {
        action()
        return self
    }

    // Allows a SwiftUI component to be referenced to a variable
    // This does not follow SwiftUI filosophy but for custom
    // components it might simplify some things
    func `referenced`<T>(by reference: Binding<T>) -> (Self?) {
        // We ensure that the binding is updated in the main thread
        DispatchQueue.main.async { reference.wrappedValue = self as! T }
        return self
    }

}

// Example Usages
struct ContentView: View {

    @State var component: ReferencableComponent?
    
    var body: some View {
    
        VStack {
            // referenced extension, if extension && funcIf extension
            VStack {
                ReferencableComponent().referenced(by: $component)
                Button(action: {
                    print(component.someInfo) // prints "some info"
                    component.doSomething()   // prints "done something"
                }) { Text("Get Component Data") }
                    .if(component == nil) { button in
                        button.foregroundColor(.red) // the foreground of the button is red if the component is nil, otherwise it will be the default
                    }
                    .funcIf(component == nil) {
                        print("the component is nil") // this code will not run if the component is not nil
                    }
            }.exec() { print("Something changed") /* will run when something changes */ }
            
        }
    
    }

}

// Components for demo
// This component simulates a component that performs it's own options
struct ReferencableComponent: View {

    @State var someInfo: String = "some info"
    var body: some View {
        // [...]
    }
    
    public function doSomething() {
        print("done something")
    }

}
