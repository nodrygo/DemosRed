Red [
        Title: "ballbounce"
        Needs: 'view
]

;; demo changing coord of circle instead of moving a face (see ballboundFace.red)
move: 2x2
running: false
changemode: func [mode][
        either mode [
             running: true
             system/view/auto-sync?: no
             ][
             running: false
             system/view/auto-sync?: yes
             ]
]
moveball: does [
    while [running] [
       lastpos: ball/2/2
       nextpos: lastpos + move 
       if nextpos/x >= 400  [move: as-pair negate random 3 (move/y)]
       if nextpos/x <= 0    [move: as-pair  random 3 (move/y)]
       if nextpos/y >= 300  [move: as-pair (move/x) negate random 3]
       if nextpos/y <= 0    [move: as-pair (move/x) random 3]
       ball/2/2: nextpos
       show b
       do-events/no-wait 
       wait 0.001 
       ]
]
ball: [[pen black fill-pen red] [circle 20x20 10]]
mainwin: layout [
    title "bouncing ball"
    button "start" [changemode true moveball ] return 
    button "stop"  [changemode false ]
    at 80x20   b: base 400x300 white  draw ball
]
; try to avoid pause when moving mouse but without succes :-(
; this behaviour doesn't exist with ball face moving demo
 mainwin/actors: context [
                on-close:  func  [face [object!] evt [event!]] [running: false 
                                                                system/view/auto-sync?: yes]
                on-over:   func  [face [object!] evt [event!]] [show b 'done]
         ]
view/no-wait/flags mainwin [modal]