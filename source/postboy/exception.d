/*======================================================================
    [ postboy ] exception.d
        o 예외정의
    2018, ZHANITEST(github.com/zhanitest/postboy), LGPL v2.1
 ======================================================================*/
module postboy.exception;
//---IMPORT-------------------------------------------------------------
import std.stdio;
//---SOURCE-------------------------------------------------------------
/**
 * SSL 인증서 없음
 *  Description:
 *      requester.d에 하드코딩된 SSL파일경로로 carcert.pem를 찾았으나 없음
 */
class SslNotFoundException : Exception
{
    this(string file = __FILE__, size_t line = __LINE__) {
        super(
            "`carcert.pem` is not found. please check out `https://curl.haxx.se/docs/caextract.html`."
            , file, line);
    }
}
/**
 * Request 생성오류
 *  Description:
 *      Request구조체를 생성하는 도중 알 수 없는 예외발생
 */
class UnableInitRequestException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(
            "Couldn't Initialize the Request struct from `Reqman`:\n"~msg
            , file, line);
    }
}
/**
 * Response Null
 *  Description:
 *      Response 응답값이 null임
 */
class ResponseNullException : Exception
{
    this(string file = __FILE__, size_t line = __LINE__) {
        super(
            "A response is null from `Reqman`.:\n"
            , file, line);
    }
}
/**
 * 추측 불가능한 에러
 *  Description:
 *      알 수 없는 시스템 에러
 */
class UnknownSystemError : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}