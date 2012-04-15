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
        return;
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

function clearHighlight() {
    var obj=document.getElementsByTagName("tbody")[0]; 
    var t=obj.innerHTML.replace(/<span\s+class=.?highlight.?>([^<>]*)<\/span>/gi,"$1"); 
    obj.innerHTML=t;
}

function highlight_this_line_keyword(line, s){
    s=encode(s); 
    var obj = document.getElementById(line);
    var cnt=loopSearch(s,obj); 
    t=obj.innerHTML 
    var r=/{searchHL}(({(?!\/searchHL})|[^{])*){\/searchHL}/g 
    t=t.replace(r,"<span class='highlight'>$1</span>"); 
    obj.innerHTML=t; 
    return cnt;
}

document.addEventListener('touchstart', function(event) {
    window.location.href= "lgz_touch_start";
}, false);

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

function highlight_keyword_by_lines(lines, s)
{
    // input as "L0,L1,L2..."
    var lineArray = lines.split(",");
    var i;
    var lineID;
    var obj;
    var curY = currentYPosition();
    var returnVal = -1;
    for (i=0; i<lineArray.length; i++) {
        lineID = lineArray[i];
        highlight_this_line_keyword(lineID, s);
        obj = document.getElementById(lineID);
        if (returnVal == -1)
        {
             if (curY <= elmYPosition(lineID))
                 returnVal = i;
        }
    }
    return returnVal;
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
//    var stopY = elmYPosition(eID) - 200;
//    scrollTo(0, stopY);
    var str = "#"+eID;
    if (window.location.hash == str)
    {
        window.location.hash = 0;
        window.location.hash = str;
    }
    else
        window.location.hash = str;
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


function showLines(start, end)
{
    var startID = 'L';
    startID = startID + start;
    var endID = 'L';
    endID = endID + end;
    var i = start;
    for (i = start; i<=end; i++)
    {
        var id = 'L';
        id += i;
        document.getElementById(id).style.display = 'table-row';
    }
    var rowID = '';
    rowID +=start;
    rowID += '-';
    rowID += end;
    var rowElem = document.getElementById(rowID);
    
    var tbody=document.getElementsByTagName("tbody")[0]; 
    tbody.removeChild(rowElem);
}

function hideLines(token, start,end)
{
    var startID = 'L';
    startID = startID + start;
    var endID = 'L';
    endID = endID + end;
    var i = start;
    for (i = start; i<=end; i++)
    {
        var id = 'L';
        id += i;
        document.getElementById(id).style.display = 'none';
    }
    
    var id = 'L';
    id += end;
    var element = document.getElementById(id);
    
    var tbody=document.getElementsByTagName("tbody")[0]; 
    var row = document.createElement("tr");
    var rowID = '';
    rowID +=start;
    rowID += '-';
    rowID += end;
    row.id = rowID;
    
    var th1 = document.createElement("th");
    th1.appendChild(document.createTextNode("*"));
    var th2 = document.createElement("th");
    th2.appendChild(document.createTextNode("+"));
    var td1 = document.createElement("td");
    
    var startContent = document.getElementById(startID);
    var startTD = startContent.childNodes[2];
    var content = startTD.textContent;
    i = content.search(token);
    var subStr = content.substring(0, i);    
    subStr += "{......}";
    var textNode = document.createTextNode(subStr);
    var divNode = document.createElement("div");
    divNode.appendChild(textNode);

    divNode.setAttribute("onclick","showLines("+start+",'"+end +"')");
    th2.setAttribute("onclick","showLines("+start+",'"+end +"')");
    
    td1.appendChild(divNode);
    td1.style.border = '1px solid yellow';
    
    row.appendChild(th1);
    row.appendChild(th2);
    row.appendChild(td1);
    tbody.insertBefore(row, element.nextSibling);
}
