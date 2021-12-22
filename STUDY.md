# 📖 정리
프로젝트를 진행하면서 공부했던 것들을 기록한 파일입니다.

&nbsp;

## 목차
+ [네트워크](#네트워크)
+ [열거형](#열거형)
+ [JSON](#json)
+ [셀 재사용 문제](#셀-재사용-문제)
+ [셀 이미지 지연로딩에 대한 명확한 이해와 IndexPath를 쓰지 말아야 하는 이유](#셀-이미지-지연로딩에-대한-명확한-이해와-indexpath를-쓰지-말아야-하는-이유)
+ [싱글톤](#싱글톤)
+ [Data extension](#data-extension)
+ [P.O.P](#pop)
+ [Capture in Struct](#capture-in-struct)
+ [Outlet](#outlet)
+ [Custom View](#custom-view)
+ [Formatting](#formatting)
+ [Cache](#cache)
+ [CollectionView](#collectionview)
+ [etc](#etc)

&nbsp;

## 네트워크

### URLSession

<details>


<summary> <b> URLSession 참고 링크 </b> </summary>

<div markdown="1">


- [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
  - [Fetching Website Data into Memory](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory)
  - [URLSessionTask](https://developer.apple.com/documentation/foundation/urlsessiontask)
  - [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system)

</div>

</details>


&nbsp;

**URLSession의 정의**

- 네트워크 데이터 전송 작업과 관련된 그룹을 조정하는 object
- 선언 형태

```swift
class URLSession : NSObject
```

&nbsp;

**Overview**

- 인증 지원, 리다이렉션, 작업완료와 같은 이벤트를 수신하기 위해 `URLSessionDelegate`와 `URLSessionTaskDelegate`를 사용할 수 있다.

- URLSession 인스턴스는 하나 이상 만들 수 있다. 각각의 인스턴스들은 데이터 전송 작업과 관련된 그룹을 조정한다.

  - 웹 브라우저를 만드는 경우 이 앱은 아마도 각각의 윈도우나 탭에 대해 하나씩의 세션을 만들 것이다.
  - 또는 하나는 상호작용의 목적으로 만들고 하나는 백그라운드 다운로드를 위한 것으로 만들 수도 있다.

  &nbsp;

**Types of URL Sessions - URLSession의 종류**

- configuration object - 단일 호스트에 대한 최대 동시 연결 수, 연결에 셀룰러 네트워크를 사용 할 수 있는지 여부 등과 같은 연결 동작을 정의하는 설정 object
- URLSession은 기본적인 요청들을 위한 `shared`세션 singleton을 가지고 있다.
  - 이 shared는 configuration object를 가지지 않는다.
  - 때문에 직접 만드는 세션과 같이 customizable하지 않다.
  - 다만, 요구사항이 굉장히 제한적인 경우 좋은 시발점 역할을 한다.
  - `shared` class method를 호출하여 이 세션에 접근 할 수 있다.
- 다른 종류의 세션들을 만들고자 하는 경우 다음 설정 중 하나로 URLSession을 만들어야 한다.
  - `Default` 세션은 shared session과 거의 비슷하게 동작하지만 설정값 조정이 가능하다. 데이터를 점진적으로 가져오기 위해 기본 세션에 delegate를 할당 할 수 있다.
  - `Ephemeral` 세션은 shared session과 거의 유사하지만 캐시, 쿠키, 자격증명을(credential) 디스크에 쓰지 않는다.
    - 일회성, 단발성 작업에 쓰일 것으로 예상된다.
    - private browsing에 쓰일 것 같다!!!
  - `Background` 세션은 컨텐츠에 대한 업로드와 다운로드를 백그라운드에서 수행 할 수 있도록 해준다. (앱이 동작중이 아니더라도!)

&nbsp;

**Types of URL Session Tasks - URL Session Task의 종류**

세션 내에서 선택적으로 데이터를 서버에 업로드한 다음, 서버로부터 데이터를 받아오는 작업을 생성한다. 

- 데이터를 받아오는 경우 디스크의 파일로 받을 수도 있고 메모리에 하나이상의 NSData object로 받을 수도 있다.

&nbsp; 

**URLSession API는 다음과 같은 4가지 유형의 task를 제공한다.**

- NSData object들을 이용하여 데이터를 보내고 받는 `Data Task`.

  - Data Task는 서버에 대한 짧은 요청을 위한 것이다. (종종 대화형 요청을 위해서도 쓰임)
  - 메모리에 있는 NSData object를 업로드하거나 메모리로 다운로드 할 때 쓰일 듯(짧고 가벼운 작업)

- `Upload Task`는 Data Task와 비슷하다.

  - 데이터 전송이 가능하며(종종 파일 형식의 데이터를 전송하는데에도 쓰일 수 있음) 앱이 동작중이지 않은 경우에 백그라운드로 업로드를 하는 것도 지원한다.
  - 길고 무거운 업로드 작업에 쓰일 듯

- `Download Task`는 파일의 형태로 데이터를 받아오는데에 쓰인다.

  - 앱이 동작중이지 않은 경우에도 백그라운드 다운로드나 업로드를 지원한다.
  - 길고 무거운 다운로드 작업에 쓰일 듯

- `WebSocket Task`는 TCP와 TLS를 통한 메시지 교환에 쓰인다.

  - RFC 6455에 정의된 웹소켓 프로토콜을 사용한다.
  - 1:1 메시지 통신에 쓰일듯?

  &nbsp; 

**Thread Safety**

URL session API는 thread-safe하다. session과 task는 어떤 쓰레드 문맥에서든지 자유롭게 만들 수 있다. delegate 메소드가 제공된 completion handler들을 호출하는 경우 작업들은 자동적으로 올바른 delegate queue에서 스케쥴링 된다.

&nbsp;

---
### URLSession 비동기 작업 완료 대응 - `@escaping completionHandler`

- 비동기적으로 수행된 작업을 처리하는 방식에는 여러가지가 있지만 우리는 그중에 completion handler를 사용하는 방식을 채택하였다. (다른 방법으로는 delegate나 async-await를 쓰는 방법이 있다고 한다.)

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

- `URLSession`의 `dataTask` `completionHandler`는 위와같이 정의하여 사용하였다. 내부에서 응답에 대한 성공/실패를 판단한 뒤 외부에서 주입된 또다른 `completionHandler`에 처리 결과를 넘겨주었다.

- 처리 결과에 대해서는 `Result`타입으로 넘겨주도록 만들었다.

  - 외부에서는 이 Result를 (switch등을 이용하여) 편리하게 핸들링 할 수 있게 되었다.

- `struct`로 이 모듈을 구현한 이유

  - 이 타입이 상속을 받는다거나 참조될 필요가 없다고 판단하였기에 `struct`로 구현하였다.

  - Apple의 공식문서에서도 나와있듯이 성능상의 이점을 가져가고자 하였다. (ARC 관리도 없으며 힙 할당도 없어서 오버헤드가 적다.)

    [https://developer.apple.com/documentation/swift/choosing_between_structures_and_classes](https://developer.apple.com/documentation/swift/choosing_between_structures_and_classes)

    [https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html)

- 메서드 내부에서 `dataTask`라는 프로퍼티를 변경하고 있기 때문에 `mutating`이 들어갔다.

- 메서드가 `mutating`이기 때문에 completion handler 클로저에서 `self`를 참조함에 문제가 생기므로 `[self]`로 `capture list`를 작성해주었다. (mutable self를 immutable self로 참조)

&nbsp;

---
### URL Loading System

- 표준 인터넷 프로토콜을 사용하여 URL과 상호작용하고 서버와 통신하기
- [https://developer.apple.com/documentation/foundation/url_loading_system](https://developer.apple.com/documentation/foundation/url_loading_system)

&nbsp;

**Overview**

- URLSession 인스턴스를 사용하여 하나 이상의 URLSessionTask 인스턴스를 생성할 수 있다.

- 이 task 인스턴스를 이용해 데이터를 가져오거나 파일 다운로드, 데이터 및 파일을 업로드 할 수 있다.

- Loading System은 비동기적으로 수행되어 즉각적으로 app은 응답을 받을수 있으며, 데이터를 처리하거나, 에러를 처리할수 있다.

- 커스텀 세션을 생성하는 경우 캐시 및 쿠키를 사용할지, 셀룰러 네트워크를 사용할지 등에 대한 설정을 `URLSessionConfiguration` object를 이용하여 할 수 있다.

  ![https://user-images.githubusercontent.com/39452092/131113260-a47ca3b7-ec4c-44ec-89ca-41b3be5a0df1.png](https://user-images.githubusercontent.com/39452092/131113260-a47ca3b7-ec4c-44ec-89ca-41b3be5a0df1.png)

- 각 세션은 주기적인 업데이트나 오류를 수신하는 delegate와 연관되어 있다.

- default delegate는 사용자가 제공한 completion handler블록을 호출하며 고유한 delegate를 제공한 경우 이 블록은 호출되지 않는다.

&nbsp;

### 이 프로젝트에서는 부하가 큰 작업이 요구되지 않기에 우리는 DataTask를 사용하였다.

- URLSession DataTask를 이용하면 메모리의 데이터를 서버와 주고받을 수 있다.
- 간단한 작업의 경우 그냥 `URLSession.shared` 싱글톤 인스턴스를 쓰면 되며 별도의 설정이 필요한 경우 `URLSessionConfiguration`을 이용하여 커스텀 `URLSession`을 만들어 사용하면 된다.
- [Fetching Website Data into Memory](https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory)에는 필요로 하는 것 이상의 세션을 만들지 말고, 비슷한 구성의 세션이 많이 필요하다면 하나를 공유해서 사용하라고 나와있다. 이에 대한 정확한 이유는 아직 잘 모르겠다.
- 세션을 가지고 있다면 dataTask() 메소드를 사용하여 Data task를 만들 수 있다. Task는 일시중지된 상태로 만들어지며, resume()을 호출함으로써 시작시킬 수 있다.

![https://user-images.githubusercontent.com/39452092/128722427-455c583c-d447-455a-8696-482238b6a6c8.png](https://user-images.githubusercontent.com/39452092/128722427-455c583c-d447-455a-8696-482238b6a6c8.png)

- completion handler는 3가지의 일을 해야한다.

  - `error` 파라미터가 nil인지 검증해야함. nil이 아니라는 것은 전송에러가 일어났음을 뜻한다. 에러를 처리하고 종료해야 한다.
  - `response` 파라미터를 확인하기. (성공을 나타내는 status code를 검증하고 MIME 타입이 예상한 값인지 검증하기 위해) 만약 아니라면 서버에러를 처리하고 종료해야 한다.
  - 필요에 따라 data 인스턴스를 사용하기.

- `**주의할 점**`

  - completion handler는 task를 생성한 것과는 다른 Grand Centeral Dispatch queue에서 호출된다. 그러므로 UI를 업데이트 하기 위해 data나 error를 사용하는 작업들은 - webView를 업데이트 한다던지 - 반드시 명시적으로 main queue에 위치해야 한다.

  - 데이터를 받아온 이후에 추가적인 작업이 필요한 경우(이를테면 UIImage로 변환하는 작업 등) 바로 main queue로 보내지 말고 부가적인 처리 후에 main으로 보내는 것이 좋다. 이렇게 해야 화면을 다시 그리는 update cycle이 버벅이지 않는다.

    ![https://user-images.githubusercontent.com/39452092/128512637-e6d6478e-a1c9-43fa-91a0-cdc45029aae9.png](https://user-images.githubusercontent.com/39452092/128512637-e6d6478e-a1c9-43fa-91a0-cdc45029aae9.png)

&nbsp;

---
### HTTP Method와 Multipart/Form-data

**HTTP란?**

- Hyper Text Transfer Protocol로서, 인터넷에서 데이터를 주고 받을수 있게 하는 프로토콜입니다. 처음에는 HTML 문서만 주고받게 설계되었으나, 다양한 데이터(멀티미디어)를 주고 받을수있게 점진적으로 발전되었습니다.
- [https://ko.wikipedia.org/wiki/HTTP](https://ko.wikipedia.org/wiki/HTTP)

&nbsp;

**HTTPS?**

- HTTP 프로트콜에 SSL 프로토콜을 추가하여 데이터를 암호화 한 방식(SSL은 버전업 되면서  TSL이라는 이름으로 바뀌었다.)
- [https://developer.mozilla.org/ko/docs/Glossary/https](https://developer.mozilla.org/ko/docs/Glossary/https)
- 보안을 추가하였기 때문에 신뢰성이 높아진다는 장점이 있다. - [https://www.notion.so/coden/aed532b513bf4c7b9318163016d4d38d#0f6a0f5469624209a4383f8c3fc3ee65](https://www.notion.so/aed532b513bf4c7b9318163016d4d38d)
- 다만 보안에 따른 오버헤드(최대 10배까지 느려진다고 함)가 발생한다. - [https://www.notion.so/coden/aed532b513bf4c7b9318163016d4d38d#568cc9349724404580eb91574d73816e](https://www.notion.so/aed532b513bf4c7b9318163016d4d38d)

&nbsp;

**TCP/IP**

- 인터넷 프로토콜 스위트(Internet Protocol Suite)라고 하여 인터넷에서 컴퓨터들이 서로 정보를 주고받는 데 쓰이는 통신규약(프로토콜)의 모음이다. 그 중 TCP와 IP가 가장 많이 쓰이기 때문에 TCP/IP 프로토콜 슈트라고 불린다. - [https://ko.wikipedia.org/wiki/인터넷_프로토콜_스위트](https://ko.wikipedia.org/wiki/%EC%9D%B8%ED%84%B0%EB%84%B7_%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C_%EC%8A%A4%EC%9C%84%ED%8A%B8)
- [https://www.ibm.com/docs/ko/aix/7.1?topic=management-transmission-control-protocolinternet-protocol](https://www.ibm.com/docs/ko/aix/7.1?topic=management-transmission-control-protocolinternet-protocol)
- TCP는 전송  제어 프로토콜이라고 하며 인터넷에 연결된 컴퓨터들 간 일련의 옥텟을 안정적으로, 순서대로, 에러없이 교환할 수 있게 한다. - [https://ko.wikipedia.org/wiki/전송_제어_프로토콜](https://ko.wikipedia.org/wiki/%EC%A0%84%EC%86%A1_%EC%A0%9C%EC%96%B4_%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C)
- IP는 인터넷 프로토콜이라고 하며 송신 호스트와 수신 호스트가 패킷 교환 네트워크에서 정보를 주고받는 데 사용하는 정보 위주의 규약이다. - [https://ko.wikipedia.org/wiki/전송_제어_프로토콜](https://ko.wikipedia.org/wiki/%EC%A0%84%EC%86%A1_%EC%A0%9C%EC%96%B4_%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C)

&nbsp;

**HTTP Methods**

[https://developer.mozilla.org/ko/docs/Web/HTTP/Methods](https://developer.mozilla.org/ko/docs/Web/HTTP/Methods)

[http://www.ktword.co.kr/test/view/view.php?m_temp1=3791](http://www.ktword.co.kr/test/view/view.php?m_temp1=3791)

- GET : 리소스 취득
  - URL(URI) 형식으로 웹서버에 리소스를 요청한다.
- POST:  내용 전송
  - 요청 데이터를 HTTP 바디에 담아 웹서버로 전송한다.
- PATCH: 내용의 부분적인 수정
  - PUT 메서드는 문서 전체의 완전한 교체만을 허용한다. 반면 PATCH메서드는 PUT 메서드와 달리 멱등성을 가지지 않으며 side effect가 존재한다. 다만 PATCH를 PUT과 같은 방식으로 사용함으로써 멱등성을 가지게 할 수 있다.
- DELETE: 파일 삭제
  - 웹 리소스를 삭제한다.

&nbsp;

**`POST`와 `PUT`의 차이**

- [https://velog.io/@53_eddy_jo/RESTful한-세계에서의-POST와-PUT의-차이-거기에-FETCH까지](https://velog.io/@53_eddy_jo/RESTful%ED%95%9C-%EC%84%B8%EA%B3%84%EC%97%90%EC%84%9C%EC%9D%98-POST%EC%99%80-PUT%EC%9D%98-%EC%B0%A8%EC%9D%B4-%EA%B1%B0%EA%B8%B0%EC%97%90-FETCH%EA%B9%8C%EC%A7%80)
- [https://multifrontgarden.tistory.com/245](https://multifrontgarden.tistory.com/245)
- PUT과 POST의 차이는 **멱등성**으로, PUT은 멱등성을 가집니다. PUT은 한 번을 보내도, 여러 번을 연속으로 보내도 같은 효과를 보입니다. 즉, 부수 효과(side effect)가 없습니다
- [https://developer.mozilla.org/ko/docs/Web/HTTP/Methods/POST](https://developer.mozilla.org/ko/docs/Web/HTTP/Methods/POST)
- [https://ko.wikipedia.org/wiki/멱등법칙](https://ko.wikipedia.org/wiki/%EB%A9%B1%EB%93%B1%EB%B2%95%EC%B9%99)
- 기본 리소스 요청방식은 `GET`이다.

&nbsp;

**multipart/form-data**

- HTTP Request Body에 여러가지 데이터를 한번에 보내야 할 때 쓰는 Content-Type이다.(Header에 표기)

- 일종의 전송 양식이라고 생각하자.

  - 이 양식에 맞춰서 보내야 서버에서도 알아듣는다.

- **양식**

  - 각각의 데이터 배치 순서는 우리 마음대로 둘 수 있다.

  - `Boundary`는 각 데이터의 구분자이며 각 데이터 위쪽에 써준다.

    - 맨 마지막 데이터를 써준 뒤에도 들어가야 하는데 이때에는 맨 뒤에 `--`가 들어간다.

    - `Boundary`에는 보통 `UUID`를 쓴다.

      [https://ko.wikipedia.org/wiki/범용_고유_식별자](https://ko.wikipedia.org/wiki/%EB%B2%94%EC%9A%A9_%EA%B3%A0%EC%9C%A0_%EC%8B%9D%EB%B3%84%EC%9E%90)

  - `name`은 키값, 개행(CRLF)을 두번 한 뒤에 들어가는 값은 `밸류값`

  - Content-Disposition: form-data

    [https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Disposition](https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Disposition)

    [https://lannstark.tistory.com/8](https://lannstark.tistory.com/8)

    - 각각의 데이터를 form-data로 보면 될 것 같다. 그리고 이러한 것들을 모아서 헤더에 multipart/form-data라고 하는 것이고..

- **`In Swift`**

  - 각각의 데이터들은 `Data()`타입으로 넣는다.(뒤에 덧붙이는 형태)

    → 꼭 Data 뒤에 Data를 붙이는 방식이어야 할까? String 등으로 일단 붙인 다음에 한번에 변환하는건 안될까? 

  - 밸류값이 복수개인 것은 키값 뒤에 `[]`를 넣어줘야 한다.

    - 키값 하나로 밸류 여러개가 들어감

  - 이미지의 경우 키값 뒤에 filename과 content-type(MIME)을 넣고 그 뒤에 이미지 데이터를 넣는다.

    - filename은 지정해서 서버한테 넣어줘도 서버가 알아서 파일의 이름을 바꾸네..? → 서버쪽에서 난수로 직접 지정해주는 것 같음(UUID)
    - 파일 확장자도 바뀜..(jpeg → png) 서버가 뭔가 컨버팅 해주나보다.

  - 데이터를 하나로 뭉친다음에 `HTTPRequest`의 `httpBody`에 설정해주면 된다.

&nbsp;

---
### MIME 타입과 Content-Disposition???

**`용어 정리`**

- MIME
  - 서버와 클라이언트간 전송되는 문서의 다양성을 알려주는 메커니즘입니다.
  - 즉 문서를 주고 받을 때 이 문서가 어떤 문서인지 알려주는 역할이라고 보면 될 것 같다.
- multipart/form-data
  - MIME타입중의 하나.
  - 일반적으로 다른 MIME 타입들을 지닌 개별적인 파트들로 나누어지는 문서의 카테고리를 가리킨다. 즉 *합성된 문서*를 나타내는 방법이다.
- Content-Type
  - 리소스의 media type을 나타내기 위해 사용된다.
- Content-Disposition
  - multipart/form-data 본문에서의 content-disposition은 multipart의 하위 파트로써 사용되며 본문 내 필드에 대한 정보를 제공한다.
- form-data
  - form 필드와 그 값을 나타내는 일련의 key/value 쌍을 쉽게 생성할 수 있는 방법을 제공

&nbsp;

**Directives(지시자들) 중 `filename`은 선택사항이다!!!** 

![https://user-images.githubusercontent.com/39452092/131147534-d8d4f7bc-314d-4a79-8f9d-e3b783a7e679.png](https://user-images.githubusercontent.com/39452092/131147534-d8d4f7bc-314d-4a79-8f9d-e3b783a7e679.png)

[https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Disposition](https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Disposition) 내용에서 발췌

&nbsp;

**Reference**

- [https://developer.mozilla.org/ko/docs/Web/HTTP/Basics_of_HTTP/MIME_types](https://developer.mozilla.org/ko/docs/Web/HTTP/Basics_of_HTTP/MIME_types)
- [https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Type](https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Type)
- [https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Disposition](https://developer.mozilla.org/ko/docs/Web/HTTP/Headers/Content-Disposition)
- [https://developer.mozilla.org/ko/docs/Web/API/FormData](https://developer.mozilla.org/ko/docs/Web/API/FormData)
- [https://lena-chamna.netlify.app/post/http_multipart_form-data/](https://lena-chamna.netlify.app/post/http_multipart_form-data/)
- [https://junghyun100.github.io/Multipart_form-data/](https://junghyun100.github.io/Multipart_form-data/)
- [https://nsios.tistory.com/39](https://nsios.tistory.com/39)

&nbsp;

**`결론`**

*우리는 POST로 request를 보낼 때 아래와 같은 작업을 하였다.*

1. request header에 Content-Type으로 multipart/form-data를 지정하였다.

   → 야 우리 body에 데이터 여러개 form-data(key, value) 형식으로 보낼꺼야!!

2. request body에서 각각의 데이터는 boundary로 구분

3. request body에서 미디어들에 대해 Content-Disposition과 Content-Type 작성

   → 이 본문 필드는 form-data 형식인데 컨텐츠 미디어 타입은 이거야! 

&nbsp;

---
### Network Response StatusCode

**HTTP의 상태코드란?**

- 클라이언트의 요청에 대한 서버의 상태를 표현한 것
- 200...299 : 성공
- 300...399 : 요청을 마치려면 추가동작이 요구됨(이를테면 리다이렉션)
- 400...499: 클라이언트 오류(이를테면 잘못된 요청 등)
- 500...599: 서버오류(서버에 오류등의 문제가 발생함)

&nbsp;

Reference

- [http://www.ktword.co.kr/test/view/view.php?no=5407](http://www.ktword.co.kr/test/view/view.php?no=5407)
- [https://developer.mozilla.org/ko/docs/Web/HTTP/Status](https://developer.mozilla.org/ko/docs/Web/HTTP/Status)
- [https://ko.wikipedia.org/wiki/HTTP_상태_코드](https://ko.wikipedia.org/wiki/HTTP_%EC%83%81%ED%83%9C_%EC%BD%94%EB%93%9C)
- [https://ko.wikipedia.org/wiki/HTTP](https://ko.wikipedia.org/wiki/HTTP)

&nbsp;

## 열거형

### Result 타입

```swift
@frozen enum Result<Success, Failure> where Failure : Error
```

- Error Throwing 함수에 대해서 Do-catch문을 주로 사용했는데, Result타입을 통해 Error을 핸들링할수 있다.
- Result타입을 통해 다양한 오류에 대해 비교적 짧고 간결하게 대처할수 있는 장점이 있다. (do-catch에 비해)
- 에러를 처리하는데에 있어 Result를 쓸지, do-catch를 쓸지는 선택의 문제일 뿐이라고 한다. - vivi

&nbsp;

### switch-case가 아닌 guard를 이용하여 열거형 해체하기

```swift
let parsedResult = parsingManager.decode(from: expectInputValue, to: Product.self)
guard case .success(let outputValue) = parsedResult else {
    return XCTFail()
}
```

- UnitTest에서 우리는 위와 같은 방식을 사용하였다.
- switch-case와는 다르게 원하는 결과 case만 받고싶은 경우 위와같이 간단히 처리할 수 있다.

&nbsp;

## JSON

### JSON을 표현할 Object와 CodingKeys 사용

- API문서에 따라 서버에 요청하여 받은 Json 데이터를 파싱할수 있도록, 데이터 모델인 Product와 Products 타입에 Codable/Decodabe 채택하여 선언
- camelCase적용을 위해 CodingKeys 프로토콜 채택

```swift
struct Product: Codable {
    let id: Int
    var title: String
    var description: String?
    var price: Int
    var currency: String
    var stock: Int
    var discountedPrice: Int?
    let thumbnails: [String]
    var images: [String]?
    let registraionDate: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case price
        case currency
        case stock
        case discountedPrice = "discounted_price"
        case thumbnails
        case images
        case registraionDate = "registration_date"
    }
}
```

- Codable에 들어가는 타입의 프로퍼티들은 Codable을 준수하고 있어야 한다.

&nbsp;

## 셀 재사용 문제

### 테이블 뷰 셀 재사용 이슈

- 화면에 Cell이 보여질 때마다 CollectionView 또는 TableView는 이 셀을 새로 만드는 것이 아니라 기존의 셀을 계속 재사용한다.
  - 이는 성능상의 이점을 가져다가 준다.
- 화면에서 사라진 셀은 Reuse Queue에 들어가게 되고 화면에 보이게 될 셀을 전담하는데에 재활용된다.
- 재활용 하기 때문에 셀의 색, 투명도같은 특징은 물론 컨텐츠들까지 다시 설정해주어야 한다.

```swift
class ListViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet private weak var tableView: UITableView!
    //MARK: Properties
    private let totalSectionCount = 10
    private let fixedLowCount = 2

    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
}

//MARK:- Conform to DataSource
extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        totalSectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section + fixedLowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BasicCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if indexPath.row % 2 == 0 {
            var backgroundConfig = cell.backgroundConfiguration
            backgroundConfig?.backgroundColor = .systemRed
            cell.backgroundConfiguration = backgroundConfig
        }        
        return cell
    }
}
```

위와 같은 코드를 실행했을 때 결과는 아래와 같았다. 

<img width=250 src="https://user-images.githubusercontent.com/39452092/131141589-bd9f6bf7-08cb-464c-a276-be0a4298b91c.gif" />

- 셀의 row값이 2의 배수인 경우에만 백그라운드가 빨간색이 되도록 했는데 어느순간 모든 셀이 빨간색이 되어버렸다.

&nbsp;

**해결에 대해 - 실제로 테스트 했던 코드로 살펴보자**

[https://github.com/ictechgy/TableViewTest](https://github.com/ictechgy/TableViewTest)

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellIdentifier = "BasicCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    var cellConfiguration = cell.defaultContentConfiguration()
    
    //cell.prepareForReuse() - 잘 알고 쓰자
    if indexPath.row == cellBackgroundDecorationRowValue {
        cell.backgroundColor = .red
    } else {
        cell.backgroundColor = .white
    }
    if indexPath.section <= cellLabelDecorationSectionDeadline {
        cellConfiguration.text = "(\(indexPath.section), \(indexPath.row))"
    } else {
        cellConfiguration.text = nil //빈 문자열로 설정하는 것보다는 nil이 적합할듯? 
    }
    if let url = CellNumber(rawValue: indexPath.row)?.imageURL {
        networkManager.receiveImage(of: url) { image in
            cellConfiguration.image = image
            cell.contentConfiguration = cellConfiguration
        }
    }
    cellConfiguration.image = nil
    cell.contentConfiguration = cellConfiguration
    
    return cell
}
```

**Basic Style 셀을 가지고 테스트**

- 셀에 지정해주었던 Text는 ~~알아서 사라지고 다시 세팅되므로 문제가 없었음~~

  → Text도 다시 설정해주어야 한다!! 

- 셀에 지정해준 background는 재사용 할 때마다 그대로 남았다.

  → 때문에 재사용 하기 전 원래대로 돌려주거나 위처럼 분기처리 필요

- 셀에 로드해준 이미지는 문제가 없는 듯 보였지만 스크롤을 빠르게 오르내리면 원치 않는 위치에 이미지가 삽입됨

  → 셀은 이미 재사용 되었는데, 이전에 보낸 이미지 로드 요청이 완료되어서 그 위에 덮이는 듯.(재사용된 셀 위에) 

  - 어떻게 해결할 수 있을까?
  - 셀 재사용 전 이미지를 nil로 처리하는 것은 효용이 없다. (어쨌든 재사용 전에 처리하기만 할 뿐이니. 컨텐츠 초기화때문에 필요하기는 하지만.. )

```swift
if let url = CellNumber(rawValue: indexPath.row)?.imageURL {
    networkManager.receiveImage(of: url) { image in
        if tableView.indexPath(for: cell) == indexPath {
            cellConfiguration.image = image
            cell.contentConfiguration = cellConfiguration
        }
    }
}
```

**위의 방법으로 해결하였다.**

- **completionHandler(클로저)** 를 넘길 때 기존 위치값인 `indexPath`와 `tableView` 및 `cell`을 capture한다. 이후 통신이 완료되었을 때 클로저를 실행하는데, 현재 이 `cell`이 `tableView`에서 어떠한 `IndexPath`를 가지는지 물어보고, 기존에 capture했던 `indexPath`와 비교한다. (IndexPath만 struct이므로 해당 인스턴스는 복사본을 capture하고 있을 것)

비교를 해서 셀의 기존 위치값(섹션 및 행)과 현재 위치값이 변함이 없는 경우에만 이미지를 설정해준다. 

→ `IndexPath`는 `Equatable`을 준수하고 있으므로 section과 row를 직접 비교하지 않고 `==`로 바로 비교해도 된다.
→ `tableView.indexPath(for:)`도 어쨌든 tableView에 접근하여 물어보는 것이므로 메인쓰레드에서 실행되어야 한다.

&nbsp;

**PrepareForReuse()**

[Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uitableviewcell/1623223-prepareforreuse)

- 컨텐츠가 아닌 것(알파 값, 배경, 선택 상태, 편집상태 등)을 재설정해줄 때에만 사용해야 함
- 쓰는 이유?
  - 테이블 뷰에서는 한가지 모양의 셀만 사용하지는 않는다.
  - 여러 종류의 셀을 사용 할 때  `tableView(_:cellForRowAt:)`내에서 각각의 셀마다 분기문으로 초기형태로 설정해 줄 필요 없이 알아서 재설정 하도록 해주기 위해
  - 다만 커스텀 셀에서만 오버라이딩해줄 수 있으므로 기본 셀에서는 사용에 제약이 있다.

&nbsp;

**셀이 재사용되려고 Reuse Queue에 들어갔거나 나올 때 기존에 보낸 네트워크 요청을 취소시키면 안될까?** 

*이 방식도 가능 할 것 같기는 하다..* 

- 커스텀 셀을 만들고 안에 task를 저장하도록 프로퍼티를 둔 뒤에 작업을 요청 할 때 같이 셀에 할당. 이후 `prepareForReuse()`에서 해당 task가 끝나지 않았으면 `task.cancel()`호출

  → **`cancel()`이 진짜 작업을 취소하는 것은 아님.** 해당 Task는 끝까지 하며 다운로드 된 뒤에 적용 할지 안할지만 결정된다. 때문에 **성능상 큰 차이는 없다**. (OperationQueue여도 똑같다고 하는데... )

  - completionHandler가 실행이 안되는건가?

- 다른 좋은 방법이 있을까?

&nbsp;

**UIImage(data:)는 어느 쓰레드에서?**

데이터를 이미지로 변환하는 위의 메소드는 부하가 큰 작업이다. 때문에 메인 쓰레드에서 호출하는 경우 화면이 뚝뚝 끊길 수 있다. → 이 메소드는 다른 쓰레드에서 호출하자. (결과값인 `UIImage`를 `ImageView`에 설정해주는 것만 메인에서)

&nbsp;

---

### 셀 이미지 지연로딩에 대한 명확한 이해와 IndexPath를 쓰지 말아야 하는 이유

**아래 문단만 읽어도 충분하다.**
+ UITableView Prefetch는 PrefetchDataSource를 설정하면 prefetch가 enable되고 nil로 설정하면 disable 됐었다.
+ 근데 iOS 15부터는 on/off 프로퍼티인 isPrefetchingEnabled 프로퍼티가 생기게 되었다. (기본값 true)
➡️ 즉, PrefetchDataSource가 설정된 상태에서 Prefetch on/off가 가능해짐!

&nbsp;

+ UICollectionView의 경우에도 PrefetchDataSource 설정 여부에 따라 prefetch가 동작하거나 동작하지 않는다.
+ isPrefetchingEnabled는 기본적으로 iOS 10부터 존재했으며 이 값을 통한 on/off 제어 가능했다. 

**➡️ 결론: prefetch가 꺼져있으면 IndexPath를 통한 비교도 안전하다!**

&nbsp;

<details>
<summary> <b> 왜 쓰지 말아야 할까?! </b> </summary>

<div markdown="1">


# TableView와 CollectionView에 대한 중요한 사실

## 들어가기에 앞서.

**UITableView**든 **UICollectionView**든 `indexPath(for:)`이라는 메소드의 반환값은 nil이 나올 수 있다는 것을 명심해야 한다. 여기서 nil이 나온 다는 것은 cell이 TableView나 CollectionView에 없다는 것을 의미하는데, 정확히는 **Reuse Queue**에 셀이 재사용되려고 들어간 상태라고 보는 것이 옳을 듯 하다. (또는 재사용되려 나왔는데 아직 그려지지 못해서 IndexPath를 가지지 못했을 수도 있다.)

&nbsp;

## 무엇이 되고 무엇이 안되는가?

**TableView**의 경우 셀이 보이려는 부분에 대해서만 DataSource의 `TableView(_:cellForRowAt:)`이 호출된다. 

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //...
    print(indexPath)
		//...
    
    return cell
}

```

![https://user-images.githubusercontent.com/39452092/130812678-6e9d355b-8369-453c-92e9-6247390a20e3.gif](https://user-images.githubusercontent.com/39452092/130812678-6e9d355b-8369-453c-92e9-6247390a20e3.gif)

위의 gif에서도 볼 수 있듯이, `TableView(_:cellForRowAt:)`은 셀이 보이려는 순간에 호출이 되므로 해당 메소드가 호출됨과 동시에 cell은 화면에 나타나게 된다. 

따라서 내부 코드에서 이미지를 요청하고 이미지가 도착했을 때 기존 `indexPath`와 `tableView.indexPath(for:)` 를 비교하는 것이 큰 문제가 되지 않는다.  그냥 데이터가 도착했을 때 indexPath를 비교하고 셀에 그릴지 말지 결정하기만 하면 된다. 

- TableViewTest코드
  - [https://github.com/ictechgy/TableViewTest](https://github.com/ictechgy/TableViewTest)

&nbsp;

### 그래서 이게 왜 문제냐고?

### 문제는 UICollectionView에서 발생한다.

```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //...
    print(indexPath)
            //...

    return customCell
}
```

&nbsp;

![https://user-images.githubusercontent.com/39452092/130816610-1114ef64-e0ac-4549-8304-11a141f7bc13.gif](https://user-images.githubusercontent.com/39452092/130816610-1114ef64-e0ac-4549-8304-11a141f7bc13.gif)

gif가 보이는가? 분명히 화면에는 [0, 0] ~ [0, 5]에 해당하는 셀들만 보이고 있다. 그런데 스크롤을 살짝 내리니 [0, 6] ~ [0, 9]에 해당하는 셀들이 만들어지도록 요구되었다. 

즉, 화면에는 아직 보이지 않지만 다음 셀들에 대한 `collectionView(_:cellForItemAt:)`이 미리 호출된 것이다. → 덕분에 우리는 렉 없는 매끄러운 스크롤을 할 수 있을 것이다.  

&nbsp;

**결정적인 문제는 이미지 로딩과 같은 비동기 작업에서 발생한다.**

셀이 아직 보이지 않는 상황에서 해당 셀의 이미지에 대한 네트워크 요청이 발생되었다고 하자. 이미지 데이터를 가져와서 `UIImage`변환까지 다 했는데 셀이 아직 화면에 그려지지 않은 상태라면? → 이 때 indexPath를 비교하여 이미지를 세팅하는 코드를 사용하는 경우 기껏 가져온 이미지는 버려지게 된다.  

`collectionView(_:cellForItemAt:)`에서 해당 셀이 어떤 indexPath를 가지게 될 것인지는 알지만 아직 해당 indexPath가 셀에 부여(?)된 것은 아니다. 때문에 이미지가 도착했을 때 셀에 대한 `collectionView.indexPath(for:)`를 호출하는 경우 결과값이 nil이 나올 수가 있다는 것이다. 

(셀에 부여될 indexPath ≠ 아직 부여되지 않은 indexPath는 nil)

&nbsp;

### 그러면 이러한 비동기 작업은 어떻게 해결할 수 있는걸까?

위에서 봤듯이 이러한 비동기 작업 처리에 대해 indexPath를 비교하는 방법은 불확실하다. ~~TableView에서만 쓰거나 아예 쓰지 말자.~~ ➡️ prefetch가 활성화되어 있지 않을 때에만 쓰자 

1. **셀이 재사용 될 때 기존에 요청한 작업을 취소하는 방식**이 가장 바람직해 보인다. 즉, 재사용 된 이후의 네트워크 요청만 남겨지도록 만들자는 뜻이다. 

   - 이 방식을 사용하면 위의 `CollectionView`에서 보이지 않는 셀에 대한 네트워크 요청이 이루어진 경우 결과 이미지는 해당 셀에 그냥 적용된다. (아직 보이지는 않겠지만 스크롤을 하면 정상적으로 이미지가 적용된 셀이 보이게 된다.)
   - 물론 '취소한다고 해서 해당 작업이 진짜 취소되는 것인지'는 살펴보아야 한다. `URLSession` 작업들의 경우 `cancel()`한다고 해서 네트워크 작업이 진짜 취소되지는 않는다. 그냥 네트워크 요청 결과가 온 것을 무시(?)할 뿐이다.

2. 다른 프로퍼티를 이용한 비교 

   - 이미지가 도착했을 때 이미지를 요청했던 셀이 그대로 화면에 남아있는지를 비교하는 방식에는 여러가지가 있을 것이다.

   1. 부여될 IndexPath 자체를 Cell이 재사용 될 때마다 내부에 넣어둔다던가
   2. 재사용 될 때, 요청에 대한 이미지 URL을 Cell이 가지도록 하고 이미지 도착시 이 URL이 그대로 남아있는지 비교
   3. tag나 이외의 프로퍼티들 이용 등 (애플 공식문서쪽에서는 별도의 identifier를 쓰고 있다.)

&nbsp;

캐시가 이 문제를 해결하는 것은 아니다.

캐시를 쓴다고 해도 어느정도의 latency는 발생한다.(네트워크만큼은 아니지만) 캐시를 쓴다고 하더라도 셀 재사용 되기 이전의 요청이 재사용 된 이후의 요청보다 늦게 도착하는 경우 이미지 덮힘이 발생할 수 있다. (가능성은 극히 낮겠지만 재사용 되기 이전에 요청된 데이터가 어느정도 크다면 충분히 발생할 수 있는 문제라고 본다.)

즉, 캐시에서도 lazy loading 문제는 발생할 수 있는 것이다.

`URLSession` **cachePolicy**를 이용해서 캐시를 다룬다면 `task.cancel()`을 했을 때 캐시에 대한 요청도 취소되지 않을까? (해당 request에 대한 데이터가 캐시에 존재해서 URLSession이 네트워크가 아닌 캐시를 통해 데이터를 가져오려고 하는 경우)

&nbsp;

### 캐시를 이용하여 해결할 수 있다?!

![야곰](https://user-images.githubusercontent.com/39452092/131179244-b8287746-04c6-4a01-9604-bb9eb6ff29e8.png)

- 야곰이 하신 말씀을 보고 수박이 해주신 말을 들어보니 **캐시를 이용하여 이미지 중복 문제를 해결할 수도 있을 것 같다.**
  - (이미지가 미리 캐싱되어 있는 경우) 네트워킹을 하지 않고 이미지를 **동기적**으로 가져와서 셀에 설정할 수 있으므로 이미지 중복 문제가 생기지 않게 될 것 같다.
  - *하지만 캐시도 결국 네트워킹을 통한 작업 결과가 일단 들어와야 캐싱할 수 있는 것이니, 근본적인 해결법이 되지는 못하는 것 아닌가?*
  - 내가 위에서 "*캐시에서도 lazy loading 문제는 발생할 수 있는 것이다.*"라고 한 것은 캐시를 비동기적으로 이용하려 했을 때 발생할 수 있는 문제인 것 같다. (물론 비동기적으로 쓸 것 같지는 않다.)

&nbsp;

### 수박의 추가의견

**캐시를 이용하여 다음에 보여질 데이터들을 미리 받아놓는다면 해결할 수 있을것으로 본다.**

이를테면 스크롤이 반쯤 내려왔을 때 다음에 보여질 이미지들을 미리 가져와서 캐시에 넣어놓으면 셀이 보여질 때 지연로딩은 발생하지 않을 것이다.

- 캐시는 자주 사용되는 데이터를 지니고 있는 목적으로만 쓴다고 생각하기 쉽지만, **앞으로 쓰일 것들을 미리 저장해놓는 용도로도 쓰인다.**
- 다만 '어떤 것이 앞으로 쓰일 것인가'를 예측해야한다는 문제는 존재한다.

&nbsp;

### 같이 이야기를 나누었던 Tacocat 🌮 🐈의 Notion

- [https://organized-join-ee3.notion.site/Lazy-Loding-Problem-in-CollectionView-d9a3b5b5f4394eec9c969d0fc49f62aa](https://www.notion.so/Lazy-Loding-Problem-in-CollectionView-d9a3b5b5f4394eec9c969d0fc49f62aa)

&nbsp;

## 정리

### indexPath(for:)를 호출했는데 nil이 나올 수 있는 경우

1. Cell이 Reuse Queue에 들어갔음
2. Cell이 Reuse Queue에서 나왔으나 아직 뷰에 그려지지 않은 상태

&nbsp;

### 네트워크를 통해 이미지를 들고 왔는데 이미지가 설정이 안될 수 있는 경우

→ indexPath를 이용한 비교구문 사용 시 `indexPath == ~view.indexPath(for: cell)`

1. 이미지를 가지고 왔는데 이미지를 요청했던 셀이 이미 재사용되어서 다른 IndexPath를 가지는 경우
2. 이미지를 가지고 왔는데 이미지를 요청했던 셀이 Reuse Queue에 들어가버린 경우
3. 이미지를 가지고 왔는데 이미지를 요청했던 셀이 아직 화면에 그려지지 않은 경우

&nbsp;

### 왜 CollectionView는 미리 로드됐던 걸까?

찾아내신 수박에게 무한 감사... 

- `UICollectionView`는 기본적으로 `isPrefetchingEnabled`값이 `true`여서 그랬다. 이때문에 화면에 보이지도 않는데, 셀에 대한 요구가 생겼던 것이다.
  - 실제로 해당 값을 `false`로 두고 테스트해봤는데 화면에 보일때 딱 `cellForItemAt:`이 호출되었다.
  - [https://developer.apple.com/documentation/uikit/uicollectionview/1771771-isprefetchingenabled](https://developer.apple.com/documentation/uikit/uicollectionview/1771771-isprefetchingenabled)
- `UITableView`에는 없을까?
  - ~~있는데 iOS 15이상부터 적용되는 베타버전이다. (기본값은 `true`)~~
  - [https://developer.apple.com/documentation/uikit/uitableview/3801922-isprefetchingenabled](https://developer.apple.com/documentation/uikit/uitableview/3801922-isprefetchingenabled)

</div>

</details>

&nbsp;

### task.cancel과 prepareForReuse()

**우리가 lazy loading문제를 해결한 방법** 

- 우리는 `collectionView(_:cellForRowAt:)`에서 이미지에 대한 요청이 발생할 때 이 요청으로 인해 생성된 `URLSessionDataTask`를 `Cell`에 주입해주었다.
- 이후 `Cell`의 `prepareForReuse()`에서는 재사용 되기 전 dataTask의 작업을 `cancel()`하고 `nil`을 할당받도록 하였다.
- 이를 통해 셀이 재사용되기 전 완료되지 않은 이미지 작업이 있다면 해당 네트워크 작업의 결과가 적용되지 않도록 만들었다. (`cancel()`은 실질적으로 네트워크 작업을 취소하는 것은 아니고 그 결과를 무시하게 하는 메서드)


<details>
<summary> <b> TableView와 CollectionView의 차이점 </b> </summary>
<div markdown="1">
    
## 테이블뷰와 컬렉션뷰의 공통점과 차이점

### 공통점

1. 셀로 각각의 요소를 표현한다. 
2. 셀을 재사용할 수 있다.
3. 크기와 높이를 지정하는 방법이 거의 동일하다.
4. 두 뷰 모두 UIScrollView를 상속받았다. 
5. DataSource와 Delegate 설정이 가능하다. (데이터 처리와 UI 처리가 분리되어 있다.)
6. 무한한 양의 정보를 제공할 수 있다.
7. 하나의 section에 Header, cell, Footer가 존재한다.

&nbsp;

### 차이점

1. TableView는 복잡한 레이아웃을 표현하기에 힘들다.
2. CollectionView는 데이터가 화면에 표시되는 방식(레이아웃 뿐만아니라 거의 모든 측면)을 커스텀할 수 있다. 다차원 데이터를 표시하기 위한 모델
3. CollectionView는 가로로 스크롤 할 수 있다. UICollectionViewDelegateFlowLayout를 이용해 왼쪽→ 오른쪽, 위→아래의 flow를 제공한다.
4. CollectionView는 layout이라는 object 설정이 필요하다. 
5. 메서드에서 tableView에서는 row라고 하는 것을 CollectionView에서는 item 이라고 표현한다. → 이유
6. **UICollectionView는 여러 다양한 레이아웃에 기반한 커스텀 애니메이션을 지원한다. (UITableView에서는 불가능한 것들을)**
7. 테이블뷰는 기본 셀을 사용할 수 있으나 콜렉션 뷰는 기본 셀이 없음

&nbsp;

## 참고 자료

- [https://ios-development.tistory.com/503](https://ios-development.tistory.com/503)
- [http://labs.brandi.co.kr/2018/05/02/kimjh.html](http://labs.brandi.co.kr/2018/05/02/kimjh.html)
- [https://jayb-log.tistory.com/229?category=930953](https://jayb-log.tistory.com/229?category=930953)
- 결국 두 View의 차이는 하나는 행으로 나열하여 자료를 보여주는 것이고, 다른 하나는 2차원으로 놓여진 무작위의(arbitrary) 아이템이라는 것입니다.
- [https://medium.com/@nitpaxy/swift-3-uicollectionview-vs-uitableview-9909bbc0ec66](https://medium.com/@nitpaxy/swift-3-uicollectionview-vs-uitableview-9909bbc0ec66)
- [https://purple-log.tistory.com/19](https://purple-log.tistory.com/19)

&nbsp;

## 짤막한 정리

- 다양한 layout을 통해 여러 기기환경에서 다양한 화면을 구현할 수 있다.
- 다만 일일히 layout을 지정해줘야 하므로 복잡할 수 있다.
- 스크롤 방향의 경우 한번에 한쪽 방향으로만 설정 가능하다.
  - 때문에 페이스북에서 특정 셀이 좌우로 스크롤 되는 것은 →  TableView에 좌우 스크롤 가능한 커스텀 셀을 썼을 가능성이 있다.

</div>

</details>


<details>


<summary> <b>CollectionView 참고 링크 </b> </summary>

<div markdown="1">


- [UICollectionView](https://developer.apple.com/documentation/uikit/uicollectionview)
  - [Modern cell configuration](https://developer.apple.com/videos/play/wwdc2020/10027/)
  - [Lists in UICollectionView](https://developer.apple.com/videos/play/wwdc2020/10026)
  - [Implementing Modern Collection Views](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views)
- [UIAlertController](https://developer.apple.com/documentation/uikit/uialertcontroller)

</div>

</details>


&nbsp;


## 싱글톤
### struct로 싱글턴을 구현할수는 없을까?

[https://www.notion.so/yagomacademy/README-0ff283043553498a805a2fedc0128d51#0714ba619deb42f8bb173de05b8a0b11](https://www.notion.so/README-0ff283043553498a805a2fedc0128d51)

- singleton은 꼭 class로만 구성해야 하는 줄 알았는데 struct로 해도 가능 할 것 같기는 하다. 다만 다른 변수에 할당하려 할때 차이는 생기겠지.
- struct의 경우 싱글톤처럼 만들어도 싱글톤 인스턴스(변수)를 다른 변수에 할당 하려 하면 인스턴스 자체가 복사됨. 때문에 싱글톤이 아니게됨. → 휴먼에러 발생할수도.
  - CoW(Copy on Write)때문에 실질적으로는 내부 값을 변경하려 할 때 복사본이 생기므로, 인스턴스 내부(프로퍼티)값 수정하려 할 때 인스턴스 복사가 일어나면서 싱글톤이 아니게 되겠지.

&nbsp;

### 싱글턴과 타입메소드를 구현하고자 할때 고려해야할 점

굳이 싱글톤 '인스턴스'를 써야할까? 그냥 타입 자체에 타입메소드들만 쓰면 되는거 아닌가?(init은 private로 막아두든지 아니면 case-less enum을 쓰던지)

- 일단 그러면 '객체에게 메시지를 보내고 책임과 역할을 분배'하는 '**객체지향프로그래밍**'이라는 관점과는 맞지 않는 것 같다. 절차지향언어의 느낌이 난다. 어쨌든 인스턴스라는건 없을테니까.
- 그리고 하나 이상의 타입 메소드가 쓰는 공통 프로퍼티가 있다면 그건 똑같이 타입 프로퍼티가 되어야 할 것이다. 이게 과연 메모리 관점에서 유익한 것일까? 궁금해진다.

&nbsp;

> *vivi의 답변 정리*
>
> sigleton은 패턴이고 타입 메소드는 구현방식이다. 딱히 정해진 정답은 없음
>
> 가능하면 shared(싱글톤)는 쓰려고 하지 않는다. FP에서는 객체의 불변성이 보장되어야 하는데 싱글톤에서는 객체의 불변성(데이터의 무결성)이 보장되지 않는다. 
>
> 앱 내내 명확히 하나만 존재해야 하는 데이터가 있으면 그건 싱글톤으로 쓰기는 함.
> (로그인한 유저 데이터 등등)
>
> 쓸 때마다 인스턴스를 만들어서 쓰도록 구성해도 괜찮다. (프로퍼티 없이 메소드만 있는 경우 등)
> → 내부 프로퍼티가 변경될 염려가 없고 인스턴스가 자주 사용되지 않는거라면! 
> ex) `SomeAPIObject().retrieveData()` 처럼 인스턴스 생성하자 마자 바로 사용
>
> `lazy` 프로퍼티는 남발하지 말도록 하자. 
>
> HTTP에 관련된 것을 enum같은 타입으로 묶는 것도 좋다. enum ~~~APIConstant 로 만들고 내부에 baseURL을 타입저장프로퍼티로 둔뒤 여러 정보들에 대한 것들은 연산프로퍼티로 돌려주도록...(각각의 API메소드들은 case로 두고 이에 대한 문자열 값은 연산프로퍼티로 돌려주는 방식)

&nbsp;

## Data extension
### Data extension으로 원본값을 수정하지 않고 Data에 String을 append 할수 있는 method추가

```swift
extension Data {
    func appending(_ newElement: String) -> Data {
        var copyData = self
        newElement.data(using: .utf8).flatMap { copyData.append($0) }
        return copyData
    }
}
```

- 원본값을 건들이지 않고 string을 Data타입으로 append시킬수 있게 구현

- 여기에서 `flatMap`은 우리가 알고 있던 `flatMap`과는 약간 달랐다.

  - [https://developer.apple.com/documentation/swift/sequence/2905332-flatmap](https://developer.apple.com/documentation/swift/sequence/2905332-flatmap)
  - 기존 flatMap은 sequence에 클로저를 적용시킨 뒤 flatten된 배열을 만드는데 사용되었었다. (이를 테면 배열 안에 배열들이 있는 경우 이를 전부 1차원 배열로 만들었었다.) 원본은 건드리지 않았다.

- 이곳에서의 `flatMap`은 `Optional`에 대한 `flatMap`이다.

  - [https://developer.apple.com/documentation/swift/optional/1540500-flatmap](https://developer.apple.com/documentation/swift/optional/1540500-flatmap)
  - 옵셔널 인스턴스가 nil이 아니면 주어진 클로져를 평가(실행)한다.
  - 클로저에는 언래핑된 값이 매개변수로 넘어가게 된다.
  - 마치 옵셔널 바인딩같았다.

  &nbsp;

**사실 우리는 Data에 String을 추가하는 코드를 아래와 같이 했었다.**

```swift
extension Data {
    mutating func append(_ newElement: String) {
        newElement.data(using: .utf8).flatMap { append($0) }
    }
}
```

<img width=600 src="https://user-images.githubusercontent.com/39452092/131143890-27c7d4ad-5549-4828-b48b-fb09f3fa1ccd.png" />

- 기존 Data를 건드리는 것 자체가 어떤 부작용을 만들지 알 수 없기에 위와같은 말씀을 해주신 것 같았다.
- 이 리뷰에 따라 코드를 수정하면서 메소드명에 대해서도 다시 생각해보았고 Swift Naming Guide에 따라 다시 작명하였다.
- [https://swift.org/documentation/api-design-guidelines/](https://swift.org/documentation/api-design-guidelines/)




&nbsp;

## P.O.P
### P.O.P에 대하여

- 아직도 Obj-C protocol에 대한 Swift Extension - Default Implementation은 안된다.

&nbsp;

### Protocol이 등장한 배경

- **class의 단점**
  - Reference Counting 오버헤드
  - 참조타입으로써의 단점을 가짐(이를테면 원치 않게 원본의 값이 바뀔 수 있다던가)
- **상속의 한계**
  - 다중 상속이 불가능하고 단일 상속만 가능
  - 여러 상위 클래스의 특징을 가져야 하는 경우 이를 해결하기 어려웠음
  - 다중상속이 가능하다고 하더라도 불필요한 기능까지 상속받을 가능성이 존재하게 됨

&nbsp;

### 때문에 Value Type을 이용하기 시작했다. → Struct

- 객체라는 표현을 쓰지 않는다. 구조체도 클래스도 인스턴스라는 용어로 통합
  - 객체라는 표현은 클래스에게만 유효하기 때문이다.
- 상속의 단점을 가져오지 않기 위해 구조체에는 상속이 불가능하게 함
- 블럭조립하듯이 구조체에 기능을 추가할 수 있도록 하자 → 프로토콜
- 상속을 통한 기능 추가가 아닌 프로토콜을 통한 기능 추가
  - 프로토콜을 extension하여 기본 기능을 구현해둠으로써 채택하는 곳에서 바로 쓸 수도 있음
  - 기본 기능(Default Implementation)은 채택하는 곳에서 덮어씌울 수도 있다.
  - extension 시 where절을 써서 특정 조건에 대한 확장이 가능하다.
  - extension을 같이 이용하여 기존 타입에 프로토콜을 채택시킬 수도 있다.
- **클래스는 개체에 대한 추상화, 프로토콜은 타입에 대한 추상화**

&nbsp;

### 프로토콜은 어떤 역할을 가지고 있고 어떤 기능을 수행할 수 있음을 나타낸다.

- 우리가 썼던 기본 기능 제공(Default Implementation) Protocol들
  - `Equatable`
  - `Comparable`
  - `Encodable`
  - `Decodable`

&nbsp;

### P.O.P의 중요한 장점 - 인터페이스 분리원칙에 따른 기능의 분리와 선택적 구현이 가능하게 됨

### P.O.P의 단점

- 저장 프로퍼티를 추가할 수 없다.
  - 프로토콜 자체에서 특정 프로퍼티를 요구할 수는 있지만 extension으로 이 저장 프로퍼티에 대한 기본 구현을 제공할 수는 없다. (연산프로퍼티로만 가능)

&nbsp;

### 채택한 두 프로토콜간 메소드명이나 프로퍼티명이 충돌하는 경우 어떻게 되나요?

```swift
protocol Thinkable {
    func think()
}

extension Thinkable {
    func think() {
            print("생각좀 하자")
    }
}

protocol Camper {
    func think()
}

extension Camper {
    func think() {
            print("생각하는 캠퍼")
    }
}

extension Thinkable where Self: Camper {
    func think() {
        print("나는 캠퍼이다.")
        print("생각을 하는 캠퍼인데..")
        print("무슨 생각을 나는 하는걸까")
    }
}

struct Person: Thinkable, Camper {}

Person().think() //extension Thinkable where Self: Camper 의 기본 구현이 실행됨
```

- 기본적으로 두 프로토콜이 다 기본 구현을 제공하는 경우 충돌이 나면 두 프로토콜 다 준수하고 있지 않는다고 컴파일 에러가 뜸(위의 `extension Thinkable where Self: Camper` 같이 특정한 구현이 제공되지 않는이상 **ambiguous**하다고 컴파일 에러!)
  - 충돌하는 부분은 구현이 안된것으로 파악되는 듯 → 채택하는 곳에서 별도의 구현이 필요함
  - 두 프로토콜 다 기본 구현을 제공하지 않는다면 → 그냥 채택한 곳에서 구현해주면 된다.
  - 둘 중 하나만 기본 구현이 제공된다면? → 기본구현이 제공되는 메소드의 내용이 실행된다.

&nbsp;


## Capture in Struct

### struct 에서 closure로 self를 캡쳐했을때 값타입으로 복사되어 캡쳐됨(캡처 리스트를 쓰든 안쓰든)

```swift
struct TestStruct {
    var testNumber = 0
    
    lazy var testLazyClosure: () -> Void = { [self] in
        print(testNumber)
    }
    
    func testFunc() -> (()-> Void) {
        return {
            print(self.testNumber)
        }
    }
    
}

var test = TestStruct()
let testClosure = test.testFunc()
testClosure() //0 출력
test.testNumber = 10
testClosure() //0 출력
```

- 테스트 결과 숫자 출력은 두번 다 `0`이 나왔다. 즉, struct의 클로저에서 self를 캡처하는 경우 self를 복사해서 가지고 나간다!
- 클로저에서 `self`를 캡처하고자 하는 경우 값을 복사하는 것이 확인되었으므로 **retain cycle**과 같은 reference cycle은 생기지 않을 것으로 보인다.
  - 위의 `lazy var testLazyClosure` 프로퍼티의 경우 나중에 이 값에 접근을 하게 되어 프로퍼티가 초기화 된다면, 내부에서 캡처하는 self는 원본 `self`인스턴스가 아닌 복사본을 가지고 있게 될 것
  - **testLazyClosure**에서 `[self]` capture list를 쓴 이유
    `self`를 capture list로 명시하지 않고 `self.testNumber`로 쓰는 경우
    mutable한 `self`를 캡쳐한다고 컴파일 에러가 떴었음
    → 내부에서 값을 바꾸려 한 것도 아닌데.. 왜 이런 에러가 떴는지는 잘 모르겠다. 
    때문에 immutable한 `self`를 캡처하도록 capture list 사용

&nbsp;

```swift
struct Test {
    var testValue = 0
    
    mutating func modifyTestValue() {
        testValue = 10
    }
}

Test().modifyTestValue() //컴파일 에러
```

- struct 인스턴스 바로 생성해서 mutating func 호출 불가

  → 해당 인스턴스는 let과 같은 형태로 만들어지는 듯

&nbsp;

## Outlet
### Outlet을 weak로 해도 되는 이유

[https://cocoacasts.com/should-outlets-be-weak-or-strong](https://cocoacasts.com/should-outlets-be-weak-or-strong)

- 모든 `ViewController`들은 `view`라는 프로퍼티를 가지는데, 이 프로퍼티는 화면 위에 올라간 모든 뷰 요소를 알고 있다. (정확히 말하자면 자식 뷰들을 알고 그 뷰들은 다시 자식 뷰를 알고 있는 형태)
- 따라서 화면에 있는 뷰 요소들은 기본적으로 strong reference되어있다.
- 덕분에 우리는 ViewController에서 뷰 요소에 대한 참조를 `weak`로 해도 된다.
- 다만 잠시 뷰에서 떼어냈다가 다시 붙여야 하는 요소들의 경우 `strong`으로 가지고 있어야 유실되지 않을 것이다.

&nbsp;
## Custom View
### xib파일을 별도로 분리하고, register하여 사용해보기

- customCell에 대한 내용을 xib파일로 별도 적용하였고, 해당 xib파일을 `OpenMarkerViewController` 내 `CollectionView`에 `register` 하였다.
- storyBoard에 직접 Cell UI를 생성한것에 비해 xib파일을 다른 곳에서도 쓸 수 있으므로  재사용에 용이하다.

```swift
openMarketCollectionView.register(
                                UINib(nibName: OpenMarketItemCell.fileName, bundle: nil),
                                forCellWithReuseIdentifier: OpenMarketItemCell.identifier
                                )
```

- `identifier`에 대한 것도 Cell 내부에 위치시킴으로써 오기입을 막을 수 있게 되었다.

&nbsp;

### nib

[https://developer.apple.com/documentation/uikit/uinib](https://developer.apple.com/documentation/uikit/uinib)

- `UINib` - Interface Builder nib 파일을 가진 Object
  - UINib object는 nib 파일의 내용을 메모리에 캐시하고, 압축해제 및 인스턴스화 할 준비가 되어있는 것이다. 앱이 nib 파일의 내용을 인스턴스화해야할 때가 되면 먼저 nib파일에서 데이터를 로드하지 않아도 되므로 성능이 향상된다. `UINib` object는 앱이 low-memory 상태인 경우 자동으로 이 캐시된 nib 데이터를 메모리에서 해제한다. 그리고 다음에 앱이 nib을 인스턴스화 할 때 이 데이터를 다시 로드한다.
  - 앱에서 동일한 nib 데이터를 반복적으로 인스턴스화 해야하는 경우 UINib object를 써야 한다. 테이블 뷰가 테이블 뷰 셀을 인스턴스화하기 위해 nib 파일을 쓴다면 nib을 `UINib` object로 캐싱해놓아야 한다. (성능 향상을 위해)
  - nib파일의 내용을 사용하여 `UINib` object를 생성할 때 object는 객체 그래프를 참조된 nib 파일에 로드한다. 다만 아직 압축을 해제한 상태는 아니다. 모든 nib 데이터를 압축해제하고 nib을 인스턴스화 하기 위해 앱은 `instantiate(withOwner:option:)` 메서드를 호출한다.

&nbsp;

**참고**

- [https://ios-development.tistory.com/184](https://ios-development.tistory.com/184)
- [https://zeddios.tistory.com/298](https://zeddios.tistory.com/298)

&nbsp;

**사용법**

- [https://medium.com/a-day-of-a-programmer/xib를-사용한-uiview-custom-제대로-이해하기-348a9b789496](https://medium.com/a-day-of-a-programmer/xib%EB%A5%BC-%EC%82%AC%EC%9A%A9%ED%95%9C-uiview-custom-%EC%A0%9C%EB%8C%80%EB%A1%9C-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0-348a9b789496)

&nbsp;

### awakeFromNib()

Interface Builder 아카이브 또는 nib 파일에서 로드된 이후 서비스를 위해 receiver를 준비시키는 곳

[https://developer.apple.com/documentation/objectivec/nsobject/1402907-awakefromnib](https://developer.apple.com/documentation/objectivec/nsobject/1402907-awakefromnib)

- nib 로딩 기반구조는 nib 아카이브에서 재생성된 각 object에 `awakFromNib` 메시지를 전송한다. 다만 아카이브의 모든 object가 로드되고 초기화 된 이후에만 전송된다.
- object가 awakeFromNib 메시지를 받았을 때에는 이미 모든 outlet과 action 연결이 구축되었음이 보장되어있다.

&nbsp;
## CollectionView
### collectionView를 다시 그리도록 할 때 `reloadData()`가 아닌 `insertItems(at:)` 이용

`reloadData()`의 경우 collecionView를 완전히 처음부터 구성하기에 비용이 많이 발생합니다. 그래서  항상 처음부터 그리지 않고, 증가된 부분만 collectionView를 다시 그리도록 설정함으로써 리소스의 낭비를 줄일수 있게 구현하였습니다.

```swift
private func reloadCollectionView(from startPoint: Int, to endPoint: Int) {
        let indexPaths = (startPoint...endPoint).map { IndexPath(item: $0, section: 0) }
        openMarketCollectionView.insertItems(at: indexPaths)
    }
```

- 이 때 인자로는 추가된 아이템들에 대한 개별 IndexPath를 배열로 만들어서 넣어주었다.

&nbsp;

### CollectionViewDelegateFlowLayout

간단한 grid를 그리는 `collectionView`에 Cell을 배치할 경우 `UICollectionViewFlowLayout`을 적용하거나, 커스터 마이징이 필요한경우 `UICollectionVeiwLayout`의 자식클래스 (`ColumnFlowLayout`, `MosaicLayout`)등을 적용하면 됩니다.

이번 프로젝트에서는 간단한 grid 방식을 적용하면되서 UICollectionViewFlowLayout 으로 적용하였습니다.

- UIEdgeInset

  뷰와 삽입되는 값의 거리를 나타내며 해당 값은 기본적으로 0으로 적용되어 있습니다. view와 cell간의 간격을 두기 위해 값을 수정하였습니다.

참고 :

- [https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/layouts/customizing_collection_view_layouts](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/layouts/customizing_collection_view_layouts)
- [https://developer.apple.com/documentation/uikit/uiedgeinsets](https://developer.apple.com/documentation/uikit/uiedgeinsets)

&nbsp;

**신기했던 점**

- TableView와는 다르게 CollectionView는 레이아웃등을 설정할 수 있었는데 설정하는 방식에 크게 2가지가 있었다는 것.
- 직접 `CollectionViewFlowLayout`을 만들어서 `collectionview` 내부 프로퍼티에 지정할 수도 있지만 `DelegateFlowLayout`을 쓸 수도 있었다.
- 이외에도 `UIEdgeInset`이나 `spacing` 값등을 설정할 때 모든 섹션/아이템에 대해 값이 언제나 동일하다면 초기에 한번에 설정할 수 있고, 그게 아니라면 `Delegate`를 이용할 수 있다는 것

&nbsp;

### Cell 내부의 레이블과 이미지에 대한 레이아웃 설정

해당 프로젝트에서 기기에 맞는 Cell 내부의 컨텐츠 레이아웃(`UILabel`)을 적용하기 위해 아래 프로퍼티들을 적용하였습니다.

- `adjustsFontSizeToFitWidth` : label의 사각형 bound에 맞추기 위해 폰트 크기를 줄여야하는지에 대한 여부를 나타내는 Bool
- `minimumScaleFactor` : 라벨 텍스트에 지원되는 최소 축적 비율
- `numberOfLines` :  라벨 텍스트를 몇줄로 보여줄것인지를 정합니다.
- `lineBreakMode` : 줄 바꿈에 대한 설정(라벨의 텍스트를 래핑하고 자르는 기술)
  - `byClipping`: 줄이 텍스트 컨테이너 가장자리를 넘을만큼 확장되지 않도록 함

이렇게 함으로써 레이블 내용의 길이가 긴 경우 레이블 텍스트 크기가 줄어들게 되었다. 

&nbsp;

참고: 

- [https://developer.apple.com/documentation/uikit/uilabel/1620546-adjustsfontsizetofitwidth](https://developer.apple.com/documentation/uikit/uilabel/1620546-adjustsfontsizetofitwidth)
- [https://developer.apple.com/documentation/uikit/uilabel/1620544-minimumscalefactor](https://developer.apple.com/documentation/uikit/uilabel/1620544-minimumscalefactor)
- [https://developer.apple.com/documentation/uikit/uilabel/1620539-numberoflines](https://developer.apple.com/documentation/uikit/uilabel/1620539-numberoflines)
- [https://developer.apple.com/documentation/uikit/uilabel/1620525-linebreakmode](https://developer.apple.com/documentation/uikit/uilabel/1620525-linebreakmode)
- [https://developer.apple.com/documentation/uikit/nslinebreakmode/byclipping](https://developer.apple.com/documentation/uikit/nslinebreakmode/byclipping)

&nbsp;

- 위의 모든 설정들은 셀의 `awakeFromNib()`에서 해주었다. (nib에서 불려와 보여질 때 한번만 수행되도록)
- 이렇게 했음에도 작은 기기에서는 레이블이 잘리는 문제가 발생하였는데 아래의 방법으로 해결하였다.
  - `ImageView`의 `Content Compression Resistance Priority`를 500으로 낮춤
  - `Label`들의 `Content Compression Resistance Priority`를 1000으로 높임
- 결과적으로 셀의 공간이 부족하게 되면 이미지가 줄어들게 된다. (레이블은 언제나 정상적으로 보이게 됨)



### Cell에 외곽선 그리기

해당 프로젝트에서 각각 Cell 외부에 외각선을 그리기 위해 CustomCell에 아래 프로퍼티를 적용하였습니다.

- `layer.borderColor` : layer 테두리의 색상설정
- `layer.borderWidth` : layer의 테두리 너비설정
- `layer.cornerRadius` : layer 배경에 둥근 모서리를 적용

참고 : 

- [https://developer.apple.com/documentation/quartzcore/calayer/1410903-bordercolor](https://developer.apple.com/documentation/quartzcore/calayer/1410903-bordercolor)
- [https://developer.apple.com/documentation/quartzcore/calayer/1410917-borderwidth](https://developer.apple.com/documentation/quartzcore/calayer/1410917-borderwidth)
- [https://developer.apple.com/documentation/quartzcore/calayer/1410818-cornerradius](https://developer.apple.com/documentation/quartzcore/calayer/1410818-cornerradius)

&nbsp;

### UICollectionViewDataSourcePrefetching과 페이지네이션

[https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching](https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching)

- CollectionView에 대해 데이터 요구사항 사전 경고를 제공하여 비동기 데이터 로딩 작업의 트리거를 할 수 있도록 해주는 프로토콜

[https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching/1771767-collectionview](https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching/1771767-collectionview)

- 우리는 이 프로토콜의 요구사항 중 `collectionView(_:prefetchItemsAt:)`을 사용하였다.
  - 제공되는 Index path에 해당하는 셀을 위한 데이터 준비를 시작하도록 prefetch data source에게 알려주는 메서드
  - collection view는 사용자가 스크롤할 때 이 메서드를 호출하여 가까운 미래에 표시될 셀에 대한 index path를 제공한다.
  - 즉 `prefetchItemsAt:`에 들어오는 index path들은 '데이터를 미리 가져올 아이템에 대한 위치가 지정된 index path'들이다.

```swift
//MARK:- Adopt and Conform to DataSourcePrefetching
extension ProductListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("호출됨 \(indexPaths)")
        for indexPath in indexPaths {
            if indexPath.item  == productList.count - 1{
                print("데이터를 로드합니다.")
                loadNextProductList(on: nextPageNumToBring)
            }
        }
    }
}
```

우리는 위와 같이 작성하였다. - print문은 이해를 돕기 위한 구문

<img width=850 src="https://user-images.githubusercontent.com/39452092/131168192-df347f5e-c743-49e8-8d9a-fc0ec15ea45b.gif" />

- 테스트 해보니 `prefetch`가 먼저 호출되고 이후에 `cellForItemAt:`이 호출되는 형식이었다.

&nbsp;

<img width=850 src="https://user-images.githubusercontent.com/39452092/131168858-fdae55d8-fe51-4691-afe3-d152a649ec1a.gif" />

- collectionView의 `isPrefetchingEnabled`를 `false`로 두니 위와 같은 결과가 나왔다.
- 아예 `prefetch`는 실행도 안되고 셀도 화면에 보일 때 `cellForItemAt:`이 호출되는 형태
- 다만 우리는 다음 데이터를 가져오는 코드가 `prefetch`쪽에 있기 때문에 다음 데이터를 가져오지 못하게 된다.

&nbsp;

### 페이지네이션에 ScrollView의 ContentOffset이용하기

[https://hanulyun.medium.com/swift-uitableview-에서-pagination을-하는-3가지-방법-ba4a024b58e5](https://hanulyun.medium.com/swift-uitableview-%EC%97%90%EC%84%9C-pagination%EC%9D%84-%ED%95%98%EB%8A%94-3%EA%B0%80%EC%A7%80-%EB%B0%A9%EB%B2%95-ba4a024b58e5)

```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let height: CGFloat = scrollView.frame.size.height
    let contentYOffset: CGFloat = scrollView.contentOffset.y
    let scrollViewHeight: CGFloat = scrollView.contentSize.height
    let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
    
    if distanceFromBottom < height {
        self.addData()
    }
}
```

- `contentYOffset`은 사용자가 보고 있는 화면의 스크롤 뷰 y값이다.(상단쪽) 사용자가 밑의 화면을 보려 할 수록 이 값은 높아진다.
- `height`는 스크롤뷰에 주어진 프레임 높이로써 변하지 않는 값이다. super view의 입장에서 스크롤뷰가 가지는 고정된 높이
- `scrollViewHeight`는 컨텐츠가 많아짐에 따라 늘어날 수 있는 컨텐츠 공간 높이다. 화면에는 다 담기지 않지만 엄청 큰 값이 보통 깔리게 된다.
- `distanceFromBottom`은 이 컨텐츠 공간 높이에서 사용자가 보고 있는 화면의 높이 값만큼을 뺀다. 당연히 사용자가 밑의 화면을 보면 볼 수록 이 값은 줄어들게 된다. (Bottom과의 차이가 줄어든다.)
- 사용자가 화면을 쭉 내리다보면  `distanceFromBottom`이 점점 줄어들다가 frame의 높이와 같아지는 순간이 생기게 된다. (frame 높이와 distance가 같아진다는 것은 사용자가 맨 아래에 도달했다는 뜻이다. `scrollView.contentSize.height - scrollView.contentOffset.y == scrollView.frame.size.height`) 그 값을 초과하면 다음 데이터를 가져온다.

위와 동일한 방식으로 동작하지만 코드는 여러 형태가 있을 수 있다.

&nbsp;
## Formatting
### ISO 4217에 따른 NumberFormatting

- 국가별 통화 코드 목록이다.

<details>


<summary> <b> 말꼬의 TIL에서 발췌 </b> </summary>

<div markdown="1">


→ ISO 4217 : 제정된 통화의 이름을 정의하기 위한 3문자의 부호(통화코드)를 기술하는 국제표준화 기구(ISO)가 정의한 국제 기준

[ISO 4217 - Currency codes](https://www.iso.org/iso-4217-currency-codes.html)

example (위키백과)

코드 : KRW

숫자 : 410 

Number of digits after the decimal separator. : 0

통화 : (대한민국) 원 ₩	

이 통화를 사용하는 지역들 : 대한민국 

→ NumberFormmater 를 이용해서 통화를 표현 할 수 있음

[Formatting numbers in Swift | Swift by Sundell](https://www.swiftbysundell.com/articles/formatting-numbers-in-swift/)

```swift
let krPrice = 1290000
let usPrice = 1690
        
let formatter = NumberFormatter()
formatter.numberStyle = .currency
        
        
formatter.currencyCode = "KRW"
        
let krNumber = NSNumber(value: krPrice)
print(formatter.string(from: krNumber)!)
        
formatter.currencyCode = "USD"
        
let usNumber = NSNumber(value: usPrice)
print(formatter.string(from: usNumber)!)
```

![돈](https://user-images.githubusercontent.com/39452092/131179464-eec7960d-fbde-469a-8a20-14f7c5fb94e2.png)

&nbsp;

### 참고링크

- numberformmater.currencyCode (Instance Property)

[Apple Developer Documentation](https://developer.apple.com/documentation/foundation/numberformatter/1410463-currencycode)

- NumberFormatter.Style (Enumeration)

[Apple Developer Documentation](https://developer.apple.com/documentation/foundation/numberformatter/1410463-currencycode)

- NumberFormatter.Style.currencyISOCode (Enumeration Case)

[Apple Developer Documentation](https://developer.apple.com/documentation/foundation/numberformatter/style/currencyisocode)

- Locale (Structure)

[Apple Developer Documentation](https://developer.apple.com/documentation/foundation/locale)

- Language and Locale IDs (Arcive)

[Language and Locale IDs](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html#//apple_ref/doc/uid/10000171i-CH15-SW9)

</div>

</details>

- 현재 프로젝트에서는 다양한 통화가 나오도록 구성되었지만, 나중에는 나라에 맞는 통화코드를 나오게 하는등 통일화가 필요할것 같다.

참고문서 :

- [https://www.iso.org/iso-4217-currency-codes.html](https://www.iso.org/iso-4217-currency-codes.html)

&nbsp;

### NSAttributedString

- `NSAttributedString`이란 텍스트에 관련된 속성(비주얼 스타일이나,하이퍼링크 접근성 데이터)이 있는 문자열 이다.
- 우리는 프로젝트에서 `Product.discountedPrice`가 있을 경우 `Label`에 strikethroughStyle 을 적용을 하기 위해서 사용하였습니다.

```swift
private func createStrikeThroughString(from value: String) -> NSMutableAttributedString {
    let lineStyle = NSUnderlineStyle.thick.rawValue
    let attributedValue = NSMutableAttributedString(string: value)
    
    attributedValue.addAttribute(.strikethroughStyle, value: lineStyle, range: NSMakeRange(.zero, attributedValue.length))
    return attributedValue
}
```

&nbsp;

- [https://developer.apple.com/documentation/foundation/nsattributedstring](https://developer.apple.com/documentation/foundation/nsattributedstring)

&nbsp;

## Cache
### NSCache와 URLCache 및 URLSession을 이용하여 URL캐시 이용하기

- `NSCache`의 경우 메모리 캐시만 지원한다.하지만 `URLCache` 및 `URLSession`을 이용하면 in Memory, on-disk cache 방식 모두 사용가능합니다.
- `URLSession.shared`는 기본적으로 캐시에 대한 설정을 제공하고 있지 않습니다. 따라서 커스텀 `URLSession`을 생성하여 내부적으로 cache를 가질 수 있도록 구현하였습니다.
- 커스텀 `URLSession`은 `URLCache.shared` 메모리 캐시를 이용하였고(기본값), cache 정책으로서 내부값을 먼저 확인하고 요청을 보내는 `returnCacheDataElseLoad`를 정책으로써 선택하였습니다.

```swift
struct ImageModule: ImageRequestable {
    private let rangeOfSuccessState = 200...299
    private let customURLSession: URLSession = {
        let oneKilobyte = 1024
        let oneMegabyte = oneKilobyte * oneKilobyte
        URLCache.shared.memoryCapacity = 512 * oneMegabyte
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        return URLSession(configuration: config)
    }()
    
    func loadImage(with url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionDataTask {
        let dataTask = customURLSession.dataTask(with: url) { data, response, error in
            if let response = response as? HTTPURLResponse,
               rangeOfSuccessState.contains(response.statusCode),
               let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completionHandler(.success(image))
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
        dataTask.resume()
        return dataTask
    }
}
```

&nbsp;

참고자료: 

- [https://developer.apple.com/documentation/foundation/url_loading_system/accessing_cached_data](https://developer.apple.com/documentation/foundation/url_loading_system/accessing_cached_data)

&nbsp;

<details>


<summary> <b> 캐시에 대한 문서들 정리 </b> </summary>

<div markdown="1">


### 1. NSCache 쓰기

[Apple Developer Documentation](https://developer.apple.com/documentation/foundation/nscache)

- 리소스가 부족하면 제거될, 임시 키-값 쌍을 잠시 저장할 때 사용하는 mutable한 컬렉션

&nbsp;

```swift
class NSCache<KeyType, ObjectType> : NSObject where KeyType : AnyObject, ObjectType : AnyObject
```

- NS라는 접두어가 있는 것으로 봐서 근본적으로는 Objective-C의 기능인 것 같다.
- `NSObject`를 상속한 클래스로써 키에는 `KeyType`, 밸류에는 `ObjectType`이라는 제네릭을 사용하였다.
- `where`절을 이용한 제약조건이 걸려있는데, 키와 밸류에는 둘 다 무조건 클래스가 와야 하는 것 같다.

&nbsp;

**Overview**

Cache object는 mutable한 컬렉션과는 다른, 다음과 같은 차이점을 가진다.

- `NSCache` class는 캐시가 시스템 메모리를 너무 많이 사용하지 않도록 하는 다양한 자동-제거 정책을 통합하였다. 만약 다른 앱이 메모리를 필요로 한다면 이러한 정책들은 캐시에서 일부 항목을 제거하여 메모리 사용 공간을 최소화 한다.

- 캐시를 직접 lock하지 않고도 여러 다른 쓰레드에서 캐시에 항목을 추가, 제거 및 쿼리할 수 있다.

- `NSMutableDictionary` object와는 다르게 캐시는 내부에 저장된 key object들을 복사하지 않는다.

  → 이게 무슨말일까? 키에 해당하는 인스턴스를 복사하지 않고 단순히 참조한다는걸까?

&nbsp;

'만드는데 큰 비용이 드는 임시 데이터'를 가진 object를 잠시 저장하는데에 `NSCache`를 쓰는 것이 일반적인 사용법이다. 이러한 object를 재사용하면 해당 값을 다시 계산할 필요가 없기 때문에 성능상의 이점을 얻을 수 있다. 다만 이러한 object들은 앱에서 중요한 것이 아니며 메모리가 부족한 경우 삭제될 수 있다. 만약 삭제된다면 필요할 때 값을 다시 계산해야 할 것이다. 

&nbsp;

사용하지 않을 때 버릴 수 있는 subcomponent들을 지닌 object들은 `NSDiscardableContent`프로토콜을 채택하여 캐시 제거 동작을 개선시킬 수 있다. 기본적으로 캐시 내에 있는 `NSDiscarableContent` object들은 object들의 컨텐츠가 삭제되면 자동으로 제거된다. 다만 이 자동 제거 정책은 변경될 수 있다. `NSDiscarableContent` object가 캐시에 있으면 캐시는 해당 object를 제거할 때 `discardContentIfPossible()`을 호출한다.

&nbsp;

[Apple Developer Documentation](https://developer.apple.com/documentation/foundation/nscachedelegate)

- 보니까 `NSCacheDelegate`도 존재한다. 이 `delegate`를 사용하면 캐시 내의 object가 제거되려 할 때 특별한 행동을 취할 수 있다고 한다. (삭제되려고 하는걸 다시 넣는다던지 할 수 있지 않을까?)

&nbsp;

### 2. URLCache 쓰기

[Apple Developer Documentation](https://developer.apple.com/documentation/foundation/urlcache)

- URL request를 캐시된 response object로 매핑하는 object

&nbsp;

```swift
class URLCache : NSObject
```

- `NSObject`를 상속받았다.

&nbsp;

**Overview**

`URLCache` 클래스는, `NSURLRequest` object를 `CachedURLResponse` object로 매핑함으로써 URL load 요청에 대한 응답 캐싱을 구현하였다. `URLCache`는 in-memory 및 on-disk 복합 캐시를 제공하며 in-memory와 on-disk 부분 모두의 사이즈를 변경할 수 있다. 또한 캐시 데이터가 영구적으로 저장되는 경로를 제어할 수도 있다. 

- iOS에서 on-disk 캐시는 시스템의 디스크 공간이 부족할 때 제거될 수 있다. 다만 이는 앱이 실행중이지 않을 때에만 수행된다.

&nbsp;

**Thread Safety**

iOS 8 이상 및 macOS 10.10 이상부터 `URLCache`는 thread safe하다.

`URLCache` 인스턴스 메소드들이 multiple execution context에서 동시에 안전하게 호출될 수 있다고 하더라도, `cachedResponse(for:)`과 `storeCachedResponse(_:for:)` 같은 메소드들은 피할 수 없는 race condition을 가질 수 있음을 주의해라. (같은 request에 대해 response를 read 또는 write하려는 경우)

`URLCache`의 하위 클래스는 이렇게 thread-safe한 방식으로 재정의된 메소드를 구현해야 한다.

&nbsp;

### 3. Custom URLSession에 cachePolicy 지정하기

이 방법은 Session이 자체적으로 URLCache를 쓰도록 하는 방법이다. 

```swift
//NetworkModule.swift
import Foundation
import UIKit.UIImage

struct ImageModule: ImageRequestable {
    private let rangeOfSuccessState = 200...299
    private let customURLSession: URLSession = {
        let oneKilobyte = 1024
        let oneMegabyte = oneKilobyte * oneKilobyte
        URLCache.shared.memoryCapacity = 512 * oneMegabyte
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        return URLSession(configuration: config)
    }()
    
    func loadImage(with url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionDataTask {
        let dataTask = customURLSession.dataTask(with: url) { data, response, error in
            if let response = response as? HTTPURLResponse,
               rangeOfSuccessState.contains(response.statusCode),
               let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completionHandler(.success(image))
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
        dataTask.resume()
        return dataTask
    }
}
```

&nbsp;

### 4. Disk cache를 직접 쓰기

 → FileManager를 이용하여 `Data Container` 안 `Library` 내부 `Cache 디렉토리` 직접 사용

[[Swift] Image Cache처리 (NSCache, FileManager)](https://nsios.tistory.com/58)

&nbsp;

다만 마음에 걸리는 것은, 원본이 변경되었는지 먼저 체크하는게 우선시되어야 할 것 같은데(Head Request) 그것이 현재 서버 API 형태에서 가능하냐는 것이다. 현재 서버 API로는 메타데이터만 요구하여 이미지 데이터가 변경되었는지만 체크하는 것이 불가능해 보인다. (아예 해당 제품 아이템을 통째로 가져와야 할 것 같음)

&nbsp;

**원본의 데이터가 바뀌었는지 체크하는 법?**

1. Etag 쓰기 - 잘 모르겠다. 아직은
2. 메타데이터 쓰기 - 데이터의 마지막 수정시각에 대한 데이터(메타데이터)만이라도 주고 받을 수 있게 해준다면 가능하지 않을까 싶다. 클라이언트에서는 캐시의 데이터를 사용하기 전 해당 정보만을 서버에 요청하고, 캐시 데이터의 마지막 수정일자와 비교하여 캐시데이터를 그대로 쓸지, 네트워크 요청을 다시 해야할지 결정하는 방식으로.

</div>

</details>

&nbsp;
## etc
### UIAlertController

Error 발생 및 목록의 끝에 도달했을때 알려주는 alert를 띄워주기 위해 구현하였습니다.

`UIAlertController`을 `extension`으로 확장하고, 새로운 메서드를 추가함으로써 재사용에 용이하게 구현하였습니다.

```swift
extension UIAlertController {
    static func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction], animated: Bool, completionHandler: (()->Void)? = nil, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            alert.addAction(action)
        }
        viewController.present(alert, animated: animated, completion: completionHandler)
    }
}
```

&nbsp;

**Strong Refernce cycle?** 

- `Alert`를 사용할 때 `ViewController`가 보통 `Alert`의 handler 클로저를 참조하지는 않는다. 때문에 handler 클로저에서 `ViewController`를 참조하는 `self`를 쓰기 쉽다. 하지만 일단 `Alert`가 띄워지면 `ViewController`는 화면에 띄워진 `Alert`를 `view`라는 프로퍼티를 통해 strong하게 참조하는 형태가 될 것이므로 이 때 `strong reference cycle`이 생길 것으로 추측된다.
- 다만 `Alert`도 `ViewController`이고 `present`라는 메소드로 띄워지기 때문에 기존 `ViewController`가 이 `Alert`를 `view`라는 프로퍼티로 참조하고 있는 것인지는 확실하지 않다.

&nbsp;

### 반환타입을 이용한 제네릭 특정하기

현재 프로젝트 코드에서는 타입과 소스를 모두 파라미터 값으로 입력하게 되어있다.

하지만 굳이 메타타입을 넘기지 않고 반환타입을 통해 컴파일러가 유추할수 있게 할수도 있다.

**기존코드**

```swift
func decode<T: Decodable>(from source: Data, to destinationType: T.Type) -> Result<T, ParsingError> {
    guard let decodedData = try? jsonDecoder.decode(destinationType, from: source) else {
        return .failure(.decodingError)
    }
    return .success(decodedData)
}
```

&nbsp;

**반환타입을 이용하여 타입을 특정하는 코드**

```swift
func decode<T: Decodable>(from source: Data) -> Result<T, ParsingError> {
    guard let decodedData = try? jsonDecoder.decode(T.self, from: source) else {
        return .failure(.decodingError)
    }
    return .success(decodedData)
}

let parsedResult: Result<Products, Error> = parsingManager.decode(from: data)
```

&nbsp;

이 방식 말고도 아래의 방식도 있다.

```swift
struct ParsingManager<T: Decodable> {
    private let jsonDecoder = JSONDecoder()
    
    func decode(from source: Data) -> Result<T, ParsingError> {
        guard let decodedData = try? jsonDecoder.decode(destinationType, from: source) else {
            return .failure(.decodingError)
        }
        return .success(decodedData)
    }
}

ParsingManager<Products>().decode(from: data)
```

&nbsp;

### Activity Indicator

처음 목록을 로드할때와 다음 목록을 로드할 때 로딩중임을 알려주기 위해 적용하였습니다.

Indicator에 오토레이아웃이 적용되지 않아 다음과 같은 메서드를 적용하였습니다.

```swift
loadingIndicatorView.center.x = self.view.center.x
loadingIndicatorView.center.y = self.view.center.y
```

&nbsp;

### Capture list

클로저 내부에서 어떤 인스턴스를 캡쳐해야 할 때 **`특별한 규칙`** 이 필요하다면 사용하는 구문

이를테면 캡쳐하려는 인스턴스를 약하게 참조하라던지, 미소유로 참조하라던지.. 대괄호`[]` 안에 써준다.

- **`weak`**

  - 캡쳐하는 대상을 약하게 캡쳐한다. 대상이 참조타입일 때 ARC의 retain count를 증가시키지 않는다.
  - 해당 인스턴스가 사라지면 자동으로 이 프로퍼티에는 nil이 할당된다. 때문에 `weak`를 쓸 때에는 무조건 참조형태가 옵셔널 타입이어야 한다.
  - 일반적으로 '내'가 '캡처하는 대상'보다 life time이 긴 경우 사용한다. (나는 계속 살아있지만 내가 살아있는 동안 상대방이 사라질 수 있는 경우)

- **`unowned`**

  - 캡쳐하는 대상을 미소유로 캡쳐한다. 대상이 참조타입일 때 ARC의 retain count를 증가시키지 않는다.
  - 해당 인스턴스가 사라진다고 해서 이 `unowned` 프로퍼티의 값이 바뀌거나 하는 동작은 수행되지 않는다.
    - 해당 인스턴스가 사라졌다면 이 프로퍼티는 dangling pointer가 되며 참조하려는 경우 크래시가 발생한다.
    - 프로퍼티는 옵셔널이 요구되지 않으며 옵셔널로 두는 경우 해당 인스턴스가 사라졌을 때 nil을 직접 할당해주어야 한다.
  - 일반적으로 '내'가 '캡처하는 대상'보다 life time이 짧은 경우 사용한다. (내가 있는동안 상대방은 무조건 살아있는 경우)

  &nbsp;

  `struct` 내부에서 사용하는 클로저는 `self`를 직접적으로 표시할 필요가 없으며 `class`의 경우 요구된다. 

  - `struct`와 같은 값타입을 캡처하는 경우 (그게 설사 자기 자신이라고 하더라도) 클로저에서 값을 변경하거나 하지 않는 경우 복사본을 캡처한다.
  - `struct`의 `mutating` 메서드 안에서 만들어지는 클로저는 일반적으로 `self`를 참조하고 있을 수 없다.
    - `self`가 `mutable`하기 때문이며 `mutable`한 `self`를 캡처하지 못하도록 막고 있기 때문
    - capture list로 `[self]`를 써서 immutable한 캡처를 하도록 만들 수 있다. (값 타입이어서 `self`가 복제된다!!!)
    - `struct` 내부에서 `lazy` 프로퍼티로 만들어지는 클로저는 `self`를 그냥 캡처할 수 없다. capture list로 `[self]`를 써야하는데 그 이유는 아직 잘 모르겠다.
  - `class`에서 `self`를 쓰도록 요구받는 이유는 `reference cycle`등에 대해 개발자가 숙지하고 쓰고 있음을 명확히 하도록 하기 위함이라고 한다. (?)
