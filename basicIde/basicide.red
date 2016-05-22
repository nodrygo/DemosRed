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

;-- redefine print is big hack 
printerr: function [xl] [
    ; print out in -panout-
    ; printorig ["printerr for x: xl" xl]
    if xl [
        case[  
             string? xl [append -panout-/text  form xl ] 
             series? xl [nxl: compose xl foreach y nxl [either string? y [printerr y][ printerr  reduce y ]]]
             true  [ append -panout-/text  form mold xl ]
        ]
    ]
]

printerrlf: function [x] [
                     printerr x  
                     append -panout-/text crlf 
                     ]
;-- some problem to redefine print with compiler 
;-- must be last to get compiled ... so in this code must use printerrlf 

comment {
    ** TODO **
externalise dialogs
add parameters tabs:  compil dll/exe/verbose  font/size/color 
save default params in file 
wait for richtext and add color syntax/completion

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
#include %../../redgit/red/system/library/call/call.red  

;-- -----------------------------------------------------
;--- INSERT EXEMPLE text area scroll CODE FROM @DOCKIMBEL 
;-- only for windows and need to be compiled 
;-- comment this code area to use in pure interpretor
;-- -----------------------------------------------------#system [
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
        resl [logic!]
        resi [integer!]
][
    hWnd: gui/face-handle? face
    pos-min: 0
    pos-max: 99999
    resl: GetScrollRange hWnd 1 :pos-min :pos-max 
    resi: SetScrollPos hWnd 1 pos-max yes
    ;print " RES RANGE " print resl print " MAX " print pos-max
    ;print " RES POS " print resi print lf
    gui/SendMessage hWnd 00B7h 0 pos-max                  ;-- EM_SCROLLCARET
    gui/SendMessage hWnd 00B6h 0 pos-max             ;-- EM_LINESCROLL
]

;-- -----------------------------------------------------
}


;-- -----------------------------------------------------

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

paramsPOPUP: function [
    "Displays parameters"
][
    view [
    style: tradio: radio 120x20
    Tab-panel [ 
        "Compiler" [ across
           panel[
              group-box "Compile Target"  [ 
                return
                tradio "windowsXP"  data true [-current-/target: "windowsXP"] return
                tradio "windows"    [-current-/target: "windows"] return
                tradio "Linux"      [-current-/target: "Linux"] return
                tradio "Linux-ARM"  [-current-/target: "Linux-ARM"] return
                tradio "RPi"        [-current-/target: "RPi"] return
                tradio "Darwin"     [-current-/target: "Darwin"] return
                tradio "Android"    [-current-/target: "Android"] 
                ]
            ]
           panel[
              group-box "Mode Compile"  [ 
                return
                tradio "Exe"   data true [-current-/outmode: "exe"] return
                tradio "Dll"  [-current-/outmode: "dll"] 
                ]return
              check "debug"   [-current-/debug: face/data] return
              check "no runtime"  [-current-/noruntime: face/data] 
           ]   
        ]
        "Presentation" [ across
          panel[
            group-box "Edit"  [return
                tradio "Font 8"   [-codesrc-/font/size: 8] return
                tradio "Font 10"  data true [-codesrc-/font/size: 10] return
                tradio "Font 12"  [-codesrc-/font/size: 12] return
                tradio "Font 14"  [-codesrc-/font/size: 14] return
                ]return
            group-box "Text color "  [return
                tradio " black"  data true [-codesrc-/font/color: black ] return
                tradio " white"   [-codesrc-/font/color: white ] return
                tradio " red"   [-codesrc-/font/color: red ] return
                tradio " blue"   [-codesrc-/font/color: blue ] return
                ]return
            group-box "Background color "  [return
                tradio "white"   [-codesrc-/color: white ] return
                tradio "black"   [-codesrc-/color: black ] return
                tradio "cyan"   data true  [-codesrc-/color: cyan ] return
                tradio "water"   [-codesrc-/color: water ]
                ] 
           ]
          panel[
                group-box "Output"  [return
                tradio "8"   [-panout-/font/size: 8] return
                tradio "10"   data true [-panout-/font/size: 10] return
                tradio "12"    [-panout-/font/size: 12] return
                tradio "14"    [-panout-/font/size: 14] return
            group-box "Background  color "  [return
                tradio "black"  data true [-panout-/font/color: black ] return
                tradio "white"   [-panout-/font/color: white ] return
                tradio "red"   [-panout-/font/color: red ] return
                tradio "blue"   [-panout-/font/color: blue ] return
                ]return
            group-box "Text color "  [return
                tradio "white"  data true [-panout-/color: white ] return
                tradio "black"    [-panout-/color: black ] return
                tradio "cyan"     [-panout-/color: cyan ] return
                tradio "water"    [-panout-/color: water ]
                ]
            ]
          ]
        ]
    ]
    return
    button "ok" [ unview]
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
    minwinsize: 900x800
    red: "red.exe  "
    redboot:  system/options/boot
    curdirfiles: []
    modified: false
    target: "Windows"
    debug: false
    cmd: ""
    editfont: "8"
    outmode: "exe" 
    noruntime: false
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

; borrow and adapt  try-do from  Red console
try-dodo: func [code /local res  strout ][
    set/any 'res  try [
        catch/name [set/any 'res  do code] 'strout
        ]
     attempt[
            ; if return is  error! object print error else print ok running
            oer: parse mold res [thru "make error!" thru end]
            either oer
                    [printerrlf [" !!! ERROR !!! " :res/id " WHERE: "  :res/where "  " :res/arg1 " " :res/arg2 :res/arg3 ]]
                    [printerrlf  "*******  RUNNING DONE  ****"]

           ]
]

; TODO   PARSE code to transform all word:  as local ???
-dolocalrun-: function[][
    either  -codesrc-/text <> none [
                printerrlf "*******   RUNNING BUFFER  ****"
                try-dodo  -codesrc-/text
            ][
                printerrlf "WARNING not a Red or Reds file "
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
          either -current-/debug [append -current-/cmd " -d "][append -current-/cmd " "]
          either --current-/outmode = "dll" [append -current-/cmd " -dlib "][append -current-/cmd " "]
          either -current-/noruntime = true [append -current-/cmd " -r "][append -current-/cmd " "]
          append -current-/cmd -curfilename-/text
          -execall- true
          printerrlf "Compilation finished see .exe in your directory"
        ][
           printerrlf "WARNING not a red or reds file "
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

lastsel: 0 
-help-: function[sel] [
    w: pick allstrwords sel
    printerrlf ["   HELP FOR : " ( pick allstrwords sel)]
    -litehelp- (pick allwords sel)
] 
-tools-bar-: [
    -tb-: panel 900x20  blue  [ across origin 1x1 space 1x1 
        toolbutton "Load" [-loadfile-]
        toolbutton "Save" [-savefile-]
        toolbutton ""  disabled
        toolbutton "Run" [-dolocalrun-]
        toolbutton "Run External" [-doextrun-]
        toolbutton "Compile Ext" [-doextcompil-]
        toolbutton "" disabled
        toolbutton "Parameters" [paramsPOPUP]
        toolbutton "" disabled
        toolbutton "" disabled
        toolbutton "" disabled
        toolbutton "" disabled
        toolbutton "About" [infoPOPUP aboutmsg]
    ]return
]
 
-mainwin-: layout compose/deep[
    style: toolbutton: button 66x18
    (-tools-bar-)
    style: txtinfo:  text bold font-size 12 font-color blue
    txtinfo "-current- Dir.:"  curdir: txtinfo "" 300  return 
    -curfilename-: field "defaulteditest.red" 200  
    button "Run" [-dolocalrun-] 
    txtinfo "  help:" 
    allw: Drop-down  80x20  on-change [-help- face/selected]   return
    workpanel: panel blue [ below 
        topp: panel black 900x440 [ origin 0x0 
            subtopp: panel blue  [ below 
                   -flist-: text-list 120x250  on-change [-curfilename-/text: pick -current-/curdirfiles face/selected -loadfile-]
                   ]
                  -codesrc-: area  bold cyan font-color black font-size 10  on-change[ -current-/modified: true]
            ]
        bottompp: panel black 900x200 [ origin 0x0
            subbottompp: panel blue [
                button 120x120 "clear err" [clear -panout-/text] 
                return
                button 120x30 "go bottom"  [scroll-bottom -panout-]
            ]
            -panout-: area  bold italic white font-color black font-size 10 on-change[scroll-bottom face]
        ]
    ]
    do [  -panout-/text: "" 
          curdir/text:  form get-current-dir 
          -setcurdirfiles- 
           -flist-/data: -current-/curdirfiles  getallwords 
           allw/data: allstrwords 
           -panout-/enable? false
        ]
]


-mainwin-/menu: [
    "File" [
            "New file"     fnew
            "Load file"    fopen
            "Save file"    fsave
            "-------"
            "Exit"        exit
           ]
    "Tool" [ 
             "Run"  runsrc
             "Run external"  runextsrc
             "Compile" compilesrc
           ]
    "Parameters"  callparams
    "Help" [ "About"  about]
]

-mainwin-/actors: context [
    on-menu: func [face [object!] event [event!]][
        either event/picked = none
           [printerrlf " !!!!!!!!!!! ALERT NONE EVENT" ]
           [switch event/picked [
               'fnew   [-flist-/selected: none  -curfilename-/text: "new.red" clear -codesrc-/text ] 
               'fopen  [-loadfile-] 
               'fsave  [-savefile-] 
               'callparams [paramsPOPUP]
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


-calcresize-: does [
    if -mainwin-/size/y < -current-/minwinsize/y 
    [ -mainwin-/size/y: -current-/minwinsize/y
    ]
    if -mainwin-/size/x < -current-/minwinsize/x 
    [ -mainwin-/size/x: -current-/minwinsize/x
    ]
    -tb-/size/x: -mainwin-/size/x - 20

    workpanel/offset/x: 0
    workpanel/size/y: to integer!  -mainwin-/size/y - 100
    workpanel/size/x: -mainwin-/size/x 

    topy:    to integer!  workpanel/size/y * 60%
    panx:    workpanel/size/x -  20

    topp/size/x:      panx 
    topp/size/y:      topy - 20 
    subtopp/size/x: 160 
    subtopp/size/y: topy - 20 

    bottompp/offset/y:  topy 
    bottompp/size/x:    panx 
    subbottompp/size/x: 160
    subbottompp/size/y:    workpanel/size/y -  topp/size/y - 40 
    bottompp/size/y:       workpanel/size/y -  topp/size/y - 40 

    -codesrc-/size/x: topp/size/x - 160
    -codesrc-/size/y: topp/size/y - 10 

    -panout-/size/x:  bottompp/size/x - 160
    -panout-/size/y:   bottompp/size/y - 10 

     ;-- print "*************************"
     ;-- print ["  -mainwin-  " -mainwin-/size] 
]

init: does [
    set 'prinorig :prin 
    set 'printorig :print 
    set 'print :printerrlf
    set 'prin :printerr
]
init
 
-mainwin-/size: -current-/minwinsize
-calcresize-
;view/flags -mainwin- [resize]
view/no-wait/flags -mainwin- [resize]

