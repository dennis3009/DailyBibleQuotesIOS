//
//  BibleQuoteView.swift
//  BibleQuotes
//
//  Created by user217575 on 5/7/22.
//

import SwiftUI
import Alamofire
import SQLite3

struct Quote: Codable{
    var bookname: String
    var chapter: String
    var verse: String
    var text: String
}


struct BibleQuoteView: View {

    let dailyOrRandom: String
    
    @State private var bookname = ""
    @State private var chapter = ""
    @State private var verse = ""
    @State private var text = ""
    
    var body: some View {
        VStack{
            Text(bookname + " " + chapter + ":" + verse).multilineTextAlignment(.leading).task{
                await getQuote()
            }
            Text(text)
            Button(action:{
                initDb()
                saveQuote(bkname: bookname, chaptr: chapter, vrs: verse, txt: text)
            }, label:{
                Text("Save quote")
                    .frame(width: 140, height: 40, alignment: .center)
                    .cornerRadius(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
            })
            Spacer()
        }
    }
    
    func saveQuote(bkname: String, chaptr: String, vrs: String, txt: String){
            var db: OpaquePointer?
            let fileUrl = try!
                FileManager.default.url(for : .documentDirectory, in: .userDomainMask,
                                        appropriateFor: nil, create: false).appendingPathComponent("QuotessDatabase.sqlite")
            
            if sqlite3_open(fileUrl.path, &db) != SQLITE_OK
            {
                print("Error opening database")
            }
            
            var stmt: OpaquePointer?

            let insertQuoteQuery = "INSERT INTO quotes (book, chapter, verse ,content) VALUES (?, ?, ?, ?)"

            if(bkname == "" || chaptr == "" || vrs == "" || txt == "")
            {
                print("Empty data field")
                return
            }
            
            if sqlite3_prepare(db, insertQuoteQuery, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 1, bkname, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding book: \(errmsg)")
                return
            }

            
            if sqlite3_bind_text(stmt, 2, chaptr, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding chapter: \(errmsg)")
                return
            }

            
            if sqlite3_bind_text(stmt, 3, vrs, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding verse: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 4, txt, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding text: \(errmsg)")
                return
            }

    
            if sqlite3_step(stmt) != SQLITE_DONE{
                print("Error inserting quote")
            }
            print("Inserted")
        }
    
    func getQuote() async {
            let quoteRequestUrl: String
            if (dailyOrRandom == "daily") {
                quoteRequestUrl = "https://labs.bible.org/api/?passage=votd&type=json"
            } else {
                quoteRequestUrl = "https://labs.bible.org/api/?passage=random&type=json"
            }
            let quoteRequest = AF.request(quoteRequestUrl, method: .get)
            quoteRequest.responseDecodable(of: Quote.self) { response in
                        guard let quotesData = response.data else {
                          return
                        }
                        do {
                            
                            let decoder = JSONDecoder()
                            let quote = try decoder.decode([Quote].self, from: quotesData)
                            bookname = quote[0].bookname
                            chapter = quote[0].chapter
                            verse = quote[0].verse
                            text = quote[0].text
                        } catch {
                            print("Error with decoding request")
                        }
                    }
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

struct BibleQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        BibleQuoteView(dailyOrRandom: "daily")
    }
}
