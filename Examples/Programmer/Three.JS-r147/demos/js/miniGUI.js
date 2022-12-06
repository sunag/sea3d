var miniGUI = { REVISION: '0.1' };

miniGUI.Slide = function(obj){
    this.container = obj.container;
    this.zone = null;
    this.bg = null;
    this.col = null;
    this.pin = null;
    this.txt = null;
    this.name = obj.name || "slider";
    this.color = obj.color || [55,123,167];
    this.id =  obj.id || 0;
    this.x = obj.x || 0;
    this.y = obj.y || 0;
    this.isMove = false;
    this.value = obj.value || 0;
    this.onChange = obj.onChange;

    this.init();
}

miniGUI.Slide.prototype = {
    constructor: miniGUI.Slide,
    init:function(){
        var _this = this;
        this.zone = document.createElement('div');
        this.zone.style.cssText = "position:absolute; left:"+this.x+"px; top:"+this.y+"px; width:120px; height:30px; cursor:pointer;";
        this.zone.id="name";
        this.container.appendChild(this.zone);

        this.bg = document.createElement('div');
        this.bg.style.cssText = "position:absolute; left:10px; top:18px; width:100px; height:4px; pointer-events:none; background-color:rgba(0,0,0,0.1);";
        this.zone.appendChild(this.bg);

        this.col = document.createElement('div');
        this.col.style.cssText = "position:absolute; left:10px; top:18px; width:"+this.value*100+"px; height:4px; pointer-events:none; ";
        this.col.style.backgroundColor = 'rgba('+this.color[0]+','+this.color[1]+','+this.color[2]+',0.5)';
        this.zone.appendChild(this.col);

        this.pin = document.createElement('div');
        this.pin.style.cssText = "position:absolute; left:"+((this.value*100)+10)+"px; top:15px; width:2px; margin-left:-1px; height:10px; pointer-events:none; background-color:#eeeeee;";
        this.zone.appendChild(this.pin);

        this.txt = document.createElement('div');
        this.txt.style.cssText = "position:absolute; left:10px; top:0px; width:120px; height:10px; pointer-events:none; font-size:11px;";
        this.zone.appendChild(this.txt);
        this.txt.textContent = this.name+ ":"+ this.value;

        this.zone.addEventListener('mouseover', function ( e ) { e.preventDefault(); _this.over(e); }, false);
        this.zone.addEventListener('mouseout' , function ( e ) { e.preventDefault(); _this.out(e);  }, false);
        this.zone.addEventListener('mousemove', function ( e ) { e.preventDefault(); _this.move(e); }, false);
        this.zone.addEventListener('mousedown', function ( e ) { e.preventDefault(); _this.isMove = true; _this.move(e); }, false);
        this.zone.addEventListener('mouseup'  , function ( e ) { e.preventDefault(); _this.isMove = false;}, false);
    },
    set:function(v){
        this.value = Math.round(v*100)/100;//v.toFixed(2);
        if(this.value<0)this.value=0;
        if(this.value>1)this.value=1;
        this.col.style.width = this.value*100+"px";
        this.pin.style.left = 10+this.value*100+"px";
        this.txt.textContent = this.name + ":"+ this.value;
    },
    over:function(e, t){
        this.bg.style.backgroundColor = 'rgba(0,0,0,0.5)'; 
        this.col.style.backgroundColor = 'rgba('+this.color[0]+','+this.color[1]+','+this.color[2]+',1)';  
    },
    out:function(e, t){
        this.isMove = false;
        this.bg.style.backgroundColor = 'rgba(0,0,0,0.1)';
        this.col.style.backgroundColor = 'rgba('+this.color[0]+','+this.color[1]+','+this.color[2]+',0.5)';
    },
    move:function(e){
        if(this.isMove){
            this.set((e.clientX-10)/100)
            this.onChange(this.value);
        }
    }
}

miniGUI.OnOff = function(obj){
    this.container = obj.container;
    this.zonen = null;
    this.bg = null;
    this.col = null;
    this.pin = null;
    this.txt = null;
    this.name = obj.name || "onOff";
    this.x = obj.x || 0;
    this.y = obj.y || 0;
    this.value = obj.value || false;
    this.onChange = obj.onChange;

    this.init();
}

miniGUI.OnOff.prototype = {
    constructor: miniGUI.OnOff,
    init:function(){
        var _this = this;
        var tx = "off";
        var p = 0;
        if(this.value){tx = "on"; p = 30;}
        this.zonen = document.createElement('div');
        this.zonen.style.cssText = "position:absolute; left:"+this.x+"px; top:"+this.y+"px; width:120px; height:30px; cursor:pointer;";
        this.container.appendChild(this.zonen);

        this.bg = document.createElement('div');
        this.bg.style.cssText = "position:absolute; left:80px; top:18px; width:30px; height:4px; pointer-events:none; background-color:rgba(0,0,0,0.1);";
        this.zonen.appendChild(this.bg);

        this.col = document.createElement('div');
        this.col.style.cssText = "position:absolute; left:80px; top:18px; width:"+p+"px; height:4px; pointer-events:none; background-color:rgba(55,123,167,0.5);";
        this.zonen.appendChild(this.col);

        this.pin = document.createElement('div');
        this.pin.style.cssText = "position:absolute; left:"+(80+p)+"px; top:15px; width:2px; margin-left:-1px; height:10px; pointer-events:none; background-color:#eeeeee;";
        this.zonen.appendChild(this.pin);

        this.txt = document.createElement('div');
        this.txt.style.cssText = "position:absolute; left:10px; top:0px; width:120px; height:10px; pointer-events:none; font-size:11px;";
        this.zonen.appendChild(this.txt);
        
        this.txt.textContent = this.name+ " "+ tx;

        this.zonen.addEventListener('mouseover', function ( e ) { e.preventDefault(); _this.over(e); }, false);
        this.zonen.addEventListener('mouseout' , function ( e ) { e.preventDefault(); _this.out(e);  }, false);
        this.zonen.addEventListener('mousedown', function ( e ) { e.preventDefault(); _this.click(e); }, false);
    },
    over:function(e){
        this.bg.style.backgroundColor = 'rgba(0,0,0,0.5)'; 
        this.col.style.backgroundColor = 'rgba(55,123,167,1)';  
    },
    out:function(e){
        this.bg.style.backgroundColor = 'rgba(0,0,0,0.1)';
        this.col.style.backgroundColor = 'rgba(55,123,167,0.5)';
    },
    click:function(e){
        var tx = "on"; 
        var p = 30;
        if(this.value){this.value = false; tx = "off"; p=0;}
        else{ this.value = true;}

        this.onChange(this.value);
        this.txt.textContent = this.name + " "+ tx;
        this.col.style.width = p+"px";
        this.pin.style.left = 80+p+"px";
    }
}