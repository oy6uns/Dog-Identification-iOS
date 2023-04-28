//
//  ViewController.swift
//  PicPractice
//
//  Created by saint on 2023/04/27.
//

import UIKit
import SnapKit
import Then
import Photos
import Moya

final class ViewController: UIViewController {
    
    let titleLabel = UILabel().then{
        $0.textColor = .hBlue1
        $0.font = .systemFont(ofSize: 30, weight: .light)
        $0.text = "What's my dog's breed?!"
    }
    
    let picBtn = UIButton().then {
        $0.backgroundColor = .hBlue2
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.hBlue4.cgColor
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.setTitle("앨범 접근", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    let cameraBtn = UIButton().then {
        $0.backgroundColor = .hBlue2
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.hBlue4.cgColor
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.setTitle("사진 촬영", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    let picView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.hBlue4.cgColor
    }
    
    let breedLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.textColor = .hBlue1
    }
    
    var breedData: ImageResponseDto?
    
    let imagePickerController = UIImagePickerController()
    
    // MARK: - Variables
    
    let userRouter = MoyaProvider<UserRouter>(
        plugins: [NetworkLoggerPlugin(verbose: true)]
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        setLayout()
        pressBtn()
        print(1)
    }
}

private extension ViewController {
    
    func setLayout() {
        view.backgroundColor = .white
        view.addSubviews([titleLabel, picBtn, cameraBtn, picView, breedLabel])
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        picBtn.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide).offset(40.adjustedW)
            $0.width.equalTo(80.adjustedW)
            $0.height.equalTo(40.adjustedW)
        }
        
        cameraBtn.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-40.adjustedW)
            $0.width.equalTo(80.adjustedW)
            $0.height.equalTo(40.adjustedW)
        }
        
        picView.snp.makeConstraints{
            $0.top.equalTo(picBtn.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300.adjustedW)
            $0.height.equalTo(400.adjustedW)
        }
        
        breedLabel.snp.makeConstraints{
            $0.top.equalTo(picView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
    }
    
    func pressBtn() {
        picBtn.press {
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        
        cameraBtn.press {
            switch PHPhotoLibrary.authorizationStatus() {
            case .denied:
                self.settingAlert()
            case .restricted:
                break
            case .authorized:
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ state in
                    if state == .authorized {
                        self.imagePickerController.sourceType = .camera
                        self.present(self.imagePickerController, animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            default:
                break
            }
        }
    }
    
    private func settingAlert(){
        if let appName = Bundle.main.infoDictionary!["CFBundleName"] as? String {
            let alert = UIAlertController(title: "설정", message: "\(appName)이(가) 카메라 접근 허용되어 있지 않습니다. 설정화면으로 가시겠습니까?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .default)
            let confirmAction = UIAlertAction(title: "확인", style: .default) {
                (action) in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            
        }
    }
    
    // MARK: - Server Helpers
    func sendImage(param: ImageRequestDto) {
        userRouter.request(.breedIdentification(param: param)) { response in
            switch response {
            case .success(let result):
                let status = result.statusCode
                if status >= 200 && status < 300 {
                    do {
                        self.breedData = try result.map(ImageResponseDto.self)
                        if let result = self.breedData{
                            print(result)
                            self.configBreed(breed: result.breed)
                        }
                    }
                    catch(let error) {
                        print(error.localizedDescription)
                    }
                }
                if status >= 400 {
                    print("error")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func configBreed(breed: String) {
        breedLabel.text = "This dog's breed is a \(breed)!"
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            picView.image = image
        }
        guard let image = picView.image else { return }
        let data = image.jpegData(compressionQuality: 1.0)
        if let data = data{
            let param = ImageRequestDto(image: data)
            sendImage(param: param)
        }
        dismiss(animated: true, completion: nil)
    }
}

