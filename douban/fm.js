//全局常量
const APPNAME='dmu';
const APPVERSION='1';
const MIN_R=Math.pow(16,9);
const RANGE_R=Math.pow(16,10)-MIN_R-1;
const AUTH_URL='http://douban.fm/j/login'
const PLAYLIST_URL='http://douban.fm/j/mine/playlist'
const TIMEOUT=5000
const VOLUME_DURATION=1000
const VOLUME_DELTA=50;

//电台控制代号

const NEW='n';
const SKIP='s';
const END='e';
const PLAYING='p';
const RATE='r';
const UNRATE='u';
const BYE='b';

//全局错误代码
const NETWORK=0;
const AUTH_FAILED=1;
const GET_PLAYLIST_FAILED=2;

//全局事件
const NEW_S_E='newsong';
const NEW_P_E='newplaylist';
const NEXT_S_C_E='nextsongchanged';
const VOLUME_E='_volumechange';
const RATE_E='rate';
const UNRATE_E='unrate';
const AUTH_S_E='authsuccess';
const PAUSE_E='_pause';
const PLAY_E='play';


//电台主控类

function fm(){
    this._playlist=[];
    this._current=null;
    this._h=[];
    this._auth=null;
    this._cookie='';
    this._nowplaying=null;
    this._next=null;
    this._channel=1;
    this._errorhandle=null;
    this._volume=1;
    this._auth_key=null;
    this.data('fm',this);
    this.push(document.createElement('audio'));
    this.attr('preload','preload');

}
fm.prototype=$();

/**
 * 以audio为基础发出一个事件,可以指定操作的歌曲id
 * @param {string} name, {string} target_sid
 * @return this
 */
fm.prototype.fire = function(name,target_sid) {
   var ev=document.createEvent('CustomEvent');
   ev.initCustomEvent(name,false,true);
   ev.song=this._current;
   ev.next = this._next;
   ev.auth = this._auth;
   ev.fm = this;
   if(target_sid) ev.sid = target_sid;
   this[0].dispatchEvent(ev);
   return this;
};


/**
 * 重写覆盖父类的构造函数
 * @param {string} name, {function} callback
 * @return this
 */
fm.prototype.bind = function(a,b) {
    this[0].addEventListener(a,b);
    return this;
};


/**
 * function intro
 * @param {string/function} 
 * @return 
 */
fm.prototype.error = function(s,e) {
    if(typeof(s)=='function') this.bind('error',s);
    else {
        var ev=document.createEvent('CustomEvent');
        ev.initCustomEvent('error',false,true);
        ev.error_id=s;
        if(e)ev.origin=e;
        this[0].dispatchEvent(ev);
    }
    return this;
};

/**
 * 认证获得对应Cookie和auth信息
 * @param {string} email {string} pass
 * @return this
 */
fm.prototype.auth = function() {
    var ts=this;
    return this.queue('fm',
            function(next){
                if(ts._auth_key == null) {
                    next();
                    return;
                }
                email=ts._auth_key.email;
                pass=ts._auth_key.pass;
        $.ajax(AUTH_URL,
            {
                'data':{
                    'alias':email,
                    'form_password':pass,
                    'source':'radio',
                },
            'type':'post',
            'timeout':TIMEOUT,
            'beforeSend':function(xhr,settings){
                xhr.setRequestHeader('cookie','');
            },
            'error':function(e){
                ts.error(NETWORK,e)
            },
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
                    ts.fire(AUTH_S_E);
                    next();
                }
                else ts.error(AUTH_FAILED);
            }

            });
    });
};





/**
 * 获得播放列表,或者设定播放列表
 * @param {string/array} type {string} sid
 * @return this
 */
fm.prototype.list = function(type,sid) {
    if(typeof(type)=='object' ||typeof(type)=='array')
    {
        this._playlist=type;
        this.fire(NEW_P_E);
        return this;
    }
    var ts=this;
    return this.queue('fm',
            function(next){
                var data={
                    'type':(type||NEW),
                    'channel':ts._channel,
                    'from':'mainsite',
                    'r':(Math.round(Math.random()*RANGE_R+MIN_R).toString(16)),
                }
                if(sid) {
                    data['sid']=sid;
                    if(data.type!=NEW && data.type!=RATE && data.type!=UNRATE){
                        ts._h.push('|'+sid +':'+data.type);
                        while(ts._h.length>10) ts._h.shift();
                    }
                }
                if(data.type==SKIP || data.type==PLAYING) data['h']=ts._h.join();
                $.ajax(PLAYLIST_URL,
                    {
                        'data':data,
                    'type':'get',
                    'timeout':TIMEOUT,
                    'beforeSend':function(xhr){
                        xhr.setRequestHeader('Cookie',this._cookie);
                    },
                    'error':function(e){
                        ts.error(NETWORK,e);
                    },
                    'success':function(json){
                        if(typeof(json)=='string' && json.toUpperCase()=='OK') return next();
                        try{
                            var list=eval(json);
                        }catch(ex){
                            ts.error(GET_PLAYLIST_FAILED);
                            return;
                        }
                        if(list.r) return this.error(GET_PLAYLIST_FAILED);
                        if(data.type==RATE){
                            ts._playlist.concat(list.song);
                            ts.fire(RATE_E,data['sid']);
                        }
                        else ts.list(list.song);
                        if(data.type==UNRATE) ts.fire(UNRATE_E,data['sid']);
                        next();
                    },
                    })
            }
    )
};





/**
 * 当准备就绪之后立即播放
 * @param none 
 * @return none
 */
fm.prototype.playOnReady = function() {
    var ts=this;
    return this.queue('fm',
           function(next){
                if(this.readyState==4) ts.play();
                else ts.one('canplay',
                    function(){
                        ts.play();
                });
                next();
           });
};





/**
 * 暂停歌曲播放
 * @param none 
 * @return this
 */
fm.prototype.pause = function() {
    var ts=this;
    return this.queue('fm',
            function(next){
                ts.fire(PAUSE_E);
               if(ts[0].duration-ts[0].currentTime <1 ){
                    this.pause()
                    return next();
               }
               ts._volume=ts.volume();
               ts.volume(0).ok(
                   function(){
                   this.pause();
                   next();
                   })
    })
};




/**
 * 播放歌曲
 * @param none
 * @return this
 */
fm.prototype.play = function() {
    var ts=this;
    return this.queue(function(next){
        if(ts.attr('src') && this.paused && (!this.ended)) {
            this.play();
            ts.volume(ts._volume);
        }
        else ts.next();
        next();
    })
};




/**
 * 立即切换到下一歌曲
 * @param none
 * @return this
 */
fm.prototype._next_ = function() {
    var ts=this;
    return this.queue('fm',
            function(next){
                if(((!ts._current)&&(ts._playlist.length<2))||(ts._playlist.length<1) ) {
                    ts.list((ts._current)?PLAYING:NEW,ts._current?ts._current.sid:false)
                    .next();
                    return next();
                }
                if(ts._next) ts.current(ts._next);
                else ts.current(ts._playlist.shift());
                ts.next(ts._playlist.shift());
                //fire an event here!
                next();
            }
           ); 
};


/**
 * function intro
 * @param {type} bye
 * @return 
 */
fm.prototype.bye = function(sid) {
    var ts=this;
    return this.queue('fm',
            function(next){
                    ts.pause().list(BYE,(sid||ts._current))._next_();
                    next();
                    });
};








/**
 * 切换到下一首歌曲的控制函数
 * 传入一个object以设置下一首歌曲的信息
 * 传入一个字符串可检索下一首歌曲对应信息
 * 不传入数据则切换到下一首歌曲
 * @param {obj/string} [obj]
 * @return this
 */

fm.prototype.next = function(obj) {
    if(typeof(obj)=='object'){
        this._next=obj;
        this.fire(NEXT_S_C_E);
        return this;
    }
    else if(typeof(obj)=='string'){
        if(this._next) return this._next[obj];
        else return null;
    }
    var ts=this;
    return this.queue('fm',
            function(next){
                if(!$(this).attr('src')) ts._next_();
                else if(this.ended) ts.pause().list(END,ts._current.sid)._next_(); 
                else if(this.paused==false) ts.pause().list(SKIP,ts._current.sid)._next_();
                next();
            }
            )
};


/**
 * 获取、设定当前歌曲
 * 指定一个object以设定当前歌曲信息
 * 指定一个字符串以检索当前歌曲的对应信息
 * 不指定参数以返回当前歌曲
 * @param {type} current
 * @return 
 */
fm.prototype.current = function(s) {
    if(typeof(s)=='object'){
        this._current=s;
        this.attr('src',this._current['url']).playOnReady();
        this.fire(NEW_S_E);
        return this;
    }
    else if(typeof(s)=='string') return this._current[s];
    else return this._current;
};



/**
 * 将当前歌曲标记为喜爱
 * @param none
 * @return this
 */
fm.prototype.rate = function(sid) {
    if((!sid)&&(!this._current)) return this;
    return this.list(RATE,(sid||this._current.sid)); 
};


/**
 * 取消将当前歌曲（或指定歌曲）标记为喜爱
 * @param {string}[ sid ]
 * @return this
 */
fm.prototype.unrate = function(sid) {
    if((!sid)&&(!this._current)) return this;
    return this.list(UNRATE,(sid||this._current.sid));
    
};




/**
 * 设定和获取当前的音量大小
 * @param {float} v
 * @return 
 */
fm.prototype.volume = function(v) {
    if(typeof(v)!='number') return this[0].volume;
    else{
        var ts=this;
        var callback={'ok':function(fc){
            callback.okf=fc;
        }
        
        };
        var intv= function(step,start,end){
            if(ts[0].paused) ts[0].volume=end;
            else if(VOLUME_DURATION-step*VOLUME_DELTA >= 0){
                
                ts[0].volume=(VOLUME_DELTA*step/VOLUME_DURATION)*(end-start) + start;
                setTimeout(function(){intv(step+1,start,end)},VOLUME_DELTA);
            }
            else{
                ts.fire(VOLUME_E);
                if(callback.okf) callback.okf.call(ts[0]);
            }
        };
        intv(0,ts[0].volume,v);
        return callback;
    }
};



/**
 * 返回已经播放过的部分占总部分的比例
 * @param none
 * @return {string}
 */
fm.prototype._played = function(d) {
    if(d) return this[0].duration-this[0].currentTime;
    return Math.round(this[0].currentTime/this[0].duration * 1000)/10 +'%';
};
/**
 * 获取播放时间情况
 * @param none 
 * @return string
 */
fm.prototype.eta = function() {
    var t2s=function(t){
        var t1=(t/60)-(t/60)%1;
        t1=t1<0?0:t1;
        var t2=Math.floor(t%60);
        return (t1<10?'0'+t1:ts) + ':' + (t2<10?'0'+t2:t2);
    };
    return t2s(this[0].currentTime) +'/' + t2s(this[0].duration);
    
};

/**
 * 立即应用压入队列的操作
 * @param none
 * @return this 
 */
fm.prototype.now = function() {
    return this.dequeue('fm');
};
