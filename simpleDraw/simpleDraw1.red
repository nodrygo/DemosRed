Red [
    title:   "simpleDraw1"
    authors: "nodrygo/renaudG" 
    goal:    "draw with list of points"
    needs:   'view
]

entities: object [
"Holds (and allow operations on) the drawing as a list of dots"
    size: 5
    elist:   [pen red fill-pen red]
    add:     function [ pos ] [ append elist compose [circle (pos) (size)]]
    setsize: func [ x ] [ form size: max 1 to integer! 100 * x ]
    reset:   does [ clear at elist 5 ]
]

view [
    title "VID demo : Simple Draw"
    sld: slider 5% [t/text: entities/setsize face/data]
    t: text "5" 
    return
    b: base 800x600 black draw entities/elist
            all-over on-over [ if event/down? [ entities/add event/offset 'done] ]
    return
    button "CLEAR" 100 [ entities/reset ]
    button "SAVE IMG" 100 [ save %dessin.png to-image b ]
    button "SAVE RED" 100 [ save %dessin.red entities/elist ]
    button "LOAD RED" 100 [ attempt [entities/elist: b/draw: load %dessin.red ] ]
]
