Red [
        Title:   "Basic demo editor"
        Purpose: "test for basic Red editor"
        File:    %basicEdit.red
        Tabs:    4
        Author: "NoDrygo"
        Rights:  ""
        License: {
            Distributed under the Boost Software License, Version 1.0.
            See https://github.com/red/red/blob/master/BSL-License.txt
        }
        Needs:   'view
]

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

;-- needed for future extension 
current: context [
    bgcolor: black
    fgcolor: white
    filename: "editest.red"
]

mainmenu: [
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
                         "Red" setfg-blue
                         "Blue" setfg-red
                         ]                         
                    "BgColor"     
                         [
                         "Black" setbg-black
                         "White" setbg-white
                         "Cyan" setbg-cyan
                         ]
                   ]
            "Tool" [ "Run"  runsrc
                     "Compile" compilesrc]
            "Help" [ "About"  about]
]
mainwin: layout [
    curdir: text  "." 500 bold font-size 12 font-color blue return 
    text  "current file:" 120 bold font-size 12 font-color blue
    curfilename: field "editest.red" 200 [current/filename: face/text] return
    codesrc: area 600x400 bold italic white font-color black font-size 14 
    do [curdir/text: copy mold get-current-dir
       ]
]

mainwin/menu: mainmenu

mainwin/actors: context [
                on-menu: func [face [object!] event [event!]][
                        switch event/picked [
                           'fnew  [ clear codesrc/text ] 
                           'fopen  [ codesrc/text: copy load to file! current/filename] 
                           'fsave  [save to file! current/filename  codesrc/text]
                           'setfont8 [codesrc/font/size: 8 ]
                           'setfont10 [codesrc/font/size: 10 ]
                           'setfont12 [codesrc/font/size: 12 ]
                           'setfont14 [codesrc/font/size: 14 ]
                           'setfg-black [codesrc/font/color: black ]
                           'setfg-white [codesrc/font/color: white ]
                           'setfg-red [codesrc/font/color: red ]
                           'setfg-blue [codesrc/font/color: blue ]
                           'setbg-black [codesrc/color: black ]
                           'setbg-white [codesrc/color: white ]
                           'setbg-cyan [codesrc/color: cyan ]
                           'runsrc [attempt [do codesrc/text]]
                           'compilesrc [alert "ToBeDone"]
                           'about [alertPOPUP "RED DEMO: SIMPLE EDITOR "]
                           'exit [quit]
                         ]
                ]
                on-resize:   func  [face [object!] event [event!]] [ codesrc/size: mainwin/size - 20x10 ]
                on-close:    func  [face [object!] event [event!]] [quit]
                on-key-down: func [face [object!] event [event!]]['done]
           ]
view/no-wait/flags mainwin [resize]
