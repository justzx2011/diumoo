
/**
 * ui控制类
 * @param none 
 * @return none
 */
function ui(q,m) {
    var ts=this;
    this._album=$('.album');
    this._timeline=$('.timeline div');
    this._eta=$('.eta');
    this.bind(NEXT_S_C_E,
            function(e){
                ts._next_s(e);
                //window.domi.signal_('newsong');
                
            })
    this.bind(AUTH_S_E,
            function(e){
                $('#user_name').text(ts._auth.user_info.name);
                $('#liked').text(ts._auth.user_info.play_record.liked)
                $('#played').text(ts._auth.user_info.play_record.played)
                $('#baned').text(ts._auth.user_info.play_record.banned)
                $('#user_info').css({'opacity':1});
                //window.domi.signal_('auth_success');
            });
    $('.next,.next_button').live('click',function(){
        ts.next().now();
    });
    this.bind(PLAY_E,function(){
        $('.pause').addClass('play');
        //window.domi.signal_('play');
    })

    this.bind(PAUSE_E,function(){
        $('.pause').removeClass('play');
        //window.domi.signal_('pause');
    })

    this.bind('error',function(e){
        //window.domi.error_(e.error_id);
    });

    $('.pause').click(function(){
        if($(this).hasClass('play')) ts.pause().now();
        else ts.play().now();
    });
    $('.likecontrol').click(function(){
        if(ts._auth && ts._auth.r==0){
            var tts=$(this);
            if($(this).hasClass('liking'))
            ts.unrate().prog(function(){
               tts.removeClass('liking').addClass('like');
               $('#liked').text(parseInt($('#liked').text())>0?(parseInt($('#liked').text())-1):0);
            }).now();
            else ts.rate().prog(function(){
                tts.removeClass('like').addClass('liking');
               $('#liked').text(parseInt($('#liked').text())+1);
            }).now();
        }
    });
    this._interval=setInterval(function(){
        if(!ts[0].paused) {
            ts._timeline.css({'width':ts._played()});
            ts._eta.text(ts.eta());
        }
        if(ts._played(true)<1){
            ts.next(true).now();
            //window.domi.signal_('ended');
        }
    },1000);


    ts.error(function(e){
        var pg=$('#prog');
        if(e.error_id==NETWORK) pg.text('发生网络错误');
        else if(e.error_id==AUTH_FAILED) pg.text('认证失败!').append('<a onclick="startInitialize(true);">跳过</a>');
        else pg.text('发生未知错误，程序已终止');
        pg.append('<a onclick="window.domi.reload()">重试</a>').addClass('error');
    })

}

ui.prototype=new fm();

/**
 * 下属一首歌回调
 * @param (Event) e
 * @return this
 */
ui.prototype._next_s = function(e) {
    var ts=this;
    ts.detail(e.song);
    $('#played').text(parseInt($('#played').text())+1);
    if(ts._album.find('.current').length!=2) ts._album.empty().append('<img class="current"/>'); 
    if(ts._album.find('.next').length<2) ts._album.append('<img class="next"/>'); 
    if(e.song.picture==ts._album.find('.next').attr('src')){
        ts._album.find('.current').removeClass('show').addClass('hidden');
        ts._album.find('.next').addClass('current').removeClass('next');
        setTimeout(function(){
            ts._album.append(
                $('<img class="next"/>')
                .one('load',function(){
                    $(this).addClass('show');
                })
                .attr('src',e.next.picture)
                );
            ts._album.find('.hidden').remove();
        },400);
    }else{
        ts._album.children().removeClass('show');
        setTimeout(function(){
            ts._album.children()
            .one('load',
                function(){
                    $(this).addClass('show');
                })
        ts._album.find('.current')
            .attr('src',e.song.picture)
            ts._album.find('.next')
            .attr('src',e.next.picture)
        },400);
    }

    return this;
};

/**
 * 设定歌曲和唱片集信息
 * @param {string} artist,{string} music,{string} album,{number} year
 * @return this
 */
ui.prototype.detail = function(artist,music,album,year,like) {
    var ts=this;
    if(typeof(artist)=='object'){
        music=artist.title;
        album=artist.albumtitle;
        year=artist.public_time;
        like=artist.like;
        rating=Math.round(parseFloat(artist.rating_avg)*10)/10;
        artist=artist.artist;
    }
    $('.eta,.detail,.rate').css({'opacity':0});
    setTimeout(function(){
        $('.artist').text(artist);
        $('.album_title').text(album);
        $('.album_year').text(year);
        $('.music_title').text(music);
        $('.rate').text(rating);
        $('.eta,.detail,.rate').css({'opacity':1});
        if(like=='1') $('.like').removeClass('like').addClass('liking');
        else $('.liking').removeClass('liking').addClass('like');
    },400)
};

ui.prototype.channel = function(n){
    if(typeof(n)=='number'){
        this._channel=n;
        this._playlist.length=0;
        this._next=null;
        this.next().now();
    }

}
ui.prototype.prog=function(t,d,e,c){
    var ts=this;
    return this.queue('fm',
            function(next){
                if(typeof(t)=='function'){ 
                    var r=t.call(ts);
                    if(r){
                        $('#prog').text((e||"发生错误，程序已中断")).append(
                                "<a onclick='window.domi.reload();'>重试</a>"
                            ).addClass('error')
                            return;
                    }
                }
                else $('#prog').text(t);
                if(d>100) setTimeout(next,d);
                else next();
            }
            );
}

/**
 * 开始初始化音乐播放
 * @param {none} 
 * @return none
 */

_U=null;

function startInitialize(d) {
    _U=new ui();
    if(d) {$('#prog').removeClass();_U.now();return}
    _U.prog('开始认证')
      .prog(function(){
           _U._auth_key=eval(window.domi.authKey());
      })
        .auth(d) 
      .prog('认证成功',200)
      .next()
      .prog('准备就绪',200)
      .prog(function(){
          $('#onlaunch').css({'top':-120});
          try{window.domi.ready();}catch(e){return};
      })
      .now();
};

/**
 * 切换到tiny模式的回调
 * @param {bool} show
 * @return 
 */
function tiny(show) {
    if(show) $('#quickbar').addClass('show');
    else $('#quickbar').removeClass('show');
}

function exit()
{
    _U.queue('fm').length=0;
    _U.pause().prog(
                function(){
                    window.domi.exit_(true);
                }
            ).now();
}

function channel(c)
{
    _U.queue('fm').length=0;
    _U.channel(c).now();
}
