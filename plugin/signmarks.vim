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
" NOTES:
"
" Version:      0.3.1
" Changes:
" 0.3.1 	Fri, 08 Jul 22.     JPuigdevall
"   - Fix: gvim menu issues.
"   - New: command Smclw to save current signs and marks replacing any
"     existant config line and save the file, all without user confirmation.
"   - New: (On commands Sm, Sma, Smo, Smd) when only one sign changed, show a
"     one line message only.
"   - New: Smqf2f by default shows only signs and marks on current window
"     unless options A or W used.
"   - New: option W for function signmarks#OpenView.
"   - Fix: remove <unique> from all mappings.
"   - New: add mapping s++ for :Sma
"   - New: add mapping s+- and s+supr for :Smd
" 0.3.0 	Tue, 30 Nov 21.     JPuigdevall
"   - Fix: the auto load asking several times, one for each plugin reload
"     performed (_smrl), the autocmd! is not applied.
"   - NEW: change plugin name from marksConfig.vim to signmarks.vim.
"   - NEW: change all 'Mk...' commands to 'Sm...'.
"   - New: command :Smc and SmC to change all signs from one level to another.
"   - New: variable g:SignMarks_userSignMappinsList to change the default mappings.
"   - New: Smsv allows to save as config line using argument 0.
"   - New: when no level selected on Smsa and Sm commands show menu to choose the sign level.
"   - New: Smsh command to show the signs available and its number and color highlighting.
"   - Fix: bug on OpenView preventing to show view with 5 or less marks/signs placed.
"   - Fix: applying marks on file open. signmarks#ApplyUserSignMaps() call from file.
"   - New: change signs colors and apply color to marks' levels: 3, 4, 5, 6 and 7.
"   - Fix: applying marks on file open. signmarks#AutoConfigInit() call from plugin file.
"   - New: command :Smo to open all signs config files related to current buffer.
"   - New: when launching Smg from main window and positioned on a line with a
"     sign or mark. Goto that sign on the view window too.
"   - New: when launching Smg from main window and not positioned on a line with a
"     sign or mark. Open (reload if already open) and stay on main window..
"   - New: apply same cursor column position after calling Smg.
"   - New: restore cursor column position after calling Sm/Sma/Smd.
"   - Fix: opening view 3 while view 2 already open, not closing previous view.
"   - Fix: opening view 2 while view 1 already open, not closing previous view.
"   - Fix: view window name, remove view number.
"   - Fix: on command :Smsv changing resizing the windows after saving the marks config.
"   - New: update view window when launching command :Smg or map m+enter on main window.
" 0.2.0 	Wed, 10 Nov 21.     JPuigdevall
"   - New: set view window as nofile and nomdifiable (except qf2f window).
"   - New: OpenView option I to show signs on view window.
"   - New: m+enter map to call Mkg command, goto main window.
"   - New: command :Mkg, once on new view window, move to same line on main
"     window. Not available on quickfix view.
"   - New: command :Mki to show signs info.
"   - New: change :Mk command to  :Mkcl.
"   - New: change :Mkm command to  :Mk.
"   - New: change :Mkma command to :Mka.
"   - New: change :Mkmd command to :Mkd.
"   - New: change :MkmD command to :MkD.
"   - New: commands Mk0 to Mk8 to load views 0 to 8.
"     Mk1 is equivalent to Mkq.
"     Mk2 is equivalent to MkQ.
"     Mk3 is equivalent to Mkw.
"     Mk4 is equivalent to MkW.
"   - New: map m+1 to m+0 to add new sign on selected lines with the required
"     level (:Mk n).
"   - New: map m+v+1 to m+v+0 to display view with the selected sign level.
"   - New: command :Mkqf2f, dump all marks and signs to file in quickfix format.
"   - New: changed command name :Mka to :Mkl.
"   - New: :Mkla command to load all saved marks and signs.
"   - New: config options to define file name and header colors:
"     g:SignMarks_highlightHeaderColor g:SignMarks_highlightFilesColor
"   - New: when using option 'A', allow to filter by file names.
"     ex: MkW a xml, to show only files's marks containing the word 'xml'.
"   - New: Mksva to save the marks on each window to a config file.
"   - New: command :Mkv and map m+tab to switch between the different views.
"   - New: option "_" while on marks/signs new/quickfix window change to a
"     new view and options.
"   - New: option "M" to apply same marks no the qf/new window.
"   - New: show signs from all files.
"   - Fix: lines order error for option 'S' when reaching line 1001. 
"     Function signmarks#CheckOrder.
"   - New: show original file name on new window header.
"   - Fix: :Mk to add a line at end of file. Prevent printing on last line.
"   - New: command :Mkl can add a config line as a parameter.
"     ex: :Mkl vim_signs:235::456::678::
" 0.1.1 	Fri, 15 Oct 21.     JPuigdevall
"   - New: complete refactoring of function OpenView.
"   - New: allow to add user options on commands: Mkw, MkW, MkQ and Mkq.
"   - New: commands Mkqo and Mkwo for user to set all options.
"   - New: option 'help', to show the available options on OpenView function.
"     ex: :Mkw help, :MkQ help, Mkwo help, ....
"   - New: OpenView function's allow to preserve line indentation on
"     quickfix window when the marks/signs names are not displayed by adding
"     the character '>'
"   - Fix: OpenView function. Deleting part of the line content when removing the
"     marks/signs names.
"   - Fix: OpenView function. when no header selected, does not display
"     marks unless there are more than 3 marks/signs.
"   - Fix: OpenView function. Apply same file type to the marks/signs filter (new/quickfix) window.
"   - Fix: omitt marks column when displaying qf window.
"   - New global variables to configure the sign character and highlight:
"     g:MarksConfig_signCharacater and g:MarksConfig_signHighlight.
" 0.1.0 	Tue, 05 Oct 21.     JPuigdevall
"   - Set config line default position at end of the file.
"   - New unnamed marks concept, unnamed marks only exist on the plugin.
"     They allow to extend marks behind the 25 letters allowed from vim Marks.
"   - New Mkm and Mkmd to add/delete unnamed marks.
"   - New Mkn and Mkp to navigate marks and signs, goto mark/sign  previous/next.
"   - Link with hi.vim plugin, allow to colorize the buffer window containing all marks
"     Apply the colors on the main window to the split with marks opened with Mkw
" 0.0.1 	Thu, 30 Sep 21.     JPuigdevall
"   - First release published

if !has('signs')
  finish
endif

if exists('g:loaded_signmarks')
    finish
endif

let g:loaded_signmarks = 1
let s:save_cpo = &cpo
set cpo&vim

let g:signmarks_version = "0.3.1"


"- configuration --------------------------------------------------------------
"

let g:SignMarks_mode                       =  get(g:, 'SignMarks_mode', 3) " Display menu on gvim

" Marks to save:
let g:SignMarks_useMarks                   =  get(g:, 'SignMarks_useMarks', "abcdefghijklmnopqrstuvwxyz")

" Config Line Options:
let g:SignMarks_configLineAskUserToApply   =  get(g:, 'SignMarks_configLineAskUserToApply', "yes")
let g:SignMarks_configLineName             =  get(g:, 'SignMarks_configLineName', "vim_signs")
let g:SignMarks_configLineDefaultPos       =  get(g:, 'SignMarks_configLineDefaultPos', "bottom") " top/bottom

" Config File Options:
" Config file format is: 
" "-PREFIX-dir1__dir2__dirN___file-SUFFIX-" or  
" "dir1/dir2/dirN/-PREFIX-file.extension-SUFFIX-" or
" "-PREFIX-29a04a611e8eb85935c4b6d5e57ca632-SUFFIX-"
let g:SignMarks_configFilePrefixPrev       =  "_vimMarksCfg_"
let g:SignMarks_configFileSuffixPrev       =  ".cfg"
"let g:SignMarks_configFilePrefix           =  get(g:, 'SignMarks_configFilePrefix', "_vim-signs_")
"let g:SignMarks_configFileSuffix           =  get(g:, 'SignMarks_configFileSuffix', ".cfg")

silent! unlet g:SignMarks_configFilePrefix
silent! unlet g:SignMarks_configFileSuffix 
let g:SignMarks_configFilePrefix           =  get(g:, 'SignMarks_configFilePrefix', "")
let g:SignMarks_configFileSuffix           =  get(g:, 'SignMarks_configFileSuffix', "_vim-signmarks.cfg")

" When 1, use mde5sum (if found) to generate the filename where saving marks on current working directory.
let g:SignMarks_configFileNameUseMd5       =  get(g:, 'SignMarks_configFileNameUseMd5', 1)

let g:SignMarks_configFileDefault          =  get(g:, 'SignMarks_configFileDefault', 3)

" Auto Load Config File:
let g:SignMarks_autoLoadConfigActive       =  get(g:, 'SignMarks_autoLoadConfigActive', 1)
" Files allowed to load marks config when openening the file.
" ATTENTION: options empty and * are forbiden, a value must be specified.
"  Otherwhise there's an issue with quickfix window
let g:SignMarks_autoLoadConfigFilter       = get(g:, 'SignMarks_autoLoadConfigFilter', "*.txt *.log *.py *.h *.cpp *.c *.rb *.sh *.xml *.diff *.patch *.json *.java")

" Sign Levels:
" Format: "[ "Mapping", "SignCharacter", "SignHighlight", "LineHighlight" ]"
silent! unlet g:SignMarks_signTypesList
let s:list = []
let s:list += [ ['>',  "",           ""] ]
let s:list += [ ['>>', "",           ""] ]
let s:list += [ ['3>', "",           ""] ]
let s:list += [ ['4>', "",           ""] ]
let s:list += [ ['5>', "",           ""] ]
let s:list += [ ['6>', "",           ""] ]
let s:list += [ ['7>', "",           ""] ]
let s:list += [ ['8>', "",           ""] ]
let s:list += [ ['9>', "",           ""] ]
let s:list += [ ['0>', "",           ""] ]
let s:list += [ ['',   "DiffAdd",    ""] ]
let s:list += [ ['',   "DiffText",   ""] ]
let s:list += [ ['',   "DiffChange", ""] ]
let s:list += [ ['',   "WarningMsg", ""] ]
let s:list += [ ['',   "Search",     ""] ]
let s:list += [ ['',   "IncSearch",  ""] ]
let s:list += [ ['',   "Error",      ""] ]
let s:list += [ ['',   "ErrorMsg",   ""] ]
let s:list += [ ['',   "",           "Conceal"] ]
let s:list += [ ['',   "",           "SpecialKey"] ]
let s:list += [ ['',   "",           "DiffAdd"] ]
let s:list += [ ['',   "",           "DiffText"] ]
let s:list += [ ['',   "",           "DiffChange"] ]
let s:list += [ ['',   "",           "Error"] ]
let s:list += [ ['',   "",           "Title"] ]
let s:list += [ ['',   "",           "Folded"] ]
let s:list += [ ['',   "",           "SpellLocal"] ]
let s:list += [ ['',   "",           "SpellCap"] ]
let s:list += [ ['',   "",           "SpellRare"] ]
let s:list += [ ['',   "",           "SpellBad"] ]
let s:list += [ ['',   "",           "PmenuSel"] ]
let s:list += [ ['',   "",           "MatchParen"] ]
let s:list += [ ['',   "",           "StatusLine"] ]
let s:list += [ ['',   "",           "Search"] ]
let s:list += [ ['',   "",           "IncSearch"] ]
let s:list += [ ['',   "",           "ErrorMsg"] ]
let g:SignMarks_signTypesList = get(g:, 'SignMarks_signTypesList', s:list)
unlet s:list

let g:SignMarks_userSignsList = get(g:, 'SignMarks_userSignsList', [])
call signmarks#AddUserCustomSigns()

" Sign Level Mappings:
silent! unlet g:SignMarks_signMappingList
let s:len  = len(g:SignMarks_signTypesList) -1
let s:str  = repeat("'', ", s:len)
let s:str .= "'', "
silent exec ("let s:list = [".s:str."]")
let g:SignMarks_signMappingList = get(g:, 'SignMarks_signMappingList', s:list)
unlet s:list

let s:signMapChar = 's'
let g:SignMarks_signMappingList[0]  = s:signMapChar.'1'
let g:SignMarks_signMappingList[1]  = s:signMapChar.'2'
let g:SignMarks_signMappingList[2]  = s:signMapChar.'3'
let g:SignMarks_signMappingList[3]  = s:signMapChar.'4'
let g:SignMarks_signMappingList[4]  = s:signMapChar.'5'
let g:SignMarks_signMappingList[5]  = s:signMapChar.'6'
let g:SignMarks_signMappingList[6]  = s:signMapChar.'7'
let g:SignMarks_signMappingList[7]  = s:signMapChar.'8'
let g:SignMarks_signMappingList[8]  = s:signMapChar.'9'
let g:SignMarks_signMappingList[9]  = s:signMapChar.'0'
"echom "SignMarks_signMappingList: "g:SignMarks_signMappingList

let g:SignMarks_userSignMappinsList = get(g:, 'SignMarks_userSignMappinsList', [])
call signmarks#AddUserCustomSignMappings()


" View Configurations:
" Format: "[ "CmdName1", "WindowType", "DataType", "ViewOptoins", "CmdName2" ]"
"   CmdName1: create command ":Sm".CmdName1 and mapping "m+".CmdName1
"   Wintype: window type.
"     qf: open on quickfix window.
"     new: show on buffer, open new window.
"     vnew: show on buffer, open new vertical window.
"     tab: show on buffer, open new tab window.
"     qf2f: open as quickfix on buffer on new tab window.
"   Marktype:
"     marks: show marks.
"     signs: show signs AKA unnamed marks.
"     marks-signs: show both signs and marks.
"   Options:
"     help: show this help.
"     A:  show all marks/signs from all open windows.
"     a:  same as A.
"     F:  apply the same file format to the qf/new window.
"     Fn: when view is showing a different file, add a new line with the file name.
"     H1: show header type 1 with two lines.
"     H2: show header type 2 with two lines.
"     I:  apply same signs on view window.
"     L:  show line numbers.
"     Lf: add line feed after.
"     M:  apply same marks on view window.
"     N:  show marks/signs names.
"     S:  sort marks by file line. Otherwise sort by marks first, signs next.
"     s[1..n]: show only the selected sign types (1 to n).
"     T:  preserve contents start of line tabulation on quickfix window. Not
"         needed when 'N' is used. Only for wintype "qf".
"     U:  do not show duplicated lines. Lines having both mark and sign.
"     _:  when placed on view window, change to the requested view and options.
"   CmdName2: create command ":Sm".CmdName2
silent! unlet g:SignMarks_viewsList
let s:list = []
let s:list += [ [1  , "qf"     , "marks&signs" , "MSU"            , "q"] ]
let s:list += [ [2  , "qf"     , "marks&signs" , "FH2MNSU.fn.lf"  , "Q"] ]
let s:list += [ [3  , "new"    , "marks&signs" , "FH1IMSU.fn.lf"  , "w"] ]
let s:list += [ [4  , "new"    , "marks&signs" , "FH2LMNSU.fn.lf" , "W"] ]
let s:list += [ [5  , "new"    , "marks&signs" , "SUfn.lf"        , "" ] ]
let g:SignMarks_viewsList                 = get(g:, 'SignMarks_viewsList', s:list)
unlet s:list

let g:SignMarks_userViewList              = get(g:, 'SignMarks_userViewList', [])
call signmarks#AddUserCustomViews()

let g:SignMarks_remapPrevMappings         = get(g:, 'SignMarks_remapPrevMappings', "")

" Highlight colors for view window.  Only if plugin hi.vim is intalled.
let g:SignMarks_highlightHeaderColor      = get(g:, 'SignMarks_highlightHeaderColor', ["c", "Cl"])
let g:SignMarks_highlightFilesColor       = get(g:, 'SignMarks_highlightFilesColor', ["w", "Cl"])

let g:SignMarks_defaultView               = get(g:, 'SignMarks_defaultView', 1)

"let g:SignMarks_keepViewUpdated           = get(g:, 'SignMarks_keepViewUpdated', 1)

let g:SignMarks_vlen                       = get(g:, 'SignMarks_vlen', 50)


"- commands -------------------------------------------------------------------

" View Commands:
" Add commands Sm0 to Sm9: open a view.
func! s:Commands_Sm0to9()
    let l:n = 1
    while l:n <= 10
        if l:n > len(g:SignMarks_viewsList) | return | endif
        if l:n == 10
            let l:pos = 10
        else
            let l:pos = l:n -1
        endif
        let l:list = []

        let l:name = g:SignMarks_viewsList[l:pos][0]
        if l:name != ""
            let l:cmd = "command! -nargs=*  Smv".l:name." call signmarks#OpenView(g:SignMarks_viewsList[".l:pos."], <f-args>)"
            "echom l:cmd
            silent exec(l:cmd)
        endif

        let l:name = g:SignMarks_viewsList[l:pos][4]
        if l:name != ""
            let l:cmd = "command! -nargs=*  Sm".l:name." call signmarks#OpenView(g:SignMarks_viewsList[".l:pos."], <f-args>)"
            "echom l:cmd
            silent exec(l:cmd)
        endif

        let l:n += 1
    endwhile
endfunction

" Open view window: predefined options.
call s:Commands_Sm0to9()

" Show all signs available and is's number and color highlighting.
command! -nargs=0  Smsh          call signmarks#ShowColors()

" Open view window: let user decide the options.
command! -nargs=*  Smqo          call signmarks#OpenView([0, "qf",  "marks-signs", ""], <f-args>)
command! -nargs=*  Smwo          call signmarks#OpenView([0, "new", "marks-signs", ""], <f-args>)

" Dump all windows' marks and signs to file in quickfix format
"command! -nargs=*  Smqf2f        call signmarks#OpenView([0, "qf2f", "marks-signs", "AL.fn.lf"], <f-args>)
command! -nargs=*  Smqf2f        call signmarks#OpenView([0, "qf2f", "marks-signs", "L.fn.lf"], <f-args>)

" Change the view type.
" Depends on the views defined on: 'g:SignMarks_viewsList'
command! -nargs=?  Smv           call signmarks#SwitchToNextView("<args>")

" Yank marks on current file as header line
command! -nargs=0  Smy           call signmarks#ConfigLineYank()
command! -nargs=0  SmY           call signmarks#ConfigLineYankWithFileName()

" Load saved marks and signs. header or marks file if found
" Arg1: [configLine]. "vim_signs:a=1::b=34::35::345::"
" Arg2: [askUserConsent]. ask user confirmation before aplying the configuration
command! -nargs=?  Sml           call signmarks#Load("<args>","verbose","")

" Save marks to a config file.
" signmarks#ConfigFileSave arguments:
"   none: open menu to choose the config file.
"   .: save on default config file path.
"   0: save on the file as config line.
"   1: save on config file on current file's directory.
"   2: save on config file on current working directory.
"command! -nargs=?  Smsv          call signmarks#Save("save", "<args>")
command! -nargs=?  Smsv          call signmarks#ConfigFileSave("<args>")

" Open all config files in new tab.
command! -nargs=0  Smo           call signmarks#ConfigFileOpen()

" Save all window marks to config files.
command! -nargs=?  Smsva         call signmarks#SaveAll("<args>")

" Load all window marks from config files.
command! -nargs=0  Smla          call signmarks#LoadAll()

" Write down the marks' config line on the first line.
command! -nargs=0  Smcl          call signmarks#SetConfigLine("clean_cofig_line", "", "user_confirm")
command! -nargs=0  Smclw         call signmarks#SetConfigLine("clean_cofig_line", "save_file", "")

" Show commands help.
command! -nargs=0 Smh            call signmarks#Help()

" Release functions:
" Create a new vimball release
command! -nargs=0  Smvba         call signmarks#NewVimballRelease()

" Edit plugin functions:
command! -nargs=0  Smedit        call signmarks#Edit()

" Unnamed Marks:
" Add/delete signs (unnamed marks)
" Unnamed marks help extend the vim marks as the later ones only allow 25 marks.
command! -nargs=? -range Sm       let w:wincol = col(".") | <line1>,<line2>call signmarks#Sign("add-delete", "<args>") | exec("normal 0".w:wincol."l")
command! -nargs=? -range Sma      let w:wincol = col(".") | <line1>,<line2>call signmarks#Sign("add", "<args>")        | exec("normal 0".w:wincol."l")
command! -nargs=? -range Smd      let w:wincol = col(".") | <line1>,<line2>call signmarks#Sign("delete", "<args>")     | exec("normal 0".w:wincol."l")
command! -nargs=?  SmD            call signmarks#SignsDeleteAll("confirm", "<args>")
command! -nargs=0  Smi            call signmarks#SignsInfo()
command! -nargs=*  SmC            call signmarks#SignsLevelChange("", <f-args>)
command! -nargs=*  Smc            call signmarks#SignsLevelChange("askUser", <f-args>)

" Move To Mark:
command! -nargs=0  Smn            call signmarks#MarksNext("marks-signs")
command! -nargs=0  Smp            call signmarks#MarksPrev("marks-signs")

command! -nargs=0  Smg            call signmarks#GotoMainFileLine()




"- mappings -------------------------------------------------------------------
"
func! s:MapViewList(list, maptype, map, cmd)
    for l:signList in a:list
        "echom "signList: "l:signList
        let l:map = l:signList[0]
        if l:map == "" | continue | endif
        if g:SignMarks_remapPrevMappings == "yes"
            let l:cmd = a:maptype."map ".a:map.l:map." ".a:cmd.l:map."<CR>"
        else
            let l:cmd = a:maptype."noremap ".a:map.l:map." ".a:cmd.l:map."<CR>"
        endif
        "echom "".l:cmd
        silent exec(l:cmd)
    endfor
endfunction

func! s:MapSignList(list, maptype, cmd)
    let l:n = 1
    for l:signMap in a:list
        if l:signMap != ""
            "echom "signMap: "l:signMap
            let l:mapCmd = a:cmd." ".l:n
            if g:SignMarks_remapPrevMappings != ""
                let l:cmd = a:maptype."map ".l:signMap." ".l:mapCmd."<CR>"
            else
                let l:cmd = a:maptype."noremap ".l:signMap." ".l:mapCmd."<CR>"
            endif
            "echom "".l:cmd
            silent exec(l:cmd)
        endif
        let l:n += 1
    endfor
endfunction

" Use command m1 to m9 for adding new signs:
"if !hasmapto('Sm', 'n')
    call s:MapSignList(g:SignMarks_signMappingList, "n", ":silent Sm")
"endif

"if !hasmapto('Sm', 'x')
    call s:MapSignList(g:SignMarks_signMappingList, "x", ":Sm")
"endif

if !hasmapto('Smv', 'n')
    " Use map m+tab to switch between views.
    exec("nnoremap ".s:signMapChar."<tab> :Smv ".g:SignMarks_defaultView."<CR>")

    " Use command m1 to m9 for opening the different views available:
    call s:MapViewList(g:SignMarks_viewsList, "n", "s<tab>", ":silent Smv")
endif

if !hasmapto('Smg', 'n')
    exec("nnoremap ".s:signMapChar."<enter> :Smg<CR>")
endif

if !hasmapto('Sma', 'n')
    " Use s+Supr key too
    exec("nnoremap ".s:signMapChar."+ :silent Sma<CR>")
endif

if !hasmapto('Sma', 'x')
    " Use s+Supr key too
    exec("xnoremap ".s:signMapChar."+ :Sma<CR>")
endif

if !hasmapto('Smd', 'n')
    " Use s+Del
    exec("nnoremap ".s:signMapChar."<delete> :silent Smd<CR>")
    " Use s+Supr key too
    exec("nnoremap ".s:signMapChar."[3~ :silent Smd<CR>")
endif

if !hasmapto('Smd', 'x')
    " Use s+Del
    exec("xnoremap ".s:signMapChar."<delete> :Smd<CR>")
    " Use s+Supr key too
    exec("xnoremap ".s:signMapChar."[3~ :Smd<CR>")
    " Use s+Supr key too
    exec("xnoremap ".s:signMapChar."- :Smd<CR>")
endif


"- abbreviations -------------------------------------------------------------------

" DEBUG functions: reload plugin
cnoreabbrev _smrl    <C-R>=signmarks#Reload()<CR>


"- menus -------------------------------------------------------------------
"
if has("gui_running")
    call signmarks#CreateMenus('cn', '.&Save', ':Smcl' , 'save marks on config line'                                 , ':Smcl')
    call signmarks#CreateMenus('cn', '.&Save', ':Smclw', 'Save marks on config line, save buffer, no confirmation'   , ':Smcl')
    call signmarks#CreateMenus('cn', '.&Save', ':Smy'  , 'Yank marks header'                                         , ':Smy')
    call signmarks#CreateMenus('cn', '.&Save', ':Smsv' , 'Save marks and signs to config file'                       , ':Smsv')
    call signmarks#CreateMenus('cn', '.&Save', ':Smsva', 'Save marks and signs from all window to config files'      , ':Smsva')
    call signmarks#CreateMenus('cn', '.&Save', ':Smo'  , 'Open all config file'                                      , ':Smo')
    call signmarks#CreateMenus('cn', '.&Save', ':Sml'  , 'Load saved marks and signs'                                , ':Sml')
    call signmarks#CreateMenus('cn', '.&Save', ':Smla' , 'Load saved marks and signs to all window'                  , ':Smla')
    
    call signmarks#CreateMenus('cn', '.&Show', ':Smq'  , 'Show marks on quickfix window, sort'                       , ':Smq')
    call signmarks#CreateMenus('cn', '.&Show', ':SmQ'  , 'Show marks on quickfix window, sort, show: names, header'  , ':SmQ')
    call signmarks#CreateMenus('cn', '.&Show', ':Smqo' , 'Show marks on quickfix window, user options'               , ':Smqo')
    call signmarks#CreateMenus('cn', '.&Show', ':Smw'  , 'Show marks on new window'                                  , ':Smw')
    call signmarks#CreateMenus('cn', '.&Show', ':SmW'  , 'Show marks on new window, sort, show: lines, names, header', ':SmW')
    call signmarks#CreateMenus('cn', '.&Show', ':Smwo' , 'Show marks on new window, set user options'                , ':Smwo')
    call signmarks#CreateMenus('cn', '.&Show', ':Smv'  , 'Switch window view'                                        , ':Smv')
    call signmarks#CreateMenus('cn', '.&Show', ':Smqf2f','Dump to new tab marks and signs in quickfix format'        , ':Smqf2f')
   
    call signmarks#CreateMenus('cn', '.&Modify', ':Sma'  , 'Add sign on the selected lines'                            , ':Sma')
    call signmarks#CreateMenus('cn', '.&Modify', ':Smd'  , 'Delete sign on the selected lines'                         , ':Smd')
    call signmarks#CreateMenus('cn', '.&Modify', ':SmD'  , 'Delete all signs'                                          , ':SmD')
    call signmarks#CreateMenus('cn', '.&Modify', ':Smi'  , 'Show signs information'                                    , ':Smi')
    call signmarks#CreateMenus('cn', '.&Modify', ':Smc'  , 'Change level on signs, ask for confirmation'               , ':Smc')
    call signmarks#CreateMenus('cn', '.&Modify', ':SmC'  , 'Change level on signs'                                     , ':SmC')
  
    call signmarks#CreateMenus('cn', '', ':Sm'   , 'Add/delete (if exist) sign on the selected lines'          , ':Sm')
    call signmarks#CreateMenus('cn', '', ':Smn'  , 'Move to next mark'                                         , ':Smn')
    call signmarks#CreateMenus('cn', '', ':Smp'  , 'Move to previous mark'                                     , ':Smp')
    call signmarks#CreateMenus('cn', '', ':Smg'  , 'On view window, switch to same line on main window'        , ':Smg')
    
    call signmarks#CreateMenus('cn', '', ':'     , '-Sep-', '')
    call signmarks#CreateMenus('cn', '' ,':Smh'  , 'Show command help'                                        , ':Smh')
endif

call signmarks#AutoConfigInit()

let &cpo = s:save_cpo
unlet s:save_cpo
