Red [title: "simpleDraw3"
     authors: "renaudG/nodrygo  " 
     goal: "draw with lines connected and color selector"
     needs: 'view]

to-color: function [r g b][
    color: 0.0.0
    if r [color/1: r]
    if g [color/2: g]
    if b [color/3: b]
    color
]

entities: object [
    size: 1
    number: 0
    pencolor: red 
    cr: 255
    cg: 0
    cb: 0
    penstatus: 'up
    startpos: 1x1
    elist: [ ]
    startline:  [line-width (size) pen (pencolor) fill-pen (pencolor) line (startpos) (startpos)]

    setr:  func [ x  ] [cr: to integer! 256 * x  pencolor: to-color cr cg cb]
    setg:  func [ x  ] [cg: to integer! 256 * x  pencolor: to-color cr cg cb]
    setb:  func [ x  ] [cb: to integer! 256 * x  pencolor: to-color cr cg cb]

    addline:    func [ pos ] [ either penstatus = 'up  [ compose startline] 
                                                       [ compose [(pos)] ]
                                 ]
    add:        func [ pos ] [     append elist   addline pos
                                   self/penstatus: 'down
                             ]
    newline:    func [ x ] [ self/penstatus: 'up  
                          self/startpos: x ]                                  
    setsize:    func [ x ] [ form size: max 1 to integer! 100 * x ]
    reset:      does [ head clear at elist 5  self/number: 0 ]
]

view [
    sld: slider 1% [t/text: entities/setsize face/data]
    t: text "1"   
    cl: base 100x20 red 

    group-box "color select"  [
      across
      text "R:"  SR: slider 100% [entities/setr SR/data  cl/color: entities/pencolor] return
      text "G:"  SG: slider      [entities/setg SG/data  cl/color: entities/pencolor] return
      text "B:"  SB: slider      [entities/setb SB/data  cl/color: entities/pencolor]
    ]return 

    b: base 800x600 black draw entities/elist
         all-over on-over [ either  event/down? [ entities/add event/offset 'done] 
                                                [ entities/newline event/offset 'done] ]
    return
    button "CLEAR"    100 [ entities/reset ]
    button "SAVE IMG" 100 [ save %dessin.png to-image b]
    button "SAVE RED" 100 [ save %dessin.red entities/elist]
    button "LOAD RED" 100 [ attempt [entities/elist: b/draw: load %dessin.red] ]
]


