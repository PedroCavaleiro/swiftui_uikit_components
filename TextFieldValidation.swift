//  Created by Pedro Cavaleiro on 14/04/2020.
//  Copyright © 2020 Pedro Cavaleiro. All rights reserved.
//

import SwiftUI

// This extension is the core of the validation as it will allow the
// usage of didSet in a binding
extension Binding {
    func didSet(execute: @escaping (Value) ->Void) -> Binding {
        return Binding(
            get: {
                return self.wrappedValue
            },
            set: {
                execute($0)
                self.wrappedValue = $0
            }
        )
    }
}

// Model as one would have, it can be a state on a content view, but for forms I prefer Models
class Model: ObservableObject {
    @Published var value: String = ""
}

// The Validation Field
// As UI point of view, this is a basic one you should make this more pretty and to match
// your application UI
struct TextFieldValidation: View {
    // This function takes the value and returns a tuple with the
    // first parameter being if the field is valid or not and the
    // second parameter the error message 
    typealias Validator = (_ value: String) -> (Bool, String)
    
    // I added the "neutral" state because I don't want the user to get
    // the state of the validation on the view is presented
    enum ValidationState {
        case neutral, invalid, valid
    }
    
    @Binding text: String
    
    @State var validationState: ValidationState = .neutral
    @State var errorMessage: String = ""
    
    var placeholder: String // If you have your app localized you can use LocalizedStringKey
    var keyboardType: UIKeyboardType = .default
    var autoCapitalization: UITextAutocapitalizationType = .none
    var textContentType: UITextContentType? = nil
    
    let transitionTime = 0.3 // defines the speed of the transition
    
    var validators: [Validator] = [] // contains all the functions that will validate the field
    
    var body: some View {
        VStack {
            ZStack {
                TextField(self.placeholder, text: self.$text.didSet{ v in self.runValidators(v) })
                    .padding()
                    .keyboardType(self.keyboardType)
                    .textContentType(textContentType != nil ? textContentType : .none)
                    .autocapitalization(self.autoCapitalization)
                HStack {
                    if self.validState == .valid {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    } else if self.validState == .invalid {
                        Spacer()
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    }
                }
                    .animation(Animation.easeInOut(duration: self.transitionTime))
                    .padding(.trailing, 15)
            }
            
            if self.validState == .invalid {
                HStack {
                    Text(self.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.leading, 15)
                
            }
        }
    }
    
    // We run all validators but stop when one fails (there's no need to keep validating)
    func runValidators(_ value: String) {
        for (i, validator) in validators.enumerated() {
            let validation = validator(value)
            if !validation.0 {
                self.validState = .invalid
                self.errorMessage = validation.1
                break
            } else {
                // We only set to .valid if there is no error and it was the last validator
                if (i + 1) == self.validators.count {
                    self.validState = .valid
                    self.errorMessage = ""
                }
            }
        }
    }
}

// Defining the validators inline
struct ContentView: View {

    @ObservedObject viewModel: Model = Model()
    
    var body: some View {
        TextFieldValidation(text: self.$viewModel.value, 
                            placeholder: "Enter some value...", 
                            validators: [ { (value: String) in if value.isEmpty { return (false, "This can't be empty") } else { (true, "") }  } ])
    }

}

// As you can see defining the validators inline can be messy specially
// if it's a complex one, so I would recommend doing something like this
struct ContentView: View {

    @ObservedObject viewModel: Model = Model()
    
    var body: some View {
        TextFieldValidation(text: self.$viewModel.value, 
                            placeholder: "Enter some value...", 
                            validators: [ self.empty ])
    }
    
    func empty(_ value: String) -> (Bool, String) {
        if value.isEmpty {
            return (false, "This can't be empty")
        } else {
            return (true, "")
        }
    }
}

// NOTE:
// I believe that the code can be simplified and optimized,
// I don't have much time to do that, so if you want you
// can contribute.
// The code is also according to my needs but it can be tweaked for anyones needs
// since it's easy to understand
// Remember, the validators: parameter is an array of functions so you can pass 
// more then one validator, there's no need to do everything in the same validator
// I choose this method because its easier to create functions to validate,
// from simple ones to complex ones.
// It also allows to reuse code, for instance you want to validate two fields both
// of them only requires to check if it's empty but only one requires to check if
// the, for exemple, the email is valid, you can pass the same empty validator for both
