Red [ ]

;;; max distance between 2 points for selection
deltaclosest: 8

comment {
    ;rewrite it more generic 
distance: function [p1 [pair!] p2 [pair!] /return [integer!]][
   x:  p2/x - p1/x 
   y:  p2/y - p1/y 
   to integer! square-root ((x * x) + (y * y)) 
]

distance 0x0 0x10 
distance 0x0 10x0 
distance 10x10 20x20
distance 20x20 10x10
}

angle: function [pc [pair!] pr [pair!] /return [integer!]][
   alpha:   to integer! (arctangent2 pr/y - pc/y  pr/x - pc/x) * (180 / pi)
]
angle360: function [pc [pair!] pr [pair!] /return [integer!]][
   ; consider inverted axis 
   alpha:   angle pc pr 
   alpha: either alpha < 0.0 [ 360 + alpha ] [ alpha ] 
   ;;;print ["pc" pc "  pr" pr "  dx" pr/x - pc/x "  dy" pr/y - pc/y "  alpha" alpha ]
   absolute alpha 
]
;angle 100x100 200x100
;angle 100x100 100x0
;angle 100x100 100x100
;angle 100x100 100x200
;angle 100x100 -100x100
;angle 100x100 100x-100 

snapto:  function [snapmode gridsize pos [pair!]  /return [pair!] ] [
         e?: either (length? entities/drlist) > 0 [true][false]
         switch/default snapmode [
                                'none         [pos]
                                'grid         [(pos + (gridsize / 2 ) / gridsize) * gridsize] 
                                'endline      [either e? [match-closeendline pos][pos]]
                                'linemidpoint [either e? [match-linemidpoint pos][pos]]
                                'centerof     [either e? [match-centerof pos][pos]]
                                'closest      [either e? [match-closestpoint pos][pos]]
         ][pos]
]

i2f: func [x /return [floas=t!]] [to float! x]

dotv: function [a [pair!] b [pair!]  /return [float!]][
      (i2f a/x * i2f b/x) + ( i2f a/y * i2f b/y)
]
norm:  function [a [pair!] /return [integer!]][
      to integer! square-root dotv a a 
]
distance:  function [a [pair!] b [pair!] /return [integer!]][
      norm (a - b)
]
comment {
distance 0x0 0x10 
distance 0x0 10x0 
distance 10x10 20x20
distance 20x20 10x10
distance -20x10 -30x10
distance  0x100 0x-50
}

inbound?: function [pos [pair!] a [pair!] b [pair!]  /return [logic!]][
  either a/x > b/x [minx: b/x  - deltaclosest  
                    maxx: a/x  + deltaclosest ]
                   [minx: a/x  - deltaclosest 
                    maxx: b/x  + deltaclosest ] 
  either a/y > b/y [miny: b/y  - deltaclosest
                    maxy: a/y  + deltaclosest ]
                   [miny: a/y  - deltaclosest 
                    maxy: b/y  + deltaclosest ] 
  ;print ["pos"  pos  "   a" a "   b" b "  minx" minx " maxx " maxx "  miny  " miny "   maxy" maxy]
  all [ pos/x < maxx 
        pos/x >= minx
        pos/y < maxy
        pos/y >= miny
      ]
]
;;;; add limit to bound of rect entite
closest-point-line: function [pos [pair!] a [pair!] b [pair!]  /return [[integer!] [pair!] [integer!]]][
   ;from http://www.faqs.org/faqs/graphics/algorithms-faq/
        c1: (i2f pos/x - i2f  a/x) * (i2f  b/x - i2f  a/x)  
        c2: (i2f pos/y - i2f  a/y) * (i2f  b/y - i2f  a/y) 
        l: distance a b
        r: c1 + c2 / i2f  power l 2
        nx: a/x + (r * ( b/x -  a/x))
        ny: a/y + (r * ( b/y -  a/y))
        np: as-pair nx ny 
        d: distance pos np 
       ; print ["d:" d "  r:" r  " nx:" nx " ny:" ny  " pos:"  pos "   a:" a "  b:" b]
        either all [ r <= 1.0 r >= 0 ] [reduce [d np r ] ] [reduce [999999 pos 0 ]]
]

comment {
a: 0x0  b: 0x30   pos: 0x20
closest-point-line 0x20 0x0  0x30 
closest-point-line 9x1 0x0 30x0
closest-point-line 10x5 0x0 30x0
closest-point-line 20x20 0x0 40x40
closest-point-line 10x40 0x0 40x40
closest-point-line 100x400 0x0 40x40
}

point-closeto-line?: function [pos [pair!] p2 [pair!] p3 [pair!]  /return [logic!]][
    cpl:  closest-point-line pos p2 p3
    cpl/1 <= deltaclosest
]

line-midpoint: function [p1 [pair!] p2 [pair!]  /return [pair!]][
        mx: (p1/x + p2/x) / 2
        my: (p1/y + p2/y) / 2  
        as-pair mx my 
]

box-midpoint: function [pos [pair!] p1 [pair!] p2 [pair!]  /return [pair!]][
        res: closetobox? pos p1 p2 
        if res/3 [ line-midpoint p1 p2 ]
        pos
]
closetoradius?: function [pos [pair!] pc [pair!] r [integer!] /return [logic!]][
    ; p1= point p2=centre  r=rayon 
    all [(distance pos pc) + deltaclosest >= r  (distance pos pc) - deltaclosest <= r ]
]

closetocircle?: function [pos [pair!] pc [pair!] r [integer!] /return [[logic!] [pair!]]][
    ; p1= point p2=centre  r=rayon  return 1/boolean 2/pos on circle 
    either (closetoradius?  pos pc r ) [ a: angle360 pc pos 
                                         nx: ((cosine a) * r) + pc/x 
                                         ny: ((sine a) * r) + pc/y
                                         npt: as-pair nx ny
                                         reduce [true npt]
                                       ]
                                       [ reduce [false pos]] 

]
closetoellipse?: function [pos [pair!] pu [pair!] pr [pair!] /return [[logic!] [pair!]]][
    ; pos= point pb=upperbox  pr=rayon x&y   return 1/boolean 2/pos on circle 
    pc:  pu + (pr / 2)
    alpha:  angle360 pc pos 
    r1: pr/x / 2 
    r2: pr/y / 2 
    switch/default alpha [ 
                      0     [ nx: (pc/x + r1)  ny: pc/y  ]
                      90    [ nx: pc/x         ny: ( pc/y + r2 )]
                      180  [ (nx: pc/x - r1)   ny: pc/y ]
                      270   [ nx: pc/x         ny: ( pc/y - r2 )]
                    ][ tt: (tangent alpha)
                       tt2: tt * tt 
                       denom: square-root ( (r2 * r2) + (r1 * r1 * tt2)) 
                       either ((alpha < 90) or (alpha > 270))
                          [
                               nx:  pc/x + ((r1 * r2) / denom )
                               ny:  pc/y + ((r1 * r2 * tt) / denom )
                          ]
                          [
                               nx:  pc/x - ((r1 * r2) / denom )
                               ny:  pc/y - ((r1 * r2 * tt) / denom )
                          ]
                        
                      ]
    npt: as-pair nx ny 
    ;;print ["  ntp" npt "  pos" pos ]
    either all [ (absolute (npt/x - pos/x))  <= deltaclosest
                 (absolute (npt/y - pos/y))  <= deltaclosest]
               [ reduce [true  npt pc] ]
               [ reduce [false pos pos ] ] 
]
closetoarcradius?: function [pos [pair!] pc [pair!] pr [pair!] alpha [integer!] beta [integer!] /return [logic!]][
    ; pos= point pc=centre  pr= point rayon alpha beta=angle debut fin arc 
    r: distance pc pr 
    a: angle pc pos
    either alpha < beta [a1: alpha a2: beta ][a1: beta a2: alpha] 
    all [(distance pos pc) + deltaclosest >= r  
         (distance pos pc) - deltaclosest <= r 
         a >= alpha a <= beta]
]

closetobox?:  function [pos [pair!] p1 [pair!]  p3 [pair!] return: [[logic!] [pair!] [pair!][pair!]]][
     " return 1/check status 2/endpoint 3/midpoint 4/closest point for box "
     p2: as-pair p3/x p1/y
     p4: as-pair p1/x p3/y
     ret: reduce [false pos pos pos ]
     res:  closest-point-line pos p1 p2  
     if all [res/1 <= deltaclosest res/3 <= 0.5][return reduce [true p1 (line-midpoint p1 p2) res/2]]
     if all [res/1 <= deltaclosest res/3 > 0.5] [return reduce [true p2 (line-midpoint p1 p2) res/2]]
     res:  closest-point-line pos p2 p3 
     if all [res/1 <= deltaclosest res/3 <= 0.5][return reduce [true p2 (line-midpoint p2 p3) res/2]]
     if all [res/1 <= deltaclosest res/3 > 0.5] [return reduce [true p3 (line-midpoint p2 p3) res/2]]
     res:  closest-point-line pos p3 p4 
     if all [res/1 <= deltaclosest res/3 <= 0.5][return reduce [true p3 (line-midpoint p3 p4) res/2]]
     if all [res/1 <= deltaclosest res/3 > 0.5] [return reduce [true p4 (line-midpoint p3 p4) res/2]]
     res:  closest-point-line pos p1 p4 
     if all [res/1 <= deltaclosest res/3 <= 0.5][return reduce [true p1 (line-midpoint p1 p4) res/2]]
     if all [res/1 <= deltaclosest res/3 > 0.5] [return reduce [true p4 (line-midpoint p1 p4) res/2]]
     return ret
]


;;; NAIVE SNAP MODE 
match-closeendline: function [pos /return [pair!]] [
    foreach e entities/drlist [ 
        unless e = [] [
        case [
            e/2/1 = 'line [
                res:  closest-point-line pos e/2/2 e/2/3
                case [
                  all [res/1 <= deltaclosest res/3 <= 0.5] [break/return e/2/2]
                  all [res/1 <= deltaclosest res/3 >  0.5] [break/return e/2/3]
                  true [pos] 
                ]]
            e/2/1 = 'box [
                res:  closetobox? pos e/2/2 e/2/3
                ;print ["ENDLINE RES:" res]
                either res/1 [break/return res/2]
                             [pos] 
                ]
            true [pos]
        ]
    ]]
]

match-linemidpoint: function [pos /return [pair!]] [
    foreach e entities/drlist [ 
        unless e = [] [
        case [
            e/2/1 = 'line [
                case [
                    (point-closeto-line? pos e/2/2  e/2/3 ) [break/return (line-midpoint e/2/2 e/2/3)]
                    true [pos] 
                ]]
            e/2/1 = 'box [
                res:  closetobox? pos e/2/2 e/2/3
                either res/1 [break/return res/3]
                             [pos] 
                ]
            true [pos] 
        ]
    ]]
]

match-closestpoint: function [pos /return [pair!]] [
    foreach e entities/drlist [
        unless e = [] [ 
        case [
            e/2/1 = 'line [
                res:  closest-point-line pos e/2/2 e/2/3
                case [
                  all [res/1 <= deltaclosest res/3 <= 0.5] [break/return res/2]
                  all [res/1 <= deltaclosest res/3 >  0.5] [break/return res/2]
                  true [pos] 
                ]]
            e/2/1 = 'box [
                res:  closetobox? pos e/2/2 e/2/3
                either res/1 [break/return res/4]
                             [pos] 
                ]
            e/2/1 = 'ellipse [ 
                res:  closetoellipse? pos e/2/2 e/2/3
                either res/1 [break/return  res/2]
                             [pos]
                         ]
            e/2/1 = 'circle [
                res:  closetocircle? pos e/2/2 e/2/3
                either res/1 [break/return res/2]
                             [pos] 
                ]
            true [pos] 
        ]
    ]]
]

match-centerof: function [pos /return [pair!]] [
    foreach e entities/drlist [
    unless e = [] [
        case [
            e/2/1 = 'circle [ 
                          case [
                           (closetoradius? pos e/2/2 e/2/3) [break/return e/2/2]
                           true [pos] 
                         ]]
            e/2/1 = 'box [ 
                res:  closetobox? pos e/2/2 e/2/3
                either res/1 [break/return  (line-midpoint e/2/2 e/2/3)]
                             [pos]
                         ]
            e/2/1 = 'ellipse [ 
                res:  closetoellipse? pos e/2/2 e/2/3
                either res/1 [break/return  res/3]
                             [pos]
                         ]
            e/2/1 = 'arc [ 
                          case [
                           (closetoarcradius? pos e/2/2 e/2/3 e/2/4  e/2/5 ) [break/return e/2/2]
                           true [pos] 
                         ]]
            true [pos]
        ]
    ]]
]

to-color: function [r g b][
    c: 0.0.0
    c/1: to integer! 255 * r
    c/2: to integer! 255 * g
    c/3: to integer! 255 * b
    c
]

to-percents: function [
    "Convert a color tuple to percent values"
    c [tuple!] "Color tuple"
] [
    reduce [ to percent! (c/1 / 255.0) to percent! (c/2 / 255.0) to percent! (c/3 / 255.0) ]
]

alertPOPUP: function [
    "Displays an alert message"
    msg [string!]  "Message to display"
][
    view [
        t: text msg center return
        b: button "ok" [ unview]
        do [b/offset/x: t/offset/x + (t/size/x - b/size/x / 2)]
    ][modal popup]
]

colorpopup: function [
    "show color box popup"
    lcolor  [tuple!]
    return: [tuple!]
][
    set [lcr lcg lcb] to-percents lcolor
    p2b: func [p] [to integer! p * 255]
    view [
        title "Color Selector"
        LCL: base 100x100 red react [color]
        GB: group-box "color select"  [ 
            return  across
            text "R:"  LSR: slider lcr [LCL/color/1: p2b LSR/data ] return
            text "G:"  LSG: slider lcg [LCL/color/2: p2b LSG/data ] return
            text "B:"  LSB: slider lcb [LCL/color/3: p2b LSB/data ]
        ] return 
        button "OK" 100     [ unview lcolor: to-color LSR/data LSG/data LSB/data ]
        button "Cancel" 100 [ unview ]
        do [LCL/size/2: GB/size/2 LCL/color: lcolor]
    ][modal popup]
    lcolor
]
;; colorpopup to-color 50% 20% 20%

img: context [
    localpath: %/images/
    remotepath: https://raw.githubusercontent.com/nodrygo/DemosRed/master/images/
    loader: func [imgname return: [image!]] [
       nlimg: copy reduce localpath   append nlimg  imgname
       nrimg: copy reduce remotepath  append nrimg  imgname
       load reduce either file? nlimg [ nlimg ] [ nrimg]
    ]
]
