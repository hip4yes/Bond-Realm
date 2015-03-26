# Bond-Realm
Binding from Bond to Realm made easy
##Why do I need it?
Bond is a wonderful framework that makes it very easy to synchronize your dynamic models, view models to views. Realm on the other hand is the best framework for persistency. Bond works with in-memory objects whereas in most cases your models should persist somewhere and be updated based on user interaction. That's where Bond-Realm comes to help!
Bond-Realm makes it easy to connect your Realm model to dynamic Bond model, so all changes made in your Bond model will be automatically saved to Realm.
##Example
Let's say you are making Todo app and have a Realm todo model:
```
class RealmTodoModel: RLMObject {
   dynamic var title = ""
   dynamic var date = NSDate()
   dynamic var extraDescription = RealmExtraDescription()
}
```
You are "dynamizing" it by creating new class:
```
class TodoModel : BRWrapper{
   let title = Dynamic("")
   let date = Dynamic(NSDate())

   override func realmModelType() -> RLMObject.Type { return RealmTodoModel.self }

   override func createBonds(){
      createBondFrom(title, toModelKeyPath: "title")
      createBondFrom(date, toModelKeyPath: "date")
   }
}
```
After that your todo edit controller will look as following:
```
class TaskController: UIViewController {
   var todoModel: TodoModel!

   @IBOutlet private weak var titleField: UITextField!
   @IBOutlet private weak var datePicker: UIDatePicker!

   override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)      
      todoModel.title <->> titleField
      todoModel.date <->> datePicker
   }
}
```
And that's it! All changes in `titleField` and `datePicker` will be automatically saved to your model and thent to Realm!
##How to bond different types of objects
In the example bellow we were working with base types such as `String` and `NSDate`.
