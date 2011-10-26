function procnode(func,timeout,retry,delay){
    this.func=func;
    this._timeout=(timeout||0);
    this._retry=(retry||0);
    this.delay=(delay||0);
    this.isTimeout=false;
    this.isFinished=false;
};
procnode.prototype.run=function(parent,d){
    this.parent=parent;
    var ts=this;
    if(this.delay>0 &&(!d)){
       setTimeout(function(){ts.run(parent,1)},this.delay);
    }
    else{
    try{
        if(this._timeout>0) setTimeout(function(){
            ts.timeout()
        },this._timeout);
        this.func.call(this);
    }catch(ex){
        if(this.retry()) throw(ex)
    }
    }

};

procnode.prototype.timeout=function(){
    if(this.isFinished)return;
    if(this.retry()){
        this.isTimeout=true;
        throw(1,'Timeout')
    }
}
procnode.prototype.finish=function(){
    if(this.isTimeout) return;
    this.isFinished=true;
    if(this.parent)
        this.parent.next();
}
procnode.prototype.retry=function(){
    this._retry=this._retry-1;
    if(this._retry>0) this.run(this.parent,1);
    else return true;

}
procnode.prototype.error=function(){
    if(this.retry())throw('error')
}

function proc(){
    this.queue=[];
    this.current=null;
}
proc.prototype.append=function(func,timeout,retry,delay)
{
    this.queue.push(
            new procnode(func,timeout,retry,delay) 
            );
    return this;
}
proc.prototype.wrap=function(ts,func){
    return function(){
        if(ts.isTimeout) return;
        func.call(ts);
        ts.finish();
    }
}
proc.prototype.next=function(){
    if(this.queue.length>0){
        this.current=this.queue.shift();
        this.current.run(this);
    }
}
proc.prototype.run=function(){
    this.next();}
