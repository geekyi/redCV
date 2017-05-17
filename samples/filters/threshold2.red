Red [
	Title:   "Thresholding Operations"
    Author:  "Francois Jouen"
    File:    %threshold2.red
    Needs:   'View
]

#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
thresh: 128
maxValue: 255

ops: [
    [rcvThreshold/binary img1 dst thresh maxValue]
    [rcvThreshold/binaryInv img1 dst thresh maxValue]
    [rcvThreshold/trunc img1 dst thresh maxValue]
    [rcvThreshold/toZero img1 dst thresh maxValue]
    [rcvThreshold/toZeroInv img1 dst thresh maxValue]
]


loadImage: does [
    isFile: false
    canvas/image/rgb: black
    canvas/size: 0x0
    tmp: request-file
    if not none? tmp [
        fileName: to string! to-local-file tmp
        win/text: fileName
        img1: rcvLoadImage tmp
        dst:  rcvCloneImage img1
        ; update faces
        if img1/size/x >= defSize/x [
            win/size/x: img1/size/x + 20
            win/size/y: img1/size/y + 260
        ] 
        either (img1/size/x = img1/size/y) [bb/size: 60x60] [bb/size: 80x60]
        canvas/size: img1/size
        canvas/image/size: canvas/size  
        canvas/offset/x: (win/size/x - img1/size/x) / 2
        bb/image: img1
        canvas/image: dst
        isFile: true
        do op: ops/1
        r1/data: true
        r2/data: false
        r3/data: false
        r4/data: false
        r5/data: false
    ]
]

; ***************** Test Program ****************************
view win: layout [
        title "Basic Thresholding Operations"
        origin margins space margins
        button 60 "Load"        [loadImage] 
                    
        button 60 "Quit"        [rcvReleaseImage img1 
                                rcvReleaseImage dst Quit]
        return
        bb: base 80x60 img1
        return
        r1: radio "Binary"          [sl2/visible?: true  do op: ops/1]
        r2: radio "Binary Inverted" [sl2/visible?: true  do op: ops/2]    
        r3: radio "Truncate"        [sl2/visible?: false do op: ops/3]   
        r4: radio "To 0"            [sl2/visible?: false do op: ops/4]
        r5: radio "To 0 Inverted"   [sl2/visible?: false do op: ops/5]       
        return
        text 100 "Threshold value"  
        sl1: slider 340 [thresh: to integer! face/data * 255 f1/data: form thresh do op]
        f1: field 50 "128" 
        return
        text 100 "Maximal value" 
        sl2: slider 340 [maxValue: to integer! face/data * 255 f2/data: form maxValue do op]
        f2: field 50 "255"
        return
        canvas: base 512x512 dst    
        do [r1/data: true sl1/data: 0.5 sl2/data: 1.0]
]