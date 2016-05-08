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
        getInfo(titulo!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    //MARK: - Controller
    func getInfo(titulo: String){
        dispatch_async(helper.globalBackgroundQueue, {
            () -> Void in
            let recurso = "t=\(titulo)"
            let recursoFormatado = recurso.stringByReplacingOccurrencesOfString(" ", withString: "+")
            self.request.GET(recursoFormatado, callback: self.setInfo)
        })
    }
    
    func setInfo( response: Dictionary<String, AnyObject> ){
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
                //self.stopIndicator() */
            })
        }
        else {
            filme = dict
            print(filme)
            let urlCartaz = dict["Poster"] as? String ?? ""
            getCartaz(urlCartaz)
            
            dispatch_async(self.helper.globalMainQueue, {
                () -> Void in
                
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
                
                /*self.stopIndicator()
                self.tableCardapio.reloadData() */
            })
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
        print("POP")
        self.navigationController?.popViewControllerAnimated(true)
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
