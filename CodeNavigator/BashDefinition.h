//
//  BashDefinition.h
//  CodeNavigator
//
//  Created by Guozhen Li on 3/30/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#ifndef CodeNavigator_BashDefinition_h
#define CodeNavigator_BashDefinition_h


#define COMMENTS_SINGLE @"#"

#define COMMENTS_MULTI @"(*&^&*&^^"

#define COMMENTS_MULTI_END @"**&&**))*&^"

#define BRACE_START @"{"

#define BRACE_END @"}"

#define KEYWORD_BASH @"break case continue do done elif else eq fi for function ge gt if in le lt ne return then until while"

#define KEYWORD_COMMANDS @"Wget alias apropos awk bash bc bg builtin bzip2 cal cat cd cfdisk chgrp chmod chown chroot cksum clear cmp comm command cp cron crontab csplit cut date dc dd ddrescue declare dfdiff diff3 dig dir dircolors dirname dirs du echo egrep eject enable env ethtool eval exec exit expand export expr false fdformat fdisk fg fgrep file find fmt fold format free fsck ftp gawk getopts grep groups gzip hash head history hostname id ifconfig import install join kill less let ln local locate logname logout look lpc lpr lprint lprintd lprintq lprm ls lsof make man mkdir mkfifo mkisofs mknod more mount mtools mv netstat nice nl nohup nslookup op open passwd paste pathchk ping popd pr printcap printenv printf ps pushd pwd quota quotacheck quotactl ram rcp read readonly remsync renice rm rmdir rsync scp screen sdiff sed select seq set sftp shift shopt shutdown sleep sort source split ssh strace su sudo sum symlink sync tail tar tee test time times top touch tr traceroute trap true tsort tty type ulimit umask umount unalias uname unexpand uniq units unset unshar useradd usermod users uudecode uuencode v vdir vi watch wc whereis which who whoami xargs yes"

#define PREPROCESSOR nil

#define PREPROCESSOR_HEADER @"**&&**))*&^"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"

#endif
