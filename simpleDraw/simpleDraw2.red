Red [title: "simpleDraw2"
     authors: "renaudG/nodrygo  " 
     goal: "draw with lines connected"
     needs: 'view]

entities: object [
    size: 1
    number: 0
    fgcolor: red 
    penstatus: 'up
    startpos: 1x1
    elist: [ ]
    startline:  [line-width (size) pen (fgcolor) fill-pen (fgcolor) line (startpos) (startpos)]
    addline:    func [ pos ] [ either penstatus = 'up  [ compose startline] 
                                                       [ compose [(pos)] ]
                                 ]
    add:        func [ pos ] [     append elist   addline pos
                                   self/penstatus: 'down
                                   number: form  length? elist ]
    newline: func [ x ] [ self/penstatus: 'up  
                          self/startpos: x ]                                  
    setsize:    func [ x ] [ form size: max 1 to integer! 100 * x ]
    reset:      does [ head clear at elist 5  self/number: 0 ]
]

el: entities/elist
nbe: entities/number

view [
    sld: slider 1% [t/text: entities/setsize face/data]
    t: text "1" text " Nb entities:" nb: text "0" 
    return
    b: base 800x600 black draw el
         all-over on-over [ either  event/down? [ entities/add event/offset 'done] 
                                                [ entities/newline event/offset 'done] ]
    return
    button "CLEAR" 100 [ entities/reset ]
    button "SAVE IMG" 100 [ save %dessin.png to-image b]
    button "SAVE RED" 100 [ save %dessin.red entities/elist]
    button "LOAD RED" 100 [ attempt [entities/elist: b/draw: load %dessin.red] ]
]


