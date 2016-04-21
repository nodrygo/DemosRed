Red [ ]


distance: function [p1 [pair!] p2 [pair!] /return [integer!]][
   x:  p1/x - p2/x 
   y:  p1/y - p2/y
   to integer! square-root ((x * x) + (y * y)) 
]


angle: function [p1 [pair!] p2 [pair!] /return [integer!]][
   dxy:  p2 -  p1 
   to integer!  (arctangent2 dxy/y  dxy/x) * (180 / pi) 
]

snapto:  function [snapmode gridsize pos [pair!]  /return [pair!] ] [
print ["snapto " snapmode "  " gridsize "  " pos ]
         switch/default snapmode [
                                'none [pos]
                                'grid [ (pos / gridsize) * gridsize] 
         ][pos]
]

;angle 100x100 200x100
;angle 100x100 100x0
;angle 100x100 100x200
;angle 100x100 -100x100
;angle 100x100 100x-100 

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

colorpopup: function [
    "show color box popup"
    lcolor  [tuple!]
    return: [tuple!]
][
    set [lcr lcg lcb] to-percents lcolor
    p2b: func [p] [to integer! p * 255]
    view [
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

img: context [
    localpath: %/images/
    remotepath: https://raw.githubusercontent.com/nodrygo/DemosRed/master/images/
    loader: func [imgname return: [image!]] [
       nlimg: copy reduce localpath   append nlimg  imgname
       nrimg: copy reduce remotepath  append nrimg  imgname
       load reduce either file? nlimg [ nlimg ] [ nrimg]
    ]
]
; i1: img/loader 'logo.png
; i2: img/loader 'RedAction.red
; change piqué sur Red/france par  fvanzeveren
change: func [
    "Changes a value in a series and returns the series after the change."
    series [series!] "Series at point to change"
    value [any-type!] "The new value"
    /part {Limits the amount to change to a given length or position.}
        range [number! series! pair!]
    /only "Changes a series as a series."
    /dup "Duplicates the change a specified number of times."
        count [number! pair!]
] [
    if string? series [range: length? value: head insert copy "" value]
    if not dup [count: 1]
    if none? range [
        range: either all [not only any-block? series any-block? value] [length? value] [1]
    ]
    range: multiply count range
    remove/part series range
    either only [loop count [insert/only series value]]
                [loop count [insert series value]]
]