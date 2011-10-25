//常量
var source="radio"
var appname="dmu";
var appversion="1";
var MAX_RETRY_TIME=5;
var MIN_R=Math.pow(16,9);
var RANGE_R=Math.pow(16,10)-MIN_R-1;

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
                        throw(1,"Returned Invalid Data");
                    }
                }
            
            });
}

function get_playlist(type,channel,sid,h) {
    if(!auth_obj.cookie) return null;
    var data={
                'type':(type||'n'),
                'channel':0,
                'r':Math.round(Math.random()*RANGE_R+MIN_R).toString(16),
            }
    if(sid) data['sid']=sid;
    if(h) data['h']=h;
    $.ajax('http://douban.fm/j/mine/playlist',
            {
                'data':data,
                'type':'get',
                'beforeSend':function(xhr){
                    xhr.setRequestHeader('Cookie',auth_obj.cookie)
                },
                'success':function(json,xhr)
                {
                    var list=eval(json);
                    if(list.r) throw(2,'Get Playlist Failed Error');
                    if(data.type=='n')
                        playlist=list.song;
                    //remember to fire a new event
                },
            });
}



function error_handle(err) {
    throw err
}
