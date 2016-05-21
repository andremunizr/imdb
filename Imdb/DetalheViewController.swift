//
//  DetalheViewController.swift
//  Imdb
//
//  Created by jenkins on 06/05/16.
//  Copyright © 2016 Imdb Teste Inc. All rights reserved.
//

import UIKit
import CoreData

class DetalheViewController: UIViewController {

    @IBOutlet var cartaz: UIImageView!
    @IBOutlet var titulo: UILabel!
    @IBOutlet var ano: UILabel!
    @IBOutlet var duracao: UILabel!
    @IBOutlet var genero: UILabel!
    @IBOutlet var diretor: UILabel!
    @IBOutlet var atores: UILabel!
    @IBOutlet var plot: UILabel!
    var filmeSelecionado:NSManagedObject!
    let helper = Helper()
    let request = Request()
    var filme = [String:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titulo = filmeSelecionado.valueForKey("titulo") as? String
        
        if Reachability.isConnectedToNetwork() == true {
            getInfo(titulo!)
        }
        else {
            recuperarFilme(titulo!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBarHidden = true
    }
    
    //MARK: - Controller
    func getInfo(titulo: String){
        dispatch_async(helper.globalBackgroundQueue, {
            () -> Void in
            let recurso = "t=\(titulo)"
            let recursoFormatado = recurso.stringByReplacingOccurrencesOfString(" ", withString: "+")
            self.request.GET(recursoFormatado, callback: self.parseInfo)
        })
    }
    
    func parseInfo( response: Dictionary<String, AnyObject> ){
        let data = response["data"] as? NSData ?? NSData()
        if data.length == 0 {
            return;
        }
        let houveErro = response["houveErro"] as! Bool
        var dict = helper.convertDataToDictionary(data, houveErro: houveErro ) as! [String:AnyObject]
        if nil != dict["Error"] {
            dispatch_async(self.helper.globalMainQueue, {
                () -> Void in
                self.showAlert( dict["Error"] as! String )
            })
        }
        else {
            filme = dict
            let urlCartaz = dict["Poster"] as? String ?? ""
            getCartaz(urlCartaz)
            atualizarFilme(filme)
            
            dispatch_async(self.helper.globalMainQueue, {
                () -> Void in
                self.setInfo(dict)
            })
        }
    }
    
    func setInfo(dict:[String:AnyObject]){
        self.titulo.text = dict["Title"] as? String ?? ""
        self.ano.text = dict["Year"] as? String ?? ""
        self.duracao.text = dict["Runtime"] as? String ?? ""
        self.genero.text = dict["Genre"] as? String ?? ""
        self.diretor.text = dict["Director"] as? String ?? ""
        self.atores.text = dict["Actors"] as? String ?? ""
        self.plot.text = dict["Plot"] as? String ?? ""
        
        self.titulo.adjustsFontSizeToFitWidth = true
        self.ano.adjustsFontSizeToFitWidth = true
        self.duracao.adjustsFontSizeToFitWidth = true
        self.genero.adjustsFontSizeToFitWidth = true
        self.diretor.adjustsFontSizeToFitWidth = true
        self.atores.adjustsFontSizeToFitWidth = true
        self.plot.adjustsFontSizeToFitWidth = true
    }
    
    func atualizarFilme(filmeDict:[String:AnyObject]){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let titulo = filmeSelecionado.valueForKey("titulo") as? String
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Filme")
        fetchRequest.predicate = NSPredicate(format: "titulo = %@", argumentArray: [titulo!])
        
        do {
            let filmes = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            if filmes.count > 0 {
                let managedObject = filmes[0]
                managedObject.setValue(filmeDict["Year"], forKey:"ano")
                managedObject.setValue(filmeDict["Runtime"], forKey:"duracao")
                managedObject.setValue(filmeDict["Genre"], forKey:"genero")
                managedObject.setValue(filmeDict["Director"], forKey:"diretor")
                managedObject.setValue(filmeDict["Actors"], forKey:"atores")
                managedObject.setValue(filmeDict["Plot"], forKey:"plot")
                managedObject.setValue(filmeDict["Poster"], forKey:"poster")
                try managedContext.save()
            }
        } catch {
            print("Erro ao salvar")
        }
    }
    
    func recuperarFilme(nomeFilme:String){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Filme")
        fetchRequest.predicate = NSPredicate(format: "titulo = %@", argumentArray: [nomeFilme])
        
        do {
            let filmes = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            if filmes.count > 0 {
                let managedObject = filmes[0]
                var filmeDict = Dictionary<String, AnyObject>()
                filmeDict["Title"] = nomeFilme
                filmeDict["Year"] = managedObject.valueForKey("ano")
                filmeDict["Runtime"] = managedObject.valueForKey("duracao")
                filmeDict["Genre"] = managedObject.valueForKey("genero")
                filmeDict["Director"] = managedObject.valueForKey("diretor")
                filmeDict["Actors"] = managedObject.valueForKey("atores")
                filmeDict["Plot"] = managedObject.valueForKey("plot")
                filmeDict["Poster"] = managedObject.valueForKey("poster")
                setInfo(filmeDict)
            }
        } catch {
            print("Erro ao salvar")
        }
    }
    
    func getCartaz(urlCartaz: String){
        let url = NSURL(string: urlCartaz)
        let request:NSURLRequest = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(request,
                                                queue: NSOperationQueue.mainQueue(),
                                                completionHandler: {
                                                    (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                                                    if error == nil {
                                                        let imagem = UIImage(data: data!)
                                                        let transitionOptions = UIViewAnimationOptions.TransitionCrossDissolve
                                                        dispatch_async(self.helper.globalMainQueue, {
                                                            UIView.transitionWithView(self.cartaz, duration: 0.5, options: transitionOptions, animations: {
                                                                self.cartaz.image = imagem
                                                                }, completion: nil)
                                                        })
                                                    }
            })
    }
    
    private func showAlert(message: String){
        let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Nav
    @IBAction private func dismissView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
