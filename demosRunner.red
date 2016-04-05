Red []
;-- as suggested and written by renaudG
samples: load https://raw.githubusercontent.com/nodrygo/DemosRed/master/demopath.red 

n: 0
samples: foreach [ttl url] samples [
    append [] reduce [n: n + 1 ttl url]    
]
forever [
    foreach [n title url] samples [ print ["- " n ": " title] ]
    unless attempt [
        r: to integer! ask "> Que voulez-vous tester ? "
        set [a b c] find samples r
        do read c
    ] [ break ]
]