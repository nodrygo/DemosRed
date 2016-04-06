Red [
        Title: "simpleDraw3"
        Author: "renaudG/nodrygo  " 
        Goal: "draw with lines/  color selector & POPUP"
        File:   %simpleDraw3.red
        Tabs:   4
        Rights: ""
        License: {
        Distributed under the Boost Software License, Version 1.0.
        See https://github.com/red/red/blob/master/BSL-License.txt
        }
        needs: 'view
]

to-color: function [r g b][
    c: 0.0.0
    c/1: to integer! 255 * r
    c/2: to integer! 255 * g
    c/3: to integer! 255 * b
    c
]

to-percents: function [
    "Convert a color tuple to percent values"
    c [tuple!] "Color tuple"
] [
    reduce [ to percent! (c/1 / 255.0) to percent! (c/2 / 255.0) to percent! (c/3 / 255.0) ]
]

entities: object [
    size: 1
    number: 0
    pencolor: red 
    penstatus: 'on-down
    startpos: 1x1
    firstpt: true
    prepareline: []
    elist: [ ]
    startline:  [line-width (size) pen (pencolor) fill-pen (pencolor) line-cap round line-join round line (startpos) ]
    addline:    func [ pos ] [ either penstatus = 'up  [ compose startline] 
                                                       [ compose [(pos)] ]
                             ]
    addpt:      func [ pos ] [  delta: absolute(pos - startpos)
                                maxdelta: make pair! reduce [size + 5 size + 5]
                                if delta > maxdelta [  
                                     if firstpt [ append elist prepareline  firstpt: false]
                                     append elist compose [(pos)]
                                ]
                              penstatus: 'down
                              print ["ENTITIES LIST:" elist]
                             ]
    newline:    func [ pos ] [ 
                            penstatus: 'down 
                            firstpt: true
                            startpos: pos 
                            prepareline: compose startline 
                             ]     
    setsize:    func [ x ] [ form size: max 1 to integer! 100 * x ]
    reset:      does [ head clear at elist 5  self/number: 0 ]
]

alertPOPUP: function [
    "Displays an alert message"
    msg [string!]  "Message to display"
][
    view/flags [
        t: text msg center return
        b: button "ok" [ unview]
        do [b/offset/x: t/offset/x + (t/size/x - b/size/x / 2)]
    ][modal popup]
]

colorpopup: function [
    "show color box popup"
    lcolor  [tuple!]
    return: [tuple!]
][
    set [lcr lcg lcb] to-percents lcolor
    p2b: func [p] [to integer! p * 255]
    view/flags [
        title "Color Selector"
        LCL: base 100x100 red react [color]
        GB: group-box "color select"  [ 
            return  across
            text "R:"  LSR: slider lcr [LCL/color/1: p2b LSR/data ] return
            text "G:"  LSG: slider lcg [LCL/color/2: p2b LSG/data ] return
            text "B:"  LSB: slider lcb [LCL/color/3: p2b LSB/data ]
        ] return 
        button "OK" 100     [ unview lcolor: to-color LSR/data LSG/data LSB/data ]
        button "Cancel" 100 [ unview ]
        do [LCL/size/2: GB/size/2 LCL/color: lcolor]
    ][modal popup]
    lcolor
]
;; colorpopup to-color 50% 20% 20%

view/no-wait [
    sld: slider 100 [t/text: entities/setsize face/data]
    t: text "1"  text  bold font-color black font-size 16 " Color:" 
    cl: base 100x25 red  on-down [ cl/color: entities/pencolor: colorpopup entities/pencolor]
    return 
    b: base 800x600 black draw entities/elist 
         all-over on-over [ either  event/down? [ entities/addpt event/offset 'done ]
                                                [ entities/newline event/offset 'done]
                          ]
    return
    button "CLEAR"    100 [ entities/reset ]
    button "SAVE IMG" 100 [ save %dessin.png to-image b     alertPOPUP "DESSIN.PNG SAVED"]
    button "SAVE RED" 100 [ save %dessin.red entities/elist alertPOPUP "DESSIN.RED SAVED"]
    button "LOAD RED" 100 [ attempt [entities/elist: b/draw: load %dessin.red] ]
]


