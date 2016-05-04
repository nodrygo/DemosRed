Red [
        Title: "ballbounce"
        Needs: 'view
]

system/view/auto-sync?: no

;; could do that with face /offset but probably not the good anwser for lot of draw entities 
;; may be I am wrong but I can't imagine Rebol demo PARTICULES with thousand of faces    
;; random/seed now ;;;;now do not exist yet
move: 2x2
running: flase

moveball: does [
while [running] [
   lastpos: ball/2/2
   nextpos: lastpos + move 
   if nextpos/x >= 400  [move: as-pair negate random 3 (move/y)]
   if nextpos/x <= 0    [move: as-pair  random 3 (move/y)]
   if nextpos/y >= 300  [move: as-pair (move/x) negate random 3]
   if nextpos/y <= 0    [move: as-pair (move/x) random 3]
   ball/2/2: nextpos
   loop 2 [do-events/no-wait wait 0.01] 
   show b
   ]
]

ball: [[pen black fill-pen red] [circle 20x20 10]]
view/no-wait [
    title "bouncing ball"
    button "start" [running: true moveball ] return 
    button "stop" [running: false  ]
    b: base 400x300 white  draw ball 
]

 