//
//  ViewController.swift
//  Imdb
//
//  Created by jenkins on 05/05/16.
//  Copyright © 2016 Imdb Teste Inc. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var nomeFilme: UITextField!
    @IBOutlet var tableFilmes: UITableView!
    @IBOutlet var label: UILabel!
    var listaFilmes = [NSManagedObject]()
    var filmeSelecionado:NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        listarFilmes()
    }
    
    // MARK: - Controller
    
    // titulo, ano, duracao, genero, diretor, atores, plot, poster
    @IBAction func salvarFilmeAction(sender:UIButton){
        let filmeInformado = nomeFilme.text! as String
        
        if filmeInformado == "" {
            return
        }
        salvarFilme(filmeInformado)
        nomeFilme.text = ""
        tableFilmes.reloadData()
    }
    
    func listarFilmes(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Filme")
        
        do {
            let lista = try managedContext.executeFetchRequest(fetchRequest)
            listaFilmes = lista as! [NSManagedObject]
            atualizaLabel()
        } catch let error as NSError {
            print("Erro ao recuperar: \(error)")
        }
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaFilmes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        let filme = listaFilmes[indexPath.row]
        
        cell!.textLabel!.text = filme.valueForKey("titulo") as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let filmeSelecionado = listaFilmes[indexPath.row]
        chamarTelaDetalhe(filmeSelecionado)
        
        tableFilmes.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    //MARK: - Navigation
    func chamarTelaDetalhe(selecionado: NSManagedObject){
        filmeSelecionado = selecionado
        performSegueWithIdentifier("fromMainToDetalhe", sender: self)
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if( segue.identifier == "fromMainToDetalhe" ){
            let detalheView = segue.destinationViewController as! DetalheViewController
            detalheView.filmeSelecionado = filmeSelecionado
        }
    }

    // MARK: - Core Data
    func salvarFilme(filmeInformado:String){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let filmeEntity = NSEntityDescription.entityForName("Filme", inManagedObjectContext: managedContext)
        let filme = NSManagedObject(entity: filmeEntity!, insertIntoManagedObjectContext: managedContext)
        filme.setValue(filmeInformado, forKey: "titulo")
        
        do {
            try managedContext.save()
            listaFilmes.append(filme)
            atualizaLabel()
        } catch let error as NSError {
            print("Erro ao salvar: \(error)")
        }
    }
    
    //MARK: - Util
    func atualizaLabel(){
        if listaFilmes.count > 0 {
            label.text = "Filmes favoritos"
        }
    }
}

