//常量
var source="radio"
var appname="dmu";
var appversion="1";
var MAX_RETRY_TIME=5;
var MIN_R=Math.pow(16,9);
var RANGE_R=Math.pow(16,10)-MIN_R-1;

//全局对象

var get_playlist_lock=false;

var playlist=[];
var recently_played=[];
var auth_obj={};
var nowplaying;
var nextplay;

var nowplaying_audio=$('<audio></audio>').attr('preload','preload');
var preload_audio=$('<audio></audio>').attr('preload','preload');

$(window).ajaxComplete(function(){get_playlist_lock=false});
$.fn.extend(
        {'playOnReady':function(){
                                     $(this).each(function(n,a){
                                         if(a.tagName.toUpperCase()!="AUDIO") return;
                                         if(a.readyState==4) a.play();
                                         else $(a).one('canplay',function(){a.play()});
                                     })
                                     return $(this);
                                 },
         'stop':function(){
            return $(this).each(function(n,a){if(a.tagName.toUpperCase()!="AUDIO")a.pause()})
         }
        })




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
    if(get_playlist_lock) return null;
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
                    get_playlist_lock=true;
                },
                'success':function(json,xhr)
                {
                    var list=eval(json);
                    if(list.r) throw(2,'Get Playlist Failed Error');
                    if(data.type=='n')
                    { 
                        playlist=list.song;
                        nextplay=playlist.shift();
                        fm_next();
                        //remember to fire a new event
                    }
                    
                },
            });
}


function fm_next(){
    if(nextplay){
        recently_played.push(nowplaying);
        nowplaying=nextplay;
        nextplay=playlist.shift();
    }
    else{
        get_playlist();
        //fire an event
    }
    if(nowplaying)
    {
        if(preload_audio.attr('src')==nowplaying.url)
        {
            nowplaying_audio.stop();
            var tmp=nowplaying_audio;
            nowplaying_audio=preload_audio;
            preload_audio=tmp;
            preload_audio.removeAttr('src').removeAttr('autoplay').attr('preload','preload');
            nowplaying_audio.attr('autoplay','autoplay').playOnReady();
        }
        else nowplaying_audio.attr('src',nowplaying.url).playOnReady();
        if(nextplay) preload_audio.attr('src',nextplay.url);
    }
};


function error_handle(err) {
    throw err
}
