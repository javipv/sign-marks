# sign-marks
Allows you to have unlimited marks by making use of the vim signs.

Previosly on: [vim.org](https://www.vim.org/scripts/script.php?script_id=5983).

Sign-marks is a plugin to:
- Add signs with different levels.
- Display the marks and signs on a quickfix or new window
- Save and restore the marks and signs.
- Navigate the signs and marks.

This plugin is a perfect complement for plugin [vim-signature](https://www.vim.org/scripts/script.php?script_id=4118)

I use sign-marks to:
- Add signs to lines (:Sm or :Sma) on large logs.
- Remove signs (:Sm or Smd).
- Navigate the log sigsn/marks (:Smn/:Smp)
- Open a view window with all signs and marks (:Smw or SmW) or quickfix window (:Smq or :SmQ).
- Open a menu to choose the view (:Smv).
- Save the signs and marks to a config file (:Smsv) or restore them from file (:Sml)
- Save the marks and signs on the file itself as a config line on the bottom of the file (:Smcl).
- Synchronize main and view window (:Smg)
- Show signs resume on new window but filter signs by level (:Smw s1 s3 s10:s15 s30:)
- Show all signs and marks used on current vim session (:Smw a or :Smq a, :SmW a, SmQ a)
- Show all signs and marks used on current vim session filter by file name and sign level (:Smw s3:s14 a +cpp)

In case the file's highlighted using plugin [hi.vim](https://github.com/javipv/hi.vim), the highlighting configuration is also aplied to the marks when opening them on a new window (:Smw) or quickfix window .(:Smq)

## Mappings:
- s+1 to s+0 to add/delete a sign on the current line or selected lines.
- s+tab+1 to s+tab+5 to open the different view windows.
- s+enter to switch between main and view window.
- s+del or s+supr to remove a sign on current or selected lines.

This last option I use it mainly when navigating code and I want to search one line a previously marked or just to understand the code viewing just the code snippets I need. Very handy when using it along with [bookmars.vim](https://github.com/javipv/bookmarks.vim)

The doc is still pending meanwhile you can check :Smh for an abridged command help and examples:

Any feedback will be welcome.


### ADVANCED:
Customizations you can add to your .vimrc file.

Overwrite maps s+1 to s+0 used on any other plugin.
```vimscript
let g:SignMarks_remapPrevMappings = "yes"
```

Remap s+0 to sign 24:
```vimscript
let g:SignMarks_userSignMappinsList  = []
let g:SignMarks_userSignMappinsList += [['s0', 24]]
```
Add new view command :Smwt, will show all marks and signs on new tab applying options:"FH1IMSU.fn.lf"
```vimscript
let g:SignMarks_userViewList  = []
let g:SignMarks_userViewList += [ ['' , "tabnew" , "marks&signs" , "FH1IMSU.fn.lf"  , "wt"] ]
```

Same as above but assign also map s+6 and add new command Smv6:
```vimscript
let g:SignMarks_userViewList  = []
let g:SignMarks_userViewList += [ [6 , "tabnew" , "marks&signs" , "FH1IMSU.fn.lf"  , "wt"] ]
```

You can see the new signs with command :Smv

Add new sign with symbol '=='
```vimscript
let g:SignMarks_userSignsList   = []
let g:SignMarks_userSignsList += [ ["==", "", ""] ]
```

Add new sign with symbol '=>', use sign highlighing: Error, and content highlighting: ErrorMsg
```
let g:SignMarks_userSignsList += [ ["=>", "Error", "ErrorMsg"] ]
```

You can see the new signs with command :Smsh

 
## Install details
Minimum version: Vim 7.0+
Recomended version: Vim 8.0+

## Install vimball:
download signmarks.vmb
vim signmarks.vmb
:so %
:q
