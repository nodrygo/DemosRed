Red [
        Title: "demo Gui runner"
        Authors: "renaudG" 
        Goal: "provide a GUI runner for demos"
        File:   %simpleDraw4.red
        Tabs:   4
        Rights: ""
        License: {
        Distributed under the Boost Software License, Version 1.0.
        See https://github.com/red/red/blob/master/BSL-License.txt
    }
        needs: 'view
]

samples: load https://raw.githubusercontent.com/nodrygo/DemosRed/master/demopath.red

choose: func [n] [
    x: samples/(2 * n)
    source: read x
    size: 0x15 * (length? split source "^/") + 500x00
    reduce [source size]
]

menu: []
foreach [title url] samples [ append menu title ]

view [
    drop-down 400 data menu on-change [
        psize: face/parent/size - ed/size
        r: choose face/selected
        ed/text: r/1
        ed/size: r/2
        b/enable?: true
        face/parent/size: psize + r/2
    ]
    b: button 80 "RUN" disabled [attempt [do ed/text]]
    return
    ed: text 500x100 255.255.255 "Choose your sample above, then run it if you wish."
]