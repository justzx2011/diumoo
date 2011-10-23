//常量
var source="radio"
var appname="dmu";
var appversion="1";
var MAX_RETRY_TIME=5;

//全局对象
var playlist=[];
var auth_obj={};





function auth(email,pass,retry) {
    $.ajax('http://douban.fm/j/login',
            {
                'data':{
                    'alias':email,
                    'form_password':pass,
                    'source':appname,
                },
                'type':'post',
                'beforeSend':function(xhr,settings){
                    xhr.setRequestHeader('cookie','');
                },
                'success':function(data,sta,xhr){
                    try{
                        var tmp=eval(data);
                        if(typeof(tmp)!="undefined" && !tmp.r){
                            auth_obj=tmp;
                            auth_obj.cookie=xhr.getResponseHeader('Set-Cookie').match(/expires=.+?,\s*(\w+=".+?");/g).join('').replace(/expires=(.+?,){2}/g,'');
                        }
                        else throw(0,"Authenticated Failed ("+tmp.err+")");
                    }catch(ex){
                        throw(1,"Connection Error");
                    }
                }
            
            });
}


function error_handle(err) {
    throw err
}
