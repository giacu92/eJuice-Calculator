//
//  ViewController.swift
//  eJuice Calculator
//
//  Created by Giacomo Mammarella on 03/01/17.
//  Copyright © 2017 Giacomo Mammarella. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var volumePicker: UIPickerView!
    @IBOutlet weak var calculateButtonPressed: UIButton!
    let volumePickerData = ["ml", "cl", "dl"]
    
    @IBOutlet weak var desiredQuantityTF: UITextField!
    @IBOutlet weak var desiredNicotineStrengthTF: UITextField!
    @IBOutlet weak var desiredVgRatioTF: UITextField!
    
    @IBOutlet weak var nicotineVGRatioTF: UITextField!
    @IBOutlet weak var nicotineNicotineStrengthTF: UITextField!
    
    @IBOutlet weak var flavorPGRatioTF: UITextField!
    @IBOutlet weak var flavorPercentageTF: UITextField!
    
    @IBOutlet weak var flavorSwitch: UISwitch!
    
    @IBOutlet weak var BaseResultLabel: UILabel!
    @IBOutlet weak var VGResultLabel: UILabel!
    @IBOutlet weak var PGResultLabel: UILabel!
    @IBOutlet weak var FlavorResultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        volumePicker.delegate = self
        volumePicker.dataSource = self
        
        // rimuove la tastiera cliccando ovunque fuori
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        BaseResultLabel.isHidden = true
        VGResultLabel.isHidden = true
        PGResultLabel.isHidden = true
        FlavorResultLabel.isHidden = true
        
        
        // aggiunge la gestione di riconoscimento tap
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return volumePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return volumePickerData[row]
    }
    
    //cambio il colore del pickerView in bianco, cambio font e allineamento
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = volumePickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name:"Arial", size: 18.0)!, NSForegroundColorAttributeName:UIColor.white])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    // rimuove la tastiera cliccando ovunque
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func calculatePressed(_ sender: Any)
    {
        BaseResultLabel.isHidden = false
        VGResultLabel.isHidden = false
        PGResultLabel.isHidden = false
        FlavorResultLabel.isHidden = false
        
        // Variabili e correzione "," -> "."
        let desiredQuantityComma:String = desiredQuantityTF.text!.replacingOccurrences(of: ",", with: ".")
        let desiredQuantity:Float = NSString(string: desiredQuantityComma).floatValue
        
        let myString = NSAttributedString(string: desiredQuantity.description, attributes: [ NSForegroundColorAttributeName:UIColor.black])
        desiredQuantityTF.attributedText = myString

        let desiredNicotineComma:String = desiredNicotineStrengthTF.text!.replacingOccurrences(of: ",",with: ".")
        let desiredNicotine:Float = NSString(string: desiredNicotineComma).floatValue
       
        
        let desiredVgRatioComma:String = desiredVgRatioTF.text!.replacingOccurrences(of: ",", with: ".")
        var desiredVgRatio:Float = NSString(string: desiredVgRatioComma).floatValue
        
        let nicotineVgRatioComma:String = nicotineVGRatioTF.text!.replacingOccurrences(of: ",", with: ".")
        var nicotineVgRatio:Float = NSString(string: nicotineVgRatioComma).floatValue
        
        let nicotineNicotineStrengthComma:String = nicotineNicotineStrengthTF.text!.replacingOccurrences(of: ",", with: ".")
        let nicotineNicotineStrength:Float = NSString(string: nicotineNicotineStrengthComma).floatValue
        
        let flavorPgRatioComma:String = flavorPGRatioTF.text!.replacingOccurrences(of: ",", with: ".")
        var flavorPgRatio:Float = NSString(string: flavorPgRatioComma).floatValue
        
        let flavorPercentageComma:String = flavorPercentageTF.text!.replacingOccurrences(of: ",", with: ".")
        var flavorPercentage:Float = NSString(string: flavorPercentageComma).floatValue
        
        // pre-considerazioni:
        if !flavorSwitch.isOn {
            flavorPercentage = 0 }
        
        // centro i valori tra 0:100
        flavorPgRatio = aggiusta(val: flavorPgRatio)
        flavorPercentage = aggiusta(val: flavorPercentage)
        desiredVgRatio = aggiusta(val: desiredVgRatio)
        nicotineVgRatio = aggiusta(val: nicotineVgRatio)
        
        desiredVgRatioTF.text = desiredVgRatio.description
        nicotineVGRatioTF.text = nicotineVgRatio.description
        flavorPGRatioTF.text = flavorPgRatio.description
        
        //calcolo:
        var flavorVolume = (((desiredQuantity*flavorPercentage.divided(by: 100))*10).rounded())/10
        var baseVolume = ((((desiredNicotine*desiredQuantity)/nicotineNicotineStrength)*10).rounded())/10
        let targetVolume = desiredQuantity-baseVolume-flavorVolume
        let targetPercentage = ((desiredVgRatio.divided(by: 100).multiplied(by: desiredQuantity) - nicotineVgRatio.divided(by: 100).multiplied(by: baseVolume) - (1-flavorPgRatio/100).multiplied(by: flavorVolume))).divided(by: targetVolume)
        
        var vgQuanResult = (((targetVolume*targetPercentage*10).rounded())/10)
        
        var pgQuanResult = (((targetVolume*(1-targetPercentage)*10).rounded())/10)
        
        if baseVolume.isNaN
        {
            baseVolume = desiredQuantity-flavorVolume
        }
        else if baseVolume == desiredQuantity
        {
            baseVolume = desiredQuantity-flavorVolume
        }
        
        else if vgQuanResult<0
        {
            vgQuanResult = 0
            flavorVolume = (((flavorPercentage.divided(by: 100).multiplied(by: desiredQuantity))/(1-flavorPercentage.divided(by: 10)*10).rounded())/100)
            desiredQuantityTF.text = (baseVolume+flavorVolume).description
            
            let myString = NSAttributedString(string: desiredQuantityTF.text!, attributes: [ NSForegroundColorAttributeName:UIColor.red])
            
            desiredQuantityTF.attributedText = myString
        }
        else if pgQuanResult<0{
            pgQuanResult = 0
            flavorVolume = ((((flavorPercentage.divided(by: 100).multiplied(by: desiredQuantity))/(1-flavorPercentage.divided(by: 100))*100).rounded())/100)
            desiredQuantityTF.text = (baseVolume+flavorVolume + vgQuanResult).description
            
            let myString = NSAttributedString(string: desiredQuantityTF.text!, attributes: [ NSForegroundColorAttributeName:UIColor.red])
            
            desiredQuantityTF.attributedText = myString
        }
        
        if pgQuanResult.isNaN || pgQuanResult<0
        {
            pgQuanResult = 0
        }
        if vgQuanResult.isNaN || vgQuanResult<0
        {
            vgQuanResult = 0
        }
        
        // visualizzo i risultati:
        BaseResultLabel.text = ("Add \(baseVolume)" + "ml of base")
        VGResultLabel.text = ("Add \(vgQuanResult)" + "ml of VG")
        PGResultLabel.text = ("Add \(pgQuanResult)" + "ml of PG")
        FlavorResultLabel.text = ("Add \(flavorVolume)" + "ml  Flavor")
    }
    
    func aggiusta (val:Float) -> Float
    {
        var value:Float = 1
        
        if val>100
        {
            value = 100
        }
        else if val<0
        {
            value = 0
        }
        else
        {
            value = val
        }
        return value
    }
    
}
