# Bond-Realm
Binding from Bond to Realm made easy
##Why do I need it?
Bond is a wonderful framework that makes it very easy to synchronize your dynamic models, view models to views. Realm on the other hand is the best framework for persistency. Bond works with in-memory objects whereas in most cases your models should persist somewhere and be updated based on user interaction. That's where Bond-Realm comes to help!
Bond-Realm makes it easy to connect your Realm models to dynamic Bond models, so all changes made in your Bond models will be automatically saved to Realm.
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
   //create dynamic properties
   let title = Dynamic("")
   let date = Dynamic(NSDate())

   //return type of realm model
   override func realmModelType() -> RLMObject.Type { return RealmTodoModel.self }

   //create bonds between TodoModel's dynamic properties to RealmTodoModel static properties so all changes in TodoModel will be automatically saved in Realm
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
##One-to-one and one-to-many
In the example bellow we were working with base types such as `String` and `NSDate`. What about one-to-one and one-to-many relationships? Rejoice, Bond-Realm has covered that!
Let's say you have a Category class that has array of Todos and a reference to the most important Todo (which can change). Then your realm class will look as following:
```
class RealmCategoryModel: RLMObject {
   dynamic var title = ""
   dynamic var mostImportantTodo = RealmTodoModel()
   dynamic var todos = RLMArray(objectClassName: RealmTodoModel.className())
}
```
To create dynamic CategoryModel your should create following class:
```
class CategoryModel: BRWrapper {
   let title = Dynamic("")
   //Note – we have reference to Dynamic TodoModel instead of RealmTodoModel.
   let mostImportantTodo: Dynamic<TodoModel!> = Dynamic(nil)
   //And we also have DynamicArray of TodoModels instead of RLMArray of RealmTodoModels
   let todos = DynamicArray<TodoModel>([])
   
   override func realmModelType() -> RLMObject.Type { return RealmCategoryModel.self }

   override func createBonds() {
      createBondFrom(title, toModelKeyPath: "title")
      createObjectBondFrom(mostImportantTodo, toModelKeyPath: "mostImportantTodo")
      createArrayBondFrom(todos, toModelKeyPath: "todos")
   }
}
```
All insertion/deletion in your todos array will be automatically update RealmCategoryModel's RLMArray of RealmTodoModel! Isn't it magic?
