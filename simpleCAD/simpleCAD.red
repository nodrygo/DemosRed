Red [   
        Title: "simpleCAD"
        Author: "nodrygo  " 
        Purpose: "little speudo CAD demo"
        Rights: ""
        License: {
        Distributed under the Boost Software License, Version 1.0.
        See https://github.com/red/red/blob/master/BSL-License.txt
    }
        needs: 'view
]

comment {
    the goal: both try to increase my Red dev skill and see RED capacities       
    ENTITIES list of elements to draw     ID is elem pos in list 
    deleted elem should become 'none to keep the order
    tree DRAW area     
       * 1 show entities in the back 
       * 2 show the grid
       * 3 show in front selection area with drag/drop 
    tree TOOLBAR
       * 1 entities selection (LINE ARC .....)
       * 2 selector mode (none=entittie creation point rectangle-exclusive rectangle-full-inclusivle)
       * 3 actions on selection MOVE DELETE 
    GRID show/hide/set grid 
    PEN set back/front color size ...
    LAYER ?? not presently
    SNAP ??  not presently 
}

; #include %commonlib.red
either file? %commonlib.red [do %commonlib.red ]
                            [do % https://raw.githubusercontent.com/nodrygo/DemosRed/master/simpleCAD/commonlib.red]



transwhite: 255.255.255.255  ; white transparent for drag area 

current: context [
    winx: 980
    winy: 568
    bgcolor: white  ; current bgcolor
    fgcolor: black  ; current fgcolor
    bgtransparent?: true
    entitiesdraw: []; current draw content for entities
    selectdraw: []  ; current draw content for drag/drop selection 
    seltype: 'none ; current type of selector
    sel: [ ]        ; current selection list of entities ID
    tool: 'line     ; current entitie
    closed?: false   ; closed entitie
    linesize: 1  
    endline: ['flat]
    joinline: ['miter]
    gridsize:  50   ; grid value
    grid?: false     ; grid show on/off
    snap: 'none
    setbg: function [][either bgtransparent? [transwhite] [bgcolor] ]
    lastkey: 'none
]


entities: context [
    drlist: copy [] 
    drgrid: copy []  

    redrawgrid: function [][setgrid current/grid?]
    setgrid:    function [mode] [ either mode [ buildgrid ][clear self/drgrid ]]

    ;; modified as suggested by  RenaudG for speed
    buildgrid:  does [
        system/view/auto-sync?: off
        nbx: current/winx / current/gridsize
        nby: current/winy / current/gridsize
        clear self/drgrid
        while [nbx >= 0] [
            n: nby 
            while [n >= 0] [   
                coord: as-pair  nbx * current/gridsize   n * current/gridsize
                append self/drgrid compose [circle (coord) 1 ]
                n: n - 1
            ]
            nbx: nbx - 1
        ]
        system/view/auto-sync?: on
        self/drgrid
        show basegrid
    ]
    add:     function [e] [append drlist e]
    remove:  function [id] [drlist/:id: 'none]
    replace: function [id e] [drlist/:id: e]
]

entcolor:  [pen (current/fgcolor)  Fill-pen (current/setbg) Line-width (current/linesize) line-cap (reduce current/endline) line-join ( reduce current/joinline)]
entline:      [line 0x0 0x0] 
entcircle:    [circle 0x0 1]
entbox:       [box 0x0 0x0]
entarc:       [arc 0x0 0x0 0 90]
entellipse:   [ellipse 0x0 1x1]
entspline:    [spline 0x0 1x1 ]


dragent: context [
    elist: []
    tmplist: []
    start: 0x0
    nbpte:  2        ; nombre points/entités 2 ou 3
    nbclick: 0       ; nbclick for entitie
    snap:   'none    ; none grid endpt midle center 
    running: false

    dragstart: func [pos] [ ; print ["ENTER DRAGSTART " ]
                pos: snapto current/snap current/gridsize pos
                current/lastkey: 'none
                nbclick: nbclick + 1 
                dragent/running: true
                if current/seltype = 'none 
                   [if nbclick = 1 [dragent/start: pos clear tmplist prepareent pos] ]
                updateelist
            ]
    dragend:  does [ ; print ["ENTER DRAGEND closed?" current/closed  "  " tmplist/2]  
                if nbclick  >=  nbpte  [dragent/running: false 
                                        nbclick: 0
                                        unless (mold current/lastkey)  =  #"^[" [
                                            if current/closed? [
                                                switch current/tool [
                                                      'poly 'arc [
                                                           append tmplist/2 'closed
                                                                 ]
                                                ]
                                            ]
                                        unless tmplist = [] [append entities/drlist  reduce[ copy tmplist]]
                                        ]
                                        clear elist clear tmplist ]
                current/lastkey: 'none
            ]
    dragmove: func [pos /local newval] [ ; print ["DRAGMOVE" current/seltype "  POS" pos] 
                ;print [ "DRAGMOVE CURRENT KEY " mold current/lastkey]
                pos: snapto current/snap current/gridsize pos
                if current/lastkey =  #"^[" [ dragent/running: false
                                              current/lastkey: "" 
                                              nbclick: 0
                                              clear tmplist clear elist
                                            ]
                if current/lastkey =  #"^M"[  if all [ 
                                                       current/tool = 'spline
                                                       dragent/running: true
                                                       nbclick > 0
                                                       (length? tmplist/2) > 3
                                                     ]
                                                     [remove back tail tmplist/2
                                                      dragent/running: false
                                                      nbclick: 999999
                                                      clear elist
                                                      current/lastkey: 'none
                                                      dragend
                                                    ]
                                            ]
                either dragent/running  [
                    switch current/tool [
                        'line      [setentpt nbclick + 1 pos]
                        'circle    [setentpt nbclick + 1 distance dragent/start pos ] 
                        'box       [setentpt nbclick + 1 pos]
                        'arc       [newval:  switch/default nbclick + 1 [
                                              2  [ absolute (dragent/start - pos)]
                                              3  [ angle360 tmplist/2/2 pos]
                                              4  [ angle360 tmplist/2/2  pos]
                                             ][pos]
                                    setentpt nbclick + 1 newval
                                    ]
                        'ellipse        [setentpt nbclick + 1 (absolute (dragent/start - pos)) ]
                        'spline         [setentpt nbclick + 1 pos]
                      ]
                    updateelist
                   ] [ if nbclick = 0 [clear elist append elist compose [pen black fill-pen red circle (pos) 4 ]]
                       ]
            ]
    prepareent: func [pos][ ; print "prepare entitie"
                ecolor:  compose entcolor  
                switch current/tool [
                  'line   [setmsg 1 nbpte: 2  append tmplist compose/deep [[(ecolor)][(entline)]]]
                  'circle [setmsg 3 nbpte: 2  append tmplist compose/deep [[(ecolor)][(entcircle)]]] 
                  'box    [setmsg 1 nbpte: 2  append tmplist compose/deep [[(ecolor)][(entbox)]]] 
                  'arc    [setmsg 3 nbpte: 4  append tmplist compose/deep [[(ecolor)][(entarc)]]]
                  'ellipse[setmsg 3 nbpte: 2  append tmplist compose/deep [[(ecolor)][(entellipse)]]]
                  'spline   [setmsg 4 nbpte: 20 append tmplist compose/deep [[(ecolor)][(entspline)]]]
                  ]
                setentpt nbclick pos
                updateelist
            ]
    setentpt: func [n pos][ ;print ["addentpt " n]
                n: n + 1 
                switch/default current/tool [
                        'spline      [either n > (length? tmplist/2)[append tmplist/2 pos][tmplist/2/:n: pos]]
                        ][tmplist/2/:n: pos]
              ]
    updateelist: func[][
               clear elist
               unless tmplist = [] [append elist tmplist]
              ]
]

setmsg: func [x] [
       switch x [
             1 [instructions/text:  "click to select next point(escape to quit)"]
             2 [instructions/text:  "click to select center (escape to quit)"]
             3 [instructions/text:  "click to select radius (escape to quit)"]
             4 [instructions/text:  "click to select next point(escape to quit/ enter to finish)"]
       ]
]

tools-bar: [
    group-box "TOOLS"  [ 
    return
    radio "line"    50x15 data true  [setmsg 1  current/tool: 'line] return
    radio "box"     50x15   [setmsg 1  current/tool: 'box] return
    radio "circle"  50x15   [setmsg 2 current/tool: 'circle] return
    radio "arc"     50x15   [setmsg 2 current/tool: 'arc] return
    radio "ellipse" 50x15   [setmsg 2 current/tool: 'ellipse] return 
    radio "spline"  50x15   [setmsg 2 current/tool: 'spline] return
    check "closed"  50x15   [current/closed: face/data] 
    ]
]

snap-bar: [
    group-box "SNAP to closest"  [ 
    return
    radio "none"   80x15  data true   [current/snap: 'none] 
    radio "grid "  80x15    [current/snap: 'grid ] return
    radio "line end" 80x15  [current/snap: 'endline] 
    radio "line midpoint"       [current/snap:  'linemidpoint] return 
    radio "center of"  80x15 [ current/snap:  'centerof]
    radio "closest"       [current/snap: 'closest]  return
    ]
]


sel-bar: [
    group-box "SELECT"  [ 
    return
    radio "none"        50x15 data true [current/tool: 'point] return
    radio "all"         50x15 [current/tool: 'point] return
    radio "point"       50x15 [current/tool: 'point] return
    radio "insideRect"  50x15 [current/tool: 'inside] return
    radio "overlapRect" 50x15 [current/tool: 'overlap] 
    ]
]

grid-bar: [
    group-box "GRID"  [ 
    return
    check "show grid "[current/grid?: face/data entities/setgrid face/data]
    text "Size: " 20x20  field  "50" on-enter[ current/gridsize: to integer! face/text entities/redrawgrid ]
    ] return 
]


typeendline: #(1 'flat 2 'square 3 'round) 
typejoinline: #(1 'miter 2 'round 3 'bevel) 

linescolortool: [
    group-box "PEN"  [ 
    return
    panel  [
            at 30x30
            bcol: base 40x40  white  on-down [ face/color: current/bgcolor: colorpopup current/bgcolor]
            at 10x10 
            fcol: base 40x40  black  on-down [ face/color: current/fgcolor: colorpopup current/fgcolor]
            ]
            panel  [
            bgt: check "bg transparent" data: true [current/bgtransparent?: face/data] return 
    text "Size: " 20x20  field  "1" on-change[ current/linesize: to integer! face/text] 
                   ]return
    panel [ across
            elt: drop-down 100 data [ "flat"  "square"  "round"]
            on-change [current/endline: select typeendline face/selected]
            do [elt/selected: 1]
            jlt: drop-down 100 data [ "miter"  "round"  "bevel"]
            on-change [ current/joinline:  select typejoinline face/selected ]
            do [jlt/selected: 1] 
       ]
    ]
]

mainmenu: [
            "File" [
                "Load file"     fopen
                "Save file"     fsave
                "-------"
                "Clear Last entitie"   clearlast
                "Clear Draw List"   cleardraw
                "-------"
                "Exit"        exit
                   ]
            "Help" [ "About"  about]
]

mainlayer: compose/deep [ 
    panel [
       text  "current file:" 120 bold font-size 12 font-color blue
       curfilename: field "redbyke.red" 80 
       return 
       (linescolortool)
       return 
       below 
       panel [ 
                across 
                (tools-bar)
                (sel-bar)
             ]
       panel [  (snap-bar) return
                (grid-bar)
             ]
       ]
    drpanel: panel  [
         at 0x0  instructions: text "for tools each click select a point" 450 bold font-size 10 font-color black

         at 0x20  basebg: base   300x480      white  all-over draw entities/drlist 
         at 0x20  basegrid: base 300x480 transwhite  all-over draw entities/drgrid
         at 0x20  basefg: base   300x480 transwhite  all-over draw dragent/elist on-key [ current/lastkey: event/key 'done ]
     ]                        
]

mainwin:     layout mainlayer
mainwin/menu: mainmenu

drpanel/flags: ['all-over]
drpanel/actors:  context [  
                on-down: func [face [object!] event [event!]][ ;print "on-down"
                                                             dragent/dragstart event/offset 
                                                            'done ]
                on-up:       func [face [object!] event [event!]][ 
                                                             dragent/dragend  
                                                            'done ]
                on-over:     func [face [object!] event [event!]][ ;print "on-over"
                                                             dragent/dragmove event/offset 
                                                              'done ]
                ]

setdrawpanel: func [][
     x: mainwin/size/x -  310
     y: mainwin/size/y -  30 
     current/winx: x
     current/winy: y
     drpanel/size/x: x
     drpanel/size/y: y
     basegrid/size/x: x
     basegrid/size/y: y
     entities/redrawgrid
     basebg/size/x: x
     basebg/size/y: y
     basefg/size/x: x
     basefg/size/y: y
]

mainwin/actors: context [
                on-menu: func [face [object!] event [event!]][
                        switch event/picked [
                           'fopen  [append entities/drlist copy load to file! curfilename/text] 
                           'fsave  [save to file! curfilename/text entities/drlist alertPOPUP copy append "DESSIN.RED SAVED " curfilename]
                           'clearlast  [remove back tail entities/drlist]
                           'cleardraw  [clear entities/drlist]
                           'about [alertPOPUP "RED SIMPLE DEMO CAD "]
                           'exit [quit]
                         ]
                ]
                on-resize: func  [face [object!] evt [event!]] [ either mainwin/size < 1024x700 
                                                                        [mainwin/size: 1024x700
                                                                         setdrawpanel   'done] 
                                                                        [setdrawpanel 'done]
                                                                ]
                on-close:  func  [face [object!] evt [event!]] [ print "win closed"]
                on-key-down: func [face [object!] event [event!]][current/lastkey: event/key
                                                                   ;print ["EVENT IN " event/window] ; useless
                                                                  'done ]

           ]


view/no-wait/flags mainwin [resize]
mainwin/size: 1024x700
setdrawpanel