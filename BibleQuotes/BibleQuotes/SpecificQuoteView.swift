//
//  SpecificQuoteView.swift
//  BibleQuotes
//
//  Created by user217575 on 5/7/22.
//

import SwiftUI
import Alamofire



struct SpecificQuoteView: View {
    
    @State private var bookname = ""
    @State private var chapter = ""
    @State private var verse = ""
    @State private var text = ""
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section{
                        TextField("Book name", text:$bookname)
                        TextField("Chapter", text:$chapter)
                        TextField("Verse", text:$verse)
                    }
                    Section{
                        Button(action:{
                            getQuote(bkname: bookname, chapt: chapter, vrs: verse)
                        }, label:{
                            Text("Get quote")
                                .frame(width: 140, height: 40, alignment: .center)
                                .cornerRadius(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                        })
                    }
                }
                Text(text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .navigationTitle("Get your specific quote")
        }
    }
    
    func getQuote(bkname: String, chapt: String, vrs: String) {
            let quoteRequestUrl: String
            quoteRequestUrl = "https://labs.bible.org/api/?passage=" + bookname +
        "+" + chapter + ":" + verse + "&type=json"

            let quoteRequest = AF.request(quoteRequestUrl, method: .get)
            quoteRequest.responseDecodable(of: Quote.self) { response in
                        guard let quotesData = response.data else {
                            text = "No quote found!"
                          return
                        }
                        do {
                            
                            let decoder = JSONDecoder()
                            let quote = try decoder.decode([Quote].self, from: quotesData)

                            text = quote[0].text
                        } catch {
                            print("Error with decoding request")
                            text = "No quote found!"
                        }
                    }
    }

}

struct SpecificQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        SpecificQuoteView()
    }
}
