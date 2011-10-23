//常量
var source="radio"
var appname="dmu";
var appversion="1";


//全局对象
var playlist=[];
var auth_obj={};





/**
 * function intro
 * @param {type} email,pass,appname,version
 * @return 
 */
function auth(email,pass) {
    $.post('http://douban.fm/j/login',
            {
                'alias':email,
                'form_password':pass,
                'source':appname,
            },
            function(data){
                try{
                    var tmp=eval(data,xhr);
                    if(typeof(tmp)!="undefined" && !tmp.r){
                            auth_obj=tmp;
                            cookie=xhr.getResponseHeader('Set-Cookie');
                    }
                    else throw(0,"Authenticated Failed ("+tmp.err+")");

                }catch(ex){
                    error_handle(ex);
                }
            });
}


/**
 * function intro
 * @param {type} err
 * @return 
 */
function error_handle(err) {
    throw err
}
