" Script Name: signmarks.vim
" Description: manage/show and save/restore marks and signs.
" -Unlimited marks by making use of the vim signs (aka here as unnamed marks).
" -Save and restore the marks/signs.
" -Handy to mark lines on large logs to navigate the log and to show the marksk
"  on a separed quickfix/window.
"
" Copyright:   (C) 2021-2022
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:  <javierpuigdevall@gmail.com>
"
" Dependencies: 
"

if !has('signs')
  finish
endif

"- Common functions -------------------------------------------------------------------

" Get the plugin reload command
function! signmarks#Reload()
    let l:pluginPath = substitute(s:plugin_path, "autoload", "plugin", "")
    let l:autoloadFile = s:plugin_path."/".s:plugin_name
    let l:pluginFile = l:pluginPath."/".s:plugin_name
    return "silent! unlet w:SignMarks_done | silent unlet loaded_signmarks | so ".l:autoloadFile." | so ".l:pluginFile." | silent let loaded_signmarks"
endfunction


" Edit plugin files
" Cmd: Smedit
function! signmarks#Edit()
    let l:plugin = substitute(s:plugin_path, "autoload", "plugin", "")
    silent exec("tabnew ".s:plugin)
    silent exec("vnew   ".l:plugin."/".s:plugin_name)
endfunction


function! s:Initialize()
    let s:verbose = 0
    "call signmarks#AutoConfigInit()
endfunction


function! s:Error(mssg)
    echohl ErrorMsg | echom "[".s:plugin."] ".a:mssg | echohl None
endfunction


function! s:Error(mssg)
    echohl ErrorMsg | echom "[".s:plugin."] ".a:mssg | echohl None
endfunction


function! s:Warn(mssg)
    echohl WarningMsg | echom a:mssg | echohl None
endfunction


function! s:EchoGreen(normalStr1, orangeStr, normalStr2)
    echon a:normalStr1
    echohl DiffAdd | echon a:orangeStr | echohl None
    echo a:normalStr2
endfunction

function! s:EchoOrange(normalStr1, orangeStr, normalStr2)
    echon a:normalStr1
    echohl WarningMsg | echon a:orangeStr | echohl None
    echo a:normalStr2
endfunction


function! s:WindowSplitMenu(default)
    let w:winSize = winheight(0)
    let text =  "split hor&izontal\n&split vertical\nnew &tab\ncurrent &window"
    let w:split = confirm("", l:text, a:default)
    redraw
endfunction


function! s:WindowSplit()
    if !exists('w:split')
        return
    endif

    let l:split = w:split
    let l:winSize = w:winSize

    if w:split == 1
        silent exec("sp! | enew")
    elseif w:split == 2
        silent exec("vnew")
    elseif w:split == 3
        silent exec("tabnew")
    elseif w:split == 4
        silent exec("enew")
    endif

    let w:split = l:split
    let w:winSize = l:winSize - 2
endfunction


function! s:WindowSplitEnd()
    if exists('w:split')
        if w:split == 1
            if exists('w:winSize')
                let lines = line('$')
                if l:lines <= w:winSize
                    echo "resize ".l:lines
                    exe "resize ".l:lines
                else
                    exe "resize ".w:winSize
                endif
            endif
            exe "normal! gg"
        endif
    endif
    silent! unlet w:winSize
    silent! unlet w:split
endfunction


"- functions -------------------------------------------------------------------



" Arg1: marktypes:
"   marks: show marks.
"   signs: show signs AKA unnamed marks.
" Returns: string with all marks and signs in config line format:
" "a=146::b=149::c=151::0=60::234::23"
function! s:GetMarksSignsAsConfigLineStr(signLeveList)
    let l:marksStr = ""
    let l:n = 0

    if a:marktypes =~ "marks"
        redir => l:marks
        silent exec("silent! marks ".g:SignMarks_useMarks)
        redir END

        if l:marks != "" && l:marks !~ "E283"
            for l:line in split(l:marks, "\n")
                if l:line == "" || l:line =~ "E283"
                    return ""
                endif
                let n += 1
                if l:n == 1 | continue | endif

                let l:line = substitute(l:line,'\s\+',' ','g')
                let l:line = substitute(l:line,'\s\+',' ','g')
                let l:line = substitute(l:line,'\s\+',' ','g')
                let l:list = split(l:line, " ")

                if len(l:list) > 0
                    let l:marksStr .= l:list[0]."=".l:list[1]."::"
                endif
            endfor
        endif
    endif

    if a:marktypes =~ "signs"
        let l:lineNumList = s:GetSignsLineNumbersAsList(a:signLeveList)
        for l:num in l:lineNumList
            let l:marksStr .= l:num."::"
        endfor
    endif

    return l:marksStr
endfunction


" Arg1: marktypes:
"   marks: show marks.
"   signs: show signs AKA unnamed marks.
" Returns: list with all marks. Format : "[ ['a', 146], [ 'b', 149] ]"
function! s:GetMarksAsList()
    let l:marksList = []
    let l:n = 0

    redir => l:marks
    silent exec("silent! marks ".g:SignMarks_useMarks)
    redir END

    if l:marks != "" && l:marks !~ "E283"
        for l:line in split(l:marks, "\n")
            if l:line == "" || l:line =~ "E283"
                return ""
            endif
            let n += 1
            if l:n == 1 | continue | endif

            let l:line = substitute(l:line,'\s\+',' ','g')
            let l:line = substitute(l:line,'\s\+',' ','g')
            let l:line = substitute(l:line,'\s\+',' ','g')
            let l:list = split(l:line, " ")

            if len(l:list) > 0
                let l:marksList += [ [ l:list[0], l:list[1] ] ]
            endif
        endfor
    endif

    return l:marksList
endfunction


" Return: list of line numbers belonging to the marks placed on current buffer.
" Return Format: "[ 11, 32, 3..]"
function! s:GetMarksLineNumbersAsList()
    let l:marksList = []
    let l:n = 0

    redir => l:marks
    silent exec("silent! marks ".g:SignMarks_useMarks)
    redir END

    if l:marks != "" && l:marks !~ "E283"
        for l:line in split(l:marks, "\n")
            if l:line == "" || l:line =~ "E283"
                continue
            endif
            let n += 1
            if l:n == 1 | continue | endif

            let l:line = substitute(l:line,'\s\+',' ','g')
            let l:line = substitute(l:line,'\s\+',' ','g')
            let l:line = substitute(l:line,'\s\+',' ','g')
            let l:list = split(l:line, " ")

            if len(l:list) > 0
                let l:marksList += [ l:list[1] ]
            endif
        endfor
    endif

    return l:marksList
endfunction


" Return: list of line numbers belonging to the unnamed marks placed on current buffer.
" Return Format: "[ 11, 32, 3..]"
function! s:GetSignsLineNumbersAsList(signLeveList)
    let l:signDict = sign_getplaced(expand("%"))
    "let l:signDict =  exec("sign place file=".expand("%"))
    "let l:signDict =  exec("sign place")
    let l:signsList = get(l:signDict, 'signs', [])
    let l:signsList = get(l:signsList, 'signs', [])
    "
    let l:linesList = []

    for l:signDict in l:signsList
        let l:name = get(l:signDict, "name", "")
        let l:found = 0

        if len(a:signLeveList) > 0
            for l:signtype in a:signLeveList
                let l:typeNr = str2nr(l:signtype)
                if l:typeNr < 0 || l:typeNr > len(g:SignMarks_signTypesList)
                    call s:Error("Wrong sign type ".l:typeNr)
                    continue
                endif

                if l:name == "VimSigns".l:signtype
                    let l:found = 1
                    break
                endif
            endfor
        else
            if l:name =~ "Signs"
                let l:found = 1
            endif
        endif

        if l:found == 1
            let l:lineNum = get(l:signDict, "lnum", "")
            if l:lineNum != ""
                let l:linesList += [ l:lineNum ]
            endif
        endif
    endfor

    return l:linesList
endfunction


" Get line sign's level on the selected line number.
" Arg1: line number.
" Return: sign level. 0 if no sign found.
function! s:GetSignLevel(lineNum)
    let l:signDict = sign_getplaced(expand("%"))
    "let l:signDict =  exec("sign place file=".expand("%"))
    "let l:signDict =  exec("sign place")
    let l:signsList = get(l:signDict, 'signs', [])
    let l:signsList = get(l:signsList, 'signs', [])

    for l:signDict in l:signsList
        let l:lineNum = get(l:signDict, "lnum", "")
        let l:name = get(l:signDict, "name", "")

        if l:lineNum == a:lineNum && l:name =~# "VimSigns"
            let l:level = substitute(l:name, "VimSigns", "", "")
            return l:level
        endif
    endfor

    return 0
endfunction


" Get a config line string with current marks and signs.
" Arg1: which marks to get on the config line: marks, signs or marks-signs.
" Return: config line with format
" "vim_signs:a=23::c=45::34::678::"
function! s:MarksGenerateConfigLine(options)
    let l:configLine = ""

    let l:configLine .= g:SignMarks_configLineName.":"
    let l:n = 0

    " Get marks:
    if a:options =~ "marks"
        for l:mark in s:GetMarksAsList()
            let l:configLine .= l:mark[0]."=".l:mark[1]."::"
            let l:n += 1
        endfor
    endif

    " Get signs:
    if a:options =~ "signs"
        " Save sign level 1.
        for l:sign in s:GetSignsLineNumbersAsList([ 1 ])
            let l:configLine .= l:sign."::"
            let l:n += 1
        endfor
        
        " Save sign levels from 2 to the last level.
        let l:i = 2
        while l:i <= len(g:SignMarks_signTypesList)
            for l:sign in s:GetSignsLineNumbersAsList([ l:i ])
                let l:configLine .= l:i.">".l:sign."::"
                let l:n += 1
            endfor
            let l:i +=1
        endwhile
    endif

    if l:n == 0
        call s:Warn("Marks not found")
        return ""
    endif

    echo l:configLine
    return l:configLine
endfunction


" Get all marks:
" Returns: list with all marks
" List format: [ [row, col, name, "line content"], ...]
" List format: [ [24, 10, "a", "line content"], [12, 3, "b", "line content"], [24, 34, "c", "line content"]]
function! s:GetMarksList()
    " Save window position
    let l:winview = winsaveview()

    redir => l:marks
    silent exec("silent! marks ".g:SignMarks_useMarks)
    redir END

    let l:marksList = []

    if l:marks == "" || l:marks =~ "E283"
        return l:marksList
    endif

    let n = 0

    for l:line in split(l:marks, "\n")
        if l:line == "" || l:line =~ "E283"
            return ""
        endif
        let n += 1
        if l:n == 1 | continue | endif

        let l:line = substitute(l:line,'\s\+',' ','g')
        let l:line = substitute(l:line,'\s\+',' ','g')
        let l:line = substitute(l:line,'\s\+',' ','g')
        let l:list = split(l:line, " ")

        let l:markName = l:list[0]
        let l:lineNum = str2nr(l:list[1])
        let l:colNum = str2nr(l:list[2])

        " Get line content from :marks command
        "call remove(l:list, 0, 2)
        "let l:content = join(l:list)

        " Get line content from file
        silent exec("normal ".l:lineNum."G")
        let l:content = getline(".")
        let l:filepath = expand("%")

        if len(l:list) > 0
            let l:marksList += [ [l:lineNum, l:colNum, l:markName, l:content, l:filepath] ] 
        endif
    endfor

    " Restore window position
    call winrestview(l:winview)

    return l:marksList
endfunction


" Get all signs:
" Returns: list with all marks
" List format: [ [row, col, signNum, "line content"], ...]
" List format: [ [24, 0, 1, "line content"], [12, 0, 2, "line content"], [34, 0, 3, "line content"]]
function! s:GetSignsList(filepath, signTypesList)
    " Save window position
    let l:winview = winsaveview()

    " Get all signs.
    let l:signDict = sign_getplaced(a:filepath)
    "let l:signDict =  exec("sign place file=".a:filepath)
    "let l:signDict =  exec("sign place")
    let l:signsList = get(l:signDict, 'signs', [])
    let l:signsList = get(l:signsList, 'signs', [])

    let l:filepath = expand("%")
    let l:returnList = []
    let n = 1
    let l:prevName = ""

    for l:signDict in l:signsList
        let l:name = get(l:signDict, "name", "")
        let l:found = 0

        if len(a:signTypesList) > 0
            for l:signtype in a:signTypesList
                if l:name == "VimSigns".l:signtype
                    let l:found = 1
                    break
                endif
            endfor
        else
            if l:name =~ "Signs"
                let l:found = 1
            endif
        endif

        if l:name != l:prevName
            let n = 1
        endif
        let l:prevName = l:name

        let l:signNum = substitute(l:name, "VimSigns", "", "")

        " Sign name: "signCharacter signNumber". ex: "> 21", "3> 234", "!> 45"
        "let l:signPos = str2nr(l:signNum) -1
        "let l:signChar = g:SignMarks_signTypesList[l:signPos][0]." ".l:n
        "let s:signLen = 3 | let s:signNum = "yes"

        " Sign name: "s+signLevel.signNumber". ex: "s1.11", "s3.2", "s10.1"
        "let l:signChar = "s".l:signNum.".".l:n | let s:signLen = 4 | let s:signNum = "yes"

        " Sign name: "s+signLevel". ex: "s1", "s3", "s10"
        let l:signChar = "s".l:signNum | let s:signLen = 3 | let s:signNum = ""

        "if l:name =~ "Signs".a:signtype
        if l:found == 1
            let l:lineNum = get(l:signDict, "lnum", "")
            if l:lineNum != ""
                silent exec("normal ".l:lineNum."G")
                let l:content = getline(".")

                "let l:returnList += [ [ l:lineNum, 0, l:n, l:content, l:filepath ] ]
                let l:returnList += [ [ l:lineNum, 0, l:signChar, l:content, l:filepath ] ]
                let n += 1
            endif
        endif
    endfor

    " Restore window position
    call winrestview(l:winview)

    return l:returnList
endfunction


" Sort list using first field on the list.
" Input format: [ [24, 0, 1, "line content"], [12, 0, 2, "line content"], [34, 0, 3, "line content"]]
function! signmarks#NumericSortList0(firstList, secondList)
  if a:firstList[0] < a:secondList[0]
    return -1
  elseif a:firstList[0] > a:secondList[0]
    return 1
  else 
    return 0
  endif
endfunction


" Get the window header lines acording to the options selected
" Returns: list with every header line.
function! s:GetHeader(wintype, marktypes, options, filterList)
    let l:headerList = []

    if a:options =~# "H"
        let l:signsStr = join(s:GetSignLevelList(a:options))

        " Mount first header (both for qf/window) line:
        let l:headerStr = "[sign-marks] show "
        if a:marktypes =~ "marks"
            let l:headerStr .= "marks"
        endif
        if a:marktypes =~ "signs"
            if a:marktypes =~ "marks"
                let l:headerStr .= " and "
            endif
            let l:headerStr .= "signs"
        endif
        if l:signsStr != ""
            let l:headerStr .= " levels:"
            let l:headerStr .= " ".l:signsStr
        endif
        let l:headerStr .= ". "

        if (a:options =~? "A" || a:options =~? "W") && len(a:filterList) > 0
            let l:headerStr .= "Filter files: ".join(a:filterList).". "
        endif

        " Add the header
        if a:options =~# "H2"
            " Not quickfix window, add window header:
            let l:str = ""
            if a:wintype == "qf"
                let l:str .= "FILEPATH|LINE| "
            else
                if a:options =~# "L"
                    let l:str .= "LINE "
                endif
            endif
            if a:options =~# "N"
                let l:str .= "[MARK] "
            else
                if a:wintype == "qf" && a:options =~# "T"
                    let l:str .= "> "
                endif
            endif
            let l:str .= "CONTENT"

            let l:headerList += [ l:headerStr ]
            let l:headerList += [ l:str ]
            let l:headerList += [ "-------------------------------------------------------" ]
        else
            let l:headerList += [ l:headerStr ]
        endif
    endif
    return l:headerList
endfunction


" Returns: fullDataList sorted and without repeated lines.
function! s:GetSortedUniqList(list, options)
    let l:inputList = a:list

    if a:options =~# "S"
        " Sort using line numbers
        call sort(l:inputList, "signmarks#NumericSortList0")
    endif

    let l:outputList = []
    let l:prevLineNum = 0

    " Check if line its the same:
    " Skip signs when there's already a mark on same line.
    if a:options =~# "U" 
        for l:list in l:inputList
            let l:lineNum = l:list[0]

            if l:lineNum == l:prevLineNum
                "echom "Skipped duplicated line:".l:lineNum
                continue
            endif
            let l:prevLineNum = l:lineNum
            let l:outputList += [ l:list ]
        endfor
    else
        let l:outputList = l:inputList
    endif
    return l:outputList
endfunction


" Get list formated to be displayed acording to wintype and options:
" Returns: list with strings.
" List format: 
" - Qf format:     "filepath:lineNumber: [mark] line content"
" - Buffer format: "line [mark] line content"
function! s:GetFormatedList(list, wintype, marktypes, options)
    "echom "s:GetFormatedList "a:list
    "echom "s:GetFormatedList ".a:wintype." ".a:marktypes." ".a:options
    let l:marksList = a:list

    if a:options =~# "S"
        " Sort using line numbers
        call sort(l:marksList, "signmarks#NumericSortList0")
    endif

    let l:formatedMarksList = []
    let l:n = 0

    if a:options =~# "H"
        if a:options =~# "H2"
            let l:n += 3
        else
            let l:n += 1
        endif
    endif

    let l:maxNameStrLen = 0
    if s:signNum != ""
        let l:maxNameStrLen = s:GetSignsNumStrLen()
    endif
    let l:maxNameStrLen += s:signLen " Count with the sign characters.
    let l:maxLineNumLen = s:GetLineNumbMaxStrLen()
    let l:marksCmdStr = ""
    let l:signsLinesList = []
    let l:prevFile    = ""
    let l:prevLine    = 0

    for l:markList in l:marksList
        let l:line    = l:markList[0]
        "let l:col     = l:markList[1]
        let l:name    = l:markList[2]
        let l:content = l:markList[3]
        let l:file    = l:markList[4]

        " Check if line its the same:
        " Skip signs when there's already a mark on same line.
        if a:options =~# "U" 
            if l:line == l:prevLine
                continue
            endif
            let l:prevLine = l:line
        endif

        let l:n += 1

        " When retrieving data from all open windows (option A)
        " Check if we must add line feed or file name.
        if a:options =~? "A" || a:options =~? "W"
            if l:file != l:prevFile
                if a:options =~# "lf"
                    " Add empty line:
                    let l:formatedMarksList += [ "" ]
                    let l:n += 1
                endif
                if a:options =~# "fn"
                    " Add file name:
                    let l:fileTmp = substitute(l:file, "^./", "", "")
                    let l:formatedMarksList += [ "#======== ".l:fileTmp." ========" ]
                    let l:n += 1
                endif
            endif
            let l:prevFile = l:file
        endif

        if g:SignMarks_useMarks =~ l:name
            " Marks:
            let l:name = printf("%".l:maxNameStrLen."s", l:name)

            " Save mark to set on the qf/new window
            if a:options =~# "M" && a:options !~? "A" && a:options !~? "W"
                let l:tmp = substitute(l:name, " ", "", "g")
                let l:marksCmdStr .= l:n."Gm".l:tmp
            endif

        else
            " Signs:
            "let l:name = printf("%".l:maxNameStrLen."d", l:name)
            let l:name = printf("%".l:maxNameStrLen."s", l:name)

            " Save signs to apply on the qf/new window
            if a:options =~# "I" && a:options !~? "A" && a:options !~? "W"
                let l:tmp = substitute(l:name, " ", "", "g")
                let l:tmp = substitute(l:tmp, "s", "", "g")
                if l:tmp == "" | let l:tmp = 1 | endif

                let l:signsLinesList += [ [ l:tmp, l:n ] ]
                "echom "signsLinesList: "l:signsLinesList
            endif
        endif

        let l:str = ""

        if a:wintype =~ "qf"
            "" Qf format: "filepath:lineNumber: [mark] line content"
            let l:str .= l:file.":".l:line.":0:"

            if a:options =~# "N"
                let l:str .= " [".l:name."] "
            elseif a:options =~# "T"
                let l:str .= " > "
            endif

            " Align content.
            if l:maxLineNumLen > 0
                let l:paddingLen = l:maxLineNumLen - len(l:line)

                if l:paddingLen > 0
                    let l:padding = repeat(" ", l:paddingLen)
                else
                    let l:padding = ""
                endif
                let l:str .= l:padding
            endif

            " Content.
            let l:str .= l:content."\n"
        else
            let l:line = printf("%-".l:maxLineNumLen."d", str2nr(l:line))

            " Buffer format: "line [mark] line content"
            if a:options =~# "L"
                let l:str .= l:line." "
            endif
            if a:options =~# "N"
                let l:str .= "[".l:name."] "
            endif
            let l:str .= l:content."\n"
        endif

        let l:formatedMarksList +=  [ l:str ]
    endfor

    return [ l:formatedMarksList, l:marksCmdStr, l:signsLinesList ]
endfunction


" Filter the sign levels to be displayed.
" When using option 'sN'.
" Examlples:
" - Show only sign level 33: s33
" - Show only sign level 2 to 33: s2:33
" - Show only sign levels 2 and 33: s2s33
" - Show only sign levels 33 and above: s33:
" - Show only sign levels 33 and below: :s33
function! s:GetSignLevelList(options)
    "echom "GetSignLevelList options:".a:options
    let l:typeList = []

    if a:options !~# "s[0-9]" && a:options !~ "s:[0-0]*"
        return l:typeList
    endif

    let l:init = 1
    let l:end = 0
    let l:last = len(g:SignMarks_signTypesList)

    for l:opt in split(a:options, "s")

        if l:opt !~ "[0-9]*" && l:opt !~ ":[0-0]*"
            continue
        endif
        "echom "opt: ".l:opt

        if l:opt =~ ":"
            let l:list = split(l:opt, ':')
            "echom "list: "l:list

            if l:opt[0] == ":"
                let l:init = 1
                let l:end = str2nr(l:list[0])
            else
                let l:init = str2nr(l:list[0])
                if len(l:list) >= 2
                    let l:end = str2nr(l:list[1])
                else
                    let l:end = l:last
                endif
            endif

            if l:init < 1 || l:init >= l:last
                call s:Error("Show sign level: ".l:init.":".l:end.". Error: unknown initial level number ".l:init)
                continue
            endif
            if l:end < 2 || l:end > l:last
                call s:Error("Show sign level: ".l:init.":".l:end.". Error: unknown end level number ".l:end)
                continue
            endif
            if l:end < l:init
                call s:Error("Show sign level: ".l:init.":".l:end.". Error: end level lower than initial level")
                continue
            endif

            let l:n = l:init
            while l:n <= l:end
                let l:typeList += [ "".l:n."" ]
                "echom "add: ".l:n
                let l:n += 1
            endwhile
        else
            let l:level = str2nr(l:opt)
            if l:level <= 0 | continue | endif
            if l:level > l:last
                call s:Error("Show sign level: ".l:level.". Error. Wrong level number ".l:end)
                continue
            endif
            let l:typeList += [ "".l:level."" ]
        endif
    endfor

    "echom "GetSignLevelList result:"l:typeList | call input("press key")
    return l:typeList
endfunction


function! s:GetViewData(view, wintype, marktypes, options, filterList)
    "echom "GetViewData "a:view." wintype:".a:wintype." marktypes:".a:marktypes." options:"a:options." filterList:"a:filterList

    if exists("s:SignMarks_filesCheckedList")
        " Prevent checking the same file twice:
        for l:file in s:SignMarks_filesCheckedList
            if l:file == expand("%")
                echo "- Skip:  ".expand("%")." (duplicate)"
                return []
            endif
        endfor
        let s:SignMarks_filesCheckedList += [ expand("%") ]
    endif

    if getwinvar(winnr(), '&syntax') == 'qf'
        if a:options =~? "a" || a:options =~? "w"
            echo "Skip:  ".expand("%")." (quickfix)"
        endif
        return []
    endif

    "echom "options: ".a:options
    if a:options !~ "_" && exists("w:SignMarks_viewConfigDict")
        " Skip any Signs view window.
        if a:options =~? "a" || a:options =~? "w"
            echo "- Skip:  ".expand("%")." (signsView)"
        endif
        return []
    endif

    if expand("%") == ""
        " Empty buffer name.
        if a:options =~? "a" || a:options =~? "w"
            echo "- Skip:  ".expand("%")." (no file name)"
        endif
        return []
    endif

    if line("$") == 0 && getline(0) == ""
        " Empty buffer.
        if a:options =~? "a" || a:options =~? "w"
            echo "- Skip:  ".expand("%")." (empty file)"
        endif
        return []
    endif

    " Filter files:
    let l:skipList = []
    let l:keepList = []

    for l:filter in a:filterList
        if l:filter[0] == "-"
            let l:skipList += [ l:filter[1:] ]
        elseif l:filter[0] == "+"
            let l:keepList += [ l:filter[1:] ]
        endif
    endfor

    if len(l:skipList) != 0
        " Skip files
        let l:found = 1
        for l:skip in l:skipList
            if expand("%") =~ l:skip
                echohl DiffDelete
                echo "- Filter:  ".expand("%"). " [-.".l:skip."]"
                return []
                echohl None
            endif
        endfor
    endif

    if len(l:keepList) != 0
        " Keep files
        let l:found = 0
        for l:keep in l:keepList
            if expand("%") =~ l:keep
                let l:found = 1
                break
            endif
        endfor
        if l:found == 0 | 
            echohl DiffDelete
            echo "- Filter:  ".expand("%")." [+.".l:keep."]"
            echohl None
            return []
        endif
    endif

    if len(a:filterList) != 0 || a:options =~? "a" || a:options =~? "w"
        "echohl WarningMsg
        echohl Directory
        echo "+ Check : ".expand("%")
        echohl None
    endif

    let l:list = []
    let l:markTypesStr = ""

    if a:marktypes =~ "marks"
        let l:list += s:GetMarksList()
        "echom "Marks: "l:list
        let l:markTypesStr .= "marks"
    endif
    if a:marktypes =~ "signs"
        let l:typeList = s:GetSignLevelList(a:options)
        let l:list += s:GetSignsList("", l:typeList)
        "echom "Signs: "l:list
        if l:markTypesStr != "" | let l:markTypesStr .= " and " | endif
        let l:markTypesStr .= "signs"
    endif

    if len(l:list) == 0
        echohl WarningMsg
        echo "  No ".a:marktypes." found"
        echohl None
        return []
    endif
    let l:fullList = l:list

    if a:options =~? "a" || a:options =~? "w"
        echohl DiffAdd
        echo "  Found : ".l:markTypesStr
        echohl None
    endif

    if a:options =~# "F"
        let l:fileType = &ft
    else
        let l:fileType = ""
    endif

    let l:list = s:GetFormatedList(l:list, a:wintype, a:marktypes, a:options)
    let l:formatedList = l:list[0]
    let l:marksCmdStr = l:list[1]
    let l:signsCmdStr = l:list[2]

    let list = [ l:fullList, l:formatedList, l:marksCmdStr, l:signsCmdStr, l:fileType ]
    "echo "GetViewData return: "l:list
    return l:list
endfunction


function! s:OpenView(optionsList, filterList)
    "echom "signmarks#OpenView optionsList: "a:optionsList" filterList: "a:filterList

    let l:view      = a:optionsList[0]
    let l:wintype   = a:optionsList[1]
    let l:marktypes = a:optionsList[2]
    let l:options   = a:optionsList[3]
    let l:userOptions = a:optionsList[4]

    let l:fileName  = expand("%")
    let l:filepath  = expand("%:p:h")."/".expand("%:t:r")
    let l:ext       = expand("%:e")

    let l:marksCmd = ""
    let l:signsLinesList = []
    let l:userOptions = ""

    if l:options =~# "help"
        call signmarks#OpenViewHelp(l:wintype, l:marktypes, l:options, a:filterList)
        return
    endif


    let l:markTypesStr = ""
    if l:marktypes =~ "marks"
        let l:markTypesStr .= "marks"
    endif
    if l:marktypes =~ "signs"
        if l:markTypesStr != " " | let l:markTypesStr .= " and " | endif
        let l:markTypesStr .= "signs"
    endif

    if l:options =~? "A" || l:options =~? "w"
        echo "Getting all ".l:markTypesStr."..."

        if len(a:filterList) != 0
            echo "Apply filters: ".join(a:filterList)
        endif
    endif

    let l:list = []
    let l:fileNum = 0

    if l:options =~ "_"
        " Change the view type.
        if exists("w:SignMarks_viewConfigDict")
            " Already on a view window. Change the view type.
            " Get the saved signs/marks from current window.
            if len(w:SignMarks_viewConfigDict) >= 4
                let l:fullList        = w:SignMarks_viewConfigDict['fullDataList']
                let l:viewOptions     = w:SignMarks_viewConfigDict['options']
                let l:viewUserOptions = w:SignMarks_viewConfigDict['userOptions']
                let l:fileType        = w:SignMarks_viewConfigDict['fileType']
                let l:headerLines     = w:SignMarks_viewConfigDict['headerLines']
                let l:fileNum         = w:SignMarks_viewConfigDict['filesNum']


                let l:winPos = line(".")
                let l:winPos -= l:headerLines

                let l:viewFullOptions = l:viewOptions.l:viewUserOptions
                "call input("0 WinPos:".l:winPos." fileNum: ".l:fileNum." headerLines:".l:headerLines)

                if l:viewFullOptions =~? "A" || l:viewFullOptions =~? "w"
                    if l:viewFullOptions =~# "fn"
                        let l:winPos -= l:fileNum
                    endif
                    if l:viewFullOptions =~# "lf"
                        let l:winPos -= l:fileNum
                    endif
                endif
                "call input("0_ WinPos:".l:winPos." fileNum: ".l:fileNum." headerLines:".l:headerLines)

                silent quit!
            endif
        else
            echo "Switch to new view error, no saved marks/signs found."
            call s:Error("Not on a Signs's view window.")
            return
        endif

        let l:list = s:GetHeader(l:wintype, l:marktypes, l:options, a:filterList)
        let l:headerLines = len(l:list)

        let l:tmplist = s:GetFormatedList(l:fullList, l:wintype, l:marktypes, l:options)
        let l:list += l:tmplist[0]
        let l:marksCmd = l:list[1]
    endif

    "echom "OPTIONS:".l:options


    if len(l:list) <= 0
        " NOT on a view window.
        " Retrieve the signs/marks list.
        if l:options =~? "A" || l:options =~? "W"
            " Get marks/signs from all buffers:
            let l:buffIdList = range(1, bufnr('$'))
            " Save window name
            let l:buffName = expand("%")
            " Save window ID
            let l:winId = win_getid()
            " Save window position
            let l:winview = winsaveview()

            let l:allWinList = []
            let s:SignMarks_filesCheckedList = []

            if l:options =~? "A"
                tabdo windo let l:allWinList += [ s:GetViewData(l:view, l:wintype, l:marktypes, l:options, a:filterList) ]
            else
                windo let l:allWinList += [ s:GetViewData(l:view, l:wintype, l:marktypes, l:options, a:filterList) ]
            endif

            unlet s:SignMarks_filesCheckedList
            let l:fileType = ""

            " Restore window
            call win_gotoid(l:winId)
            " Restore window position
            call winrestview(l:winview)
        else
            " Get marks/signs from current buffer:
            let s:SignMarks_filesCheckedList = []
            let l:allWinList = [ s:GetViewData(l:view, l:wintype, l:marktypes, l:options, a:filterList) ]
            unlet s:SignMarks_filesCheckedList
        endif

        let l:fullList = []
        let l:list = s:GetHeader(l:wintype, l:marktypes, l:options, a:filterList)
        let l:headerLines = len(l:list)
        let l:fileTypeList = []

        let l:fileNum = 0
        let l:n = 0
        for l:winList in l:allWinList
            if len(l:winList) >= 5
                let l:fullList += l:winList[0]
                let l:list += l:winList[1]
                let l:marksCmd .= l:winList[2]
                let l:signsLinesList = l:winList[3]
                let l:fileTypeList += [ l:winList[4] ]
                let l:fileNum += 1
                let l:n += 1
            endif
        endfor
        "call input("fileNum0: ".l:fileNum)

        if l:fileNum == 0
            call s:Warn("[sign-marks] No marks found")
            return
        else
            if l:options =~? "A" || l:options =~? "w"
                echo "Found ".l:fileNum." files with ".l:markTypesStr."."
            endif
        endif

        " Check all buffers have the same file format:
        call sort(l:fileTypeList)
        call uniq(l:fileTypeList)

        if len(l:fileTypeList) == 1
            let l:fileType = l:fileTypeList[0]
        else
            let l:fileType = ""
        endif
    endif

    if len(l:list) == 0
        call s:Warn("[sign-marks] No marks found")
        return
    endif

    " Get window color config:
    if exists('g:HiLoaded')  && (l:options !~? "A" || l:options =~? "w")
        if exists("w:ColoredPatternsList")
            let l:HiColorList = w:ColoredPatternsList
        endif
    endif

    " Save window height:
    let l:winLen = winheight(0) " window lenght

    " Save paramenters to reload the view window:
    if l:options !~? "a" || l:options =~? "w"
        let w:SignMarks_mainConfigDict = {}
        call extend(w:SignMarks_mainConfigDict, { "optionsList"   : a:optionsList })
        call extend(w:SignMarks_mainConfigDict, { "filterList"    : a:filterList })
    endif

    " Get new view window name:
    if l:wintype == "qf2f"
        let l:newFileName = "_signs_qf2f.txt"
    else
        if l:options !~? "a" || l:options =~? "w"
            "let l:newFileName = l:filepath."_signsView".l:view.".".l:ext
            let l:newFileName = l:filepath."_signsView.".l:ext
        else
            "let l:newFileName = "_signsView".l:view.".txt"
            let l:newFileName = "_signsView.txt"
        endif
    endif
    if l:newFileName != ""
        " Close config window if already open
        silent! exec "bd! ".l:newFileName
    endif

    " Create new/vnew/tab buffer:
    let l:resize = ""
    if l:wintype == "qf"
        silent new
        let l:resize = "yes"
    elseif l:wintype == "qf2f"
        silent tabedit
    elseif l:wintype == "new"
        silent exec(l:wintype)
        let l:resize = "yes"
    else
        " vnew or tab
        silent exec(l:wintype)
    endif

    if l:wintype == "vnew" || l:wintype == "vertical new"
        if g:SignMarks_vlen != "" && g:SignMarks_vlen != 0
            exe "vertical resize ".g:SignMarks_vlen
        endif
    endif

    if expand("%") != "" || line("$") != 1 || getline(1) != ""
        call s:Error("Expected empty buffer")
        return
    endif

    " Dump lines to buffer:
    for l:line in l:list
        let @z = l:line
        put z
    endfor
    normal ggdd

    if l:wintype == "qf"
        " Save to tmp file.
        let l:tmpFile = tempname()
        silent exec "w! ".l:tmpFile
        silent quit!

        " Load file to quickfix
        silent exec "lgetfile " . l:tmpFile
        silent lwindow
        setlocal cursorline
        wincmd j
        silent exe "silent normal! gg"

        silent! delete(l:tmpFile)
        silent! normal zO
    endif

    if l:newFileName != ""
        " Rename window
        silent  exec("0file")
        silent! exec("file ".l:newFileName)
    endif

    " Apply signs to current window:
    if l:options =~# "I" && (l:options !~? "A" || l:options =~? "w")
        if len(l:signsLinesList) > 0
            call s:ApplySignsToView(l:signsLinesList)
        endif
    endif

    " Apply marks to current window:
    if l:options =~# "M" && (l:options !~? "A" || l:options =~? "w")
        if l:marksCmd != ""
            silent! exec("normal ".l:marksCmd)
            silent exec("normal gg")
        endif
    endif

    " Save the marks and signs used for current window.
    " Used for switching views:
    if l:wintype != "qf2f"
        let w:SignMarks_viewConfigDict = {}
        call extend(w:SignMarks_viewConfigDict, { "fullDataList" : l:fullList })
        call extend(w:SignMarks_viewConfigDict, { "options"      : a:optionsList[3] })
        call extend(w:SignMarks_viewConfigDict, { "userOptions"  : l:userOptions })
        call extend(w:SignMarks_viewConfigDict, { "fileType"     : l:fileType })
        call extend(w:SignMarks_viewConfigDict, { "viewNum"      : l:view })
        call extend(w:SignMarks_viewConfigDict, { "headerLines"  : l:headerLines })
        call extend(w:SignMarks_viewConfigDict, { "filesNum"     : l:fileNum })
        call extend(w:SignMarks_viewConfigDict, { "fileName"     : l:fileName })

        if l:wintype != "qf"
            set buflisted
            set bufhidden=delete
            setl noswapfile
            setl buftype=nofile
            setl nomodifiable
        endif
    endif

    if l:resize != ""
        " Resize the quickfix window:
        " Workout the window resize data:
        let buffLen = line('$') " buffer lenght
        let maxlen = l:winLen/2

        if l:buffLen < l:maxlen
            exe "resize ".l:buffLen
        endif
    endif
    normal! gg

    if l:fileType != ""
        " Set file type:
        exec "set ft=".l:fileType
    endif

    if exists('g:HiLoaded')
        " Apply hi.vim colors:
        if exists("l:HiColorList")
            let w:ColoredPatternsList = l:HiColorList
            silent! call hi#hi#Refresh()
        endif

        if (l:options =~? "A" || l:options =~? "w") && g:SignMarks_highlightFilesColor[0] != ""
            let l:hiColor = g:SignMarks_highlightFilesColor[0]
            let l:hiOptions = g:SignMarks_highlightFilesColor[1]

            silent! call hi#config#PatternHighlight(l:hiColor, "#======", l:hiOptions)
        endif

        if l:options =~# "H"
            if g:SignMarks_highlightHeaderColor[0] != ""
                let l:hiColor = g:SignMarks_highlightHeaderColor[0]
                let l:hiOptions = g:SignMarks_highlightHeaderColor[1]

                silent! call hi#config#PatternHighlight(l:hiColor, "sign-marks", l:hiOptions)

                if l:options =~# "H2"
                    silent! call hi#config#PatternHighlight(l:hiColor, "CONTENT", l:hiOptions)
                    silent! call hi#config#PatternHighlight(l:hiColor, "-----------------------------", l:hiOptions)
                endif
            endif
        endif

        silent! call hi#config#Reload()
    endif

    " When switching views:
    " Restore window position
    if exists("l:winPos")
        "call input("1_ WinPos:".l:winPos." fileNum: ".l:fileNum." headerLines:".l:headerLines)
        let l:winPos += l:headerLines

        if l:options =~? "A" || l:options =~? "w"
            if l:options =~# "fn"
                let l:winPos += l:fileNum
            endif
            if l:options =~# "lf"
                let l:winPos += l:fileNum
            endif
        endif

        "call input("1_ WinPos:".l:winPos." fileNum: ".l:fileNum." headerLines:".l:headerLines)
        silent exec("normal ".l:winPos."Gzz")
    endif
endfunction


" Show marks on quickfix/new window.
" Arg1: view, view number (position of current configuration on g:SignMarks_viewsList).
" Arg2: list [wintype, marktype, optoins]:
" Wintype: window type.
"   qf: open on quickfix window.
"   new: show on buffer, open new window.
"   vnew: show on buffer, open new vertical window.
"   tab: show on buffer, open new tab window.
"   qf2f: open as quickfix on buffer on new tab window.
" Marktype:
"   marks: show marks.
"   signs: show signs AKA unnamed marks.
"   marks-signs: show both signs and marks.
" Options:
"   A:  show all marks/signs from all open windows.
"   a:  same as A.
"   F:  apply the same file format to the qf/new window.
"   fn: when view is showing a different file, add a new line with the file name.
"   H1: show header type 1 with two lines.
"   H2: show header type 2 with two lines.
"   I:  apply same signs on view window.
"   L:  show line numbers.
"   lf: add line feed after.
"   M:  apply same marks on new window.
"   N:  show marks/signs names.
"   S:  sort marks by file line. Otherwise sort by marks first, signs next.
"   T:  preserve contents start of line tabulation on quickfix window. Not
"       needed when 'N' is used. Only for wintype "qf".
"   U:  do not show duplicated lines. Lines having both mark and sign.
"   _:  when placed on view window, change to the requested view and options.
"   W:  show all marks and signs on current tab.
" Arg3: [userOptions]: same as options plus you can add the patterns to filter
"      when using option 'A'.
" Commands: Sm1, Sm2, Sm3, Sm4, Smq, SmQ, Smw, SmW, Smwo, Smqo, Smqf2f.
function! signmarks#OpenView(optionsList, ...)
    "echom "signmarks#OpenView "a:optionsList" "a:000

    let l:view      = a:optionsList[0]
    let l:wintype   = a:optionsList[1]
    let l:marktypes = a:optionsList[2]
    let l:options   = a:optionsList[3]
    let l:userOptions = ""

    if l:marktypes !~ "marks" && l:marktypes !~ "signs"
        call s:Error("Error: unknwon mark type ".l:marktypes." (use: \"marks\" or \"signs\" or both)")
        return
    endif

    "echom "signmarks#OpenView ".l:view." ".l:wintype." ".l:marktypes." ".l:options." ".a:userOptions

    " Extract options+userOptions and filter words
    let l:filterList = []

    if a:0 > 0
        " Parse arguments:
        for l:arg in a:000
            if l:options =~? "a" || l:options =~? "w"
                if l:arg[0] == "+" || l:arg[0] == "-"
                    let l:filterList += [ l:arg ]
                else
                    let l:options .= l:arg
                endif
            else
                let l:options .= l:arg
            endif
            let l:userOptions .= " ".l:arg
        endfor
    endif

    if l:options !~ "_" && exists("w:SignMarks_viewConfigDict")
        " We on a view window.
        call s:Warn("Already on a view window")
        return
    endif

    let l:optionsList = [l:view, l:wintype, l:marktypes, l:options, l:userOptions]
    call s:OpenView(l:optionsList, l:filterList)
endfunction



function! s:ApplySignsToView(signLineList)
    "echom "signLineList: "a:signLineList
    for l:signList in a:signLineList
        let l:level = l:signList[0]
        let l:line = l:signList[1]
        "echom "Apply sign level: ".l:level." line: ".l:line
        silent! exec("normal ".l:line."gg")
        silent! call signmarks#Sign("add", l:level)
    endfor
    silent exec("normal gg")
endfunction


function! s:ShowOptionMarkIfSelected(options, name, nameArgs, text, caseInsen)
    let l:name = printf("%-6s", a:name)
    if a:name == ""
        echon " ".l:name."  ".a:text."\n"
    else
        if a:options =~# a:name || (a:caseInsen == 1 && a:options =~? a:name)
            echohl WarningMsg
            echon " ".l:name
            echohl None
        else
            echon " ".l:name
        endif
        echon " ".a:nameArgs
        echon ": ".a:text."\n"
    endif
endfunction


function! signmarks#OpenViewHelp(wintype, marktypes, options, filterList)
    let l:options = substitute(a:options,"help","","")

    echo "Available options:"
    echo ""
    call s:ShowOptionMarkIfSelected(a:options, "A", "", "get marks/signs from all open windows.", 1)
    call s:ShowOptionMarkIfSelected(a:options, "F", "", "apply current file format to the qf/new window.", 0)

    if l:options !~? "A" || l:options =~? "w"
        call s:ShowOptionMarkIfSelected(a:options, "fn", "", "show file name when displaying new file.", 0)
    endif

    call s:ShowOptionMarkIfSelected(a:options, "H1", "", "show header type 1, one line.", 0)
    call s:ShowOptionMarkIfSelected(a:options, "H2", "", "show header type 2, two lines.", 0)

    if l:options !~? "A" || l:options =~? "w"
        call s:ShowOptionMarkIfSelected(a:options, "I", "", "apply same signs on view window.", 0)
    endif
    
    call s:ShowOptionMarkIfSelected(a:options, "L", "", "show line numbers.", 0)

    if l:options !~? "A" || l:options =~? "w"
        call s:ShowOptionMarkIfSelected(a:options, "lf", "", "add line feed when displaying new file.", 0)
        call s:ShowOptionMarkIfSelected(a:options, "M", "", "apply same marks on view window.", 0)
    endif

    call s:ShowOptionMarkIfSelected(a:options, "N", "", "show marks' names and signs' levels.", 0)
    call s:ShowOptionMarkIfSelected(a:options, "S", "", "sort marks by file line. Otherwise sort by marks first, signs next.", 0)
    call s:ShowOptionMarkIfSelected(a:options, "s[0-9]", "", "show only the selected sign levels.", 0)

    if a:wintype == "qf" && l:options !~ "N"
        call s:ShowOptionMarkIfSelected(a:options, "T", "", "preserve contents start of line tabulation on quickfix window.", 0)
        call s:ShowOptionMarkIfSelected(a:options, "", "", "not needed when 'N' is used. Only for window type \"qf\".", 0)
    endif

    call s:ShowOptionMarkIfSelected(a:options, "U", "", "do not show duplicated lines. Lines having both mark and sign.", 0)
    call s:ShowOptionMarkIfSelected(a:options, "W", "", "get marks/signs from all windows on current tab.", 1)

    if l:options !~? "A" || l:options =~? "w"
        call s:ShowOptionMarkIfSelected(a:options, "+", "PATTERN", "keep files with pattern.", 0)
        call s:ShowOptionMarkIfSelected(a:options, "-", "PATTERN", "discard files with pattern.", 0)
    endif

    call s:ShowOptionMarkIfSelected(a:options, "_", "", "on a view window, switch to a different view.", 0)

    echo " "
    echo "Current selection:"
    echo ""
    call s:EchoOrange(" Window type:    ", a:wintype, "")

    call s:EchoOrange(" Content type:   ", a:marktypes, "")
    if l:options == ""
        let l:options = "none"
    endif
    
    call s:EchoOrange(" Active options: ", l:options, "")

    if len(a:filterList) != 0
        call s:EchoOrange(" Filter files:   ", join(a:filterList), "")
    endif
endfunction


" Switch to another view.
" Required to be on Signs view window (qf/new).
" Depends on the views defined on: 'g:SignMarks_viewsList'
" Arg1: [view]. change to view number.
" Command: Smv
function! signmarks#SwitchToNextView(view)
    if len(g:SignMarks_viewsList) <= 0
        call s:Error("No view defined.")
        return
    endif

    let l:filterSignLevel = ""
    let l:filterFiles = ""

    if a:view =~ "help" || a:view == ""
        if a:view =~ "h"
            echo "Options:"
            echo " A:  get marks/signs from all open windows."
            echo " F:  apply current file format to the qf/new window."
            echo " Fn: show file name when displaying new file."
            echo " H1: show header type 1, one line."
            echo " H2: show header type 2, two lines."
            echo " L:  show line numbers."
            echo " Lf: add line feed when displaying new file."
            echo " M:  apply same marks on new window."
            echo " N:  show marks/signs names."
            echo " S:  sort marks by file line. Otherwise sort by marks first, signs next."
            echo " s[0-9]: show only the selected sign levels."
            echo " T:  preserve contents start of line tabulation on quickfix window."
            echo "     not needed when 'N' is used. Only for window type \"qf\"."
            echo " U: do not show duplicated lines. Lines having both mark and sign."
            echo " W:  show all marks and signs on current tab."
            echo " +PATTERN: keep files with pattern."
            echo " -PATTERN: discard files with pattern."
            echo " _: on a view window, switch to a different view."
            echo " "
            echo " "
        endif

        echo "Available views: "
        echo printf("%4s  %-7s  %-12s  %-15s  %-7s   %s", "Num)", "WinType", "MarkTypes", "Options", "Mapping", "Commands")
        echo "------------------------------------------------------------"

        let l:n = 1
        for l:view in g:SignMarks_viewsList
            "let l:viewnum   = l:view[0]
            let l:mapping   = l:view[0]
            let l:wintype   = l:view[1]
            let l:marktypes = l:view[2]
            let l:options   = l:view[3]
            let l:command   = l:view[4]

            let l:commands = ""
            if l:command != ""
                let l:commands .= ":Sm".l:command
            endif

            if l:mapping != ""
                if l:commands == ""
                    let l:commands .= ":Smv".l:mapping
                else
                    let l:commands .= " :Smv".l:mapping
                endif

                let l:mapping  = "s+tab+".l:mapping
            endif

            echo printf("%4s  %-7s  %-12s  %-15s  %-7s   %s", l:n.")", l:wintype, l:marktypes, l:options, l:mapping, l:commands)
            let l:n += 1
        endfor

        echo " "
        let l:viewstr = input("Choose view number: ")
        if l:viewstr == "" | return | endif
        let l:view = str2nr(l:viewstr)

        echo " "
        let l:level = input("Filter sign level: ")
        if l:level != ""
            let l:level = str2nr(l:level)
            if l:level <= 0 && l:level > len(g:SignMarks_signTypesList)
                call s:Error("Level not found ".l:level)
                return
            else
                let l:filterSignLevel = "s".l:level
            endif
        endif

        let l:options = g:SignMarks_viewsList[l:view - 1][3]
        if l:options =~ "a" || l:options =~ "w"
            echo " "
            let l:filterFiles = " ".input("Filter by file pattern: ")
        endif

        echo " "
    else
        let l:view = str2nr(a:view)
    endif

    if !exists("w:SignMarks_viewConfigDict")
        let l:onViewWindow = "no"
    else
        let l:onViewWindow = "yes"
    endif

    if l:view != ""
        if l:view <= 0 || l:view > len(g:SignMarks_viewsList)
            call s:Error("Switch to new view error, view ".l:view." not found.")
            return
        endif
    endif

    let l:userOptions = ""

    if l:onViewWindow == "no"
        if l:view == ""
            if exists("b:SignMarks_defaultView")
                let l:view = b:SignMarks_defaultView
            else
                let l:view = g:SignMarks_defaultView
            endif
            if l:view < 1 || l:view > len(g:SignMarks_viewsList)
                call s:Error("Wrong view number ".l:view."")
                return
            endif
        endif

    else
        if l:view == ""
            let l:view = w:SignMarks_viewConfigDict["viewNum"]
            "echo "VIEW:".l:view

            if l:view >= len(g:SignMarks_viewsList)
                let l:view = 1
            else
                let l:view += 1
            endif

        endif

        if w:SignMarks_viewConfigDict["userOptions"] !~ '_'
            let l:userOptions .= "_"
        endif
        let l:userOptions .= w:SignMarks_viewConfigDict["userOptions"]
        let l:userOptions .= l:filterFiles
        "echom "userOptions: ".l:userOptions
    endif

    let l:pos = l:view - 1
    let l:list = g:SignMarks_viewsList[l:pos]
    let l:list[3] .= l:filterSignLevel
    
    echo "Switch to view: ".l:list[0].", ".l:list[1]." window, show: ".l:list[2].", options: '".l:list[3]."' userOptions: '".l:userOptions."'"

    call signmarks#OpenView(g:SignMarks_viewsList[l:pos], l:userOptions)
endfunction


" Yank marks on current file as config line
" Format: "vim_signs::23::234::2>45"
" Command: Smy
function! signmarks#ConfigLineYank()
    "echo "[sign-marks] Config line:"
    "let @" = s:MarksGenerateConfigLine()
    let l:configLine = ""

    if exists("b:SignMarks_commentLeader")
        " Comment the config line.
        let l:configLine .= b:SignMarks_commentLeader
    endif

    let l:configLine .= s:MarksGenerateConfigLine("marks-signs")
    let @" = l:configLine
endfunction


" Yank to default buffer marks and signs on current file as config line
" Format: "filename vim_signs::23::234::2>45"
" Command: SmY
function! signmarks#ConfigLineYankWithFileName()
    let l:config = s:MarksGenerateConfigLine("marks-signs")
    let l:file = substitute(expand("%"), "^./", "", "")
    let @" = l:file." ".l:config
endfunction


" Apply marks found on a config line.
" Arg1: config line.
" Return: number of marks applied.
function! s:SignsLineApply(line)
    " Check if we're on a qf window
    if getwinvar(winnr(), '&syntax') == 'qf'
        return 0
    endif
    if a:line == ""
        return 0
    endif
    if a:line !~ g:SignMarks_configLineName.":"
        return 0
    endif
    
    " Delete the string header, ex: '#vim_signs:' or '//vim_signs:'
    let l:line = substitute(a:line,'^.*'.g:SignMarks_configLineName.':','','')

    let l:n = 0

    for l:mark in split(l:line, '::')
        let l:fields = split(l:mark, '=')
        if l:n == 0
            echo "[sign-marks] Apply saved marks:"
        endif
        if len(l:fields) == 2
            " Named marks: "::a=234::"
            let l:name = l:fields[0]
            let l:line = str2nr(l:fields[1])

            if l:name != "" && l:line != 0
                echo " ".l:n.") mark ".l:name." on line ".l:line
                silent! exec("normal ".l:line."Gm".l:name)
                let l:n += 1
            endif
        else
            " Signs, Unnamed marks:
            let l:fields = split(l:mark, '>')
            if len(l:fields) == 2
                " Sign with level: "::2.234::"
                let l:level = str2nr(l:fields[0])
                let l:line = str2nr(l:fields[1])

                if l:level > 0 && level <= len(g:SignMarks_signTypesList) && l:line > 0
                    echo " ".l:n.") sign level ".l:level." on line ".l:line
                    silent exec("normal ".l:line."G")
                    silent! call signmarks#Sign("add", l:level)
                    let l:n += 1
                endif
            else
                " Sign without level: "::234::"
                let l:line = str2nr(l:fields[0])
                if l:line > 0
                    echo " ".l:n.") sign level 1 on line ".l:line
                    silent exec("normal ".l:line."G")
                    silent! call signmarks#Sign("add", 1)
                    let l:n += 1
                endif
            endif
        endif
    endfor

    return l:n
endfunction


" Apply the config line, set all marks.
" If the config line is found on file's first or last 10 lines.
" Arg1: askUser. ask user confirmation before aplying the configuration
function! s:SignsLineParseAndApply(askUser)
    if s:isVimSignsConfigFile() == 1 | return 0 | endif
    "if expand("%:t") =~ g:SignMarks_configFilePrefix
        " Opened a marks config file, do not try loading marks.
        "return
    "endif

    " Save window position
    let l:winview = winsaveview()
    " Save window ID
    "let l:winNr = win_getid()

    " Add lines to be checked for the configuration line
    " Line numbers on top of the file
    let lineNumberList = []
    let l:n = 1

    while l:n <= 10
        let lineNumberList += [l:n]
        let l:n += 1
    endwhile

    " Line numbers on bottom of the file
    let l:n = line("$") - 10
    while l:n <= line("$")
        let lineNumberList += [l:n]
        let l:n += 1
    endwhile

    let l:n = 0
    " Parse first file lines:
    for l:lineNumber in l:lineNumberList
        silent exec 'normal '. l:lineNumber . 'GV"zy'
        let l:line = @z
        "echo "Check config line on line:".l:lineNumber." ".l:line

        if l:line =~ g:SignMarks_configLineName.":"
            if a:askUser != ""
                echo "[sign-marks] Config line found: ".l:line
                if confirm("Apply marks?","&yes\n&no",2) == 2 | 
                    " Restore window position
                    call winrestview(l:winview)
                    return 0
                endif
            endif
            echo "[sign-marks] Config line found on line: ".l:lineNumber
            let l:n = s:SignsLineApply(l:line)
            break
        endif
    endfor

    " Restore window 
    "call win_gotoid(l:winNr)
    " Restore window position
    call winrestview(l:winview)

    return l:n
endfunction

" Return: 1 if is current buffer is a vim-signs config file.
function! s:isVimSignsConfigFile()
    if g:SignMarks_configFilePrefix != ""
        if expand("%:t") =~ g:SignMarks_configFilePrefix
            " Opened a marks config file, do not try loading marks.
            call s:Error("File is a vim-signs config file. (prefix ".g:SignMarks_configFilePrefix." found)")
            return 1
        endif
    endif

    if g:SignMarks_configFileSuffix != ""
        if expand("%:t") =~ g:SignMarks_configFileSuffix
            " Opened a marks config file, do not try loading marks.
            call s:Error("File is a vim-signs config file. (suffix ".g:SignMarks_configFileSuffix." found)")
            return 1
        endif
    endif

    return 0
endfunction


" Save marks to a config file.
" Arg1: file. config file to open.
" Arg2: askUserConsent. ask user confirmation before aplying the configuration
function! s:SignsConfigFileApplyConfigLine(file, askUserConsent)
    "echom "SignsConfigFileApplyConfigLine file:".a:file

    if s:isVimSignsConfigFile() == 1 | return 0 | endif

    "if g:SignMarks_configFilePrefix != ""
        "if expand("%:t") =~ g:SignMarks_configFilePrefix
            "" Opened a marks config file, do not try loading marks.
            "call s:Error("File is a vim-signs config file.")
            "return 0
        "endif
    "endif

    "if g:SignMarks_configFileSuffix != ""
        "if expand("%:t") =~ g:SignMarks_configFileSuffix
            "" Opened a marks config file, do not try loading marks.
            "call s:Error("File is a vim-signs config file.")
            "return 0
        "endif
    "endif

    if !filereadable(a:file)
        return 0
    endif

    echo "[sign-marks] Config file found: ".a:file
    silent exec ("new ".a:file)
    silent exec 'normal ggV"zy'
    silent quit!
    let l:line = @z

    if a:askUserConsent != ""
        echo "[sign-marks] Config line found: ".l:line
        if confirm("Apply marks?","&yes\n&no",2) == 2 | 
            return 0 
        endif
    endif

    if l:line != ""
        return s:SignsLineApply(l:line)
        "silent! call s:SignsLineApply(l:line)
        "return
    endif
    return 0
endfunction


" Return: filename to save the config on same directory of current file.
function! s:getConfigFile1()
    " Config file type 1: "dir1/dir2/dirN/_marks_file.extension"
    let l:file = expand("%:h")."/".g:SignMarks_configFilePrefix.expand("%:t:r").g:SignMarks_configFileSuffix
    return l:file
endfunction


" Return: filename to save the config on current working current directory.
function! s:getConfigFile2()
    let l:file = ""
    " Config file type 2:
    if executable('md5sum') && g:SignMarks_configFileNameUseMd5 == 1
        " Convert filename to md5 number:
        let l:result = system("md5sum ".expand("%"))
        let l:list = split(l:result, " ")
        " File name is: "_vimSignMarks_29a04a611e8eb85935c4b6d5e57ca632.cfg"
        let l:file = g:SignMarks_configFilePrefix.l:list[0].g:SignMarks_configFileSuffix
    else
        " File name is:  "dir1/dir2/dirN/_vimSignMarks_fileName.cfg"
        let l:file = expand("%:h")."/".g:SignMarks_configFilePrefix.expand("%:t:r").g:SignMarks_configFileSuffix
    endif
    "echo "file2: ".l:file
    return l:file
endfunction


" Return: filename to save the config on same directory of current file.
"function! s:getConfigFile3()
    " Config file type 1: "dir1/dir2/dirN/file.extension.vim-hi.cfg"
    "let l:file = expand("%:h")."/".g:SignMarks_configFilePrefix.expand("%:t:r").g:SignMarks_configFileSuffix
    "return l:file
"endfunction




" Apply marks config line if found otherwhise search
" and apply the marks on the config file.
" Command: Sml
" Arg1: [configLine]. "vim_signs:a=1::b=34::35::345::"
" Arg2: [askUserConsent]. ask user confirmation before aplying the configuration
function! signmarks#Load(configLine, verbose, askUserConsent)
    if getwinvar(winnr(), '&syntax') == 'qf'
        return
    endif

    if a:verbose != ""
        echo expand("%")
        silent call signmarks#SignsDeleteAll("","")
    endif

    if s:isVimSignsConfigFile() == 1 | return 0 | endif

    if a:configLine != ""
        " Use the config line passed as parameter.
        call s:SignsLineApply(a:configLine)
        return
    endif

    if s:SignsLineParseAndApply(a:askUserConsent) != 0
        echo "[sign-marks] Marks config line applied"
        return
    endif

    " First search for config file on current working directory:
    let l:file =  s:getConfigFile2()
    if s:SignsConfigFileApplyConfigLine(l:file, a:askUserConsent) != 0
        echo "[sign-marks] Marks config file2 applied: ".l:file
        return
    endif

    " Search for config on the current file directory:
    let l:file =  s:getConfigFile1()
    if s:SignsConfigFileApplyConfigLine(l:file, a:askUserConsent) != 0
        echo "[sign-marks] Marks config file1 applied: ".l:file
        return
    endif
endfunction


" Apply marks config line if found otherwhise search
" and apply the marks on the config file.
" Arg1: askUserConsent. ask user confirmation before aplying the configuration
function! signmarks#LoadAuto(askUserConsent)
    " Prevent auto config from launching SetConfigLine again.
    if exists("w:SignMarks_done")
        return
    endif
    let w:SignMarks_done = 1

    call signmarks#Load("", "", a:askUserConsent)
endfunction


" Open all config files
" Cmd: SingsUpdateOldCfg
function! signmarks#OldConfigFileUpdate()
    if getwinvar(winnr(), '&syntax') == 'qf'
        return
    endif

    if exists("w:SignMarks_viewConfigDict")
        " Skip any Signs view window.
        return
    endif

    let l:file = expand("%")

    let l:configFilesList  =  []
    let l:configFilesList +=  [ s:getConfigFile1() ]
    let l:configFilesList +=  [ s:getConfigFile2() ]

    let l:configFiles = 0
    for l:configFile in l:configFilesList
        if !empty(glob(l:configFile)) && filereadable(l:configFile)
            echo "Check ".l:configFile." found"
            if l:configFiles == 0
                silent exec ("tabnew ".l:configFile)
            else
                silent exec ("new ".l:configFile)
            endif
        else
            echo "Check ".l:configFile." not found"
        endif
    endfor
endfunction


" Open all config files
" Cmd: Smo
function! signmarks#ConfigFileOpen()
    if getwinvar(winnr(), '&syntax') == 'qf'
        return
    endif

    if exists("w:SignMarks_viewConfigDict")
        " Skip any Signs view window.
        "echom "Skip file: ".expand("%")
        return
    endif

    let l:file = expand("%")

    let l:configFilesList  =  []
    let l:configFilesList +=  [ s:getConfigFile1() ]
    let l:configFilesList +=  [ s:getConfigFile2() ]

    let l:configFiles = 0
    for l:configFile in l:configFilesList
        if !empty(glob(l:configFile)) && filereadable(l:configFile)
            call s:EchoGreen("Check '".l:configFile."' ", "found", "")

            if l:configFiles == 0
                silent exec ("tabnew ".l:configFile)
            else
                silent exec ("new ".l:configFile)
            endif
        else
            call s:EchoOrange("Check '".l:configFile."' ", "NOT found", "")
        endif
    endfor
endfunction


" Save marks to a config file.
" Arg1: useFileNum.
"   none: open menu to choose the config file.
"   .: save on default config file path.
"   1: save on the file as config line.
"   2: save on config file on current file's directory.
"   3: save on config file on current working directory.
" Command: Smsv
function! signmarks#ConfigFileSave(useFileNum)
    if getwinvar(winnr(), '&syntax') == 'qf'
        return
    endif

    if exists("w:SignMarks_viewConfigDict")
        " Skip any Signs view window.
        "echom "Skip file: ".expand("%")
        return
    endif

    let l:file = expand("%")
    echo l:file
    echo " "

    let l:newfile1 =  s:getConfigFile1()
    let l:newfile2 =  s:getConfigFile2()

    if a:useFileNum == ""
        echo "[sign-marks] Save marks config on file:"
        echo " 1) current file: ".expand("%")." (as config line)"
        echo " 2) ".l:newfile1
        echo " 3) ".getcwd()."/".l:newfile2
        echo " 4) enter name manually"
        "echo " 5) last file: "
        let l:useFileNum = confirm("","Choose option? &1\n&2\n&3\n&4", g:SignMarks_configFileDefault)
    else
        if a:useFileNum == "."
            let l:useFileNum = g:SignMarks_configFileDefault
        else
            let l:useFileNum = a:useFileNum
        endif
    endif

    if l:useFileNum == "1"
        call signmarks#SetConfigLine("", "")
        return
    elseif l:useFileNum == "2"
        let l:newfile = l:newfile1
    elseif l:useFileNum == "3"
        let l:newfile = l:newfile2
    elseif l:useFileNum == "4"
        let l:newfile = input("Use filename: ")
    else
        call s:Error("Unknown option: ".l:useFileNum)
        return
    endif

    let l:linesList =  s:GetMarksLineNumbList("marks-signs", [])
    if len(l:linesList) == 0
        call s:Warn("No marks found")
        return
    endif

    let l:configLine = s:MarksGenerateConfigLine("marks-signs")
    echo " "
    if l:configLine == ""
        return
    endif


    let fileExist = 1
    if empty(glob(l:newfile)) || !filereadable(l:newfile)
        let l:fileExist = 0
    endif

    " Save window ID
    let l:winId = win_getid()
    " Save window position
    let l:winview = winsaveview()

    silent exec ("tabnew ".l:newfile)
    if l:fileExist == 0
        let @z = l:file
        silent put z
    endif
    let @z = l:configLine
    normal! gg
    silent put z
    normal! ggddp
    silent w
    silent quit!

    " Restore window
    call win_gotoid(l:winId)
    " Restore window position
    call winrestview(l:winview)

    if l:useFileNum != ""
        echo "Marks config line saved to: ".l:newfile.""
    endif
endfunction


" Save all window marks to config files.
" Arg1: useFileNum.
"   none: open menu to choose the config file.
"   0: save on default config file path.
"   1: save on config file on current file's directory.
"   2: save on config file on current working directory.
" Command: Smsva
function! signmarks#SaveAll(useFileNum)
    " Save window 
    let l:winId = win_getid()

    " Save window position
    let l:winview = winsaveview()

    "tabdo windo call signmarks#Save(a:useFileNum)
    "bufdo call signmarks#Save(a:useFileNum)
    bufdo call signmarks#ConfigFileSave(a:useFileNum)

    " Restore window
    call win_gotoid(l:winId)

    " Restore window position
    call winrestview(l:winview)
endfunction


" Load all window marks from config files.
" Command: Smla
function! signmarks#LoadAll()
    " Save window 
    let l:winId = win_getid()

    " Save window position
    let l:winview = winsaveview()

    "tabdo windo call signmarks#Load("", "")
    bufdo call signmarks#Load("", "verbose", "")

    " Restore window
    call win_gotoid(l:winId)

    " Restore window position
    call winrestview(l:winview)
endfunction


" Add config line on current file to save all marks.
" Config line position depends on the file type, usually is writted down on
" top of the file.
" Command: Smcl, Smclw
function! signmarks#SetConfigLine(cleanConfigLine, saveFile, userConfirm)
    if s:isVimSignsConfigFile() == 1 | return 0 | endif
    "if expand("%:t") =~ g:SignMarks_configFilePrefix
        " Opened a marks config file, do not try loading marks.
        "return
    "endif

    " Save window position
    let l:winview = winsaveview()

    silent let l:configLineTmp = s:MarksGenerateConfigLine("marks-signs")
    if a:cleanConfigLine != "" && a:userConfirm != ""
        call confirm("Add or replace (if exists) the config line?")
    endif

    if l:configLineTmp != ""
        let l:configLine = ""
        if exists("b:SignMarks_commentLeader")
            " Comment the config line.
            let l:configLine .= b:SignMarks_commentLeader
        endif
        let l:configLine .= l:configLineTmp

        if a:cleanConfigLine != ""
            " Remove any previous config line.
            silent exec("silent! g/".g:SignMarks_configLineName.":/d")
        endif

        let @" = l:configLine

        if exists("b:SignMarks_line")
            if b:SignMarks_line <= 0
                " Set config line x lines upwards from file's bottom.
                " If 0, set on bottom.
                let l:line = line("$") - b:SignMarks_line
                silent exec("normal ".l:line."Gop")
            else
                " Set config line x lines downwards from file's top
                let l:line = b:SignMarks_line
                silent exec("normal ".l:line."GOp")
            endif
            echo "[sign-marks] Config line set on line: ".l:line
        else
            if g:SignMarks_configLineDefaultPos == "top"
                " Set config line on first file's line.
                normal ggOp
                echo "[sign-marks] Config line first line."
            else
                " Set config line on last file's line
                silent exec("normal Gop")
                echo "[sign-marks] Config line set on last line."
            endif
        endif
    endif

    " Restore window position
    call winrestview(l:winview)

    if a:saveFile != ""
        silent w
    endif
endfunction


"------------------------------------------------
" Signs AKA Unnamed Marks:
"------------------------------------------------

function! s:ShowdefaultHighlightingGroupColors()
        let l:colorList = ["ColorColumn", "Conceal", "Cursor", "CursorIM", "CursorColumn", "CursorLine", "Directory", "DiffAdd", "DiffChange", "DiffDelete", "DiffText", "ErrorMsg", "VertSplit", "Folded", "FoldColumn", "SignColumn", "IncSearch", "LineNr", "MatchParen", "ModeMsg", "MoreMsg", "NonText", "Normal", "Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb","Question", "Search", "SpecialKey", "SpellBad", "SpellCap", "SpellLocal", "SpellRare", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel", "Title", "Visual", "VisualNOS", "WarningMsg", "WildMenu"]
        let n = 1
        for l:color in l:colorList
            if l:n > 6 | let l:n = 1 | echo "" | endif
            exec ("echohl ".l:color) 
            echon printf("%14s ", l:color)
            echohl None
            let n += 1
        endfor
        echo " "
endfunction


" Show all signs available and is's number and color highlighting.
function! s:ShowSignColorsCompact()
    let l:columns = 3
    echon printf("(SignLevel) Sign|LineContent\n")
    echon printf("--------------------------------------------------------\n")
    let l:n = 1
    let l:i = 0
    for l:colorList in g:SignMarks_signTypesList
        let i += 1
        if l:n == 100
            break
        endif

        echon printf("%-4s ", "(".l:n.")")
        exec ("echohl ".l:colorList[1]) 

        if l:colorList[0] == ""
            echon printf("%-2s", l:n)
        else
            echon printf("%-2s", l:colorList[0])
        endif
        echohl None

        echon printf("|")

        exec ("echohl ".l:colorList[2]) 
        echon printf("Content")
        echohl None

        echon printf("     ")
        if l:i == l:columns
            echon printf("\n")
            let l:i = 0
        endif
        let n += 1
    endfor
endfunction


" Show all signs available and is's number and color highlighting.
function! s:ShowSignColors()
    echon printf("%-5s %-4s   LineContent   Mapping\n", "Level", "Sign")
    echon printf("-----------------------------------\n")

    let n = 1
    for l:colorList in g:SignMarks_signTypesList
        if l:n == 100
            break
        endif

        echon printf("%-5d ", l:n)
        exec ("echohl ".l:colorList[1]) 

        if l:colorList[0] == ""
            echon printf("%-4s", l:n)
        else
            echon printf("%-4s", l:colorList[0])
        endif
        echohl None

        echon printf("   ")

        exec ("echohl ".l:colorList[2]) 
        echon printf("Line content")
        echohl None

        echon printf("   ")
        echon printf("%s\n", g:SignMarks_signMappingList[l:n-1])
        let n += 1
    endfor
endfunction


" Show all signs available and is's number and color highlighting.
" Cmd: Smsh
function! signmarks#ShowColors()
    echon printf("[sign-marks] available signs:\n\n")
    call s:ShowSignColors()
endfunction


" Add/delete signs (unnamed mark) on current/selected lines 
" Unnamed marks help extend the vim marks as the later ones only allow 25 marks.
" Arg1: options:
"  "add-delete": add new sign, delete it if there's already a sign on the same line.
"  "add": add new sign if there's no sign on the same line.
"  "delete": delete the sign if already exists a sign on the same line.
" Arg2: sign level number, related to g:SignMarks_signTYpesList.
" Command: Sm, Sma, Smd
function! signmarks#Sign(options, level) range
    if exists("w:SignMarks_viewConfigDict")
        " We are on a view window.
        call s:Warn("Can't add sign on a view window.")
        return
    endif

    if expand("%") == ""
        call s:Warn("[sign-marks] can't place sign on unnamed buffer")
        return
    endif

    if a:options !~ "add" && a:options !~ "delete"
        call s:Err("[sign-marks] Missing options: add, delete or add-delete.")
        return
    endif

    " Save window position
    let l:winview = winsaveview()

    let l:linesList = []
    let l:linesNum = a:lastline - a:firstline

    if l:linesNum != 0
        let l:n = str2nr(a:firstline)
        while l:n <= a:lastline
            let l:linesList += [ l:n ]
            let l:n += 1
        endwhile
    else
        let l:linesList += [ line(".") ]
    endif

    let l:addNum = 0
    let l:delNum = 0

    if a:level != ""
        if a:level == "0"
            let l:levelStr = "10"
        else
            let l:levelStr = a:level
        endif
        let l:level = str2nr(l:levelStr)
        if l:level >= 100 || l:level <= 0
            call s:Error("Wrong sign level ".l:level)
            return
        endif

        if l:level < 0 || l:level > len(g:SignMarks_signTypesList)
            call s:Error("Wrong sign level ".l:level)

            " Restore window position
            call winrestview(l:winview)
            return
        endif
    else
        let l:level = -1
    endif

    let l:messageList = []

    for line in l:linesList
        let l:prevLevel = s:GetSignLevel(l:line)
        "echom "prevLevel: ".l:prevLevel." level: ".l:level | call input("")

        if a:options =~ "delete" && l:prevLevel != 0 
            if l:level == -1 || l:level == l:prevLevel
                " Remove already existing mark
                silent exec("sign unplace ".l:line." file=".expand("%"))
                let l:messageStr = "Sign deleted on line ".l:line
                let l:messageList += [ l:messageStr ]
                let l:delNum += 1
                continue
            endif
        endif

        if a:options =~ "add"
            if l:prevLevel != 0 && l:level != l:prevLevel
                " Remove already existing mark
                silent exec("sign unplace ".l:line." file=".expand("%"))
                let l:message = "changed"
            else
                let l:message = "added"
            endif

            if l:level == -1
                call s:ShowSignColorsCompact()
                while 1
                    let l:levelStr = input("Choose sign level: ")
                    if l:levelStr == "" || l:levelStr == ''
                        return
                    endif
                    let l:messageList += [ " " ]
                    let l:level = str2nr(l:levelStr)
                    if l:level > 0 && l:level <= len(g:SignMarks_signTypesList)
                        redraw
                        break
                    endif
                    call s:Warn("Wrong level ".l:level. " (Use numbers between 1 and ".len(g:SignMarks_signTypesList).")")
                endwhile
            endif

            " Add new mark
            silent exec("sign place ".l:line." line=".l:line." name=VimSigns".l:level." file=".expand("%"))
            let l:addNum += 1
            let l:messageStr = "Sign s".l:level." ".l:message." on line ".l:line
            let l:messageList += [ l:messageStr ]
        endif
    endfor

    if len(l:messageList) == 1
        echo "[sign-marks] ".l:messageList[0]
    elseif len(l:messageList) > 0
        for l:message in l:messageList
            echo l:message
        endfor
        echo "[sign-marks] ".l:addNum." signs added, ".l:delNum." signs deleted"
    endif

    " Restore window position
    call winrestview(l:winview)
endfunction


" Delete all signs (unnamed marks).
" Arg1: [signLevels], string with the sign levels to delete.
" ex: "1 2 3"
" Command: SmD
function! signmarks#SignsDeleteAll(confirm, signLevels)
    if exists("w:SignMarks_viewConfigDict")
        " We are on a main window neither a view window.
        return
    endif

    let l:levelStr = ""
    if a:signLevels != ""
        let l:levelStr = " with levels: ".a:signLevels
    endif

    if a:confirm == "confirm"
        call confirm("[sign-marks] Delete all signs".l:levelStr."?")
    endif

    let l:signLevelsList = split(a:signLevels)
    let l:lineNumList = s:GetSignsLineNumbersAsList(l:signLevelsList)

    if len(l:lineNumList) <= 0
        call s:Warn("[sign-marks] No signs found.")
        return
    endif

    let l:n = 0
    for l:line in l:lineNumList
        echo "Delete sign on line ".l:line
        silent exec("sign unplace ".l:line." file=".expand("%"))
        let l:n += 1
    endfor

    echo " "
    echo "[sign-marks] ".l:n." signs deleted"
endfunction


" Get signs info.
" Display the total number of signs on current file.
" Display the number of signs on each level too.
" Cmd: Smi
function! signmarks#SignsInfo()
    if exists("w:SignMarks_viewConfigDict")
        " We are on a view window.
        "call s:Warn("Can't show sign info on a view window.")

        let l:headerLines = w:SignMarks_viewConfigDict["headerLines"]
        let l:pos = line(".") - l:headerLines

        let l:row = w:SignMarks_viewConfigDict["fullDataList"][l:pos][0]
        let l:col = w:SignMarks_viewConfigDict["fullDataList"][l:pos][1]
        let l:sign = w:SignMarks_viewConfigDict["fullDataList"][l:pos][2][1:]
        let l:text = w:SignMarks_viewConfigDict["fullDataList"][l:pos][3]

        echo "Sign Info: level:".l:sign." line:".l:row." content:'".l:text."'" 
        return
    endif

    let l:signNumOnLevelList = []
    let l:signsFound = 0

    for l:level in g:SignMarks_signTypesList
        let l:signNumOnLevelList += [ 0 ]
    endfor

    let l:signDict = sign_getplaced(expand("%"))
    "let l:signDict =  exec("sign place file=".expand("%"))
    "let l:signDict =  exec("sign place")
    let l:signsList = get(l:signDict, 'signs', [])
    let l:signsList = get(l:signsList, 'signs', [])

    for l:signDict in l:signsList
        let l:name = get(l:signDict, "name", "")

        if l:name =~ "VimSigns"
            let l:level = substitute(l:name, "VimSigns", "", "")
            let l:levelNr = str2nr(l:level)

            if l:levelNr > 0 && l:levelNr <= len(g:SignMarks_signTypesList)
                let l:signNumOnLevelList[l:levelNr-1] += 1
                let l:signsFound += 1
            endif
        endif
    endfor

    if l:signsFound > 0
        let l:n = 1
        for l:signNumbOnLevel in l:signNumOnLevelList
            if l:signNumbOnLevel > 0
                let l:signChar = g:SignMarks_signTypesList[l:n-1][0]
                if l:signChar == ""
                    let l:signChar = l:n
                endif

                let l:signHi = g:SignMarks_signTypesList[l:n-1][1]
                let l:lineHi = g:SignMarks_signTypesList[l:n-1][2]

                if l:lineHi != "" | exec("echohl ".l:lineHi) | endif
                echon printf("Signs on level s%-2d : %-4d   ", "".l:n, l:signNumbOnLevel)
                echohl None

                if l:signHi != "" | exec("echohl ".l:signHi) | endif
                echon printf("(%2s)\n", l:signChar)
                echohl None
            endif
            let l:n += 1
        endfor
        echo "[sign-marks] Total signs found: ".l:signsFound
    else
        echo "[sign-marks] No signs found."
    endif
endfunction


" Replace/delete sign levels.
" Arg1: [currentLevel], level number to be replaced (1 to 36).
" Arg2: [newLevel], level to put in place (1 to 36). Use '-' to delete the sign.
" Cmd: Smc, SmC
function! signmarks#SignsLevelChange(...)
    let l:askUser = ""
    let l:currentLevel = ""
    let l:newLevel = ""
    let l:max = len(g:SignMarks_signTypesList)

    if a:0 >= 1
        let l:askUser = a:1
        "echom "askUser ".l:askUser
    endif
    if a:0 >= 2
        if a:2 == "-" || a:2 == ""
            let l:currentLevel = ""
        else
            let l:currentLevel = str2nr(a:2)
            if l:currentLevel < 1 || l:currentLevel > l:max
                call s:Error("Wrong sign level ".a:2)
                return
            endif
        endif
        "echom "currentLevel ".l:currentLevel
    endif
    if a:0 >= 3
        if a:3 != "-"
            let l:newLevel = str2nr(a:3)
            if l:newLevel < 1 || l:newLevel > l:max
                call s:Error("Wrong sign level ".a:3)
                return
            endif
        else
            let l:newLevel = "-"
        endif
        "echom "newLevel ".l:newLevel
    endif

    let l:newTmpLevel = ""
    let l:n = 0
    let l:i = 0

    if l:currentLevel != ""
        if l:currentLevel =~ ","
            let l:checkLevelsList = split(l:curentLevel,',')
            let l:signsList = s:GetSignsList("", l:checkLevelsList)
        else
            let l:signsList = s:GetSignsList("", [l:currentLevel])
        endif
    else
        let l:signsList = s:GetSignsList("", [])
    endif
    "echom "signsList "l:signsList

    for l:signsList in l:signsList
        redraw

        if l:newTmpLevel != ""
            let l:newLevel = ""
        endif
        let l:line = l:signsList[0]
        let l:level = l:signsList[2]
        let l:content = l:signsList[3]
        let i += 1

        if l:newLevel == ""
            echo "Line:".l:line." | Level:".l:level." | Content:".l:content
            while 1
                let l:newLevelStr = input("Select new sign level (1-".l:max."): ")
                let l:newTmpLevel = str2nr(l:newLevelStr)
                if l:newTmpLevel == 0 | break | endif
                if l:newTmpLevel >= 1 && l:newTmpLevel <= l:max
                    let l:newLevel = l:newTmpLevel
                    break
                endif
                call s:Warn(" Wrong sign level ".l:newTmpLevel)
                echo ""
            endwhile
            if l:newTmpLevel == 0 | continue | endif

        elseif l:askUser != ""
            echo "Line:".l:line." | Level:".l:level." | Content:".l:content
            if l:newLevel != "-"
                let l:userResp = confirm("Change sign to level ".l:newLevel, "&yes\n&no\n&all", 2)
            else
                let l:userResp = confirm("Remove sign with level ".l:level, "&yes\n&no\n&all", 2)
            endif
            if l:userResp == 2
                continue
            elseif l:userResp == 3
                let l:askUser = ""
            endif
        endif

        silent exec("sign unplace ".l:line." file=".expand("%"))
        if l:newLevel != "-"
            silent exec("sign place ".l:line." line=".l:line." name=VimSigns".l:newLevel." file=".expand("%"))
        endif
        let n += 1

        redraw
    endfor

    if l:newTmpLevel != ""
        let l:newLevel = ""
    endif

    if l:i == 0
        if l:currentLevel == ""
            call s:Warn("No signs found")
        else
            call s:Warn("No signs found on level ".l:currentLevel)
        endif
    else
        if l:newLevel == "-"
            if l:n > 0
                if l:currentLevel == ""
                    echo "[sign-marks] ".l:n." signs removed"
                else
                    echo "[sign-marks] ".l:n." signs changed from level s".l:currentLevel
                endif
            else
                if l:currentLevel == ""
                    call s:Warn("No signs changed")
                else
                    call s:Warn("No signs removed from level s".l:currentLevel)
                endif
            endif
        else
            if l:n > 0
                if l:currentLevel == "" && l:newLevel == ""
                    echo "[sign-marks] ".l:n." signs changed".l:currentLevel
                elseif l:currentLevel != "" && l:newLevel == ""
                    echo "[sign-marks] ".l:n." signs changed from ".l:currentLevel
                elseif l:currentLevel == "" && l:newLevel != ""
                    echo "[sign-marks] ".l:n." signs changed to s".l:newLevel."."
                else
                    echo "[sign-marks] ".l:n." signs changed from ".l:currentLevel." to s".l:newLevel."."
                endif
            else
                if l:currentLevel == "" && l:newLevel == ""
                    call s:Warn("No signs changed")
                elseif l:currentLevel != "" && l:newLevel == ""
                    call s:Warn("No signs changed from level ".l:currentLevel)
                elseif l:currentLevel == "" && l:newLevel != ""
                    call s:Warn("No signs changed to ".l:newLevel)
                else
                    call s:Warn("No signs changed from level ".l:currentLevel." to ".l:newLevel)
                endif
            endif
        endif
    endif
endfunction


"------------------------------------------------
" Utils Functions:
"------------------------------------------------

" Get the maximum name lenght of the marks and signs.
" Return: maximum name's string lenght.
function s:GetSignsNumStrLen()
    let l:lineNumList = s:GetSignsLineNumbersAsList([])
    let l:listLen = len(l:lineNumList)
    let l:numbLen = len(l:listLen)
    "echo "numbLen: ".l:numbLen
    if l:numbLen == 0
        return 1
    else 
        return l:numbLen
    endif
endfunction


" Return: maximum string length for the line number field.
function! s:GetLineNumbMaxStrLen()
    let l:list = []
    let l:list += s:GetMarksList()
    let l:list += s:GetSignsList("", [])

    if len(l:list) <= 0
        return 0
    endif

    "call sort(l:list,"n")
    call sort(l:list, "signmarks#NumericSortList0")
    let l:maxLen = len(l:list[-1][0])
    "echo "maxLen:".l:maxLen
    return l:maxLen
endfunction


"------------------------------------------------
" Navigate On Marks And Signs:
"------------------------------------------------

" Arg1: marktypes:
"   marks: show marks.
"   signs: show signs AKA unnamed marks.
" Return: list with all line numbers having a mark or an unnamed mark.
function! s:GetMarksLineNumbList(marktypes, signLeveList)
    let l:linesList = []

    if a:marktypes =~ "marks"
        " Get named marks:
        let l:linesList += s:GetMarksLineNumbersAsList()
    endif

    if a:marktypes =~ "signs"
        " Get signs:
        let l:linesList += s:GetSignsLineNumbersAsList(a:signLeveList)
    endif

    call sort(l:linesList, "n")
    "echo "LIST: "l:linesList
    return l:linesList
endfunction


" Goto next mark
" Arg1: marktypes:
"   marks: show marks.
"   signs: show signs AKA unnamed marks.
" Command: Smn, SmN
function! signmarks#MarksNext(marktypes)
    let l:linesList = s:GetMarksLineNumbList(a:marktypes, [])
    if len(l:linesList) == 0
        call s:Warn("No marks found")
        return
    endif

    let l:nextMark = ""
    for l:line in l:linesList
        if l:line > line(".")
            let l:nextMark = l:line
            break
        endif
    endfor

    if l:nextMark != ""
        silent exec("normal ".l:nextMark."G")
    else
        call s:Warn("Last mark")
        normal gg
        call signmarks#MarksNext(a:marktypes)
    endif
endfunction


" Goto previous mark
" Arg1: marktypes:
"   marks: show marks.
"   signs: show signs AKA unnamed marks.
" Command: Smp, SmP
function! signmarks#MarksPrev(marktypes)
    let l:linesList = s:GetMarksLineNumbList(a:marktypes, [])
    if len(l:linesList) == 0
        call s:Warn("No marks found")
        return
    endif

    call reverse(l:linesList)
    let l:prevMark = ""

    for l:line in l:linesList
        if l:line < line(".")
            let l:prevMark = l:line
            break
        endif
    endfor

    if l:prevMark != ""
        silent exec("normal ".l:prevMark."G")
    else
        call s:Warn("First mark")
        normal G
        call signmarks#MarksPrev(a:marktypes)
    endif
endfunction


"------------------------------------------------


" Once on view window type new/tab/vertical new, 
" goto same line on main window.
" Command: Smg
function! signmarks#GotoMainFileLine()
    " Save window ID
    let l:winId = win_getid()
    " Save window position
    let l:winview = winsaveview()
    " Save column position
    let l:col = col(".")

    if exists("w:SignMarks_mainConfigDict")
        " We are on a main window.
        let l:mainWinLineNum = line(".")
        let l:mainLineContent = getline(".")

        " Reload the view window.
        let l:optionsList = w:SignMarks_mainConfigDict["optionsList"]
        let l:filterList = w:SignMarks_mainConfigDict["filterList"]
        call s:OpenView(l:optionsList, filterList)

        " Check if current line has a sign or mark
        let lineFound = 0
        let n = 1

        let l:headerLines  = w:SignMarks_viewConfigDict["headerLines"]
        let l:fullDataList = w:SignMarks_viewConfigDict["fullDataList"]
        let l:options      = w:SignMarks_viewConfigDict["options"].w:SignMarks_viewConfigDict["userOptions"]

        let l:fullDataListSortUniq = s:GetSortedUniqList(l:fullDataList, l:options)

        for l:dataList in l:fullDataListSortUniq
            if l:dataList[0] == l:mainWinLineNum
                " Line has sign or mark
                " Synchronize the position on main and view windows:
                let l:viewWinLineNum = l:headerLines + l:n
                " Goto same row on view window
                silent! exec("normal ".l:viewWinLineNum."G")
                " Restore column position
                silent! exec("normal 0".l:col."l")
                let lineFound = 1
                "normal zz
                echo "[sign-marks] Goto view window, line: ".l:viewWinLineNum."."
                break
            endif
            let n += 1
        endfor

        if lineFound == 0
            " If line on main window does not contain a sign,
            " Or the sign is not been found on view window,
            " Stay in main window
            " Restore window
            call win_gotoid(l:winId)
            " Restore window position
            call winrestview(l:winview)
            echo "[sign-marks] Update view window."
        else
            if stridx(getline("."), l:mainLineContent) < 0
                echo "Expected content: '".l:mainLineContent."'"
                echo "Found content:    '".getline(".")."'"
                call s:Warn("Attention! Mismatch found: content changed between main and view windows'")
            endif
        endif
        return
    endif

    if !exists("w:SignMarks_viewConfigDict")
        " We are not on a main window neither a view window.
        return
    endif

    if len(g:SignMarks_viewsList) <= 0
        call s:Error("Empty views list (Err1).")
        return
    endif

    let l:view = w:SignMarks_viewConfigDict["viewNum"]
    if l:view == "" || l:view > len(g:SignMarks_viewsList)
        call s:Error("View number not found ".l:view)
        return
    endif

    let l:wintype = g:SignMarks_viewsList[l:view-1][1]
    if l:wintype == "qf" 
        " Quickfix window, no need of Smg command, just press <enter>
        normal 
        return
    endif

    let l:options = w:SignMarks_viewConfigDict["options"].w:SignMarks_viewConfigDict["userOptions"]
    if l:options =~? "A" || l:options =~? "W" 
        call s:Warn("Option not available when showing all windows' signs/marks (option A or W active)")
        return
    endif

    let l:headerLines = w:SignMarks_viewConfigDict["headerLines"]
    let l:pos = line(".") - l:headerLines -1
    "echom "pos:".l:pos

    let l:fullDataList = w:SignMarks_viewConfigDict["fullDataList"]
    let l:filteredFultDataList = s:GetSortedUniqList(l:fullDataList, l:options)
    if l:pos > len(l:filteredFultDataList)
        call s:Error("Line number not found. Out of list, pos:".l:pos)
        return
    else
        let l:lineNum = l:filteredFultDataList[l:pos][0]
    endif
    "echo "pos:".l:pos." line:".line(".")." headerLine:".l:headerLines." lineNum:".l:lineNum

    if l:lineNum == 0
        call s:Error("Line number not found.")
        return
    endif

    echo "[sign-marks] Goto main window, line ".l:lineNum."."

    let l:filename = w:SignMarks_viewConfigDict["fileName"]
    let l:lineContent = getline(".")

    if l:wintype == "new" 
        wincmd k 
    elseif l:wintype == "vnew" 
        wincmd h 
    else
        call s:Error("Option not available for ".l:wintype." window")
        return
    endif
 
    if expand("%") != l:filename
        " Restore window
        call win_gotoid(l:winId)
        " Restore window position
        call winrestview(l:winview)
        call s:Error("Main file not found: ".l:filename)
        return
    endif

    if l:lineNum > line("$")
        " Restore window
        call win_gotoid(l:winId)
        " Restore window position
        call winrestview(l:winview)
        call s:Error("Line not found: ".l:lineNum)
        return
    endif

    silent exec("normal ".l:lineNum."Gzz")

    if stridx(l:lineContent, getline(".")) < 0
        echo "Expected content: '".l:lineContent."'"
        echo "Found content:    '".getline(".")."'"
        call s:Warn("Attention! Mismatch found: content changed between view and main windows'")
    endif

    " Restore column position
    silent! exec("normal 0".l:col."l")
endfunction


"------------------------------------------------
" Auto Load Config File:
"------------------------------------------------
" Search for the marks config line on current file.
" If not found, try to open marks config file.
" Config file possible paths are: 
"   "_marks_29a04a611e8eb85935c4b6d5e57ca632.cfg" or if no md5sum command: 
"   "_marks_dir1__dir2__dirN___fileName.cfg" and  
"   "dir1/dir2/dirN/_marks_fileName.cfg"
" config line format:  
function! signmarks#AutoConfigInit()
    "echom "mAutoConfigInit()"
    if g:SignMarks_autoLoadConfigActive != 1
        return
    endif

    augroup SignMarks_AutoConfig
        silent! autocmd!

        let filterList = []

        " ATTENTION: options empty and * are forbiden, a value must be specified.
        "  Otherwhise there's an issue with quickfix window
        if g:SignMarks_autoLoadConfigFilter == "" || g:SignMarks_autoLoadConfigFilter == "*"
            call s:Error("Auto load config filter: '".g:SignMarks_autoLoadConfigFilter."' not allowed.")
            return
        else
            let list = split(g:SignMarks_autoLoadConfigFilter, " ")
            if len(l:list) > 0
                let l:filterList = l:list
            else
                let filterList .= [g:HiAutoConfigSearchOnFileTypes]
            endif
        endif
        "echom "filterList: "l:filterList

        for filtStr in l:filterList
            silent! exec "noauau BufReadPost ".l:filtStr
            let cmd = "au BufReadPost ".l:filtStr." call signmarks#Load(\"\", \"\", \"".g:SignMarks_configLineAskUserToApply."\")"
            "echom "au ".l:cmd
            silent exec(l:cmd)
        endfor
    augroup END
endfunction


"------------------------------------------------
" Help And Menus Functions:
"------------------------------------------------
" Show plugin command help menu.
" Command: Smh
function! signmarks#Help()
    let l:text  = ""
    let l:text .= "[".s:plugin_name."] help (v".g:signmarks_version."):\n"
    let l:text .= "  \n"
    let l:text .= "Abridged command help:\n"
    let l:text .= "\n"
    let l:text .= "Sign commands:\n"
    let l:text .= "   Smsh        : show the sign levels available and its color configuration.\n"
    let l:text .= "   Sm [LEVEL]  : add or delete (if already exists) a sign on th selected lines\n"
    let l:text .= "   Sma [LEVEL] : add sign on the selected lines\n"
    let l:text .= "   Smd         : delete sign on the selected lines\n"
    let l:text .= "   SmD [LEVEL] : delete all signs\n"
    let l:text .= "   Smi         : show signs info\n"
    let l:text .= "   Smc [LEVEL] [NEW_LEVEL] : change signs on level to new_level, ask user confirmation\n"
    let l:text .= "   SmC [LEVEL] [NEW_LEVEL] : change signs on level to new_level\n"
    let l:text .= "\n"
    let l:text .= "View commands:\n"
    let l:text .= "Dump marks/signs to either quickfix or new buffer:\n"
    let l:text .= "   Smq  [OPT] : show current file marks on quickfix window, sorted by line number\n"
    let l:text .= "   SmQ  [OPT] : show current file marks on quickfix window, sorted by line number,\n"
    let l:text .= "                show header and marks/signs names.\n"
    let l:text .= "   Smqo [OPT] : show current file marks on quickfix window, user to set all the options\n"
    let l:text .= "   Smw  [OPT] : show current file marks on new window, sorted by line number\n"
    let l:text .= "   SmW  [OPT] : show current file marks on new window, sorted by line number,\n"
    let l:text .= "                show header, line numbers and marks/signs names.\n"
    let l:text .= "   Smwo [OPT] : show current file marks on new window, user to set all the options\n"
    let l:text .= "   Smv1 [OPT] : same as Smq\n"
    let l:text .= "   Smv2 [OPT] : same as SmQ\n"
    let l:text .= "   Smv3 [OPT] : same as Smw\n"
    let l:text .= "   Smv4 [OPT] : same as SmW\n"
    let l:text .= "   Smv5 [OPT] : like Smw with less options active\n"
    let l:text .= "* Use OPT: help to display all options.\n"
    let l:text .= "   Smv  [NUM] : cycle between different window views.\n"
    let l:text .= "   Smqf2f     : dump marks and signs in quickfix format to new tab.\n"
    let l:text .= "\n"
    let l:text .= "Config line commands:\n"
    let l:text .= "   Smcl       : save current file marks as config line on last line of the file\n"
    let l:text .= "   Smclw      : save current file marks as config line on last line of the file\n"
    let l:text .= "                save buffer, do not ask user confirmation.\n"
    let l:text .= "   Smy        : yank to default buffer a config line with all marks\n"
    let l:text .= "\n"
    let l:text .= "Config file commands:\n"
    let l:text .= "   Smsv [NUM] : save current marks on config file\n"
    let l:text .= "                Use NUM:empty to choose file on menu\n"
    let l:text .= "                Use NUM:1 to save on current opened file as config line.\n"
    let l:text .= "                Use NUM:2 to save on config file on current opened file directory.\n"
    let l:text .= "                Use NUM:3 to save on config file on current working directory.\n"
    let l:text .= "   Smsva [NUM]: save all windowss' marks to config files.\n"
    let l:text .= " Smo        : open all config files.\n"
    let l:text .= "\n"
    let l:text .= "   Sml [configLine]: load marks' config from config line or config files\n"
    let l:text .= "                First try finding a config line on current file.\n"
    let l:text .= "                Next try finding a config file on file's directory.\n"
    let l:text .= "                Next try finding a config file on current working directory.\n"
    let l:text .= "   Smla       : load all windowss' saved marks and signs.\n"
    let l:text .= "\n"
    let l:text .= "Move to mark or sign:\n"
    let l:text .= "   Smn        : move to next mark (either named or unnamed)\n"
    let l:text .= "   Smp        : move to previous marks (either named or unnamed)\n"
    let l:text .= "   Smg        : on view window, switch to same line on main window\n"
    let l:text .= "\n"
    let l:text .= "\n"
    let l:text .= "   Smh        : show command help\n"
    let l:text .= "\n"
    let l:text .= "-------------------------------------------------------------------------\n"
    let l:text .= "\n"
    let l:text .= "EXAMPLES:\n"
    let l:text .= "\n"
    let l:text .= "Config line with marks a and b on lines 10 and 25:\n"
    let l:text .= "".g:SignMarks_configLineName.":a=10::b=25::\n"
    let l:text .= "\n"
    let l:text .= "Config line with marks a and b on lines 10, 25 and signs on 123, 124:\n"
    let l:text .= "".g:SignMarks_configLineName.":a=10::b=25::113::124\n"
    let l:text .= "\n"
    let l:text .= "Add sign on current line:\n"
    let l:text .= ":Sm\n"
    let l:text .= "\n"
    let l:text .= "Add sign type 2 on current line:\n"
    let l:text .= ":Sm\n"
    let l:text .= "m+2\n"
    let l:text .= "\n"
    let l:text .= "Open marks and sign view, select view type on menu:\n"
    let l:text .= ":Smv\n"
    let l:text .= "\n"
    let l:text .= "Open marks and sign view, select view type on menu and show options help:\n"
    let l:text .= ":Smv help\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs on quickfix window (view 1):\n"
    let l:text .= ":Smq\n"
    let l:text .= ":Sm1\n"
    let l:text .= "m+v+1\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs on quickfix window (view 2):\n"
    let l:text .= ":SmQ\n"
    let l:text .= ":Sm2\n"
    let l:text .= "m+v+2\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs on new window (view 3):\n"
    let l:text .= ":Smw\n"
    let l:text .= ":Sm3\n"
    let l:text .= "m+v+3\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs on new window (view 4):\n"
    let l:text .= ":SmW\n"
    let l:text .= ":Sm4\n"
    let l:text .= "m+v+4\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs on new window (view 5):\n"
    let l:text .= ":Sm5\n"
    let l:text .= "m+v+5\n"
    let l:text .= "\n"
    let l:text .= "Show user options and current configuration:\n"
    let l:text .= ":Smq help\n"
    let l:text .= ":Sm1 help\n"
    let l:text .= ":SmQ help\n"
    let l:text .= ":Sm2 help\n"
    let l:text .= ":Smw help\n"
    let l:text .= ":Sm3 help\n"
    let l:text .= ":SmW help\n"
    let l:text .= ":Sm4 help\n"
    let l:text .= ":Sm5 help\n"
    let l:text .= ":Smqo help\n"
    let l:text .= ":Smwo help\n"
    let l:text .= "\n"
    let l:text .= "Open view window type 1:\n"
    let l:text .= ":Smv 1\n"
    let l:text .= "m+v+1\n"
    let l:text .= "\n"
    let l:text .= "Open view window menu:\n"
    let l:text .= ":Smv\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs from all windows:\n"
    let l:text .= ":Smw a\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs from all windows of current tab:\n"
    let l:text .= ":Smw w\n"
    let l:text .= "\n"
    let l:text .= "Show sign and marks from all windows byt only ccp files:\n"
    let l:text .= ":SmQ a +cpp\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs from all windows only files matching: 'name.*ccp'\n"
    let l:text .= ":SmW a +name.*cpp\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs from all windows only files not matching: 'xml'\n"
    let l:text .= ":SmQ a -xml\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs from all windows only 'cpp' files lacking name 'config':\n"
    let l:text .= ":Smq a +cpp -config\n"
    let l:text .= "\n"
    let l:text .= "Add a new sign on current sign with sign level 2\n"
    let l:text .= ":Sm 2\n"
    let l:text .= "m+2\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs with levels 2 and 3\n"
    let l:text .= ":Smq s2s3\n"
    let l:text .= ":Sm1 s2s3\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs with levels 2 to 5\n"
    let l:text .= ":Smq s2:5\n"
    let l:text .= ":Sm1 s2:5\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs with levels from 1 to 5\n"
    let l:text .= ":Smq s:5\n"
    let l:text .= ":Sm1 s:5\n"
    let l:text .= "\n"
    let l:text .= "Show marks and signs with levels from 2 to 10\n"
    let l:text .= ":Smq s2:\n"
    let l:text .= ":Sm1 s2:\n"
    let l:text .= "\n"
    let l:text .= "Change signs on level 2 to level 22, ask user confirmation:\n"
    let l:text .= ":Smc 2 22\n"
    let l:text .= "\n"
    let l:text .= "Change signs on level 2 to level 22, no user confirmation required:\n"
    let l:text .= ":Smc 2 22\n"
    let l:text .= "\n"
    let l:text .= "Change any signs to level 22:\n"
    let l:text .= ":Smc - 22\n"
    let l:text .= "\n"
    let l:text .= "Change signs on levels 2 and 3, ask user the new level:\n"
    let l:text .= ":Smc 2,3\n"
    let l:text .= "\n"
    let l:text .= "Change any sign, ask user new sign level:\n"
    let l:text .= ":Smc\n"
    let l:text .= "\n"
    let l:text .= "Delete signs with level 18, ask user permission:\n"
    let l:text .= ":Smc 18 -\n"
    let l:text .= "\n"
    let l:text .= "Switch view to quickfix:\n"
    let l:text .= ":Smq _\n"
    let l:text .= ":SmQ _\n"
    let l:text .= "\n"
    let l:text .= "Switch view to window:\n"
    let l:text .= ":Smw _\n"
    let l:text .= ":SmW _\n"
    let l:text .= "\n"
    let l:text .= "Get marks on quickfix format to save on file:\n"
    let l:text .= "From current buffer:\n"
    let l:text .= ":Smqf2f\n"
    let l:text .= "From all buffers (like tabdo window):\n"
    let l:text .= ":Smqf2f a\n"
    let l:text .= "From all buffers on current tab (like windo):\n"
    let l:text .= ":Smqf2f w\n"
    let l:text .= ":SmW _\n"

    redraw
    call s:WindowSplitMenu(4)
    call s:WindowSplit()
    silent put = l:text
    silent! exec '0file | file svnTools_plugin_help'
    normal ggdd
    call s:WindowSplitEnd()
endfunction


" Create menu items for the specified modes.
function! signmarks#CreateMenus(modes, submenu, target, desc, cmd)
    " Build up a map command like
    let plug = a:target
    let plug_start = 'noremap <silent> ' . ' :call Marks("'
    let plug_end = '", "' . a:target . '")<cr>'

    " Build up a menu command like
    "let menuRoot = get(['', 'Signs', '&Signs', "&Plugin.&Signs".a:submenu], 3, '')
    let menuRoot = get(['', 'SignMarks', '&SignMarks', "&Plugin.&SignMarks".a:submenu], 3, '')
    let menu_command = 'menu ' . l:menuRoot . '.' . escape(a:desc, ' ')

    if strlen(a:cmd)
        let menu_command .= '<Tab>' . a:cmd
    endif

    let menu_command .= ' ' . (strlen(a:cmd) ? plug : a:target)
    "let menu_command .= ' ' . (strlen(a:cmd) ? a:target)

    "call s:Verbose(1, expand('<sfile>'), l:menu_command)

    " Execute the commands built above for each requested mode.
    for mode in (a:modes == '') ? [''] : split(a:modes, '\zs')
        if strlen(a:cmd)
            execute mode . plug_start . mode . plug_end
            "call s:Verbose(1, expand('<sfile>'), "execute ". mode . plug_start . mode . plug_end)
        endif
        " Check if the user wants the menu to be displayed.
        if g:SignMarks_mode != 0
            execute mode . menu_command
        endif
    endfor
endfunction


"- Release tools ------------------------------------------------------------
"

" Create a vimball release with the plugin files.
" Commands: Smvba
function! signmarks#NewVimballRelease()
    let text  = ""
    let text .= "plugin/signmarks.vim\n"
    let text .= "autoload/signmarks.vim\n"

    silent tabedit
    silent put = l:text
    silent! exec '0file | file vimball_files'
    silent normal ggdd

    let l:plugin_name = substitute(s:plugin_name, ".vim", "", "g")
    let l:releaseName = l:plugin_name."_".g:signmarks_version.".vmb"

    let l:workingDir = getcwd()
    silent cd ~/.vim
    silent exec "1,$MkVimball! ".l:releaseName." ./"
    silent exec "vertical new ".l:releaseName
    silent exec "cd ".l:workingDir
endfunction


"- User remapping tools ------------------------------------------------------------
"

" Change default sign mappings and apply the user's selected mapping.
" Variable g:SignMarks_userSignMappinsList needs to be changed.
" Ex: reassign map s+0 to the sign level 24
"   let g:SignMarks_userSignMappinsList = [['s0', 24]]
function! signmarks#AddUserCustomSignMappings()
    let l:i = -1
    for l:userMap in g:SignMarks_userSignMappinsList
        let l:signMap   = l:userMap[0]
        let l:signLevel = l:userMap[1]
        let l:n = 0
        let l:i += 1

        if l:signLevel > len(g:SignMarks_signMappingList)
            echo "Wrong g:SignMarks_userSignMappinsList[".l:n."] configuration"
            call s:Error("Error. Sign level not found: ".l:signLevel.". Last level is: ".len(g:SignMarks_signMappingList))
            continue
        endif

        if len(l:signMap) > 2
            echo "Wrong g:SignMarks_userSignMappinsList[".l:n."] configuration"
            call s:Error("Error. Sign mapping not allowed: ".l:signMap.". Lenght must be lower than 3 characters")
            continue
        endif

        for l:map in g:SignMarks_signMappingList
            "echom "Check userMap: ".l:signMap." map: ".l:map
            if l:map == l:signMap
                "echom "Remove map: ".l:n
                let g:SignMarks_signMappingList[l:n] = ''
            endif
            let l:n += 1
        endfor

        let g:SignMarks_signMappingList[l:signLevel-1] = l:signMap

        "let l:cmdList = []
        "let l:cmdList += [ "silent! nunmap ".l:signMap ]
        "let l:cmdList += [ "silent! xunmap ".l:signMap ]

        "if g:SignMarks_remapPrevMappings == "yes"
            "let l:cmdList += [ "nmap ".l:signMap." :silent Sm ".l:signLevel."<CR>" ]
            "let l:cmdList += [ "xmap ".l:signMap." Sm ".l:signLevel."<CR>" ]
        "else
            "let l:cmdList += [ "nnoremap <unique> ".l:signMap." :silent Sm ".l:signLevel."<CR>" ]
            "let l:cmdList += [ "xnoremap <unique> ".l:signMap." Sm ".l:signLevel."<CR>" ]
        "endif

        "for l:cmd in l:cmdList
            ""echom "Cmd: ".l:cmd
            "silent exec(l:cmd)
        "endfor
    endfor
endfunction


function! signmarks#AddUserCustomViews()
    let l:n = 0
    for l:newViewList in g:SignMarks_userViewList
        for l:viewList in g:SignMarks_userViewList
            if l:newViewList[0] != "" && l:viewList[0] == l:newViewList[0]
                let g:SignMarks_userViewList[l:n][0] = ''
            endif
            if l:newViewList[4] != "" && l:viewList[4] == l:newViewList[4]
                let g:SignMarks_userViewList[l:n][4] = ''
            endif
        endfor
        let g:SignMarks_viewsList += [ l:newViewList ]
        let l:n += 1
    endfor
endfunction


function! signmarks#AddUserCustomSigns()
    let l:n = 0
    for l:newSignList in g:SignMarks_userSignsList
        if len(l:newSignList) != 3
            call s:Error("Error: g:SignMarks_userSignsList position ".l:n." lenght")
            continue
        endif
        let g:SignMarks_signTypesList += [ l:newSignList ]
        let l:n += 1
    endfor
endfunction

"- initializations ------------------------------------------------------------
"

let  s:plugin = expand('<sfile>')
let  s:plugin_path = expand('<sfile>:p:h')
let  s:plugin_name = expand('<sfile>:t')

call s:Initialize()

" Set the apropiate word for commenting lines of code.
augroup Signmarks_CommentLines
    autocmd!
    autocmd FileType c,cpp,java,scala let b:SignMarks_commentLeader = '// '
    autocmd FileType sh,ruby,python   let b:SignMarks_commentLeader = '# '
    autocmd FileType conf,fstab       let b:SignMarks_commentLeader = '# '
    autocmd FileType patch,diff       let b:SignMarks_commentLeader = '# '
    autocmd FileType tex              let b:SignMarks_commentLeader = '% '
    autocmd FileType mail             let b:SignMarks_commentLeader = '> '
    autocmd FileType vim              let b:SignMarks_commentLeader = '" '

    "autocmd FileType c,cpp,java,scala b:SignMarks_line = 1

    autocmd FileType c,cpp,java,scala let b:SignMarks_defaultView = 1
    autocmd FileType sh,ruby,python   let b:SignMarks_defaultView = 1
    autocmd FileType json,xml         let b:SignMarks_defaultView = 4
    autocmd FileType log,txt          let b:SignMarks_defaultView = 4
augroup END

let s:n = 1
for s:signTypesList in g:SignMarks_signTypesList
    if s:n >= 100
        call s:Error("Sign definition error. Wrong g:SignMarks_signTypesList. Sign number exceeds 99.")
        break
    endif

    let s:signCharacter = s:signTypesList[0]
    let s:signHl        = s:signTypesList[1]
    let s:signLineHl    = s:signTypesList[2]

    if s:signCharacter == ""
        let s:signCharacter = s:n
    endif

    call sign_define([ {'name' : 'VimSigns'.s:n, 'text' : s:signCharacter, 'texthl' : s:signHl, 'linehl' : s:signLineHl } ])
    "silent let result = sign_define([ {'name' : 'VimSigns'.s:n, 'text' : s:signCharacter, 'texthl' : s:signHl, 'linehl' : s:signLineHl } ])
    "echom "VimSigns".s:n." text : ".s:signCharacter." texthl  : ".s:signHl." linehl : ".s:signLineHl

    let s:n += 1
endfor

