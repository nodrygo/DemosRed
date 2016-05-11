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

alert: function [
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
    red: system/options/boot
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
            "Tool" [ "Run"  runsrc
                     "Compile" compilesrc]
            "Help" [ "About"  about]
]
mainwin: layout [
    style: txtinfo:  text bold font-size 12 font-color blue
    txtinfo "Current Dir.:" curdir: txtinfo   "." 500 return 
    txtinfo "Current file:" 120 
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
                           'setbg-forest [codesrc/color: forest ]
                           'setbg-olive [codesrc/color: olive ]
                           'setbg-water [codesrc/color: water ]
                           'runsrc [attempt [do codesrc/text]]
                           'compilesrc [alert "ToBeDone"]
                           'about [alert "RED DEMO: SIMPLE EDITOR "]
                           'exit [quit]
                         ]
                ]
                on-resize:   func  [face [object!] event [event!]] [ codesrc/size: mainwin/size - 20x10 ]
                on-close:    func  [face [object!] event [event!]] [quit]
                on-key-down: func [face [object!] event [event!]]['done]
           ]
view/no-wait/flags mainwin [resize]
