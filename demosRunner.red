Red []
;-- as suggested and written by renaudG
samples: load %https://raw.githubusercontent.com/nodrygo/DemosRed/master/demopath.red 

forever [
    foreach [n title url] samples [ print ["- " n ": " title] ]
    unless attempt [
        r: to integer! ask "> Que voulez-vous tester ? "
        set [a b c] find samples r
        do read c
    ] [ break ]
]