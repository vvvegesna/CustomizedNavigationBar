//
//  StackOverflows.swift
//  TestNavigation
//
//  Created by vijay varma vegesna on 8/8/21.
//

import SwiftUI

struct StackOverflows: View {
    @State private var imageNames = ["person", "person.fill", "person.circle"]
    
    var body: some View {
        NavigationView {
            MasterView(imageNames: $imageNames)
                .navigationBarTitle(Text("Master"))
                .navigationBarItems(leading: EditButton(),trailing: Button(action: {
                    withAnimation {
                        // simplified for example
                        self.imageNames.insert("image", at: 0)
                    }
                }) {
                    Image(systemName: "plus")
                })
        }
    }
}

struct MasterView: View {
    @Binding var imageNames: [String]
    
    var body: some View {
        List {
            ForEach(imageNames, id: \.self) { imageName in
                NavigationLink(
                    destination: DetailView(selectedImageName: imageName)
                ) {
                    Text(imageName)
                }
            }
        }
    }
}

struct DetailView: View {
    
    var selectedImageName: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        CustomizedNavigationController(imageName: selectedImageName) { backButtonDidTapped in
            if backButtonDidTapped {
                presentationMode.wrappedValue.dismiss()
            }
        } // creating customized navigation bar
        .navigationBarTitle("Detail")
        .navigationBarHidden(true) // Hide framework driven navigation bar
    }
}

/*
 Using UINavigationBar.appearance() is quite unsafe in scenarios like when we want to present both of these Master and Detail views within a popover. There is a chance that all other nav bars in our appliction might acquire  the same nav bar configuration of Detail view.
 */
struct CustomizedNavigationController: UIViewControllerRepresentable {
    let imageName: String
    var backButtonTapped: (Bool) -> Void
    
    class Coordinator: NSObject {
        var parent: CustomizedNavigationController
        var navigationViewController: UINavigationController
        
        init(_ parent: CustomizedNavigationController) {
            self.parent = parent
            let navVC = UINavigationController(rootViewController: UIHostingController(rootView: Image(systemName: parent.imageName).resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.blue)))
            navVC.navigationBar.isTranslucent = true
            navVC.navigationBar.tintColor = UIColor(red: 41/255, green: 159/244, blue: 253/255, alpha: 1)
            navVC.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.red]
            navVC.navigationBar.barTintColor = .yellow
            navVC.navigationBar.topItem?.title = parent.imageName
            self.navigationViewController = navVC
        }
        
        @objc func backButtonPressed(sender: UIBarButtonItem) {
            self.parent.backButtonTapped(sender.isEnabled)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        // creates custom back button 
        let navController = context.coordinator.navigationViewController
        let backImage = UIImage(systemName: "chevron.left")
        let backButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: context.coordinator, action: #selector(Coordinator.backButtonPressed))
        navController.navigationBar.topItem?.leftBarButtonItem = backButtonItem
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        //Not required
    }
}

struct StackOverflows_Previews: PreviewProvider {
    
    static var previews: some View {
        StackOverflows()
    }
}
