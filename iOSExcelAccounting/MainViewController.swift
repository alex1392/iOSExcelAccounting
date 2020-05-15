import UIKit
import MSGraphClientModels
import SwiftyJSON

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, ViewControllerWithSpinner {
    
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dataPicker: UIPickerView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    public let spinner = SpinnerViewController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.keyboardDismissMode = .interactive
        
        self.commentText.delegate = self
        
        // adjust for keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // setup button
        negativeButton.setImage(UIImage(systemName: "plus.square"), for: .normal)
        negativeButton.setImage(UIImage(systemName: "minus.square.fill"), for: .selected)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // change the title of back button in the next page
        let backItem = UIBarButtonItem()
        backItem.title = "返回"
        navigationItem.backBarButtonItem = backItem
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    // pickerView delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return DataManager.categories.count
        case 1:
            return DataManager.shops.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return DataManager.categories[row]
        case 1:
            return DataManager.shops[row]
        default:
            return ""
        }
    }
    // pickerView delegates
    
    @IBAction func amountEditStart(_ sender: Any) {
        amountText.inputAccessoryView = doneButtonToolBar()
    }
    
    @IBAction func commentEditStart(_ sender: Any) {
//        commentText.inputAccessoryView = doneButtonToolBar()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func doneButtonToolBar() -> UIToolbar {
        // let user dismiss keyboard by tapping anywhere outside of the keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        // add done button on the keyboard
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        return keyboardToolbar
    }
    
    @IBAction func negative(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        button.isSelected = !button.isSelected
    }
    
    @IBAction func upload(_ sender: Any) {
        // check user input
        guard let amount_text = self.amountText.text, !amount_text.isEmpty else {
            AlertManager.showWithCustom(controller: self, title: "別忘記輸入金額哦，豬頭嬛～～～😜", message: "豬頭就是豬頭😂", actionTitle: "Me八嘎🤣🤣🤣")
            return
        }
        guard let amount_double = Double((self.negativeButton.isSelected ? "-" : "") + amount_text) else {
            AlertManager.showWithOK(controller: self, title: "輸入金額格式錯誤", message: "請在金額欄僅輸入正確的數字格式")
            return
        }
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let date = dateFormatter.string(from: self.datePicker.date)
            let category = DataManager.categories[self.dataPicker.selectedRow(inComponent: 0)]
            let comsumeCategory = DataManager.comsumeCategories[self.dataPicker.selectedRow(inComponent: 0)]
            let shop = DataManager.shops[self.dataPicker.selectedRow(inComponent: 1)]
            
            let amount = String(format: "%.2f", amount_double)
            let cost = String(format: "%.2f", -amount_double)
            /// CHECK with the file
            guard let balance_index = DataManager.headers.firstIndex(of: "餘額") else {
                AlertManager.showWithOK(controller: self, title: "記帳表CSV文件餘額無法解析", message: "請檢查記帳表餘額欄位標題是否存在")
                return
            }
            guard let balance_last = Double(DataManager.csvTable.table[0][balance_index].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "£"))) else{
                AlertManager.showWithOK(controller: self, title: "記帳表CSV文件餘額無法解析", message: "請檢查記帳表餘額欄位數字格式正確")
                return
            }
            let balance = String(format: "%.2f", balance_last + amount_double)
            let comment = self.commentText.text ?? ""
            
            // show alert to let user check again
            let data = [date,amount, balance,category,shop,comment,cost,comsumeCategory] /// CHECK with the file
            let alert = UIAlertController(title: "確認輸入", message: "", preferredStyle: .alert)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            let messageText = NSAttributedString(
                string: "📅：\(date)\r\n" +
                "🏷：\(category)\r\n" +
                "🏠：\(shop)\r\n" +
                "£：\(amount)\r\n" +
                "💬：\(comment)\r\n",
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                ]
            )
            alert.setValue(messageText, forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                // get table
                DataManager.getTable(controller: self) { (error) in
                    // if not successful, return
                    guard error == nil else { return }
                    // TODO: lock the file?
                    // get user inputs
                    guard let id_index = DataManager.headers.firstIndex(of: "ID") else {
                        AlertManager.showWithOK(controller: self, title: "記帳表CSV文件ID無法解析", message: "請檢查記帳表ID欄位標題是否存在")
                        return
                    }
                    guard let id_last = Int(DataManager.csvTable.table[0][id_index].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                        AlertManager.showWithOK(controller: self, title: "記帳表CSV文件ID無法解析", message: "請檢查記帳表ID欄位數字格式正確")
                        return
                    }
                    let id = String(format: "%03d", id_last+1)
                    // insert new row
                    let row = [id] + data
                    DataManager.csvTable.table.insert(row, at: 0)
                    DataManager.uploadTable(controller: self) {
                        DataManager.uploadedData.append(row)
                        self.amountText.text = ""
                        AlertManager.showWithOK(controller: self, title: "登錄成功！", message: "會記帳的小環環最棒了😍")
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func signOut() {
       AuthenticationManager.instance.signOut()
       self.performSegue(withIdentifier: "userSignedOut", sender: self)
    }
    
}
