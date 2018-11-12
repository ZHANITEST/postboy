/*======================================================================
    [ postboy ] requester.d
        o 외부통신 및 headless browsing 담당
    2018, ZHANITEST(github.com/zhanitest/postboy), LGPL v2.1
 ======================================================================*/
module postboy.requester;
//---IMPORT-------------------------------------------------------------
import std.uri;
import std.conv;
import std.file;
import std.stdio;
import std.outBuffer;
import requests;
import postboy.util;
import postboy.header;
import postboy.exception;
//---SOURCE-------------------------------------------------------------
/**
 * 포스트보이
 */
class Postboy{
    private Request  rq; /// Request
    private Response rp; /// Response 
    private Header   hd; /// Header
    private string  url; /// url string
    /**
     * 생성자
     */
    this(){
        string cacert_name =    ""; // cacert file path
        bool   had_cacert  = false; // have you cacert ?

        // 인증서를 찾기위한 경로
        string[] cacert_path = [ 
            "C:\\cacert.pem"
        ,   "D:\\cacert.pem"
        ,   "cacert.pem"
        ];

        // SSL 인증서 여부 검사
        for(int i=0; i<cacert_path.length; i++){
            had_cacert = exists(cacert_path[i]);
            if(had_cacert){
                cacert_name = cacert_path[i];
            }
        }
        
        if(!had_cacert){ // 인증서 없을 시 throw처리
            throw new SslNotFoundException;
        }
        
        try{
            this.rq = Request();          // Request 준비
            rq.sslSetCaCert(cacert_name); // 인증서 로드
        }
        catch(Exception e){
            throw new UnableInitRequestException(e.msg); // 초기화오류
        }
    }

    /**
     * 헤더데이터 설정
     *  Params:
     *      hd = Request의 Header값 대입
     */
    void setHeader(Header hd){
        this.hd = hd;
    }

    /**
     * 헤더데이터 추출
     *  Returns:
     *      this.hd -> Request의 Header값 리턴
     */
    Header getHeader(){
        return this.hd;
    }

    /**
     * Request시 거래내용 상세보기
     *  Description:
     *      디버그(debug) 시에만 동작한다.
     *  Params:
     *      code = Request의 verbosity값 조정(디버시에만 동작한다.)
     */
    void setVerbosity(int code=3){
        debug{
            // 디버그 빌드 시 로그 콘솔에 출력하도록 설정
            this.rq.verbosity = code;
        }
        version(release){
            puts("*** Couldn't set a verbosity -> LEVEL "~to!string(code));
        }
    }

    /**
     * GET 요청
     *  Description:
     *      임의의  URL로 GET요청을 날린다.
     *  Params:
     *      url = GET요청할 주소
     */
    void GET(string url){
        string encoded_url = encode(url);
        this.url = url;
        debug{ putz( "[GET] "~getSysdate()~" / "~encoded_url); }
        
        try{
            this.rq.addHeaders(this.hd.getHeaderData());
            this.rp = rq.get(encoded_url);
            this.rq.addHeaders(null);
        }
        catch(Exception e){ this.CLOSE(); }
        finally {}
    }

    /**
     * POST 요청
     *  Description:
     *      POST의 경우 헤더 데이터에 자동으로 "Content-Type":"application/x-www-form-urlencoded" 값이 추가되며,
     *      이에 대해서는 Request의 헤더값 필드를 오염시키지 않고 사본을 사용한다.(POST 거래 시마다 header 사본 복사/소멸)
     *  Params:
     *      url   = POST 요청 할 주소
     *      query = 파라메터로 줄 값(key:value)
     */
    void POST(string url, string[string] query){
        string encoded_url = encode(url);
        this.url = url;
        debug{
            putz("[POST] "  ~getSysdate()     // 시스템 현재날짜
                            ~" / "            //
                            ~encoded_url      // 요청 URL
                            ~" "              //
                            ~to!string(query) // POST값을 날릴 파라메터
            );
        }
        
        try{
            // header 필드를 오염시키지 않도록 복사본을 사용하며,
            // POST요청은 헤더에 특별한 값을 추가한다
            Header post_header = this.hd; 
            post_header.addElement("Content-Type", "application/x-www-form-urlencoded");

            this.rq.addHeaders(post_header.getHeaderData()); // 헤더추가
            this.rp = rq.post(encoded_url, query);           // 파라메터와 함께 요청 날리기
            this.rq.addHeaders(null);                        // 사용한 헤더 날리기
        }
        catch(Exception e){ this.CLOSE(); }
    }

    /**
     * Data추출
     *  Description:
     *      GET/POST하여 받을 값이 바이너리라면 이 메서드를 사용하여 바이트로 받는다.
     *  Returns:
     *      this.rp.responseBody.data -> 바이트로 받기
     */
    ubyte[] getResponsedBinary(){
        ubyte[] result = null;
        if(this.rp is null){
            throw new ResponseNullException();
        }
        try                 { result = this.rp.responseBody.data;   }
        catch(Exception e){ this.CLOSE(); }
        return result;
    }

    /**
     * Data추출
     *  Description:
     *       GET/POST하여 받을 값이 HTML값이라면 이 메서드를 사용하여 string으로 받는다.
     *  Returns:
     *      to!string(this.rp.responseBody.data) -> 문자열로 받기
     */
    string getResponsedString(){
        string result = null;
        if(this.rp is null){
            throw new ResponseNullException();
        }

        try{
            OutBuffer buf = new OutBuffer();
            buf.write(this.rp.responseBody.data);
            result =  buf.toString();
        }
        catch(Exception e) { this.CLOSE(); }
        //writeln(this.rp);
        return result;
    }

    /**
     * 소멸여부 확인 - 굳이 필요할 것같진 않아서 주석처리
     */
    // bool isClose(){
    //     bool result = false;
    //     static if(is(typeof(this.rq is null))){ // null은 `특수한 타입`이므로 compile-time에 처리필요(static if)
    //         result = true;
    //     }
    //     return result;
    // }

    /**
     * 소멸처리
     *  Description:
     *      모든 필드를 초기화한다.
     */
    void CLOSE(){
        debug{ putz("[END] "~getSysdate()~" / "~this.url); }
        this.rq =     Request ();
        this.rp = new Response();
        this.hd =     Header  ();
    }
}