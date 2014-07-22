#Swift Style Guide

##Table of Contents


1. [Spacing](#spacing)
1. [Comments](#comments)
1. [Naming](#naming)
1. [Class Prefixes](#class-prefixes)
1. [Semicolons](#semicolons)
1. [Classes and Structures](#sclasses)
1. [Function Declarations](#function-declarations)
1. [Closures](#closures)
1. [Types](#types)
1. [Constants](#spacing)
1. [Optionals](#optionals)
1. [Type Inference](#type-inference)
1. [Syntactic Sugar](#syntatic-sugar)
1. [Control Flow](#control-flow)
1. [Use of Self](#self)



##Spacing

Indent using 2 spaces rather than tabs to conserve space and help prevent line wrapping. Be sure to set this preference in Xcode.
Method braces and other braces (if/else/switch/while etc.) always open on the same line as the statement but close on a new line.

Preferred:

````javascript
if user.isHappy {
  //Do something
} else {
  //Do something else
}
````

Not Preferred:
````javascript
if user.isHappy
{
    //Do something
}
else {
    //Do something else
}
````
There should be exactly one blank line between methods to aid in visual clarity and organization. Whitespace within methods should separate functionality, but having too many sections in a method often means you should refactor into several methods.


##Comments

When they are needed, use comments to explain why a particular piece of code does something. Comments must be kept up-to-date or deleted.

Avoid block comments inline with code, as the code should be as self-documenting as possible. Exception: This does not apply to those comments used to generate documentation.

##Naming

Use descriptive names with camel case for classes, methods, variables, etc. Class names and constants in module scope should be capitalized, while method names and variables should start with a lower case letter.

Preferred:
````javascript
let MaximumWidgetCount = 100

class WidgetContainer {
  var widgetButton: UIButton
  let widgetHeightPercentage = 0.85
}
````
Not Preferred:
````javascript
let MAX_WIDGET_COUNT = 100

class app_widgetContainer {
  var wBut: UIButton
  let wHeightPct = 0.85
}
````
For functions and init methods, prefer named parameters for all arguments unless the context is very clear. Include external parameter names if it makes function calls more readable.
````javascript
func dateFromString(dateString: NSString) -> NSDate
func convertPointAt(#column: Int, #row: Int) -> CGPoint
func timedAction(#delay: NSTimeInterval, perform action: SKAction) -> SKAction!

// would be called like this:
dateFromString("2014-03-14")
convertPointAt(column: 42, row: 13)
timedAction(delay: 1.0, perform: someOtherAction)
````

##Class Prefixes

Swift types are all automatically namespaced by the module that contains them. As a result, prefixes are not required in order to minimize naming collisions. If two names from different modules collide you can disambiguate by prefixing the type name with the module name:

````javascript
import MyModule

var myClass = MyModule.MyClass()
You should not add prefixes to your Swift types.
````
If you need to expose a Swift type for use within Objective-C you can provide a suitable prefix (following our Objective-C style guide) as follows:

@objc (RWTChicken) class Chicken {
   ...
}

##Semicolons

Swift does not require a semicolon after each statement in your code. They are only required if you wish to combine multiple statements on a single line.

Do not write multiple statements on a single line separated with semicolons.



Preferred:
````javascript
var swift = "not a scripting language"
````
Not Preferred:
````javascript
var swift = "not a scripting language";
````
NOTE: Swift is very different to JavaScript, where omitting semicolons is generally considered unsafe

Classes and Structures

Here's an example of a well-styled class definition:

````javascript
class Circle: Shape {
  var x: Int, y: Int
  var radius: Double
  var diameter: Double {
    get {
      return radius * 2
    }
    set {
      radius = newValue / 2
    }
  }

  init(x: Int, y: Int, radius: Double) {
    self.x = x
    self.y = y
    self.radius = radius
  }

  convenience init(x: Int, y: Int, diameter: Double) {
    self.init(x: x, y: y, radius: diameter / 2)
  }

  func describe() -> String {
    return "I am a circle at (\(x),\(y)) with an area of \(computeArea())"
  }

  func computeArea() -> Double {
    return M_PI * radius * radius
  }  
}
````
The example above demonstrates the following style guidelines:

Specify types for properties, variables, constants, argument declarations and other statements with a space after the colon but not before, e.g. x: Int, and Circle: Shape.
Indent getter and setter definitions and property observers.
Define multiple variables and structures on a single line if they share a common purpose / context.
Use of Self

Avoid using self since Swift does not require it to access an object's properties or invoke its methods.

The only reason for requiring the use of self is to differentiate between property names and arguments when initializing a class or structure:

````javascript
class BoardLocation {
  let row: Int, column: Int

  init(row: Int,column: Int) {
    self.row = row
    self.column = column
  }
}
````
##Function Declarations

Keep short function declarations on one line including the opening brace:

````
func reticulateSplines(spline: [Double]) -> Bool {
  // reticulate code goes here
}
````
For functions with long signatures, add line breaks at appropriate points and add an extra indent on subsequent lines:
````
func reticulateSplines(spline: [Double], adjustmentFactor: Double,
    translateConstant: Int, comment: String) -> Bool {
  // reticulate code goes here
}
````
##Closures

Use trailing closure syntax wherever possible. In all cases, give the closure parameters descriptive names:
````
return SKAction.customActionWithDuration(effect.duration) { node, elapsedTime in 
  // more code goes here
}
````
For single-expression closures where the context is clear, use implicit returns:
````
attendeeList.sort { a, b in
  a > b
}
````
##Types

Always use Swift's native types when available. Swift offers bridging to Objective-C so you can still use the full set of methods as needed.

Preferred:
````
let width = 120.0                                           //Double
let widthString = width.bridgeToObjectiveC().stringValue    //String
````
Not Preferred:
````
let width: NSNumber = 120.0                                 //NSNumber
let widthString: NSString = width.stringValue               //NSString
````
In Sprite Kit code, use CGFloat if it makes the code more succinct by avoiding too many conversions.

##Constants

Constants are defined using the let keyword, and variables with the var keyword. Any value that is a constant must be defined appropriately, using the let keyword. As a result, you will likely find yourself using let far more than var.


##Optionals

Declare variables and function return types as optional with ? where a nil value is acceptable.

Use implicitly unwrapped types declared with ! only for instance variables that you know will be initialized later before use, such as subviews that will be set up in viewDidLoad.

When accessing an optional value, use optional chaining if the value is only accessed once or if there are many optionals in the chain:

myOptional?.anotherOne?.optionalView?.setNeedsDisplay()
Use optional binding when it's more convenient to unwrap once and perform multiple operations:

if let view = self.optionalView {
  // do many things with view
}
##Type Inference

The Swift compiler is able to infer the type of variables and constants. You can provide an explicit type via a type alias (which is indicated by the type after the colon), but in the majority of cases this is not necessary.

Prefer compact code and let the compiler infer the type for a constant or variable.

Preferred:
````
let message = "Click the button"
var currentBounds = computeViewBounds()
````
Not Preferred:
````
let message: String = "Click the button"
var currentBounds: CGRect = computeViewBounds()
````
NOTE: Following this guideline means picking descriptive names is even more important than before.

##Syntactic Sugar

Prefer the shortcut versions of type declarations over the full generics syntax.

Preferred:

````
var deviceModels: [String]
var employees: [Int: String]
var faxNumber: Int?
````
Not Preferred:
````
var deviceModels: Array<String>
var employees: Dictionary<Int, String>
var faxNumber: Optional<Int>
````
##Control Flow

Prefer the for-in style of for loop over the for-condition-increment style.

Preferred:
````
for _ in 0..<3 {
  println("Hello three times")
}

for person in attendeeList {
  // do something
}
````
Not Preferred:
````
for var i = 0; i < 3; i++ {
  println("Hello three times")
}

for var i = 0; i < attendeeList.count; i++ {
  let person = attendeeList[i]
  // do something
}
````