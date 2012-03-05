var returnArray = new Array();
var index = 0;
function addResult(id, count)
{
    if (index == 0)
        smoothScroll(id);
    //for (i=0; i<count; i++)
        returnArray[index++] = id;
}
function encode(s){ 
    return  s.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/([\\\.\*\[\]\(\)\$\^])/g,"\\$1"); 
} 
function decode(s){ 
    return  s.replace(/\\([\\\.\*\[\]\(\)\$\^])/g,"$1").replace(/&gt;/g,">").replace(/&lt;/g,"<").replace(/&amp;/g,"&"); 
} 
function highlight(s){ 
    returnArray.splice(0, returnArray.length);
    index = 0;
    if (s.length==0){ 
        
    } 
    s=encode(s); 
    var obj=document.getElementsByTagName("tbody")[0]; 
    var t=obj.innerHTML.replace(/<span\s+class=.?highlight.?>([^<>]*)<\/span>/gi,"$1"); 
    obj.innerHTML=t; 
    var cnt=loopSearch(s,obj); 
    t=obj.innerHTML
    var r=/{searchHL}(({(?!\/searchHL})|[^{])*){\/searchHL}/g 
    t=t.replace(r,"<span class='highlight'>$1</span>"); 
    obj.innerHTML=t; 
    return cnt;
} 

function highlight_this_line_keyword(line, s){
    s=encode(s); 
    var obj=document.getElementsByTagName("tbody")[0]; 
    obj = document.getElementById(line);
    var cnt=loopSearch(s,obj); 
    t=obj.innerHTML 
    var r=/{searchHL}(({(?!\/searchHL})|[^{])*){\/searchHL}/g 
    t=t.replace(r,"<span class='highlight'>$1</span>"); 
    obj.innerHTML=t; 
    return cnt;
}

function currentYPosition() {
    // Firefox, Chrome, Opera, Safari
    if (self.pageYOffset) 
        return self.pageYOffset;
    return 0;
}

function elmYPosition(eID) {
    var elm = document.getElementById(eID);
    var y = elm.offsetTop;
    var node = elm;
    while (node.offsetParent && node.offsetParent != document.body) {
        node = node.offsetParent;
        y += node.offsetTop;
    } return y;
}

function smoothScrollToPosition(stopPosition)
{
    var startY = currentYPosition();
    var stopY = stopPosition;
    if (stopY < 0)
        stopY = 0;
    var distance = stopY > startY ? stopY - startY : startY - stopY;
    if (distance == 0)
        return;
    if (distance < 100) {
        scrollTo(0, stopY); 
        return;
    }
    if (distance > 1000){
        scrollTo(0, stopY); 
        return;
    }
    var speed = Math.round(distance / 1000);
    //if (speed >= 20) speed = 20;
    var step = Math.round(distance / 5);
    var leapY = stopY > startY ? startY + step : startY - step;
    var timer = 0;
    if (stopY > startY) {
        for ( var i=startY; i<stopY; i+=step ) {
            setTimeout("window.scrollTo(0, "+leapY+")", timer * speed);
            leapY += step; if (leapY > stopY) leapY = stopY; timer++;
        } return;
    }
    for ( var i=startY; i>stopY; i-=step ) {
        setTimeout("window.scrollTo(0, "+leapY+")", timer * speed);
        leapY -= step; if (leapY < stopY) leapY = stopY; timer++;
    }
}

function smoothScroll(eID) {
    var stopY = elmYPosition(eID) - 200;
    scrollTo(stopY);
    //smoothScrollToPosition(stopY);
}

function gotoLine(i)
{
    smoothScroll(returnArray[i]);
}

function loopSearch(s,obj){ 
    var cnt=0; 
    var temp = 0;
    if (obj.nodeType==3){ 
        cnt=replace(s,obj); 
        return cnt; 
    } 
    var id="";
    for (var i=0,c;c=obj.childNodes[i];i++){ 
        id = c.id;
        if (!c.className||c.className!="highlight") 
        {
            temp =loopSearch(s,c); 
            if (temp>0 && id != undefined && id != "")
                addResult(id, temp);
            cnt+=temp;
        }
    } 
    return cnt; 
} 
function replace(s,dest){ 
    var r=new RegExp(s,"g"); 
    var tm=null; 
    var t=dest.nodeValue; 
    var cnt=0; 
    if (tm=t.match(r)){ 
        cnt=tm.length; 
        t=t.replace(r,"{searchHL}"+decode(s)+"{/searchHL}") 
        dest.nodeValue=t; 
    } 
    return cnt; 
}

function mousedown(obj)
{
    var tmp = "lgz_redirect:";
    tmp = tmp + obj.textContent;
    window.location = tmp;
}

function bodyHeight()
{
    return document.body.scrollHeight;
}