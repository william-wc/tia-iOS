//
//  TIAManager.swift
//  MackTIA
//
//  Created by joaquim on 21/08/15.
//  Copyright (c) 2015 Mackenzie. All rights reserved.
//

import Foundation


/** TIAManager Class

*/
class TIAManager {
    
    static let LoginSucessoNotification = "LoginSucessoNotification"
    static let LoginErroNotification = "LoginErroNotification"
    static let FaltasRecuperadasNotification = "FaltasRecuperadasNotification"
    static let FaltasErroNotification = "FaltasErroNotification"
    static let NotasRecuperadasNotification = "NotasRecuperadasNotification"
    static let NotasErroNotification = "NotasErroNotification"
    
    let DescricaoDoErro = "descricao"
    
    
    private var token_parte1:String
    private var token_parte2:String
    private var config:NSDictionary
    private var usuario:Usuario?
    
    class var sharedInstance : TIAManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : TIAManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = TIAManager()
        }
        return Static.instance!
    }
    
    private init(){
        if let path = NSBundle.mainBundle().pathForResource("token", ofType: "plist") {
            var tokenDict = NSDictionary(contentsOfFile: path)
            self.token_parte1 = tokenDict!.valueForKey("parte 1") as! String
            self.token_parte2 = tokenDict!.valueForKey("parte 2") as! String
        } else {
            println("There are a problem in token.plist")
            self.token_parte1 = ""
            self.token_parte2 = ""
        }
        
        if let path = NSBundle.mainBundle().pathForResource("config", ofType: "plist") {
            self.config = NSDictionary(contentsOfFile: path)!
        } else {
            self.config = NSDictionary()
        }
    }
    
    private func gerarToken() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: date)
        
        var day = "\(components.day)"
        var month = "\(components.month)"
        var year = "\(components.year)"
        
        if (components.day < 10) {
            day = "0\(day)"
        }
        
        if (components.month < 10) {
            month = "0\(month)"
        }
        
        var token = "\(self.token_parte1)\(month)\(year)\(day)\(self.token_parte2)"
        
        return token.md5
    }
    
    
    func login(usuario:Usuario) {
        
        if usuario.tia == "" || usuario.senha == "" || usuario.unidade == "" {
            NSNotificationCenter.defaultCenter().postNotificationName(TIAManager.LoginErroNotification, object: self, userInfo: [self.DescricaoDoErro : "Erro ao informar os dados do aluno"])
            return
        }
        
        if let stringURL = self.config.objectForKey("loginURL") as? String {
            
            let request = NSMutableURLRequest(URL: NSURL(string: stringURL)!)
            request.HTTPMethod = "POST"
            
            let postString = "mat=\(usuario.tia)&pass=\(usuario.senha)&unidade=\(usuario.unidade)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(TIAManager.LoginErroNotification, object: self, userInfo: [self.DescricaoDoErro : "Erro ao acessar o serviço do Mackenzie. Provavelmente a culpa não é usa, por favor verifique se sua internet está funcionando. Se o problema persistir entre em contato com o helpdesk"])
                    return
                }
                
                var errorJson:NSError?
                if let resposta = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &errorJson) as? NSDictionary {
                    
                    if let ping = resposta.objectForKey("sucesso") as? String {
                        println("Login: \(ping)")
                        NSNotificationCenter.defaultCenter().postNotificationName(TIAManager.LoginSucessoNotification, object: self)
                        return
                    }
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(TIAManager.LoginErroNotification, object: self, userInfo: [self.DescricaoDoErro : "Erro ao acessar o serviço do Mackenzie. Provavelmente a culpa não é usa, por favor verifique se sua internet está funcionando. Se o problema persistir entre em contato com o helpdesk"])
            })
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(TIAManager.LoginErroNotification, object: self, userInfo: [self.DescricaoDoErro : "Erro interno no aplicativo. Provavelmente a culpa não é usa, por algum motivo desconhecido o aplicativo não está funcionando. Tente apagar ele do seu dispositivo e instalar novamente. Caso não funcione não deixe de entrar em contato reportando o problema."])
        }
    }
}
