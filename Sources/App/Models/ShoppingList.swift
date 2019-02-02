//
//  ShoppingList.swift
//  App
//
//  Created by MacBook Pro on 1/29/19.
//

import Vapor
import FluentProvider
import HTTP

final class ShoppingList: Model {
    
    let storage = Storage()
    var name: String
    var items: Children<ShoppingList, Item> {
        return children()
    }
    
    struct Keys {
        static let id = "id"
        static let name = "name"
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get(ShoppingList.Keys.name)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(ShoppingList.Keys.name, name)
        return row
    }
}

extension ShoppingList: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(ShoppingList.Keys.name)
        }
}
    static func revert(_ database: Database) throws {
        try database.delete(self)

    }
}

extension ShoppingList: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(name: try json.get(ShoppingList.Keys.name))
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(ShoppingList.Keys.id, id)
        try json.set(ShoppingList.Keys.name, name)
        try json.set("items", items.all())
        return json
    }
}

extension ShoppingList: Updateable {
    public static var updateableKeys: [UpdateableKey<ShoppingList>] {
        return [
            UpdateableKey(ShoppingList.Keys.name, String.self) { shoppingList, name in
                shoppingList.name = name
            }
        ]
    }
}

extension ShoppingList: ResponseRepresentable { }


extension ShoppingList: Replaceable {
    func replaceAttributes(from list: ShoppingList) {
        self.name = list.name
    }
}




