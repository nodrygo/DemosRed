Red [
        Title:   "Basic demo ide editor"
        Purpose: "demo for basic Red ide editor"
        File:    %basicide.red
        Tabs:    4
        Author: "NoDrygo"
        License: {
            Distributed under the Boost Software License, Version 1.0.
            See https://github.com/red/red/blob/master/BSL-License.txt
        }
        Needs:   'view
]


comment {
**WARNING**Red is far to be finished and still lack a lot of things so this code is prematured and only for fun (main lack for RED GC IO better CALL )
 NEED TO BE COMPILED TO WORK with RUN external and compile 
 !!!! this is a BIG HACK you are warned !!!!!!
  Adapt include below to your path
}

#include %../../red/system/library/call/call.red 

;-- system/view/debug?: yes
aboutmsg: { Basic demo ide editor
  writen in Red Lang 
            Distributed under the Boost Software License, Version 1.0.
            See https://github.com/red/red/blob/master/BSL-License.txt

        } 
alertPOPUP: function [
    "Displays an alert message"
    msg [string!]  "Message to display"
][
    view [
        t: text msg center return
        b: button "ok" [ unview]
        do [b/offset/x: t/offset/x + (t/size/x - b/size/x / 2)]
    ][modal popup]
]
infoPOPUP: function [
    "Displays an alert message"
    msg [string!]  "Message to display"
][
    view [
        t: area  msg center return
        b: button "ok" [ unview]
        do [b/offset/x: t/offset/x + (t/size/x - b/size/x / 2)]
    ][modal popup]
]


-current-: context [
    bgcolor: black
    fgcolor: white
    red: "red.exe  "
    redboot:  system/options/boot
    curdirfiles: []
    modified: false
    target: "Windows"
    cmd: ""
]

if system/platform <> 'Windows [ -current-/red: "red  "  ]

-mainmenu-: [
            "File" [
                    "New file"     fnew
                    "Load file"     fopen
                    "Save file"     fsave
                    "-------"
                    "Exit"        exit
                   ]
            "Font" [
                    "Size"     
                         [
                         "8" setfont8
                         "10" setfont10
                         "12" setfont12
                         "14" setfont14
                         ]
                    "FgColor"     
                         [
                         "Black" setfg-black
                         "White" setfg-white
                         "Blue" setfg-blue
                         "Red" setfg-red
                         ]                         
                    "BgColor"     
                         [
                         "Black" setbg-black
                         "White" setbg-white
                         "Water" setbg-water
                         "Cyan" setbg-cyan
                         "Forest" setbg-forest
                         "Olive" setbg-olive
                         ]
                   ]
            "Tool" [ 
                     "Run"  runsrc
                     "Run external"  runextsrc
                     "Compile" compilesrc
                   ]
            "Help" [ "About"  about]
]




dirfiles: function [
    "select files and return list (poor copy from original file)"
    'dir [any-type!] "Folder to list"
][
    unless value? 'dir [dir: %.]
    unless find [file! word! path!] type?/word :dir [
        cause-error 'script 'expect-arg ['list-dir type? :dir 'dir]
    ]
    list: read normalize-dir dir
    reslist: copy []
    foreach  d list[
        unless parse d [thru "exe"][
                                 append reslist form d
                                   ]
    ]
    reslist
]

-loadfile-: does[ print ["-loadfile- " curfilename/text ]
                fn: to file! curfilename/text
                ;--if exists? fn [-codesrc-/text: replace/all read fn "^/" "^/"]
                if exists? fn [-codesrc-/text:  read  fn]
                -current-/modified: false
                if -codesrc-/text = none [print "WARNING CODSRC/TEXT IS NONE"]
              ]

-savefile-: does [write/binary (to file! curfilename/text) -codesrc-/text  -current-/modified: false]

-setcurdirfiles-: does [-current-/curdirfiles: dirfiles ]

-execall-: function [waitexe?] [
    "call red as external program red.exe must be in path"
    either -current-/modified 
        [  alertPOPUP "Please save file before" 
        ][ attempt [
                either waitexe?
                      [pid: call/wait/console -current-/cmd]
                      [pid: call/console -current-/cmd]  
               append codeerr/text (append  copy "^/START PID:" form pid)
               ]
        ]
]

-dolocalrun-: does[ 
                  either  -codesrc-/text <> none [
                     print ["RUN " curfilename/text] 
                     attempt [do -codesrc-/text]
                  ][
                     print "-codesrc-/TEXT is NONE please try to RELOAD FILE  " 
                  ]
]

-doextrun-: does [
    clear -current-/cmd
    append -current-/cmd -current-/red   ;--"red.exe  "
    append -current-/cmd curfilename/text
    codeerr/text:  -current-/cmd 
    -execall- false
]

-doextcompil-: does [
    clear -current-/cmd
    append -current-/cmd -current-/red   ;--"red.exe  "
    append -current-/cmd " -c -t "
    append -current-/cmd -current-/target
    either modedebug/data [append -current-/cmd " -d "][append -current-/cmd " "]
    append -current-/cmd curfilename/text
    codeerr/text:  -current-/cmd
    -execall- true
]

-calcresize-: does [
    newsize: -mainwin-/size - -codesrc-/offset
    -codesrc-/size: newsize - 10x110
]

-comptype-bar-: [
    group-box "Compile Target type"  [ 
    return
    radio "windowsXP"  80x15 data true [-current-/target: "windowsXP"] return
    radio "windows"    80x15  [-current-/target: "windows"] return
    radio "Linux"      80x15  [-current-/target: "Linux"] return
    radio "Linux-ARM"  80x15  [-current-/target: "Linux-ARM"] return
    radio "RPi"        80x15  [-current-/target: "RPi"] return
    radio "Darwin"     80x15  [-current-/target: "Darwin"] return
    radio "Android"    80x15  [-current-/target: "Android"] return
    modedebug: check "debug"    80x15    return
    ]
] 

-mainwin-: layout compose/deep[
    style: txtinfo:  text bold font-size 12 font-color blue
    txtinfo "-current- Dir.:"  curdir: txtinfo "" 300  return 
    curfilename: field "defaulteditest.red" 200  
    button "Run" [-dolocalrun-] return
    below
panel [
    panel [ below
           -flist-: text-list 120x250  on-change [curfilename/text: pick -current-/curdirfiles face/selected -loadfile-]
           (-comptype-bar-)
           ]
    panel [ 
          -codesrc-: area 700x420 bold italic white font-color black font-size 14  on-change[ -current-/modified: true]
          ]
]
panel[
    button 120x120 "clear err" [clear -panout-/text] 
    panel [
           
          -panout-: area 700x220 bold italic white font-color black font-size 14  
          
          ]
]
    do [ -panout-/text: "" curdir/text:  form get-current-dir -setcurdirfiles-  -flist-/data: -current-/curdirfiles ]
]

-mainwin-/menu: -mainmenu-

-mainwin-/actors: context [
    on-menu: func [face [object!] event [event!]][
        either event/picked = none
           [print " !!!!!!!!!!! ALERT NONE EVENT" ]
           [switch event/picked [
               'fnew   [clear -codesrc-/text ] 
               'fopen  [-loadfile-] 
               'fsave  [-savefile-] 
               'setfont8  [-codesrc-/font/size: 8 -panout-/font/size: 8 ]
               'setfont10 [-codesrc-/font/size: 10 -panout-/font/size: 10]
               'setfont12 [-codesrc-/font/size: 12 -panout-/font/size: 12]
               'setfont14 [-codesrc-/font/size: 14 -panout-/font/size: 14]
               'setfg-black [-codesrc-/font/color: black ]
               'setfg-white [-codesrc-/font/color: white ]
               'setfg-red [-codesrc-/font/color: red ]
               'setfg-blue [-codesrc-/font/color: blue ]
               'setbg-black [-codesrc-/color: black ]
               'setbg-white [-codesrc-/color: white ]
               'setbg-cyan [-codesrc-/color: cyan ]
               'setbg-forest [-codesrc-/color: forest ]
               'setbg-olive [-codesrc-/color: olive ]
               'setbg-water [-codesrc-/color: water ]
               'runsrc [-dolocalrun-]
               'runextsrc  [-doextrun-]
               'compilesrc [-doextcompil-  alertPOPUP "finished"]
               'about [infoPOPUP aboutmsg]
               'exit [unview]
             ]]
         none
    ]
    on-resize:   func  [face [object!] event [event!]] [ -calcresize- ]
    on-key-down: func [face [object!] event [event!]]['done]
    ]

printerr: function [xl] [
    ; print out in -panout-
    if xl [
       case[  
             string? xl [append -panout-/text  xl ] 
             series? xl [foreach y xl   [printerr reduce y]]
             true  [append -panout-/text mold  xl ]
           ] 
    ] 
]
printerrlf: function [x] [printerr x  append -panout-/text crlf]

set 'prinorig :prin 
set 'printorig :print 
set 'print :printerrlf
set 'prin :printerr

view/flags -mainwin- []