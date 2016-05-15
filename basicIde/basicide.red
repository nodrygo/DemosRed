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
**WARNING** 
Red is far to be finished and still lack a lot of things so this code is prematured and only for fun (main lack for RED are  GC, IO, better CALL, isolated threads )

 NEED TO BE COMPILED TO WORK with RUN EXTERNAL and COMILE
 External call NEED red.exe in your path
 !!!! this is a BIG HACK you are warned !!!!!!

}
;-- system/view/debug?: yes


; to make interpretor  happy 
; scroll-bottom: none


; !!!!!!!  TO COMPILE UNCOMMENT THIS BLOCK    
;-- and adapt include below to your path

comment {

#include %../../red/system/library/call/call.red  

;-- -----------------------------------------------------
;--- INSERT EXEMPLE text area scroll CODE FROM @DOCKIMBEL 
;-- only for windows and need to be compiled 
;-- comment this code area to use in pure interpretor
;-- -----------------------------------------------------
#system [
    #import [
        "User32.dll" stdcall [
            GetScrollRange: "GetScrollRange" [
                hWnd     [handle!]
                nBar     [integer!]
                lpMinPos [int-ptr!]
                lpMaxPos [int-ptr!]
                return:  [logic!]
            ]
            SetScrollPos: "SetScrollPos" [
                hWnd    [handle!]
                nBar    [integer!]
                nPos    [integer!]
                bRedraw [logic!]
                return: [integer!]
            ]
        ]
    ]
]

scroll-top: routine [
    face [object!]
    /local
        hWnd [handle!]
][
    hWnd: gui/face-handle? face
    SetScrollPos hWnd 1 0 yes
    gui/SendMessage hWnd 00B6h 0 0                          ;-- EM_LINESCROLL
    gui/SendMessage hWnd 00B7h 0 0                          ;-- EM_SCROLLCARET
]

scroll-bottom: routine [
    face [object!]
    /local 
        hWnd    [handle!]
        pos-min [integer!]
        pos-max [integer!]
][
    hWnd: gui/face-handle? face
    pos-min: 0
    pos-max: 0
    GetScrollRange hWnd 1 :pos-min :pos-max
    SetScrollPos gui/face-handle? face 1 pos-max yes
    gui/SendMessage hWnd 00B6h 0 99999                      ;-- EM_LINESCROLL
    gui/SendMessage hWnd 00B7h 0 0                          ;-- EM_SCROLLCARET
]

;-- -----------------------------------------------------

}

;-- -----------------------------------------------------
;-- redefine print is big hack 
 
printerr: function [xl] [
    ; print out in -panout-
    ; printorig ["printerr for x: xl" xl]
    if xl [
        case[  
             string? xl [append -panout-/text  form xl ] 
             series? xl [foreach y xl   [printerr mold compose y]]
             true  [ append -panout-/text  form mold xl  ]
        ] 
    ]
]

printerrlf: function [x] [printerr x  append -panout-/text crlf]

aboutmsg: { Basic demo ide editor
  writen in Red Lang (http://www.red-lang.org/) 
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

;;; NEED to redeclare lite help to work with my limited print 
-litehelp-: func[w][
            spec: spec-of get w 
            either any [
                string? desc: spec/1 
                string? desc: spec/2
            ] [
                printerrlf [desc]
            ] [printerrlf "no doc avalaible" ]
]

-current-: context [
    red: "red.exe  "
    redboot:  system/options/boot
    curdirfiles: []
    modified: false
    target: "Windows"
    cmd: ""
]

if system/platform <> 'Windows [ -current-/red: "red  "  ]

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

-loadfile-: does[ 
            printerrlf ["Loadfile --> " -curfilename-/text ]
            fn: to file! -curfilename-/text
            if exists? fn [-codesrc-/text:  read  fn]
            -current-/modified: false
]

-savefile-: does [write/binary (to file! -curfilename-/text) -codesrc-/text  -current-/modified: false]

-setcurdirfiles-: does [-current-/curdirfiles: dirfiles ]

-execall-: function [mustwait] [
    "call red as external program red.exe must be in path"
    printerrlf ["TRY TO RUN EXTERNAL  " -current-/cmd]
    either -current-/modified 
        [  alertPOPUP "Please save file before" ]
        [  either mustwait [attempt [call/wait/console -current-/cmd]]
                           [attempt [call/console -current-/cmd]]
        ]
]

-check-is-red-: function[fn][parse fn [thru ["reds" | "red"] ] ]

-dolocalrun-: does[
    either  -codesrc-/text <> none [
                printerrlf ["Run file -->  " -curfilename-/text] 
                attempt [do -codesrc-/text]
            ][
                printerrlf "WARNING not a red or reds file "
           ]
]

-doextrun-: does [
    either (-check-is-red- -curfilename-/text)[
          clear -current-/cmd
          append -current-/cmd -current-/red   ;--"red.exe  "
          append -current-/cmd -curfilename-/text 
          -execall- false
        ][
         printerrlf "WARNING not a red or reds file "
        ]
]

-doextcompil-: does [
    either (-check-is-red- -curfilename-/text)[
          clear -current-/cmd
          append -current-/cmd -current-/red   ;--"red.exe  "
          append -current-/cmd " -c -t "
          append -current-/cmd -current-/target
          either modedebug/data [append -current-/cmd " -d "][append -current-/cmd " "]
          append -current-/cmd -curfilename-/text
          -execall- true
          printerrlf "Compilation finished see .exe in your directory"
        ][
           printerrlf "WARNING not a red or reds file "
        ]
]

-comptype-bar-: [
    group-box "Compile Target"  [ 
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

allwords: copy []
allstrwords: copy []
getallwords: does [
    foreach w sort words-of system/words [
        if all [word? w any-function? get/any :w] [
                       unless parse mold w ["-" thru "-"]
                               [append allwords w  
                                append allstrwords (mold w)]
                       ]
        ]
]

-help-: function[f] [
    printerrlf ["   HELP FOR : " ( pick allstrwords f/selected)]
    -litehelp- (pick allwords f/selected)
]

-mainwin-: layout compose/deep[
    style: txtinfo:  text bold font-size 12 font-color blue
    txtinfo "-current- Dir.:"  curdir: txtinfo "" 300  return 
    -curfilename-: field "defaulteditest.red" 200  
    button "Run" [-dolocalrun-] 
    txtinfo "  help:" 
    allw: text-list  60x10 [-help- face] return
    below
    space 2x2
    panel [
        panel 130x450 [ below space 2x2
               -flist-: text-list 120x180  on-change [-curfilename-/text: pick -current-/curdirfiles face/selected -loadfile-]
               (-comptype-bar-)
               ]
        -pansrc-: panel 710x460 [
              -codesrc-: area 700x440 bold italic white font-color black font-size 14  on-change[ -current-/modified: true]
              ]
    ]
    panel [
        panel 130x200 [
            button 120x120 "clear err" [clear -panout-/text] 
        ]
        -panres-: panel 710x210 [
              -panout-: area 700x200 bold italic white font-color black font-size 14 on-change[ scroll-bottom face] 
              ]
    ]
    do [  -panout-/text: "" curdir/text:  form get-current-dir -setcurdirfiles-  -flist-/data: -current-/curdirfiles  getallwords allw/data: allstrwords ]
]

-mainwin-/menu: [
    "File" [
            "New file"     fnew
            "Load file"    fopen
            "Save file"    fsave
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

-mainwin-/actors: context [
    on-menu: func [face [object!] event [event!]][
        either event/picked = none
           [printerrlf " !!!!!!!!!!! ALERT NONE EVENT" ]
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
               'setbg-olive [-codesrc-/color: olive ]
               'setbg-water [-codesrc-/color: water ]
               'runsrc [-dolocalrun-]
               'runextsrc  [-doextrun-]
               'compilesrc [-doextcompil- ]
               'about [infoPOPUP aboutmsg]
               'exit [unview]
             ]]
         none
    ]
    on-resize:   func  [face [object!] event [event!]] [ -calcresize- ]
    on-key-down: func [face [object!] event [event!]]['done]
    ]

-minwinsize-: 900x820
-calcresize-: does [
    deltasize: -mainwin-/size  -  -minwinsize-
    either -mainwin-/size < -minwinsize- 
        [
         -mainwin-/size: -minwinsize-
         -pansrc-/size:  710x460
         -panres-/size:  710x210
         -codesrc-/size: 700x450
         -panout-/size:  700x200
         ]
        [
         -pansrc-/size:  710x460 + deltasize 
         -panres-/size:  710x210 + deltasize 
         -codesrc-/size: 700x450 + deltasize
         -panout-/size:  700x200 + deltasize
          ]
          printerrlf ["*************************"]
          printerrlf ["WITH DELTA " deltasize]
          printerrlf ["  -mainwin-  " -mainwin-/size] 
          printerrlf ["  -pansrc-   " -pansrc-/size ]
          printerrlf ["  -panres-   " -panres-/size ]
          printerrlf ["  -codesrc-  " -codesrc-/size ]
          printerrlf ["  -panout-   " -panout-/size ]
]



;-- some problem to redefine print with compiler 
;-- must be last to get compiled ... so in this code must use printerrlf 
init: does [
    set 'prinorig :prin 
    set 'printorig :print 
    set 'print :printerrlf
    set 'prin :printerr
]
init

view/flags -mainwin- [resize]

