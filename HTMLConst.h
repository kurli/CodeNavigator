#include <Foundation/Foundation.h>

#define HTML_HEAD @"\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">\n\
<head>\n\
<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\n\
"

#define HTML_STYLE_LINK @"<link rel=\"stylesheet\" type=\"text/css\" href=\"theme.css?v=1\" />\n"

#define HTML_JS_LINK @"<script type=\"text/javascript\" src=\"lgz_javascript.js\"></script>\n"

#define HTML_STYLE @" \
.defination { color: DEFINE; font-style: italic; }\n\
.comment { color: COMENT; font-style: italic; }\n\
.header { color: HEADER; }\n\
.string { color: STRING; }\n\
.float { color: #996600; }\n\
.int { color: #999900; }\n\
.bool { color: #000000; font-weight: bold; }\n\
.type { color: #FF6633; }\n\
.flow { color: #FF0000; }\n\
.keyword { color: KEYWRD; }\n\
.other { color: -OTHER-; }\n\
.operator { color: #663300; font-weight: bold; }\n\
\
body {\n\
background:-BGCOL-;\n\
}\n\
\
table.code {\n\
 border-spacing: 0;\n\
 border-top: 0;\n\
 border-collapse: collapse; \n\
 empty-cells: show;\n\
 font-size: FONT_SIZEpx;\n\
 line-height: 130%;\n\
 padding: 0;\n\
 table-layout: fixed;\n\
}\n\
\
.highlight{background:green;font-weight:bold;color:white;} \n\
\
table.code tbody th {\n\
 background: #-BGCOL-;\n\
 color: #886;\n\
 font-weight: normal;\n\
 padding: 0 .5em;\n\
 text-align: right;\n\
 vertical-align: top;\n\
}\n\
table.code tbody th :link, table.code tbody th :visited {\n\
 border: none;\n\
 color: #886;\n\
 text-decoration: none;\n\
}\n\
table.code tbody th :link:hover, table.code tbody th :visited:hover {\n\
 color: #000;\n\
}\n\
table.code td {\n\
 font: bold FONT_SIZEpx monospace;\n\
 overflow: none;\n\
 padding: 1px 2px;\n\
 vertical-align: top;\n\
 background: -BGCOL-;\n\
 font-weight: bold;\n\
 color: #808080;\n\
 -webkit-user-select: text;\n\
 padding-right: 20px;\n\
}\n\
"

#define HTML_HEAD_END @"</head>\n"

#define HTML_BODY_START @"<body><pre>\n\
<table class=\"code\"><tbody>\
"

#define HTML_LINE_START @"<tr id=\"L%d\"><th><a href=\"#L%d\">%d</a></th><td>    "

#define HTML_LINK @"<a href=\"%@=%@\" class=\"%@\" style=\"text-decoration: none\">"
#define HTML_LINK_END @"</a>"

#define HTML_LINE_END @"</td></tr>\n"

#define HTML_END @"</tbody></table> \n\
</pre>\n\
</body>\n\
</html>\n\
"

#define HTML_COMMENT_START @"<span class=\"comment\">"

#define HTML_HEADER_START @"<span class=\"header\">"

#define HTML_STRING_START @"<span class=\"string\">"

#define HTML_KEYWORD_START @"<span class=\"keyword\">"

#define HTML_OTHER_WORD @"<span class=\"other\" onmousedown=\"mousedown(this);\">"

#define HTML_UNKNOWN_LINE @"<span class=\"other\">%@</span>"

#define HTML_SPAN_END @"</span>"

#define HTML_ENTER @"\n"

#define HTML_BLANK @"\n"
