/*======================================================================
    [ postboy ] util.d
        o 유틸리티 모음
    2018, ZHANITEST(github.com/zhanitest/postboy), LGPL v2.1
 ======================================================================*/
module postboy.util;
//---IMPORT-------------------------------------------------------------
import std.conv;
import std.file;
import std.regex;
import std.stdio;
import std.string;
import std.datetime.systime;
//---SOURCE-------------------------------------------------------------
/**
 * 빌드모드 명시
 */
string getBuildedStatus(){
	string build_mode = "release";
	debug{
        build_mode = "debug";
    }
    return build_mode;
}
/**
 * Writeln 단축
 */
void putz(string msg){
    writeln(msg);
}
/**
 * 해당하는 문자열로 문자열을 배열로 나눈 값 추출
 * Params:
 *      butter = 자를 대상 문자열
 *      knife  = 자를 기준 문자열
 *      index  = 자르고 난 후 배열의 인덱스(기본 값 -1 -> 맨 마지막 요소 가져오기)
 */
string chap(string butter, string knife, int index=-1){
    string[] cutted_butter = butter.split(knife);
    int reindex = index==-1 ? cutted_butter.length-1:index; // -1은 요소의 마지막 인덱싱
    return cutted_butter[reindex];
}
/**
 * 특수문자 제거
 * Params:
 *      text = 특수문자를 제거할 임의의 문자열
 */
string removeSpecialChar(string text){
	string  result = text;
	string[] table = [ "/", ":", "*", "?", "<", ">", "|", "？", "\\"];
	foreach(t; table){
		result = result.replace(t, "");
	}
	return result;
}
/**
 * 시스템 시간 구하기
 * Returns: sysdate.toSimpleString -> 현재시간을 문자열로 리턴
 */
string getSysdate(){
    SysTime sysdate = Clock.currTime();
    return  sysdate.toSimpleString();
}

/**
 * 호스트 긁어내기
 * Description:
 *      호스트만 추출한다.
 *      ex. http://example.org/act?name=zhanitest -> example.org
 * Params:
 *      url = http://가 붙은 URL주소
 * Returns:
 *      호스트만 추출한 문자열
 */
string stripHost(string url){
    string result;
    auto m = matchAll(url, regex("https*:\\/\\/([\\d\\w]+\\.[\\w]+\\.*[\\w]*)"));
    result = to!string(m.front.hit); // 두번째가 (그룹핑)한 값임
    return to!string(m.front[1]);
}