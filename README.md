# iOS-Dog-Identification-model

개 이미지의 품종, 특징 등을 분류, 인식하여 아이콘을 만들어주는 'Dog-Identification-model'을 FastAPI와 AWS EC2로 서빙해 놓은 상황입니다.
프로토타입 테스트를 위해 iOS 프로토타입 앱과 서버연결을 해보았습니다. 

### Ver 23/04/29.
POST 요청으로 사진을 MultipartFormData에 담아 보내면 response로 보낸 개 사진의 품종을 받을 수 있습니다.
현재 EC2에 서빙된 FastAPI 코드에는 statusCode가 없는 상태라, 만약 모델을 다시 서빙한다면, "ImageResponseDto.swift"파일의 responseBody에 statusCode를 추가해줘야합니다. 

### Ver 23/05/04.
- responseBody에 statusCode, success Message, breed를 추가했습니다.
- AWS EC2 인스턴스가 계속 혼자 중지되는 문제를 확인하고, 이를 해결했습니다. 

![IMG_4054 2](https://github.com/oy6uns/iOS-Dog-Identification-model/assets/45239582/15769395-81b5-48e1-a546-10e859572238) |![IMG_4055 2](https://github.com/oy6uns/iOS-Dog-Identification-model/assets/45239582/2bc65c33-bf19-466f-8aca-7a01bef9ec61)
--- | --- | 
