import Vapor
import FluentProvider
import HTTP

final class Item: Model {
    let storage = Storage()
    var name: String
    var isChecked: Bool = false
    var shoppingListId: Identifier
    var list: Parent<Item, ShoppingList> {
        return parent(id: shoppingListId)
    }
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let isChecked = "is_checked"
        static let shoppingListId = "shopping_list__id"
    }
    
    init(name: String, isChecked: Bool, shoppingListId: Identifier) {
        self.name = name
        self.isChecked = isChecked
        self.shoppingListId = shoppingListId
    }
    
    init(row: Row) throws {
        name = try row.get(Item.Keys.name)
        isChecked = try row.get(Item.Keys.isChecked)
        shoppingListId = try row.get(Item.Keys.shoppingListId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Item.Keys.name, name)
        try row.set(Item.Keys.isChecked, isChecked)
        try row.set(Item.Keys.shoppingListId, shoppingListId)
        return row
    }
}

extension Item: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Item.Keys.name)
            builder.bool(Item.Keys.isChecked)
            builder.parent(ShoppingList.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Item: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Item.Keys.name),
            isChecked: try json.get(Item.Keys.isChecked),
            shoppingListId: try json.get(Item.Keys.shoppingListId)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Item.Keys.id, id)
        try json.set(Item.Keys.name, name)
        try json.set(Item.Keys.isChecked, isChecked)
        try json.set(Item.Keys.shoppingListId, shoppingListId)
        return json
    }
}

extension Item: Updateable {
    public static var updateableKeys: [UpdateableKey<Item>] {
        return [
            UpdateableKey(Item.Keys.name, String.self) { item, name in
                item.name = name
            },
            UpdateableKey(Item.Keys.isChecked, Bool.self) { item, isChecked in
                item.isChecked = isChecked
            },
            UpdateableKey(Item.Keys.shoppingListId, Identifier.self) { item, shoppingListId in
                item.shoppingListId = shoppingListId
            }
        ]
    }
}

extension Item: ResponseRepresentable { }

extension Item: Replaceable {
    func replaceAttributes(from item: Item) {
        self.name = item.name
        self.isChecked = item.isChecked
        self.shoppingListId = item.shoppingListId
    }
}
