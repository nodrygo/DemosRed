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
    the goal is to test both increase my Red dev skill and see RED capacities    
    need multiple file ??    
    ENTITIES list of elements to draw     ID is elem pos in list 
    deleted elem should become 'none to keep the order
    two DRAW area     
       * 1 show entities in the back 
       * 2 show in front selection area with drag/drop 
    tree TOOLBAR
       * 1 entities selection (LINE ARC .....)
       * 2 selector mode (clear unique rectangle-exclusive rectangle-full-inclusivle)
       * 3 actions on selection MOVE DELETE 
    GRID show/hide/set grid 
    COLOR set back/front color
    LAYER ?? not presently
    SNAP ?? not presently 
}

; #include %commonlib.red
either file? %commonlib.red [do %commonlib.red ]
                            [do % https://raw.githubusercontent.com/nodrygo/DemosRed/master/simpleCAD/commonlib.red]
current: context [
    winx: 800
    winy: 600
    bgcolor: white  ; current bgcolor
    fgcolor: black  ; current fgcolor
    entitiesdraw: []; current draw content for entities
    selectdraw: []  ; current draw content for drag/drop selection 
    seltype: 'point ; current type of selector
    sel: [ ]        ; current selection list of entities ID
    tool: 'line     ; current entitie 
    endline: 'flat
    joinline: 'miter
    gridsize:  50   ; grid value
    grid: false     ; grid show on/off
]


entities: context [
    drlist: [ ;[pen red    Line-width 2 ]
              [pen red   Fill-pen off Line-width 2 line 10x10 100x100] 
              [pen green Fill-pen green Line-width 2   circle 110x130 50] 
              [pen blue  Fill-pen blue Line-width 4 line 30x30 200x150]
              [pen blue  Fill-pen off Line-width 4 circle 100x150 20] 
            ] 
    drgrid: []  

    redrawgrid: function [][setgrid current/grid]
    setgrid:    function [mode] [ if mode [ buildgrid ]]
    buildgrid:  function [] [
              nbx: current/winx / current/gridsize
              nby: current/winy / current/gridsize
              clear self/drgrid
              while [nbx >= 0] [ n: nby 
                                 while [n >=  0] [   
                                        coord: make pair! compose[(nbx * current/gridsize) (n * current/gridsize) ]
                                        append self/drgrid compose [circle (coord) 1 ]
                                        n: n - 1
                                       ]
                              nbx: nbx - 1
                              ]
                self/drgrid
               ]
    add:     function [e] [append drlist e]
    remove:  function [id] [drlist/:id: 'none]
    replace: function [id e] [drlist/:id: e]
    ;moveto:   function [ pt [point!] e] [
    ;] 
    ;drawhandle: [] function [] [
    ;          [foreach e in drlist draw square at end] 
    ;]
]

dragent: context [
   elist: [line-width 2 pen black circle 50x50 20]
   start: 0x0
   end: 0x0
   running: false
]

tools-bar: [
    group-box "TOOLS"  [ 
    return
    radio "line"  data true  [current/tool: 'line] return
    radio "arc"     [current/tool: 'line] return
    radio "circle"  [current/tool: 'line] return
    radio "rect"    [current/tool: 'line] 
    ]
]

sel-bar: [
    group-box "SELECT"  [ 
    return
    radio "none"  data true       [current/tool: 'point] return
    radio "all"         [current/tool: 'point] return
    radio "point"         [current/tool: 'point] return
    radio "insideRect"    [current/tool: 'inside] return
    radio "overlapRect"   [current/tool: 'overlap] 
    ]
]

grid-bar: [
    group-box "GRID"  [ 
    return
    check "show grid "[current/grid: face/data entities/setgrid face/data] return
    text "Size: " 30x20  field  "50" on-enter[ current/gridsize: to integer! face/text entities/redrawgrid ]
    ] return 
]

snap-bar: [
    group-box "SNAP"  [ 
    return
    radio "endpoint"         [current/tool: 'point] return
    radio "midpoint"         [current/tool: 'point] return
    radio "midpoint"         [current/tool: 'point] return
    radio "center"           [current/tool: 'point] return
    radio "midpoint"         [current/tool: 'point] 
    ]
]

typeendline: #(1 'flat 2 'square 3 'round) 
typejoinline: #(1 'miter 2 'round 3 'bevel) 

endlinetool: [
    elt: drop-down 100 data [ "flat"  "square"  "round"]
    on-change [current/endline: select typeendline face/selected ]
    do [elt/selected: 1]
]

joinlinetool: [
    jlt: drop-down 100 data [ "miter"  "round"  "bevel"]
    on-change [ current/joinline:  select typejoinline face/selected ]
    do [jlt/selected: 1]
]

mainmenu: [
            "File" [
                "OpenRed"     open
                "Savered"     save
                "Exit"        exit
                   ]
            "Help" [ "About"  about]
]

transwhite: 255.255.255.255  ; white transparent for drag area 

mainlayer: compose/deep[ 
       panel [
          text  "current file:" 120 bold font-size 12 font-color blue    
          curfilename: field "demos.cad" 80 return 
          below 
          panel [
                  at 30x30
                  fcol: base 40x40  black  on-down [ face/color: current/fgcolor: colorpopup current/fgcolor]
                  at 10x10 
                  bcol: base 40x40  white  on-down [ face/color: current/bgcolor: colorpopup current/bgcolor]

                  ]
          panel [ across 
                 (tools-bar)
                 (sel-bar)]
          panel [ 
                 (grid-bar)
                ]
          panel [ across
                 (endlinetool)
                 (joinlinetool) 
                ]                
          ]
       drpanel: panel  [
            at 10x10  basegrid: base 500x500 white       all-over draw entities/drgrid
            at 10x10  basebg: base 500x500 transwhite       all-over draw entities/drlist 
            at 10x10  basefg: base 500x500 transwhite  all-over draw dragent/elist 
        ]                        
]

mainwin:     layout mainlayer
mainwin/menu: mainmenu

drpanel/flags: ['all-over]
drpanel/actors:  context [  
                on-down: func [face [object!] event [event!]][
                         print "down" 
                         dragent/running: true  
                         dragent/start: event/offset 
                         basefg/draw/6: event/offset 
                         'done ]
                on-up:   func [face [object!] event [event!]][ 
                        print ["up"]  
                        dragent/running: false 
                        'done
                ]
                on-over:  func [face [object!] event [event!]][ 
                        if dragent/running  [
                                             basefg/draw/7: to integer! distance dragent/start event/offset 
                                             'done ]
                        ]
                ]

setdrawpanel: func [][
     x: mainwin/size/x -  280
     y: mainwin/size/y -  20 
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
                         if event/picked = 'open  [alertPOPUP "open dessins list"]
                         if event/picked = 'save  [save %dessin.red entities/drlist alertPOPUP "DESSIN.RED SAVED"]
                         if event/picked = 'about [alertPOPUP "RED SIMPLE DEMO CAD "]
                ]
                on-resize: func  [face [object!] evt [event!]] [ either mainwin/size < 790x540 
                                                                        [mainwin/size: 790x540
                                                                         setdrawpanel   'done] 
                                                                        [setdrawpanel 'done]
                                                                ]
                on-close:  func  [face [object!] evt [event!]] [ print "win closed"]
           ]


view/no-wait/flags mainwin [resize]
mainwin/size: 790x540
setdrawpanel