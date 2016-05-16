Red [
        Title: "ballbounce with Faces"
        Needs: 'view
]


alert: function [
    "Displays an alert message"
    msg [string!]  "Message to display"
][
    view [
        t: text msg center return
        b: button "ok" [ unview]
        do [b/offset/x: t/offset/x + (t/size/x - b/size/x / 2)]
    ][modal popup]
]

;; random/seed now ;;;;now do not exist yet
transwhite: 255.255.255.255  ; white transparent for drag area 

move: 2x-2
running: false
changerunningmode: func [mode][
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
   if ball/offset/x >= 400  [move: as-pair negate random 3 (move/y)]
   if ball/offset/x <= 0    [move: as-pair  random 3 (move/y)]
   if ball/offset/y >= 300  [changerunningmode false alert"YOU LOSE" ]
   if ball/offset/y <= 0    [inverty]
   ball/offset: ball/offset + move 
   loop 2 [do-events/no-wait wait 0.01] 
   checkpaddle 
   show gamearea
   ]
]

 
i2f: func [x return:  [float!]] [to float! x]
dotv: function [a [pair!] b [pair!]  return:  [float!]][
      (i2f a/x * i2f b/x) + ( i2f a/y * i2f b/y)
]
norm:  function [a [pair!] return:  [integer!]][
      to integer! square-root dotv a a 
]
distance:  function [a [pair!] b [pair!] return:  [integer!]][
      norm (a - b)
]
line-midpoint: function [p1 [pair!] p2 [pair!]  return:  [pair!]][
        mx: (p1/x + p2/x) / 2
        my: (p1/y + p2/y) / 2  
        as-pair mx my 
]
closest-point2line: function [pos [pair!] a [pair!] b [pair!]  ][
        "find the closest point from pos point to a/b line return distance "
        c1: (i2f pos/x - i2f  a/x) * (i2f  b/x - i2f  a/x)  
        c2: (i2f pos/y - i2f  a/y) * (i2f  b/y - i2f  a/y) 
        l: distance a b
        r: c1 + c2 / i2f  power l 2
        nx: a/x + (r * ( b/x -  a/x))
        ny: a/y + (r * ( b/y -  a/y))
        np: as-pair nx ny 
        d: distance pos np 
        either all [ r <= 1.0 r >= 0 ][reduce [d np d r] ] [reduce [999999 pos d r]]
]
deltaclosest: 10
closetobox?:  function [pos [pair!] p1 [pair!]  p3 [pair!] ][
     " return 1/check status 2/endpoint 3/midpoint 4/closest point for box "
     p2: as-pair p3/x p1/y
     p4: as-pair p1/x p3/y
     ret: reduce [false 9999]
     ; case close to corner 
     if any [(distance p1 pos) <= deltaclosest 
             (distance p2 pos) <= deltaclosest 
             (distance p3 pos) <= deltaclosest
             (distance p4 pos) <= deltaclosest 
            ][ return reduce [true 0 0]]
    ; case close to a box line  
     res:  closest-point2line pos p1 p2  
     if (res/1 <= deltaclosest) [ return reduce [true res/1 res/3]]
     res:  closest-point2line pos p2 p3 
     if (res/1 <= deltaclosest) [ return reduce [true res/1 res/3]]
     res:  closest-point2line pos p4 p3 
     if (res/1 <= deltaclosest) [ return reduce [true res/1 res/3]]
     res:  closest-point2line pos p1 p4 
     if (res/1 <= deltaclosest) [ return reduce [true res/1 res/3]]
     return ret 
]
checkinbound?: function[f][
      ballcenter: ball/offset + 20x20
      res: closetobox? ballcenter f/offset (f/offset + f/size)
      res/1
]
checkpaddle: does [
     ballcenter: ball/offset + 20x20
     paddlelower: paddle/offset + paddle/size
     if all [ (checkinbound?  paddle)
              ballcenter/y < paddlelower/y
              move/y > 0
              ] 
        [inverty]
]

inverty: does [move: as-pair (move/x) (negate move/y)]

remainbricks: 15
makebrick:  [  base  40x20 brick
            react [
               [ball/offset]
               if all [face/visible? (checkinbound? face)][
                   inverty
                   remainbricks:  remainbricks - 1
                   face/visible?: false 
                   if remainbricks <= 0 [ changerunningmode false  alert "CONGRAT YOU WIN"]
                ]
            ]
]

bricks: copy [] 
repeat x 5  [ append bricks reduce['at (as-pair x * 60 20)]  append bricks copy/deep makebrick ] 
repeat x 5  [ append bricks reduce['at (as-pair x * 60 60)]  append bricks copy/deep makebrick ] 
repeat x 5  [ append bricks reduce['at (as-pair x * 60 100)]  append bricks copy/deep makebrick ] 
;probe bricks 

refreshbrick: does [ball/offset: 200x280 move: as-pair (random 3) (negate random 3) foreach e gamearea/pane [e/visible?: true]]

ball: [[ pen black fill-pen red] [circle 20x20 10]]
wall: compose/deep [
    title "face  ball"
    button "start" [changerunningmode true moveball ] return 
    button "stop"  [changerunningmode false ]  return 
    button "refresh"  [changerunningmode false refreshbrick]
    gamearea: panel 420x320  white [
           ( append [at 200x280  ball: base 40x40 transwhite loose draw ball] (bricks)) 
             at 210x300 paddle: base   black 
    ] all-over on-over [ paddle/offset/x: event/offset/x  'done ]
]
;probe wall

mainwin:  layout wall
mainwin/actors: context [
                on-close:  func  [face [object!] evt [event!]] [running: false 
                                                                system/view/auto-sync?: yes]
         ]
view/no-wait  mainwin 
