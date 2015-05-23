
import UIKit
import Foundation

class InstructionsTableViewController: UITableViewController {
    
    var colors = [UIColor]()
    var instructions = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting color scheme: https://kuler.adobe.com/Copy-of-Close-to-the-Garden-but-more-Teal-color-theme-4324985/
        self.colors.append(colorize(0xFC5B3F))
        self.colors.append(colorize(0xFCB03C))
        self.colors.append(colorize(0x6FD57F))
        self.colors.append(colorize(0x068F86))
        self.colors.append(colorize(0xFC5B3F))
        self.colors.append(colorize(0xFCB03C))
        self.colors.append(colorize(0x6FD57F))
        self.colors.append(colorize(0x068F86))
        
        self.instructions.append("Welcome!")
        self.instructions.append("Add a destination, and tap on it to get times.")
        self.instructions.append("To delete a destination, swipe it towards the left (try it here).")
        self.instructions.append("We provide times for BART, MUNI metro, and Caltrain routes.")
        self.instructions.append("If you'd like others, let us know:")
        self.instructions.append("shouldIRunSF@gmail.com")
        self.instructions.append("@shouldIRunSF")
        self.instructions.append("Run!")
        
        // Navigation and background colors
        self.navigationController?.navigationBar.tintColor = globalTintColor
        self.view.backgroundColor = globalBackgroundColor
        self.navigationController?.navigationBar.barStyle = globalBarStyle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 101
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InstructionsPC", forIndexPath: indexPath) as! UITableViewCell
        let row = indexPath.row

        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.backgroundColor = self.colors[row]
        cell.textLabel!.text = self.instructions[row]
        cell.textLabel!.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Thin", size: 30), size: 30)
        if row == 7 {
            cell.textLabel!.font = UIFont(descriptor: UIFontDescriptor(name: "Helvetica Neue Light Italic", size: 40), size: 40)
        }
        cell.textLabel!.minimumScaleFactor = 0.5
        cell.textLabel!.numberOfLines = 2
        if (row == 5) {
            cell.textLabel!.numberOfLines = 1
        }
        cell.textLabel!.adjustsFontSizeToFitWidth = true

        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
}
