Red [title: "Basic Red GUI Widgets" needs: 'view]
view [
    img: image loose http://static.red-lang.org/red-logo.png 
    t: text "LOGO RED" button "Click Me" [t/text: "LOGO RED is moveable"] return
    text  bold italic red font-size 14 "Text with properties"
    field 300 "single line text" return 
    below
    check 160x24 data false [
        t/text: either face/data ["true"]["false"]
    ]
    group-box "Grouped Radio"  [
        return 
        across
        radio 40x40 "A" radio 40x40 "B" radio 40x40 "C"
    ]
    area 200x200 text "Multiline area here"
]