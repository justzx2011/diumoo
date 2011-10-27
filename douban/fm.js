//常量
var source="radio"
var appname="dmu";
var appversion="1";
var MAX_RETRY_TIME=5;
var MIN_R=Math.pow(16,9);
var RANGE_R=Math.pow(16,10)-MIN_R-1;

//全局对象
playlist=[];
h=[];
auth_obj={};
nowplaying=null;
nextplay=null;
currentChannel=0;

nowplaying_audio=$('<audio></audio>').attr('preload','preload');
preload_audio=$('<audio></audio>').attr('preload','preload');

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
         },
         'playedPercent':function(){if($(this)[0].tagName.toUpperCase()=="AUDIO") return $(this)[0].currentTime/$(this)[0].duration;else return 0}
        })




function auth(email,pass,retry) {
    var ts=this;
    $.ajax('http://douban.fm/j/login',
            {
                'data':{
                    'alias':email,
                    'form_password':pass,
                    'source':appname,
                },
                'type':'post',
                'timeout':1000,
                'beforeSend':function(xhr,settings){
                    xhr.setRequestHeader('cookie','');
                },
                'error':function(){ts.retry()},
                'success':function(data,sta,xhr){
                    
                    try{
                        var tmp=eval(data);
                        if(typeof(tmp)!="undefined" && !tmp.r){
                            auth_obj=tmp;
                            auth_obj.cookie=xhr.getResponseHeader('Set-Cookie').match(/expires=.+?,\s*(\w+=".+?");/g).join('').replace(/expires=(.+?,){2}/g,'');
                        }
                        else throw(0,"Authenticated Failed ("+tmp.err_msg+")");
                    }catch(ex){
                        throw ex;
                    }
                    ts.finish();
                }
            
            });
}

function get_playlist(type,sid) {
    var ts=this;
    var data={
                'type':(type||'n'),
                'channel':currentChannel,
                'from':'mainsite',
            }
    if(sid) data['sid']=sid;
    if(data.type!='n' && data.type!="r" && data.type!='u'){
        while(h.length>19) h.shift();
        h.push('|'+sid.toString()+':'+data.type);
    }
    else data['r']=Math.round(Math.random()*RANGE_R+MIN_R).toString(16);
    if(type=='e' && playlist.length>2) return;
    if(h.length>0) data['h']=h.join();
    $.ajax('http://douban.fm/j/mine/playlist',
            {
                'data':data,
                'type':'get',
                'timeout':1000,
                'beforeSend':function(xhr){
                    xhr.setRequestHeader('Cookie',auth_obj.cookie)
                    get_playlist_lock=true;
                },
                'error':function(){ts.retry()},
                'success':function(json,xhr)
                {
                    var list=eval(json);
                    if(list.r) throw(2,'Get Playlist Failed Error');
                    if(data.type=='n'|| data.type=='p'||playlist.length==0)
                    { 
                        playlist=list.song;
                        if(!nextplay) nextplay=playlist.shift();
                        //remember to fire a new event
                    }
                    ts.finish();
                    
                },
            });
}


function fm_next(){
    if(nextplay){
        var tmp=nowplaying;
        nowplaying=nextplay;
        if(playlist.length>0)nextplay=playlist.shift();
        if(tmp && tmp.url==nowplaying_audio.attr('src')){
            if(nowplaying_audio[0].ended||nowplaying_audio.playedPercent()>0.8){
                if(playlist.length>0) get_playlist('e',nowplaying.sid);
                else get_playlist('p',tmp.sid);
            }
            else get_playlist('s',tmp.sid);
        }
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
    this.finish();
};


function error_handle(err) {
    throw err
}
