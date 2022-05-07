//
//  LastQuoteView.swift
//  BibleQuotes
//
//  Created by user217575 on 5/7/22.
//

import SwiftUI
import SQLite3

struct LastQuoteView: View {
    
    @State private var id = 0
    @State private var bookname = ""
    @State private var chapter = ""
    @State private var verse = ""
    @State private var text = ""
    
    var body: some View {
        VStack{
            Text(bookname + " " + chapter + ":" + verse).multilineTextAlignment(.leading).task{
                initDb()
                getLastQuote()
            }
            Text(text)
            Button(action:{
                if(id != 0)
                {
                    //initDb()
                    deleteQuote(i: id)
                    getLastQuote()
                }
            }, label:{
                Text("Delete quote")
                    .frame(width: 140, height: 40, alignment: .center)
                    .cornerRadius(8)
                    .background(Color.red)
                    .foregroundColor(.white)
            })
            Spacer()
        }
    }
    
    func getLastQuote(){
        
        var db: OpaquePointer?
        let fileUrl = try!
            FileManager.default.url(for : .documentDirectory, in: .userDomainMask,
                                    appropriateFor: nil, create: false).appendingPathComponent("QuotessDatabase.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK
        {
            print("Error opening database")
        }
        
        let selectQuery = "SELECT id, book, chapter, verse, content FROM quotes WHERE id = (SELECT MAX(id) FROM quotes)"
        
        var stmt : OpaquePointer?
        
        var s: String
        
        s = ""
        
        if sqlite3_prepare_v2(db, selectQuery, -1, &stmt, nil) == SQLITE_OK{

            if sqlite3_step(stmt) == SQLITE_ROW{
                //print("bruh")
                let i = sqlite3_column_int(stmt, 0)
                id = Int(i)
                guard let aux = sqlite3_column_text(stmt, 1)
                else {
                    print("Query result is nil")
                    return
                }
                bookname = String(cString: aux)
                
                guard let aux2 = sqlite3_column_text(stmt, 2)
                                else {
                                    print("Query result is nil")
                                    return
                                }
                                chapter = String(cString: aux2)

                guard let aux3 = sqlite3_column_text(stmt, 3)
                                else {
                                    print("Query result is nil")
                                    return
                                }
                                verse = String(cString: aux3)

                guard let aux4 = sqlite3_column_text(stmt, 4)
                                else {
                                    print("Query result is nil")
                                    return
                                }
                                text = String(cString: aux4)
                
                //s = String(cString: aux)
                //print(s)
                //deleteQuote(i: String(i))
                //print(String(cString: sqlite3_column_text(stmt, 1)))
            }
        }
        else{
            let err = String(cString: sqlite3_errmsg(db))
            print (err)
        }
        print(s)
    }
    
    func deleteQuote(i: Int){
            var db: OpaquePointer?
            let fileUrl = try!
                FileManager.default.url(for : .documentDirectory, in: .userDomainMask,
                                        appropriateFor: nil, create: false).appendingPathComponent("QuotessDatabase.sqlite")
            
            if sqlite3_open(fileUrl.path, &db) != SQLITE_OK
            {
                print("Error opening database")
            }
            
            var stmt: OpaquePointer?

            let deleteQuoteQuery = "DELETE FROM quotes where id = ?"

            
            if sqlite3_prepare(db, deleteQuoteQuery, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing delte: \(errmsg)")
                return
            }

            if sqlite3_bind_int(stmt, 1, Int32(i)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding id: \(errmsg)")
                return
            }

            
            if sqlite3_exec(db, deleteQuoteQuery, nil, nil, nil) != SQLITE_OK{
                print("Error deleting quote")
                let err = String(cString: sqlite3_errmsg(db)!)
                print(err)
                return
            }
            print("Deleted")
        }
    
    func initDb(){
            
            var db: OpaquePointer?
            let fileUrl = try!
                FileManager.default.url(for : .documentDirectory, in: .userDomainMask,
                                        appropriateFor: nil, create: false).appendingPathComponent("QuotessDatabase.sqlite")
            
            if sqlite3_open(fileUrl.path, &db) != SQLITE_OK
            {
                print("Error opening database")
            }
        
            let createTableQuery = "CREATE TABLE IF NOT EXISTS quotes (id INTEGER PRIMARY KEY AUTOINCREMENT, book TEXT, chapter TEXT, verse TEXT ,content TEXT)"
            if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
                print("Error creating table")
            }
        }

    
}

struct LastQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        LastQuoteView()
    }
}
