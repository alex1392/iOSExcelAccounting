import UIKit

class SignInViewController: UIViewController {

    private let spinner = SpinnerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.spinner.start(container: self)

        // See if a user is already signed in
        AuthenticationManager.instance.getTokenSilently {
            (token: String?, error: Error?) in
            DispatchQueue.main.async {
                self.spinner.stop()
                guard let _ = token, error == nil else { return } // not already signed in, just stay here
                self.performSegue(withIdentifier: "userSignedIn", sender: self) // if sign in successfully, go to the user page
            }
        }
    }
    
    

    @IBAction func signIn() {
        spinner.start(container: self)
        // Do an interactive sign in
        AuthenticationManager.instance.getTokenInteractively(parentView: self) {
            (token: String?, error: Error?) in
            DispatchQueue.main.async {
                self.spinner.stop()
                guard let _ = token, error == nil else { return }
                // if signed in successfully
                self.performSegue(withIdentifier: "userSignedIn", sender: self)
            }
        }
    }
}
