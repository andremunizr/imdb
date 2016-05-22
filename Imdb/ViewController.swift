//
//  ViewController.swift
//  Imdb
//
//  Created by jenkins on 05/05/16.
//  Copyright © 2016 Imdb Teste Inc. All rights reserved.
//

import UIKit
import CoreData

let RI = "FilmeCell"

class ViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {

    @IBOutlet var nomeFilme: UITextField!
    @IBOutlet var sugestao: UILabel!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!
    var listaFilmes = [NSManagedObject]()
    var filmeSelecionado:NSManagedObject!
    var dicionarioImagens: Dictionary<Int, AnyObject> = [1000:"-"]
    var filme = [String:AnyObject]()
    var cartaz :UIImage!
    let helper = Helper()
    let request = Request()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBarHidden = true
        sugestao.adjustsFontSizeToFitWidth = true
        listarFilmes()
    }
    
    // MARK: - Controller
    @IBAction func salvarFilmeAction(sender:UIButton){
        let filmeInformado = nomeFilme.text! as String
        
        if filmeInformado == "" {
            return
        }
        startIndicator()
        getInfo(filmeInformado)
    }
    
    func listarFilmes(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Filme")
        
        do {
            let lista = try managedContext.executeFetchRequest(fetchRequest)
            listaFilmes = lista as! [NSManagedObject]
            if listaFilmes.count > 0 {
                sugestao.hidden = true
            }
            else {
                sugestao.hidden = false
            }
        } catch let error as NSError {
            print("Erro ao recuperar: \(error)")
        }
    }
    
    @IBAction func mostrarFormularioDeInsercao(sender: UIButton){
        let alerta = UIAlertController(title: nil, message: "Qual o nome do filme?", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
                let filmeInformado = self.nomeFilme.text! as String
            
                if filmeInformado != "" {
                    self.startIndicator()
                    self.getInfo(filmeInformado)
                }
        })
        
        alerta.addAction(defaultAction)
        alerta.addTextFieldWithConfigurationHandler({
            (textField: UITextField!) -> Void in
                textField.placeholder = ""
                self.nomeFilme = textField
        })
        
        presentViewController(alerta, animated: true, completion:nil)
    }
    
    @IBAction func mostrarMenu(sender: AnyObject, indexPath: NSIndexPath){
        let filmeSelecionado = self.listaFilmes[indexPath.row]
        let titulo = filmeSelecionado.valueForKey("titulo") as! String
        
        let alerta = UIAlertController(title: titulo, message: "E agora?", preferredStyle: .Alert)
        let detalhar = UIAlertAction(title: "Detalhar", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
                self.chamarTelaDetalhe(filmeSelecionado)
        })
        let remover = UIAlertAction(title: "Remover", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
                self.removerFilme(titulo, index: indexPath.row)
        })
        let cancelar = UIAlertAction(title: "Cancelar", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alerta.addAction(detalhar)
        alerta.addAction(remover)
        alerta.addAction(cancelar)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    func imagemParaFilme(urlCartaz: String, hashValue: Int, index: Int){
        
        if let imagem = imagemParaHash(hashValue) {
            dispatch_async(self.helper.globalMainQueue, {
                let imagemNaCell:UIImageView = (self.view.viewWithTag( index ) as? UIImageView)!
                imagemNaCell.image = imagem
            })
        }
        else {
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
                                                                let imagemNaCell:UIImageView = (self.view.viewWithTag( index ) as? UIImageView)!
                                                                self.salvarImagem(imagem!, hashValue: hashValue)
                                                                
                                                                UIView.transitionWithView(imagemNaCell, duration: 0.5, options: transitionOptions, animations: {
                                                                    imagemNaCell.image = imagem
                                                                    }, completion: nil)
                                                            })
                                                        }
            })
        }
        
        /*
        let url = NSURL(string: urlCartaz)
        let request:NSURLRequest = NSURLRequest(URL: url!)
        if nil == dicionarioImagens[ hashValue ] {
            NSURLConnection.sendAsynchronousRequest(request,
                                                    queue: NSOperationQueue.mainQueue(),
                                                    completionHandler: {
                                                        (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                                                        if error == nil {
                                                            let imagem = UIImage(data: data!)
                                                            let transitionOptions = UIViewAnimationOptions.TransitionCrossDissolve
                                                            dispatch_async(self.helper.globalMainQueue, {
                                                                self.dicionarioImagens[ hashValue ] = imagem
                                                                let imagemNaCell:UIImageView = (self.view.viewWithTag( index ) as? UIImageView)!
                                                                self.salvarImagem(imagem!, hashValue: hashValue)
                                                                
                                                                UIView.transitionWithView(imagemNaCell, duration: 0.5, options: transitionOptions, animations: {
                                                                    imagemNaCell.image = imagem
                                                                    }, completion: nil)
                                                            })
                                                        }
            })
        }
        else {
            let image = self.dicionarioImagens[ hashValue ] as! UIImage
            dispatch_async(self.helper.globalMainQueue, {
                let imagemNaCell:UIImageView = (self.view.viewWithTag( index ) as? UIImageView)!
                imagemNaCell.image = image
            })
        } */
    }
    
    func imagemParaHash(hashValue: Int) -> UIImage? {
        let hash:String = "\(hashValue)"
        let data = NSUserDefaults.standardUserDefaults().objectForKey(hash) as? NSData
        
        if nil != data {
            let imagem = UIImage(data: data!)!
            return imagem
        }
    
        return nil
    }
    
    func salvarImagem(imagem: UIImage, hashValue: Int){
        let key:String = "\(hashValue)"
        
        if let imageDataPNG: NSData = UIImagePNGRepresentation(imagem) {
            NSUserDefaults.standardUserDefaults().setObject(imageDataPNG, forKey: key)
        }
        else if let imagemDataJPEG: NSData = UIImageJPEGRepresentation(imagem, 1.0) {
            NSUserDefaults.standardUserDefaults().setObject(imagemDataJPEG, forKey: key)
        }
    }
    
    func diretorioGaleria() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let diretorio = paths[0]
        return diretorio
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        mostrarMenu(collectionView, indexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 6
        let height = width * 1.4
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listaFilmes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(RI, forIndexPath: indexPath) as! FIlmeCell
       
        cell.cartaz.image = UIImage(named: "placeholder.jpg")
        
        if listaFilmes.count > 0 {
            let filmeDaRow = listaFilmes[indexPath.row] as NSManagedObject
            let urlImagem = filmeDaRow.valueForKey("poster") as? String
            let index:Int = indexPath.row * 33 + 1
            cell.cartaz.tag = index
            let hashValue:Int = filmeDaRow.objectID.hashValue
            dispatch_async(helper.globalBackgroundQueue, {
                self.imagemParaFilme(urlImagem!, hashValue: hashValue, index: index)
            })
            return cell
        }
        else {
            return cell
        }
    }
    
    //MARK: - Navigation
    func chamarTelaDetalhe(selecionado: NSManagedObject){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detalheView = storyBoard.instantiateViewControllerWithIdentifier("DetalheViewController") as! DetalheViewController
        detalheView.filmeSelecionado = selecionado
        self.navigationController!.pushViewController(detalheView, animated:true)
    }

    // MARK: - Core Data
    func salvarFilme(filmeInformado:String){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Filme")
        fetchRequest.predicate = NSPredicate(format: "titulo = %@", argumentArray: [filmeInformado])
        
        do {
            let filmes = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            if filmes.count > 0 {
                showAlert("Ops! Filme já adicionado!")
            }
            else {
                let filmeEntity = NSEntityDescription.entityForName("Filme", inManagedObjectContext: managedContext)
                let filmeObj = NSManagedObject(entity: filmeEntity!, insertIntoManagedObjectContext: managedContext)
                filmeObj.setValue(filmeInformado, forKey: "titulo")
                
                filmeObj.setValue(filme["Year"], forKey:"ano")
                filmeObj.setValue(filme["Runtime"], forKey:"duracao")
                filmeObj.setValue(filme["Genre"], forKey:"genero")
                filmeObj.setValue(filme["Director"], forKey:"diretor")
                filmeObj.setValue(filme["Actors"], forKey:"atores")
                filmeObj.setValue(filme["Plot"], forKey:"plot")
                filmeObj.setValue(filme["Poster"], forKey:"poster")
                
                try managedContext.save()
                listaFilmes.append(filmeObj)
            }
        } catch let error as NSError {
            print("Erro ao salvar: \(error)")
        }
    }
    
    func removerFilme(filmeInformado:String, index:Int){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Filme")
        fetchRequest.predicate = NSPredicate(format: "titulo = %@", argumentArray: [filmeInformado])
        
        do {
            let filmesRec = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            if filmesRec.count > 0 {
                let filmeRecuperado = filmesRec[0]
                managedContext.deleteObject(filmeRecuperado)
                try managedContext.save()
                
                listaFilmes.removeAtIndex(index)
                collectionView.reloadData()
                if listaFilmes.count > 0 {
                    sugestao.hidden = true
                }
                else {
                    sugestao.hidden = false
                }
            }
        } catch let error as NSError {
            print("Erro ao salvar: \(error)")
        }
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
        filme = dict
        if nil != dict["Error"] {
            dispatch_async(self.helper.globalMainQueue, {
                () -> Void in
                self.stopIndicator()
                self.showAlert( "Ops! Filme não encontrado!" )
            })
        }
        else if "N/A" == dict["Poster"] as! String {
            dispatch_async(self.helper.globalMainQueue, {
                () -> Void in
                self.stopIndicator()
                self.showAlert( "Ops! Este filme não tem cartaz!" )
            })
        }
        else {
            let urlCartaz = dict["Poster"] as? String ?? ""
            self.getCartaz(urlCartaz)
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
                                                        self.cartaz = imagem

                                                        dispatch_async(self.helper.globalMainQueue, {
                                                            () -> Void in
                                                            self.stopIndicator()
                                                            self.mostrarFilmeRecuperado()
                                                        })
                                                                    
                                                        /*let transitionOptions = UIViewAnimationOptions.TransitionCrossDissolve
                                                        dispatch_async(self.helper.globalMainQueue, {
                                                            UIView.transitionWithView(self.cartaz, duration: 0.5, options: transitionOptions, animations: {
                                                                self.cartaz.image = imagem
                                                                }, completion: nil)
                                                        }) */
                                                    }
        })
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let newWidth:CGFloat = 55
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func mostrarFilmeRecuperado(){
        let nomeFilme = filme["Title"] as! String
        let alertController = UIAlertController(title: nil, message: nomeFilme, preferredStyle: .ActionSheet)
        let salvarAction = UIAlertAction(title: "Adicionar", style: .Default, handler: {
            (alert: UIAlertAction!) in
            self.salvarFilme(nomeFilme)
            self.collectionView.reloadData()
            if self.listaFilmes.count > 0 {
                self.sugestao.hidden = true
                self.scrollToBottom()
            }
            else {
                self.sugestao.hidden = false
            }
        })
        let image = resizeImage(cartaz)
        salvarAction.setValue(image.imageWithRenderingMode(.AlwaysOriginal), forKey: "image")
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil)
    
        alertController.addAction(cancelarAction)
        alertController.addAction(salvarAction)
        self.presentViewController(alertController, animated: true, completion: {})
    }
    
    //MARK: - Util
    
    func scrollToBottom(){
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = NSIndexPath(forItem: item, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true)
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func startIndicator(){
        loader.startAnimating()
    }
    
    func stopIndicator(){
        loader.stopAnimating()
    }
}

