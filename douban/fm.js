//全局变量
APPNAME='dmu';
APPVERSION='1';
MIN_R=Math.pow(16,9);
RANGE_R=Math.pow(16,10)-MIN_R-1;
AUTH_URL='http://douban.fm/j/login'
PLAYLIST_URL='http://douban.fm/j/mine/playlist'

//电台控制代号

NEW='n';
SKIP='s';
END='e';
PLAYING='p';
RATE='r';
UNRATE='u';

//全局错误代码
NETWORK=0;
AUTH_FAILED=1;
GET_PLAYLIST_FAILED=2;

function fm(){
    this._playlist=[];
    this._h=[];
    this._auth=null;
    this._cookie='';
    this._nowplaying=null;
    this._next=null;
    this._channel=1;
    this._errorhandle=null;
    this.data('fm',this);
    this.push(document.createElement('audio'));
    this.attr('preload','preload');

}
fm.prototype=$();

/**
 * 认证获得对应Cookie和auth信息
 * @param {string} email {string} pass
 * @return this
 */
fm.prototype.auth = function(email,pass) {
    var ts=this;
    return this.queue(function(next){
        $.ajax(AUTH_URL,
            {
                'data':{
                    'alias':email,
                    'form_password':pass,
                    'source':'radio',
                },
            'type':'post',
            'timeout':2000,
            'beforeSend':function(xhr,settings){
                xhr.setRequestHeader('cookie','');
            },
            'error':function(){},
            'success':function(data,sta,xhr){
                try{
                    var tmp=eval(data);
                }catch(ex){
                    ts.error(NETWORK);
                    return;
                }
                if(typeof(tmp.r)!='undefined' && tmp.r==0){
                    ts._auth=tmp;
                    ts._cookie=xhr.getResponseHeader('Set-Cookie').match(/expires=.+?,\s*(\w+=".+?");/g).join('').replace(/expires=(.+?,){2}/g,'');
                    next();
                }
                else ts.error(AUTH_FAILED);
            }

            });
    });
};


/**
 * 获得播放列表
 * @param {string} type {string} sid
 * @return this
 */
fm.prototype.list = function(type,sid) {
    var ts=this;
    return this.queue(
            function(next){
                var data={
                    'type':(type||NEW),
                    'channel':this._channel,
                    'from':'mainsite',
                    'r':(Math.round(Math.random()*RANGE_R+MIN_R).toString(16)),
                }
                if(sid) {
                    data['sid']=sid;
                    if(data.type!=NEW && data.type!=RATE && data.type!=UNRATE){
                        this._h.push('|'+sid +':'+data.type);
                        while(this._h.length>10) this._h.shift();
                    }
                }
                if(data.type=='s' || data.type=='p') data['h']=h.join();
                $.ajax(PLAYLIST_URL,
                    {
                        'data':data,
                    'type':'get',
                    'beforeSend':function(xhr){
                        xhr.setRequestHeader('Cookie',this._cookie);
                    },
                    'error':function(){},
                    'success':function(json){
                        if(json.toUpperCase()=='OK') return;
                        try{
                            var list=eval(json);
                        }catch(ex){
                            ts.error(GET_PLAYLIST_FAILED);
                            return;
                        }
                        if(ts.r) return this.error(GET_PLAYLIST_FAILED);
                        ts._playlist=list;
                        next();
                    },
                    })
            }
    )
};
