#include <Foundation/Foundation.h>

#define HTML_HEAD @"\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">\n\
<head>\n\
<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\n\
"

#define HTML_STYLE_LINK @"<link rel=\"stylesheet\" type=\"text/css\" href=\"theme.css\" />\n"

#define HTML_JS_LINK @"<script type=\"text/javascript\" src=\"lgz_javascript.js\"></script>\n"

#define HTML_STYLE @" \
html {-webkit-text-size-adjust: none;}\n\
.defination { color: DEFINE; font-style: italic; }\n\
.comment { color: COMENT; font-style: italic; }\n\
.header { color: HEADER; }\n\
.string { color: STRING; }\n\
.keyword { color: KEYWRD; }\n\
.other { color: -OTHER-; }\n\
.function { color: -FUNCTION-COLOR-; font-size: --FONT_FUNCTION_SIZE--px; font-style: italic;}\n\
.system { color: #774499; }\n\
.number { color: --NUMBER--; }\n\
.fold { font-style: italic; }\n\
.fold_comments { font-style: italic; }\n\
\
body {\n\
background:-BGCOL-;\n\
}\n\
\
table.code {\n\
 font-family: FONT_FAMILY;\n\
 font-size: FONT_SIZEpx;\n\
 table-layout: fixed;\n\
 -webkit-border-vertical-spacing: 0px\n\
}\n\
\
.highlight{background:green;font-weight:bold;color:white;} \n\
\
table.code tbody th {\n\
 text-align: right;\n\
 vertical-align: top;\n\
 margin:0px;\n\
}\n\
table.code tbody th :link, table.code tbody th :visited {\n\
 color: --LINENUMBER--;\n\
}\n\
table.code td {\n\
 padding: 1px 2px;\n\
 color: #808080;\n\
 vertical-align: top;\n\
}\n\
a {\n\
color: inherit;\n\
text-decoration: none;\n\
}\n\
pre {\n\
margin:0px;\n\
}\n\
.linenumber{\n\
 border-right: solid;\n\
 border-color:--LINENUMBER--;\n\
 display:--DISPLAYLINENUM--;\n\
}\n\
"

#define HTML_HEAD_END @"</head>\n"

#define HTML_BODY_START @"<body>\n\
<table class=\"code\"><tbody>\
"

#define HTML_LINE_START @"<tr id=\"L%d\"><th class=\"linenumber\"><a href=\"lgz_comment:%d\"><pre>%d</pre></a></th><th><a href=\"lgz_fold__*&^\" class=\"fold\"><pre> </pre></a></th><td><pre>"

#define HTML_LINK @"<a href=\"%@=%@\" class=\"%@\" style=\"text-decoration: none\">"
#define HTML_LINK_END @"</a>"

#define HTML_LINE_END @"</pre></td></tr>\n"

#define HTML_END @"</tbody></table> \n\
</body>\n\
</html>\n\
"

#define HTML_COMMENT_START @"<span class=\"comment\">"

#define HTML_HEADER_START @"<span class=\"header\">"

#define HTML_STRING_START @"<span class=\"string\">"

#define HTML_KEYWORD_START @"<span class=\"keyword\">"

#define HTML_OTHER_WORD @"<span class=\"other\" onmousedown=\"mousedown(this);\">"

#define HTML_FUNCTION_WORD @"<span class=\"function\" onmousedown=\"mousedown(this);\">"

#define HTML_SYSTEM_START @"<span class=\"system\">"

#define HTML_UNKNOWN_LINE @"<span class=\"other\">%@</span>"

#define HTML_NUMBER_START @"<span class=\"number\">"

#define HTML_SPAN_END @"</span>"

#define HTML_ENTER @"\n"

#define HTML_BLANK @" "

#define HTML_IMAGE @"<br><br><br><img src=\"%@\"/>"

