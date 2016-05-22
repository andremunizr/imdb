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
        setInfo(filmeSelecionado)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Controller
    func setInfo(filme:NSManagedObject){
        self.titulo.text = filme.valueForKey("titulo") as? String ?? ""
        self.ano.text = filme.valueForKey("ano") as? String ?? ""
        self.duracao.text = filme.valueForKey("duracao") as? String ?? ""
        self.genero.text = filme.valueForKey("genero") as? String ?? ""
        self.diretor.text = filme.valueForKey("diretor") as? String ?? ""
        self.atores.text = filme.valueForKey("atores") as? String ?? ""
        self.plot.text = filme.valueForKey("plot") as? String ?? ""
        
        self.titulo.adjustsFontSizeToFitWidth = true
        self.ano.adjustsFontSizeToFitWidth = true
        self.duracao.adjustsFontSizeToFitWidth = true
        self.genero.adjustsFontSizeToFitWidth = true
        self.diretor.adjustsFontSizeToFitWidth = true
        self.atores.adjustsFontSizeToFitWidth = true
        self.plot.adjustsFontSizeToFitWidth = true
        
        let hashValue:String = "\(filmeSelecionado.objectID.hashValue)"
        let data = NSUserDefaults.standardUserDefaults().objectForKey(hashValue) as! NSData
        let imagem = UIImage(data: data)
        cartaz.image = imagem
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
