document.onreadystatechange=function()
{
    if(document.readyState == 'interactive'){
        var value = (new Date()).valueOf();
        var css = document.getElementsByTagName('link')[0].getAttribute('href');
        css = css + '?v=' + value;
        document.getElementsByTagName('link')[0].setAttribute('href',css);
        document.body.style.webkitTouchCallout='none';        
    }
}

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
    while (1) {
        var objs = document.getElementsByClassName('highlight');
        if (objs.length != 0) {
            var childs = objs[0].parentNode.childNodes;
            var i=0;
            for (i=0; i<childs.length; i++) {
                if (childs[i] == objs[0]){
                    childs[i].outerHTML = objs[0].innerText;
                }
            }
        } else {
            break;
        }
    }
}

function highlight_this_line_keyword(line, s, color){
    s=encode(s);
    var obj = document.getElementById(line);
    var cnt=loopSearch(s,obj);
    var t=obj.innerHTML;
    if (cnt > 0) {
        var r=/{searchHL}(({(?!\/searchHL})|[^{])*){\/searchHL}/g
        if (color === undefined || color === null) {
            t=t.replace(r,"<span class='highlight'>$1</span>");
        } else {
            t=t.replace(r,"<span class='highlight' style='background:" + color + "'>$1</span>");
        }
        obj.innerHTML=t;
    } else {
        // CLear highlights
        while(1) {
            var objs = obj.getElementsByClassName('highlight');
            var index = 0;
            for (index=0; index<objs.length; index++) {
                if (objs[index].innerText == s) {
                    break;
                }
            }
            if (index >= objs.length) {
                break;
            }
            
            var childs = objs[index].parentNode.childNodes;
            var i = 0;
            for (i=0; i<childs.length; i++) {
                if (childs[i] == objs[index] && s == childs[i].innerText){
                    childs[i].outerHTML = objs[index].innerText;
                }
            }
        }
    }
    return cnt;
}

document.addEventListener('touchstart', function(event) {
    window.location.href= "lgz_touch_start";
    clearPreTouches();
}, false);

var preTouches = new Array();
var touchMode = 0;

var TouchPoint = {
    clientX:0,
    clientY:0
};

function clearPreTouches() {
    preTouches.pop();
    preTouches.pop();
    touchMode = 0;
}

document.addEventListener('touchmove', function(event) {
    if (event.touches.length == 2)
    {
        event.preventDefault();
        if (preTouches.length == 0) {
            var touch0 = Object.create(TouchPoint);
            var touch1 = Object.create(TouchPoint);
            touch0.clientX = event.touches[0].clientX;
            touch0.clientY = event.touches[0].clientY;
            touch1.clientX = event.touches[1].clientX;
            touch1.clientY = event.touches[1].clientY;
            preTouches.push(touch0);
            preTouches.push(touch1);
            return;
        }
        
        var touch0 = event.touches[0];
        var touch1 = event.touches[1];
		
		var finger0DistX = touch0.clientX - preTouches[0].clientX;
		var finger1DistX = touch1.clientX - preTouches[1].clientX;
		
        if (touchMode != 1 && finger0DistX*finger1DistX>0) {
            var value = "lgz_multi_touch_start:"+touch0.clientX;
            window.location.href = value;
            touchMode = 2;
			return;
        }
        
        var distX = preTouches[1].clientX-preTouches[0].clientX;
        var distY = preTouches[1].clientY-preTouches[0].clientY;
        var distPre = ~~Math.sqrt(distX*distX + distY*distY);
        
        distX = touch0.clientX-touch1.clientX;
        distY = touch0.clientY-touch1.clientY;
        var distNow = ~~Math.sqrt(distX*distX + distY*distY);
		
        if (touchMode != 2 && Math.abs(distPre-distNow) > 5) {
            var value = "lgz_font_size_change:"+(distNow-distPre);
            window.location.href = value;
            touchMode = 1;
            return;
        }
    }
}, false);

document.addEventListener('touchend', function(event) {
    if (touchMode != 0) {
        window.location.href= "lgz_touch_end";
        clearPreTouches();
    }
}, false);

document.addEventListener('touchcancel', function(event) {
    if (touchMode != 0) {
        window.location.href= "lgz_touch_end";
        clearPreTouches();
    }
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

function randomColor() {
    var color = Math.round(Math.random() * 0xffffff);
    
    color = "00000"+color.toString(16);
    
    color = color.substring(color.length - 6);
    
    return '#' + color;
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
    var color = randomColor();
    for (i=0; i<lineArray.length; i++) {
        lineID = lineArray[i];
        highlight_this_line_keyword(lineID, s, color);
        obj = document.getElementById(lineID);
        if (returnVal == -1)
        {
            if (curY <= elmYPosition(lineID))
                returnVal = i;
        }
    }
    return returnVal;
}

function deFocusLine(eID) {
    eID.style.backgroundColor = document.body.background;
}

function FocusLine(eID) {
    var obj = document.getElementById(eID);
    obj.style.backgroundColor = 'yellow';
    setTimeout("deFocusLine("+eID+")", 500);
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
    
    var tbody=document.getElementsByTagName("tbody")[0];
    var trList = tbody.getElementsByTagName("tr");
    
    var tagStartIndex;
    for (tagStartIndex = start-1; tagStartIndex<trList.length; tagStartIndex++)
    {
        if (trList[tagStartIndex].id == 'L'+start)
            break;
    }
    if (tagStartIndex == trList.length)
    {
        alert("Source Parse Error, Please reparse it");
        return;
    }
    var tagEndIndex;
    for (tagEndIndex = end-1; tagEndIndex<trList.length; tagEndIndex++)
    {
        if (trList[tagEndIndex].id == 'L'+end)
            break;
    }
    if (tagEndIndex == trList.length)
    {
        alert("Source Parse Error, Please reparse it");
        return;
    }
    
    var i;
    for (i = tagStartIndex; i<=tagEndIndex; i++)
    {
        //        var id = 'L';
        //        id += i;
        trList[i].style.display = 'table-row';
        //document.getElementById(id).style.display = 'table-row';
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
    var tbody=document.getElementsByTagName("tbody")[0];
    var trList = tbody.getElementsByTagName("tr");
    
    var tagStartIndex = start;
    for (tagStartIndex = start-1; tagStartIndex<trList.length; tagStartIndex++)
    {
        if (trList[tagStartIndex].id == 'L'+start)
            break;
    }
    if (tagStartIndex == trList.length)
    {
        alert("Source Parse Error, Please reparse it");
        return;
    }
    var tagEndIndex;
    for (tagEndIndex = end-1; tagEndIndex<trList.length; tagEndIndex++)
    {
        if (trList[tagEndIndex].id == 'L'+end)
            break;
    }
    if (tagEndIndex == trList.length)
    {
        alert("Source Parse Error, Please reparse it");
        return;
    }
    
    var i;
    for (i = tagStartIndex; i<=tagEndIndex; i++)
    {
        //        var id = 'L';
        //        id += i;
        //        document.getElementById(id).style.display = 'none';
        trList[i].style.display = 'none';
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
    th1.className = "linenumber";
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

function showComment(trID, comment)
{
    var trObj = document.getElementById('L'+trID);
    var tbody=document.getElementsByTagName("tbody")[0];
    //remove pre comment
    var preComment = document.getElementById(trID+"-comment");
    if (preComment)
    {
        tbody.removeChild(preComment);
        if (comment.length == 0)
            return;
    }
    
    var row = document.createElement("tr");
    row.id = trID+"-comment";
    var th1 = document.createElement("th");
    //    //th1.appendChild(document.createTextNode(" "));
    var th2 = document.createElement("th");
    //    //th2.appendChild(document.createTextNode(" "));
    var td1 = document.createElement("td");
    comment = comment.replace(/lgz_br_lgz/ig, '\n');
    var textNode = document.createTextNode(comment);
    var divNode = document.createElement("div");
    divNode.style.backgroundColor = 'yellow';
    divNode.style.color = 'black';
    divNode.appendChild(textNode);
    divNode.setAttribute("onclick","window.location='lgz_comment:"+trID+"'");
    td1.appendChild(divNode);
    td1.style.border = '1px solid yellow';
    row.appendChild(th1);
    row.appendChild(th2);
    row.appendChild(td1);
    tbody.insertBefore(row, trObj.nextSibling);
}

function addTablePadding(value) {
    var tbody=document.getElementsByTagName("table")[0];
    tbody.style.paddingTop=value;
    tbody.style.paddingBottom=value;
}

function removeTablePadding() {
    var tbody=document.getElementsByTagName("table")[0];
    tbody.style.paddingTop="0px";
    tbody.style.paddingBottom="0px";
}

function autoFold() {
    var folds = document.getElementsByClassName("fold_comment");
    var i = 0;
    for (i=0; i<folds.length; i++) {
        var item = folds[i];
        var test = item.attributes[0].nodeValue;
        test = test.replace("lgz_fold_", "");
        var array = test.split(":");
        hideLines(array[0], new Number(array[1]), new Number(array[2]));
    }
}
