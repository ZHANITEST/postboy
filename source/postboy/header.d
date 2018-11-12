/*======================================================================
    [ postboy ] header.d
        o requester가 참조하는 헤더관리
    2018, ZHANITEST(github.com/zhanitest/postboy), LGPL v2.1
 ======================================================================*/
module postboy.header;
//---IMPORT-------------------------------------------------------------
import std.stdio;
import postboy.util;
//---SOURCE-------------------------------------------------------------
/**
 * 운영체제
 *  Description:
 *      헤더에 들어갈 운영체제 정보 정의
 */
enum OS{
    , Win32
    , Win64
}
/**
 * 클라이언트
 *  Description:
 *      헤더에 들어갈 클라이언트(웹브라우저) 정보 정의
 */
enum CLIENT{
    , Chrome
    , Firefox
}
/**
 * 헤더
 *  Description:
 *      헤더데이터 관리를 위한 해시 맵
 */
struct Header{
    private string[string] header;  /// 헤더데이터를 담는 해시
    private OS     ostype;          /// User-Agent : os 
    private CLIENT brtype;          /// User-Agent : browser
    private string      userAgent;  /// User-Agent String 

    /**
     * 초기화
     *  Description:
     *      HTTP/HTTPS 페이지 요청을 위한 기본 헤더값(User-Agent)을 세팅한다.
     *  Params:
     *      os      = 헤더에 들어갈 클라이언트의 운영체제 타입
     *      browser = 헤더에 들어갈 클라이언트의 브라우저 타입
     */
    this(OS os, CLIENT browser){
        this.ostype = os;
        this.brtype = browser;
        this.header["User-Agent"] = this.fetchUserAgent();
    }


    /**
     * 헤더에 값 추가
     *  Description:
     *      중복되는 key에 대해서 덮어쓰기 된다.
     *  Params:
     *      key   = 헤더의 키
     *      value = 헤더의 값
     */
    void addElement(string key, string value){
        this.header[key] = value;
    }

    /**
     * 헤더에 값들 추가
     *  Description:
     *      중복되는 key에 대해서 덮어쓰기 된다.
     *  Params:
     *      pair = key:value쌍의 해시(Associative Arrays)
     */
    void addElements(string[string] pair){
        foreach(k; pair.keys()){
            this.header[k] = pair[k];
        }
    }

    /**
     * 헤더 값 제거
     *  Description:
     *      this.header필드를 null로 초기화한다.
     */
    void clearElement(){
        this.header = null;
    }

    /**
     * 헤더데이터 생성
     *  Returns:
     *      this.header = 헤더 필드값 그대로 리턴
     */
    string[string] getHeaderData(){
        return this.header;
    }

    /**
     * User-Agent 생성
     *  Description:
     *      생성자에서 정의했던 os type과 brower type을 적절히 조합해 User-Agent값을 생성한다.
     */
    private string fetchUserAgent(){
        //Firefox: Windows NT 10.0; Win64; x64; rv:63.0
        //Chrome : (Windows NT 10.0; Win64; x64
        string os_str = "Mozilla/5.0 (Windows NT 10.0; "~(
            this.ostype==OS.Win32 ? "Win32; x32;":"Win64; x64;"
        )~") ";
        string client_str = (this.brtype==CLIENT.Firefox ?
              "Gecko/20100101 Firefox/63.0"
            : "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3555.0 Safari/537.36"
        );
        return os_str~client_str;
    }
}