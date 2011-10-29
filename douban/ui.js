
/**
 * ui控制类
 * @param none 
 * @return none
 */
function ui(quickbox) {
    var ts=this;
    this._quickbox=$(quickbox);
    this._album=this._quickbox.find('.album');
    this._timeline=$('.timeline div');
    this._eta=$('.eta');
    this._fm=new fm();
    this._fm.bind(NEXT_S_C_E,
            function(e){
                ts._next_s(e);
            })
    this._fm.bind(AUTH_S_E,
            function(e){
                ts._auth_s(e);
            });
    this._interval=setInterval(function(){
        if(!ts._fm[0].paused) {
            ts._timeline.css({'width':ts._fm._played()});
            ts._eta.text(ts._fm.eta());
        }
    },1000);
}

ui.prototype=$();

/**
 * 下属一首歌回调
 * @param (Event) e
 * @return this
 */
ui.prototype._next_s = function(e) {
    var ts=this;
    ts.detail(e.song);
    console.log('e:'+e.next.picture);
    console.log('a:'+ts._album.find('.next').attr('src'));
    if(ts._album.find('.current').length!=1) ts._album.empty().append('<img class="current"/>'); 
    if(ts._album.find('.next').length<1) ts._album.append('<img class="next"/>'); 
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
ui.prototype.detail = function(artist,music,album,year) {
    var ts=this;
    if(typeof(artist)=='object'){
        music=artist.title;
        album=artist.albumtitle;
        year=artist.public_time;
        artist=artist.artist;
    }
    $('.eta,.detail').css({'opacity':0});
    setTimeout(function(){
        $('.artist').text(artist);
        $('.album_title').text(album);
        $('.album_year').text(year);
        $('.music_title').text(music);
        $('.eta,.detail').css({'opacity':1});
    },400)
};

/**
 * 认证成功的回调
 * @param {event} e
 * @return this
 */
fm.prototype._auth_s = function(e) {
    return this;
};
