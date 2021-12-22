# 🛒 오픈 마켓 프로젝트

**프로젝트 기간: 2021년 8월 9일 ~ 8월 27일**

with 🐶 [*Coden*](https://github.com/ictechgy), 🔫 [*Geon*](https://github.com/jgkim1008), ☁️ [*Tyler*](https://github.com/TaeJoongYoon)(Reviewer)

&nbsp;
## 프로젝트 설명
사용자가 등록한 물품들을 그리드 리스트 형태로 보여주는 마켓 어플리케이션

&nbsp;   

## 목차
+ [실행 화면](#실행-화면)
+ [초기 UML](#초기-uml)
+ [최종 UML](#최종-uml)
+ [주요 구현 사항](#주요-구현-사항)
    1. [모델 타입 및 Unit Test 구현](#1-모델-타입-및-unit-test-구현)
        * [💫 Unit Test TroubleShooting](#-unittest-troubleshooting)
    2. [네트워크 통신 및 UI구현](#2-네트워크-통신-및-ui-구현)
        * [💫 Network TroubleShooting](#-network-troubleshooting) 
        * [💫 UI TroubleShooting](#-ui-troubleshooting) 

&nbsp;

## 실행 화면
|상황|실행화면|
|:--:|:--:|
|초기 로딩|<img width=300 src="https://user-images.githubusercontent.com/52707151/147071022-8d1f25ff-66ac-4815-9212-beed5642031d.gif">|
|리스트 끝 도달|<img width=300 src="https://user-images.githubusercontent.com/52707151/147069360-b414d724-b179-43e1-99c4-3deebc70b46d.gif">|

&nbsp;

## 초기 UML

<img width=400 src="https://user-images.githubusercontent.com/39452092/131108853-720f9df6-10dd-49e5-8da7-c2a2c4f7f1ba.png" />

&nbsp;

## 최종 UML

![https://user-images.githubusercontent.com/39452092/131107727-b1dbd858-8fd4-4eaf-a31c-c4b9201b3a83.png](https://user-images.githubusercontent.com/39452092/131107727-b1dbd858-8fd4-4eaf-a31c-c4b9201b3a83.png)

&nbsp;
# 주요 구현 사항
+ 아이템(물품) 데이터를 서버로부터 페이지 단위로 가져온 뒤 화면에 띄움.
    + 각 페이지당 아이템은 20개로 구성
    + 가져온 데이터는 파싱 처리를 거침

+ 첫 페이지에 대한 데이터 요청은 리스트 화면 `ViewController - viewDidLoad()`에서 이루어짐.
+ 사용자 스크롤에 따른 이후 데이터 요청은 `collectionView(_:prefetchItemsAt:)에서 이루어짐.`
+ 물품에 대한 이미지는 `collectionView(_:cellForItemAt:)`에서 요청
+ 가져온 이미지들은 추후 재사용을 위해 `URLCache.shared`에 **캐싱**
+ 서버 통신 완료 유무에 따라 Indicator가 보이거나 / 사라지도록 구현
+ 리스트의 끝에 도달하면 Alert가 띄워지도록 구현
+ 아이템 이미지가 없거나 불러오지 못한 경우 대체 이미지가 띄워지도록 구현

&nbsp;

## 1. 모델 타입 및 Unit Test 구현

+ 모델 타입 구현

+ 네트워크 통신이 불가능한 상황을 가정하고 구현한 모델 타입으로 파싱이 잘 이루어지는지 Unit Test 진행
    + 테스트용 더미 Asset 데이터 이용

&nbsp;

### 💫 UnitTest TroubleShooting
서버로부터 데이터가 넘어오는 상황을 어떻게 임의로 만들어볼 수 있을까 고민하였다. 이를 아래와 같은 방식으로 해결하였다.

+ 데이터를 받아오는 모듈에 대한 `Mock`객체를 구현하여 테스트. 

    + `Mock`객체에 대한 의존성 주입이 가능하도록 구현하여 테스트의 용이성 확보
&nbsp;
```swift
//우리가 구현한 Mock
import Foundation
import UIKit.NSDataAsset
@testable import OpenMarket

struct MockNetworkModule: DataTaskRequestable {
    let isSuccessTest: Bool
    
    init(isSuccessTest: Bool) {
        self.isSuccessTest = isSuccessTest
    }
    
    func runDataTask(with request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        var data: Data?
        
        switch request.httpMethod {
        case OpenMarketAPIConstants.listGet.method:
            data = NSDataAsset(name: "Items")?.data
        default:
            data = NSDataAsset(name: "Item")?.data
        }
        
        guard isSuccessTest, let data = data else {
            completionHandler(.failure(NetworkError.unknown))
            return
        }
        completionHandler(.success(data))
    }
}

```
&nbsp;
<details>
    <summary><b>Jost와 잼킹 조는 서버에 대한 역할을 대신 할 Mock을 만들 때 아래와 같은 방식을 사용하였다.</b></summary>
    <div markdown="1">
        
```swift
//서버와 통신을 할 클래스가 가져야 하는 역할과 책임을 프로토콜로 선언
protocol API {
    func getItemList(for page: Int, completionHandler: @escaping (Item?)->Void)
    func modifyItem...
    func removeItem...
}

//for Mock Object
class MockNetworkManager: API {
    func getItemList(for page: Int, completionHandler: @escaping (Item?)->Void) {
            //로컬 파일을 가져와서 파싱한 뒤에 completionHandler로 넘겨줌
            //DispatchQueue asyncAfter를 이용하여 임의의 시간 딜레이 부여
    }
        
    func modifyItem...
    func removeItem...
}

//for Real Object
class NetworkManager: API {
    func getItemList(for page: Int, completionHandler: @escaping (Item?)->Void) {
            //URLSession을 이용하여 실제 데이터를 가져오는 로직
    }
        
    func modifyItem...
    func removeItem...
}
```

- 위와같이 **프로토콜**을 사용하였고 테스트/프로덕션 용도에 따라 API타입 변수에 두 class타입 인스턴스 중 원하는 것으로 갈아 끼울 수 있도록 구현하였다. (**의존성 주입**처럼 보이며 **개방폐쇄원칙**도 지켜진 것 같다.)
        
    </div>
</details>


<details>
<summary><b>나(Coden)는 아래와 같은 방식을 생각하였다.</b></summary>
    <div markdown="1">

```swift
//내가 작성해본 코드
protocol DataTaskCreatable {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: DataTaskCreatable {}

class MockSessionDataTask: URLSessionDataTask {
    var completionHander: (() -> Void)
    
    init(handler: @escaping ()-> Void) {
        self.completionHander = handler
    }
    
    override func resume() {
        completionHander()
    }
}

class MockSession: DataTaskCreatable {
    private var requestCount = 0
    private var lastRequestURL: URLRequest?
    private var itemsData: Data?
    private var itemData: Data?
    private var httpResponse: URLResponse?
    private var httpError = NSError()
    var isFailureTest: Bool {
        didSet {
            if isFailureTest {
                itemsData = nil
                itemData = nil
                httpResponse = HTTPURLResponse(url: URL(string: "")!, statusCode: 999, httpVersion: nil, headerFields: nil)
            } else {
                itemsData = NSDataAsset(name: "items.json")?.data
                itemData = NSDataAsset(name: "item.json")?.data
                httpResponse = HTTPURLResponse(url: URL(string: "")!, statusCode: 200, httpVersion: nil, headerFields: nil)
            }
        }
    }
    
    init(isFailureTest: Bool) {
        self.isFailureTest = isFailureTest
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockSessionDataTask {
            completionHandler(nil, nil, nil)
            self.requestCount += 1
            self.lastRequestURL = request //값의 복사본을 capture
        }
    }
}

class NetworkManager {
    private let urlSession: DataTaskCreatable
    
    //의존성 주입
    init(urlSession: DataTaskCreatable = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    //목록을 가져오는 메소드
    func retrieveProducts(of pageNum: Int) {
        let requestURL = URLRequest(url: URL(string: "")!)
        let task = urlSession.dataTask(with: requestURL) { data, response, error in
            
        }
        task.resume()
    }
}
```
        
</div>
</details>


<details>
<summary><b>린생이 알려주신 방법을 떠올려가며</b></summary>
    <div markdown="1">

```swift
//린생이 알려주신 방법을 떠올려가며 작성
protocol Requestable {
    func request(completionHandler: @escaping (Result<Data, Error>) -> Void)
}

//실제 네트워크용
class RealRequestSession: Requestable {
    func request(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "")!)) { data, response, error in
            
        }
    }
}

//테스트용
class MockRequestSession: Requestable {
    var isFailTest: Bool
    
    init(isFailTest: Bool) {
        self.isFailTest = isFailTest
    }
    
    func request(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        if isFailTest {
            completionHandler(.failure(NSError()))
        } else {
            completionHandler(.success(Data()))
        }
    }
}

//기능을 검증하고자 하는 class
class KingNetworkManager {
    var session: Requestable
    
    init(session: Requestable = RealRequestSession()) {
        self.session = session
    }
    
    func requestItems(of pageNum: Int, completionHandler handler: @escaping (Result<Data, Error>) -> Void) {
        session.request(completionHandler: handler)
    }
}
```
</div>
</details>
        
        
<details>
<summary><b>좀 더 쉬운 예</b></summary>        
<div markdown="1">

```swift
//좀 더 쉬운 예
protocol Soundable {
    func sound(completionHandler: @escaping (Result<String, Error>) -> Void)
}

//production
class MP3: Soundable {
    func sound(completionHandler: @escaping (Result<String, Error>) -> Void) {
        //서버와 실제로 통신하고 그 결과를 completionHandler에 담아준 뒤 실행
        URLSession.shared.dataTask(with: URL(string: "some file URL")!) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
            }else {
                completionHandler(.success("신호등 - 이무진")) //실제로는 data를 넣거나 data를 가공해서 넣거나
            }
        }.resume()
    }
}

//test
class MockFile: Soundable {
    var isSuccessTest: Bool
    var count = 0
    
    init(isSuccessTest: Bool) {
        self.isSuccessTest = isSuccessTest
    }
    
    func sound(completionHandler: @escaping (Result<String, Error>) -> Void) {
        if isSuccessTest {
            completionHandler(.success("Butter - BTS"))
        } else {
            completionHandler(.failure(NSError()))
        }
        count += 1
    }
}

protocol MusicPlayer {
    var file: Soundable { get set }
    func play(completionHandler: @escaping (Result<String, Error>) -> Void)
}

class Melon: MusicPlayer {
    var file: Soundable
    
    init(file: Soundable = MP3()) { //의존성주입, 개방폐쇄원칙
        self.file = file
    }
    
    //서버로부터 데이터를 가져와서 플레이해주세요! <- 기능 검증을 하고 싶은 메소드
    func play(completionHandler: @escaping (Result<String, Error>) -> Void) {
        file.sound(completionHandler: completionHandler)
    }
}
```
            
    </div>
</details>

    
<details>
<summary><b>의존성 주입이란</b></summary>    
<div markdown="1">
        
### 의존성 주입

- 위의 UnitTest를 위해 우리는 의존성 주입이라는 방식을 사용하였다.
1. Manager에서 실질적인 기능을 하는 Module 타입을 바로 의존하지 않도록 하고 Requestable이라는 프로토콜을 의존하도록 만들었다. 
2. 테스트냐 프로덕션이냐에 따라 Requestable 프로토콜을 채택한 타입을 별도로 만들어주었다. (각각의 module 타입과 Mock객체)
3. 이후 목적에 따라 Manager에 해당 프로토콜을 준수한 타입을 주입해줌으로써 원하는 기능이 동작되도록 만들었다. 

&nbsp;

**`의존성 주입?`**

- 소프트웨어 엔지니어링에서 의존성 주입(dependency injection)은 하나의 객체가 다른 객체의 의존성을 제공하는 테크닉이다. "의존성"은 예를 들어 서비스로 사용할 수 있는 객체이다. 클라이언트가 어떤 서비스를 사용할 것인지 지정하는 대신, 클라이언트에게 무슨 서비스를 사용할 것인지를 말해주는 것이다. - [https://ko.wikipedia.org/wiki/의존성_주입](https://ko.wikipedia.org/wiki/%EC%9D%98%EC%A1%B4%EC%84%B1_%EC%A3%BC%EC%9E%85)
- 의존성주입은 쉽게 말하면 '특정 타입에서 사용하는 인스턴스를 외부에서 주입해준다'는 개념이다.
    - [https://velog.io/@wlsdud2194/what-is-di](https://velog.io/@wlsdud2194/what-is-di)
- 의존성 주입을 통해 우리는 개방-폐쇄원칙을 지킬 수 있게 된다.
    - 새로운 기능이 필요할 때 코드를 수정하는 대신 새로운 타입을 만들어서 주입해주면 된다.
- 의존성 주입을 위한 프로토콜을 만들면서 의존성 역전원칙이 지켜지게 된다.
    - 상호 타입간 결합도가 낮아지고 타입에 수정이 발생했을 때 서로에게 미치는 영향이 줄어든다.

&nbsp; 
        
</div>
</details>

&nbsp;   

- 참고링크
    - [https://ko.wikipedia.org/wiki/모의_객체](https://ko.wikipedia.org/wiki/%EB%AA%A8%EC%9D%98_%EA%B0%9D%EC%B2%B4
    
    - [https://medium.com/@SlackBeck/mock-object란-무엇인가-85159754b2ac](https://medium.com/@SlackBeck/mock-object%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%B8%EA%B0%80-85159754b2ac)
    - [https://martinfowler.com/articles/mocksArentStubs.html](https://martinfowler.com/articles/mocksArentStubs.html)
    - [https://www.crocus.co.kr/1555](https://www.crocus.co.kr/1555)
    - [http://www.incodom.kr/Mock](http://www.incodom.kr/Mock)
    - [https://academy.realm.io/kr/posts/making-mock-objects-more-useful-try-swift-2017/](https://academy.realm.io/kr/posts/making-mock-objects-more-useful-try-swift-2017/)
    
&nbsp;

## 2. 네트워크 통신 및 UI 구현
+ 네트워크 통신

    + 물품 데이터에 대한 통신 타입과 이미지에 대한 통신 타입을 분리하여 구현
    
+ UI 구현
    
    + CollectionView를 통한 Grid 스타일로 UI 구현

&nbsp;
    
### 💫 Network TroubleShooting
1. 예기치 않은 동작에 의해 동일한 페이지에 대한 요청이 두 번 이상 발생 할 수 있다고 판단하였다. 이러한 동작은 불필요한 리소스 낭비를 초래하기 때문에 아래와 같은 방식으로 막고자 하였다. 
   
    
+ **다수의 네트워크 통신이 요청되었을때 마지막 네트워크 통신만 요청하게 하고 나머지는 취소되게 로직 변경**

    - 중복되는 네트워킹에 대한 방어처리를 하여 불필요한 리소스 발생하지 않게 구현
    
    - 네트워크 요청이 있을때 dataTask 프로퍼티에 요청한 URLSessionDataTask를 저장하여, 네트워크 요청이 새로 들어왔을때 기존 네트워크 요청이 있으면 cancel하도록 구현

&nbsp;
    
<details>
<summary><b>기존 코드</b></summary>    
<div markdown="1">
    

    
```swift
struct NetworkModule: DataTaskRequestable {
    private let rangeOfSuccessState = 200...299

    mutating func runDataTask(with request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let response = response as? HTTPURLResponse,
               rangeOfSuccessState.contains(response.statusCode),
               let data = data {
                DispatchQueue.main.async {
                    completionHandler(.success(data))
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(.failure(NetworkError.unknown))
                }
            }
        }.resume()
    }
}
```
    
</div>
</details>


<details>
<summary><b>수정한 코드</b></summary>    
<div markdown="1">

```swift
struct NetworkModule: DataTaskRequestable {
    private var dataTask: URLSessionDataTask?
    private let rangeOfSuccessState = 200...299

    mutating func runDataTask(with request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        dataTask?.cancel()
        dataTask = nil
        
        dataTask = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let response = response as? HTTPURLResponse,
               rangeOfSuccessState.contains(response.statusCode),
               let data = data {
                DispatchQueue.main.async {
                    completionHandler(.success(data))
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(.failure(NetworkError.unknown))
                }
            }
        }
        dataTask?.resume()
    }
}
```
    
- 위의 코드에서 하나의 `NetworkModule` 인스턴스로 여러 네트워크 작업이 요청된다면, 기존의 작업은 취소된 뒤에 실행되게 된다.
    
</div>
</details>

&nbsp;

2. `Cell` 재사용에 의해 기존에 요청된 이미지가 잘못된 `Cell`에 적용될 수 있는 문제가 있었다. 이 것을 해결하고자 다음과 같은 방식들을 고려하였다. 

    
+ **이미지가 로드되었을 때 `IndexPath`를 비교**
    + 이 방식은 prefetch가 Enabled되어있을 때에는 사용해서는 안된다.

+ **Cache를 이용**
    + *재사용 목적의 캐싱으로는 이 문제를 해결하지 못한다.(어쨌든 초기 로딩은 필요하므로)*
    + 이미지를 미리 다운받아 캐시에 저장시키는 방법으로 해결 가능하다.(나중에 보여줄 때 캐시 이용)
    + 다만 어떤 이미지를 미리 다운받을 것인지 결정해주어야 한다.
    + 이미지를 미리 다운받았는데 사용하지 않는다면 용량 낭비가 될 수 있다.


+ **요청이 새로 발생 할 때마다 이미지 `URL` 또는 이미지 `id`를 `Cell`에 저장시킨 뒤, 이미지 로드가 끝났을 때 `Cell`이 가지고 있는 `URL` / `id`와 비교**
    
+ **`URLSessionDataTask`를 `Cell`타입에 전달해주고, 재사용 될 때 호출되는 `prepareForReuse()`메서드 내에서 기존 작업 `cancel` 처리**
    + 우리가 선택한 방식이다. 
<details>
<summary><b>코드</b></summary>    
<div markdown="1">
    
```swift
//Cell 코드
OpenMarketItemCell: UICollectionViewCell 
    private var imageDataTask: URLSessionDataTask?

    override func prepareForReuse() {
        super.prepareForReuse()
        imageDataTask?.cancel()
        imageDataTask = nil
    }
    
    func configure(from product: Product, with dataTask: URLSessionDataTask?) {
        imageDataTask = dataTask
    }
}
    
//리스트 화면에 대한 ViewController
extension ProductListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OpenMarketItemCell.identifier, for: indexPath)
        guard let customCell = cell as? OpenMarketItemCell else {
            return cell
        }
        
        let product = productList[indexPath.item]
        var imageDataTask: URLSessionDataTask? = nil
        
        if let validThumbnail = product.thumbnails.first {
            imageDataTask = imageManager.fetchImage(from: validThumbnail) { result in
                switch result {
                case .success(let image):
                    customCell.configure(image: image)
                case .failure:
                    customCell.configure(image: #imageLiteral(resourceName: "ErrorImage"))
                }
            }
        }
        
        customCell.configure(from: product, with: imageDataTask)
        return customCell
    } 
}
```
1. `URLSessionDataTask`를 `ViewController`에서 `Cell`에게 넘김
2. `Cell`이 재사용 되기 전에 스스로 기존 작업을 취소
&nbsp;
+ **하지만 이와 같은 방식은 MVC원칙에 위배된다.**
    
    + 뷰가 모델을 알고 있는 형태이다. 
    + 뷰가 모델을 의존하게 되고, 뷰의 재사용성이 떨어진다. 
    
    ➡️ `URL` 또는 `id`를 이용하는 방식이 가장 최선인 것 같다. 

</div>
</details>
   
    
    
    



&nbsp;
    
### 💫 UI TroubleShooting
1. `Cell` 내용 중 가격에 대한 부분이 잘려서 보이는 문제가 발생하였다. CHCR을 건드림으로써 해결하였다. 

&nbsp;
    
|상황|gif|
|:--:|:--:|
|CHCR적용 전|<img width=250 src="https://user-images.githubusercontent.com/39452092/131164624-f49d583d-8304-42f2-948a-f6e2acd9849a.gif" />|
|CHCR적용 후|<img width=250 src="https://user-images.githubusercontent.com/39452092/131164018-7c26a183-1703-4675-97fb-b71d1acb662c.gif" />|

&nbsp;
    
2. 아이템이 추가 될 때마다 전체 `CollectionView`를 `reload`하는 것은 리소스 낭비라고 생각하였다. 때문에 `insertItems(at:)`를 이용하였다.
&nbsp;
<details>
<summary><b>코드</b></summary>    
<div markdown="1">
    
```swift
private func reloadCollectionView(from startPoint: Int, to endPoint: Int) {
    let indexPaths = (startPoint...endPoint).map { IndexPath(item: $0, section: 0) }
    openMarketCollectionView.insertItems(at: indexPaths)
}
```
1. 데이터가 로드되었을 때 새 데이터들 `IndexPath` 범위를 별도로 계산
2. 이후 해당 범위에 대해 `insertItems(at:)` 호출
    
</div>
</details>
&nbsp;
