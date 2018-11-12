/*======================================================================
    [ postboy ] test.d
        o 라이브러리 동작여부 테스트
    2018, ZHANITEST(github.com/zhanitest/postboy), LGPL v2.1
 ======================================================================*/
import std.stdio;
import std.string;
import postboy.util;
import postboy.header;
import postboy.requester;

/**
 * carcert.pem 인증서는 여기(https://curl.haxx.se/ca/cacert.pem)를 참고하여 받는다.
 */
unittest{
    string url = "http://info.cern.ch/hypertext/WWW/TheProject.html"; // 이 세상에서 가장 먼저 태어난 WWW 페이지
	Postboy client = new Postboy();
    Header  header = Header(OS.Win64, CLIENT.Firefox);
    
    // 똑같지
    header.addElement(
        "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    );
    header.addElements([
          "Accept-Encoding": "gzip, deflate"
        , "Accept-Language": "ko-KR,ko;q=0.8,en-US;q=0.5,en;q=0.3"
        , "Cache-Control"  : "max-age=0"
        , "Connection"     : "max-age=0"
        , "Host"           : "info.cern.ch"
    ]);

    client.setHeader(header); // 편집한 헤더셋팅
    client.GET(url);          // Act GET
    assert(client.getResponsedString().indexOf("World Wide Web")>0);
    assert(stripHost(url)=="info.cern.ch", stripHost(url));
}