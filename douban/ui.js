//准备工作
//

//图片延迟加载控制

$('img').live('load',function(){
    $(this).css({'opacity':1});
});


/**
 * ui控制类
 * @param none 
 * @return none
 */
function ui(quickbox) {
    var ts=this;
    this._quickbox=quickbox;
    this._album=quickbox.find('.album');
    this._fm=new fm();
    this._fm.bind(NEXT_S_C_E,
            function(){
                ts._next_s();
            })
    this._fm.bind(AUTH_S_E,
            function(){
                ts._auth_s();
            });
}

this.prototype=$();

/**
 * 下属一首歌回调
 * @param (Event) e
 * @return this
 */
ui.prototype._next_s = function(e) {
    var ts=this;
    return this.queue('ui',function(next){
        if(!ts._quickbox.find('.current').length!=1) ts._quickbox.empty().append('<img class="current"/>'); 
        if(!ts._quickbox.find('.next').length==0) ts._quickbox.append('<img class="next"/>'); 
        if(e.song.picture==this._quickbox.find('.next').attr('src')){
            this._quickbox.find('.current').addClass('hidden');
            this._quickbox.find('.next').addClass('current').removeClass('next');
            setTimeout(function(){
                this._quickbox.find('#album').append(
                    $('<img class="next"/>').attr('src',e.next.picture)
                    .css({'margin-bottom':0})
                    );
                next();
            },400);
        }else{
            this._quickbox.children().css({'opacity':0});
            setTimeout(function(){
                this._quickbox.find('.current').attr('src',e.current.picture);
                this._quickbox.find('.next').attr('src',e.current.picture);
                next();
            },200);
        }
    })
    };
