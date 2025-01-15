# findlines
Find all lines or multi-line paragraphs containing a set of strings in filtered files of current folder
and its subfolders, in a simple way for most common usage, without need of complex regular expressions.

### USAGE:

  fl [-i] [-p=N] [-w] [pathstr|/pathstr]* str [+|-|++|-- str]*

### DESCRIPTION:

  The goal of this linux sh script is to simply and quickly display all the lines or multi-line paragraphs
  matching the str parameters in all the files being filtered by the pathstr parameters:
  see below examples.  
  Special characters (like *, +, |, :, ...) are explicitly searched (they are not interpreted
  as in regular expressions which may be complex to use): they are applied as provided in str
  parameters.  
  Binary files contents are also searched, so that as many matching lines as possible are
  displayed at the end and no occurrence is missed.

### OPTIONS:

  -i: ignore lower/upper case during the search  
  -p=N: consider paragraphs of 2N+1 lines during the search (N >= 1) instead of line
      by line search (2N+1 = N lines before first str matching line + first str
      matching line + N lines after first str matching line)  
  -w: first str to find shall be a whole word (word-constituent characters are letters,
      digits and underscore)

### EXAMPLES:

  fl str  
  => find all lines containing str in all files of current folder and its subfolders
    
  fl .c str  
  => find all lines containing str in the .c files of current folder and its subfolders
    
  fl .c .h str1 + str2 - str3  
  => find all lines containing str1 and str2 and not str3 in the .c and .h files
       of current folder and its subfolders
       
  fl .c .h str1 ++ str2 -- str3  
  => find all lines containing str1 and then str2 and then not str3 in the .c and .h files
       of current folder and its subfolders

  fl .c /pathstr str  
  => find all lines containing str in the .c files of current folder and its subfolders
       whose path does not contain pathstr (/pathstr excludes, pathstr/ would include,
       pathstr can refer to file and/or folder names)
       
  fl -i .c str  
  => find all lines containing str in the .c files of current folder and its subfolders
       with lower/upper case ignored
       
  fl -w .c str  
  => find all lines containing the whole word "str" in the .c files of current folder
       and its subfolders
       
  fl -p=1 .c str1 + str2  
  => find all 3-lines long paragraphs containing str1 and str2 in the .c files
       of current folder and its subfolders

Special characters can be searched directly, for example fl "if (a*b+[(x/y)-z] || d == e) {" will search exactly this string without need to escape
the special characters.  
Exception: linux shell \$ and \\ special characters shall be escaped with \\\$ and \\\\, for example fl "\\\\xxx\\\$" will search all lines containing "\\xxx\$" in files.  
Special characters can also be searched directly with their ASCII code, for example fl \$'\x09' will search tab characters (\t) in all files.

