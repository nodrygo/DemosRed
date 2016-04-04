Red []
;-- as suggested and written by renaudG
samples: [
    1  "Simple drawing with circles"  https://raw.githubusercontent.com/nodrygo/DemosRed/master/simpleDraw/simpleDraw1.red
    2  "Simple line drawing"          https://raw.githubusercontent.com/nodrygo/DemosRed/master/simpleDraw/simpleDraw2.red
]

forever [
    foreach [n title url] samples [ print ["- " n ": " title] ]
    unless attempt [
        r: to integer! ask "> Que voulez-vous tester ? "
        set [a b c] find samples r
        do read c
    ] [ break ]
]