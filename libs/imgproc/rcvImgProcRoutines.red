Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvImgProcRoutines.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;***************** COLORSPACE CONVERSIONS ************
; Based on  OpenCV 3.0 implementation for 8-bit image
; exported as functions in /libs/imgproc/rcvImgProc.red

;RGB<=>CIE XYZ.Rec 709 with D65 white point
_rcvXYZ: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh         
        rf: as float! r 
		gf: as float! g 
		bf: as float! b   	
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)	
    	switch op [
    		1 [r: as integer! zf g: as integer! yf b: as integer! xf] ;rgb
    		2 [r: as integer! xf g: as integer! yf b: as integer! zf] ;bgr
    	] 	
    	pixD/value: ((a << 24) OR (b << 16 ) OR (g << 8) OR r)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

_rcvXYZRGB: routine [
    src1 [image!]
    dst  [image!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24				; 
       	r: pix1/value and FF0000h >> 16	; X  
        g: pix1/value and FF00h >> 8 		; Y  
        b: pix1/value and FFh 				; Z 
        xf: as float! r
		yf: as float! g
		zf: as float! b
		rf: (xf * 3.240479) + (yf * -1.53715) + (zf * -0.498535)			
		gf: (xf * -0.969256) + (yf * 1.875991) + (zf * 0.041556)
		bf: (xf * 0.055648)+ (yf * -0.204043) + (zf * 1.057311)
		r: as integer! (xf * 255.0) 
    	g: as integer! (yf * 255.0) 
    	b: as integer! (zf * 255.0)
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


;RGB<=>YCrCb JPEG (a.k.a. YCC)
_rcvYCrCb: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf 
        yy cr cb
        delta
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    Yy: 0.0
	cr: 0.0
	cb: 0.0
    delta: 128.0; for 8-bit image 
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        rf: (as float! r) 
		gf: (as float! g)
		bf: (as float! b)
		Yy: (0.299 * rf) + (0.587 * gf) + (0.114 * bf) 
		cr: ((rf - Yy) * 0.713) + delta
		cb: ((bf - Yy) * 0.514) + delta 
		switch op [
			1 [r: as integer! Yy g: as integer! cr b: as integer! cb]
			2 [r: as integer! cb g: as integer! cr b: as integer! Yy]
		]
		pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


;RGB<=>HSV

_rcvHSV: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf 
        mini maxi
        hh s v
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    hh: 0.0
	s: 0.0
	v: 0.0
	mini: 0.0
	maxi: 0.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0
		either rf < gf [mini: rf] [mini: gf]
		if bf < mini [mini: bf] 
		either rf > gf [maxi: rf] [maxi: gf]
		if bf > maxi [maxi: bf]	
		v: maxi	
		; either grayscale no chroma ... or color chromatic data
		either (maxi - mini = 0.0) [s: 0.0 hh: 0.0] 
			[s: (v - mini) / v
			if v = rf [hh: (gf - bf) * 60 / s ]
			if v = gf [hh: 180.0 + (bf - rf) * 60 / s ]
			if v = bf [hh: 240.0 + (rf - gf) * 60 / s ]]
		if hh < 0.0 [ hh: hh + 360.0]
		switch op [
			1 [r: as integer! hh / 2 g: as integer! s * 255 b: as integer! v * 255]
			2 [r: as integer! v * 255 g: as integer! s * 255 b: as integer! hh / 2 ]
		]
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]



;RGB<=>HLS
_rcvHLS: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf 
        mini maxi l
        hh s
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    hh: 0.0
	s: 0.0
	mini: 0.0
	maxi: 0.0
	l: 0.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        rf: (as float! r) / 255.0
		gf: (as float! g) / 255.0
		bf: (as float! b) / 255.0
		either rf < gf [mini: rf] [mini: gf]
		if bf < mini [mini: bf] 
		either rf > gf [maxi: rf] [maxi: gf]
		if bf > maxi [maxi: bf]
		l: (maxi + mini) / 2
		either l < 0.5 [s: (maxi - mini ) / (maxi + mini)]
				[ s: (maxi - mini ) / (2.0 - (maxi + mini))]
		if maxi = rf [hh: (gf - bf) * 60 / s]
		if maxi = gf [hh: 180.0 + (bf - rf) * 60 / s]	
		if maxi = bf [hh: 240.0 + (rf - gf) * 60 / s]	
		if hh < 0.0 [ hh: hh + 360.0]
		switch op [
			1 [r: as integer! hh / 2 g: as integer! l * 255 b: as integer! s * 255]
			2 [r: as integer! s * 255 g: as integer! l * 255 b: as integer! hh / 2 ]
		]
    	pixD/value: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

; A REVOIR
;RGB<=>CIE L*a*b* 
_rcvLab: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf l aa bb
        delta ratio ratio2
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    delta: 128.0
    ratio: 1.0 / 3.0
    ratio2: 16.0 / 116.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh  
        rf: as float! r / 255.0
		gf: as float! g / 255.0
		bf: as float! b / 255.0
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)
    	xf: xf / 0.950456
    	zf: zf / 1.088754
    	either yf > 0.008856 [l: 116.0 *  (pow yf ratio)] [l: 903.3 * yf]			
    	either yf > 0.008856 [aa: 500.0 * ((pow xf ratio) - (pow yf ratio)) + delta
    						bb: 200.0 * ((pow yf ratio) - (pow zf ratio)) + delta] 
    				[aa: 500.0 * ((7787.0 * xf + ratio2) - (7787.0 * yf + ratio2))
    				 bb: 200.0 * ((7787.0 * yf + ratio2) - (7787.0 * zf + ratio2))
    				]
		l: l * 255.0 / 100.0
		aa: aa + 128.0
		bb: bb + 128.0
    	switch op [
    		1 [r: as integer! l g: as integer! aa b: as integer! bb] ;rgb
    		2 [r: as integer! bb g: as integer! aa b: as integer! l] ;bgr
    	]	
    	pixD/value: (a << 24) OR (b << 16) OR (g << 8) OR r	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


_rcvLuv: routine [
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a rf gf bf xf yf zf 
        l u v uu vv 
       ratio
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    ratio: 1.0 / 3.0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        ; convert R,G,B to CIE XYZ
        rf: as float! r / 255.0
		gf: as float! g / 255.0
		bf: as float! b / 255.0
		xf: (rf * 0.412453) + (gf *  0.357580) + (bf * 0.180423)
    	yf: (rf * 0.212671) + (gf *  0.715160) + (bf * 0.072169)
    	zf: (rf * 0.019334) + (gf *  0.119193) + (bf * 0.950227)
    	either yf > 0.008856 [l: (116.0 * (pow yf ratio)) - 16.00] 
    				[l: 903.3 * yf]	
    	;convert XYZ to CIE Luv
    	uu: (4.0 * xf) / (xf + 15.00 * yf + 3.0 * zf)			
    	vv: (9.0 * yf) / (xf + 15.00 * yf + 3.0 * zf)
    	u: 13.00 * l * (uu - 0.19793943)
		v: 13.00 * l * (vv - 0.46831096)
		l: l / 100.0 * 255.0
		u: (u + 134.0)  / 354.0 * 255.0
		v: (v + 140.0)  / 266.0 * 255.0    	 
    	switch op [
    		1 [r: as integer! l g: as integer! u b: as integer! v] ;rgb
    		2 [r: as integer! v g: as integer! u b: as integer! l] ;bgr
    	]	
    	pixD/value: (a << 24) OR (b << 16 ) OR (g << 8) OR r	
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


;***************** IMAGE TRANSFORMATION ROUTINES ***********************
; exported as functions in /libs/imgproc/rcvImgProc.red

_rcvFlipHV: routine [
    src  [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y        
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx: null
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
        switch op [
        	0 [idx: pix1 + (y * w) + x] 				; no change
            1 [idx: pix1 + (y * w) + (w - x) - 1] 		;left/right
            2 [idx: pix1 + (w * h) - (y * w) + x - w] 	; up/down
            3 [idx: pix1 + (w * h) - (y * w) - x - 1]	; both flips
        ]  
        pixD/value: idx/value
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

; *************** IMAGE CONVOLUTION *************************
; exported as functions in /libs/imgproc/rcvImgProc.red

{The 2D convolution operation isn't extremely fast, 
unless you use small filters. We'll usually be using 3x3 or 5x5 filters. 
There are a few rules about the filter:
Its size has to be uneven, so that it has a center, for example 3x3, 5x5, 7x7 or 9x9 are ok. 
The sum of all elements of the filter should be 1 if you want the resulting image to have the same brightness as the original
If the sum of the elements is larger than 1, the result will be a brighter image
If it's smaller than 1, a darker image. 
If the sum is 0, the resulting image isn't necessarily completely black, but it'll be very dark
Apart from using a kernel matrix, it also has a multiplier factor and a delta. 
After applying the filter, the factor will be multiplied with the result, and the bias added to it. 
So if you have a filter with an element 0.25 in it, but the factor is set to 2, all elements of the filter 
are  multiplied by two so that element 0.25 is actually 0.5. 
The delta can be used if you want to make the resulting image brighter. 
}

_rcvConvolve: routine [
    src  	[image!]
    dst  	[image!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        r g b
        accR accG accB
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	accR: 0.0
        accG: 0.0 
        accB: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK  
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
            		r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh  
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			accR: accR + (f/value * r)
        			accG: accG + (f/value * g)
        			accB: accB + (f/value * b)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        r: as integer! ((accR * factor) + delta)				 
        g: as integer! ((accG * factor) + delta)
        b: as integer! ((accB * factor) + delta)				 
        if r < 0   [r: 0]
        if r > 255 [r: 255]
        if g < 0   [g: 0]
        if g > 255 [g: 255]
        if b < 0   [b: 0]
        if b > 255 [b: 255]				 
        pixD/value: (255 << 24) OR ( r << 16 ) OR (g << 8) OR b
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]



;-2147483648 to 2147483647




; only for 1-channel image (8-bit)
_rcvFastConvolve: routine [
    src  	[image!]
    dst  	[image!]
    channel	[integer!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        v
        accV 
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	accV: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
            		switch channel [
						1 [v: idx/value and 00FF0000h >> 16 ]
						2 [v: idx/value and FF00h >> 8 ]
						3 [v: idx/value and FFh]
					]
					;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			accV: accV + ((as float! v) * f/value)
         			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        v: as integer! (accV * factor)						 
    	v: v + as integer! delta
        if v < 0 [v: 0]
        if v > 255 [v: 255]
        pixD/value: (255 << 24) OR (v << 16 ) OR (v << 8) OR v	
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; Similar to convolution but the sum of the weights is computed during the summation, 
; and used to scale the result.

_rcvFilter2D: routine [
    src  	[image!]
    dst  	[image!]
    kernel 	[block!] 
    delta	[integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        r g b
        accR accG accB
        weightSum
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	weightSum: 0.0
    	accR: 0.0
        accG: 0.0 
        accB: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
            		r: idx/value and 00FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh  
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			accR: accR + ((as float! r) * f/value)
        			accG: accG + ((as float! g) * f/value)
        			accB: accB + ((as float! b) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        either (weightSum > 0.0) [r: as integer! (accR / weightSum)] 
        						 [r: as integer! (accR)]
        either (weightSum > 0.0) [g: as integer! (accG / weightSum)] 
        						 [g: as integer! (accG)]
        either (weightSum > 0.0) [b: as integer! (accB / weightSum)] 
        						 [b: as integer! (accB)]
        r: r + delta
        g: g + delta
        b: b + delta
        if r < 0 [r: 0]
        if r > 255 [r: 255]
        if g < 0 [g: 0]
        if g > 255 [g: 255]
        if b < 0 [b: 0]
        if b > 255 [b: 255]				 
        pixD/value: (255 << 24) OR (r << 16 ) OR (g << 8) OR b
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; a faster version without controls on pixel value !
; basically for 1 channel gray scaled image
;the sum of the weights is computed during the summation, and used to scale the result

_rcvFastFilter2D: routine [
    src  [image!]
    dst  [image!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        handle1 handleD h w x y i j
        pixel
        weightSum
        weightAcc
        f  imx imy 
		kWidth 
		kHeight 
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	weightAcc: 0.0 
    	weightSum: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pix1 + (imy * w) + imx  ; corrected pixel index
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + ((as float! idx/value) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        either (weightSum > 0.0) [pixD/value: as integer! (weightAcc / weightSum)] 
        						 [pixD/value: as integer! (weightAcc)]
       
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


; ****************integral image************************
; exported as functions in /libs/imgproc/rcvImgProc.red

_rcvIntegral: routine [
    src  [image!]
    dst  [image!]
    dst2 [image!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        pixD2 	[int-ptr!]
        idxD	[int-ptr!]
        idxD2	[int-ptr!]
        handle1 handleD handleD2 h w x y pindex pindex2 val
        sum sqsum     
][
    handle1: 0
    handleD: 0
    handleD2: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    pixD2: image/acquire-buffer dst2 :handleD2
    idxD: pixD
    idxD2: pixD2
    pindex: 0
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    while [x < w] [
    	y: 0
    	sum: 0
    	sqsum: 0
       	while [y < h][
       		pindex: x + (y * w) 
       		sum: sum + pix1/value
       		sqsum: sqsum + (pix1/value * pix1/value)
       		either x = 0 [pixD/value: sum pixD2/value: sqsum] 
       					 [
       					 ;sum
       					 pixD: idxD + pindex - 1
       					 val: pixD/value + sum
       					 pixD: idxD + pindex
       					 pixD/value: val
       					 ; square sum
       					 pixD2: idxD2 + pindex - 1
       					 val: pixD2/value + sqsum
       					 pixD2: idxD2 + pindex
       					 pixD2/value: val
       					 ]
        	pix1: pix1 + 1
        	y: y + 1
       ]
       x: x + 1
       
    ]
    
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
    image/release-buffer dst2 handleD2 yes
]


; ******************* morphological Operations**************************
; exported as functions in /libs/imgproc/rcvImgProc.red

_rcvErode: routine [
    src  	[image!]
    dst  	[image!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        idxD	[int-ptr!]
        handle1 handleD h w x y i j
        mini
        k  imx imy imx2 imy2
       	radiusX radiusY
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idx2: pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    j: 0
    i: 0
    while [y < (h - radiusY)] [
       while [x < (w - radiusX)][
       		idx: pix1 + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	mini: 0
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: pix1 + (imy2 * w) + imx2
        			k: as red-integer! kValue
        			if k/value = 1 [
        				if idx2/value < mini [mini: idx2/value]
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		pixD: idxD + (y * w) + x
           	pixD/value: mini
           	x: x + 1
       ]
       x: 0
       y: y + 1    
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


_rcvDilate: routine [
    src  	[image!]
    dst  	[image!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        idxD	[int-ptr!]
        handle1 handleD h w x y i j
        maxi
        k  imx imy imx2 imy2
       	radiusX radiusY
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idx2: pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    j: 0
    i: 0
    while [y < (h - radiusY)] [
       while [x < (w - radiusX)][
       		idx: pix1 + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	maxi: (255 << 24) OR (0 << 16) or (0 << 8) OR 0
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: pix1 + (imy2 * w) + imx2
        			k: as red-integer! kValue
        			
        			if k/value = 1 [
        				if idx2/value > maxi [maxi: idx2/value]
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		pixD: idxD + (y * w) + x
           	pixD/value: maxi
           	x: x + 1
       ]
       x: 0
       y: y + 1 
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]


_rcvMMean: routine [
    src  	[image!]
    dst  	[image!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idx2	[int-ptr!]
        idxD	[int-ptr!]
        handle1 handleD h w x y i j
        maxi
        count
        k  imx imy imx2 imy2
       	radiusX radiusY
		kBase 
		kValue  
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idx2: pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    j: 0
    i: 0
    while [y < (h - radiusY)] [
       while [x < (w - radiusX)][
       		idx: pix1 + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	maxi: 0
        	count: 0
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: pix1 + (imy2 * w) + imx2
        			k: as red-integer! kValue
        			
        			if k/value = 1 [
        				count: count + 1
        				maxi: maxi + idx2/value
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		pixD: idxD + (y * w) + x
           	pixD/value: maxi / count
           	x: x + 1
       ]
       x: 0
       y: y + 1 
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

_rcvBlend: routine [
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    alpha	[float!]
    /local
        pix1 	[int-ptr!]
        pix2 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        a1 r1 g1 b1
        a2 r2 g2 b2
        a3 r3 g3 b3
        calpha
][
	handle1: 0
	handle2: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle1
    pixD: image/acquire-buffer dst  :handleD
	w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    a3: 0
    r3: 0
    g3: 0
    b3: 0
    calpha: 1.0 - alpha
    while [y < h] [
		while [x < w][
				a1: pix1/value >>> 24
       			r1: pix1/value and 00FF0000h >> 16 
        		g1: pix1/value and FF00h >> 8 
        		b1: pix1/value and FFh 
        		a2: pix2/value >>> 24
       			r2: pix2/value and 00FF0000h >> 16 
        		g2: pix2/value and FF00h >> 8 
        		b2: pix2/value and FFh 
        		a3: as integer! (alpha * a1) + (calpha * a2) 
        		r3: as integer! (alpha * r1) + (calpha * r2) 
        		g3: as integer! (alpha * g1) + (calpha * g2)
        		b3: as integer! (alpha * b1) + (calpha * b2)
        		pixD/value: (a3 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pix1: pix1 + 1
				pix2: pix2 + 1
				pixD: pixD + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]




; ************tools for edges detection***********
; exported as functions in /libs/imgproc/rcvImgProc.red
;G= Sqrt Gx^2 +Gy^2

_rcvMagnitude: routine [
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    /local
        pix1 	[int-ptr!]
        pix2 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        r1 g1 b1
        r2 g2 b2
        r3 g3 b3
][
	handle1: 0
	handle2: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle1
    pixD: image/acquire-buffer dst :handleD
	w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    r3: 0
    g3: 0
    b3: 0
    while [y < h] [
		while [x < w][
       			r1: pix1/value and 00FF0000h >> 16 
        		g1: pix1/value and FF00h >> 8 
        		b1: pix1/value and FFh 
       			r2: pix2/value and 00FF0000h >> 16 
        		g2: pix2/value and FF00h >> 8 
        		b2: pix2/value and FFh 
        		r3: as integer! sqrt as float! ((r1 * r1) + (r2 * r2)) 
        		g3: as integer! sqrt as float! ((g1 * g1) + (g2 * g2))
        		b3: as integer! sqrt as float! ((b1 * b1) + (b2 * b2))
        		pixD/value: (255 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pix1: pix1 + 1
				pix2: pix2 + 1
				pixD: pixD + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle1 no
	image/release-buffer dst handleD yes
]


; atan Gy / Gx to be improved 
_rcvDirection: routine [
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    /local
        pix1 	[int-ptr!]
        pix2 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        r1 g1 b1
        r2 g2 b2
        r3 g3 b3
][
	handle1: 0
	handle2: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle1
    pixD: image/acquire-buffer dst :handleD
	w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    r3: 0
    g3: 0
    b3: 0
    while [y < h] [
		while [x < w][
       			r1: as float! pix1/value and 00FF0000h >> 16 
        		g1: as float! pix1/value and FF00h >> 8 
        		b1: as float! pix1/value and FFh 
       			r2: as float! pix2/value and 00FF0000h >> 16 
        		g2: as float! pix2/value and FF00h >> 8 
        		b2: as float! pix2/value and FFh 
        		either r1 > 0.0 [r3: as integer! atan (r2 / r1)]
        		 			  [r3: 0]
        		either g1 > 0.0 [g3: as integer! atan (g2 / g1)]
        		     		  [g3: 0]
        		either b1 > 0.0 [b3: as integer! atan (b2 / b1)]
        					  [b3: 0]
        		pixD/value: (255 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pix1: pix1 + 1
				pix2: pix2 + 1
				pixD: pixD + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle1 no
	image/release-buffer dst handleD yes
]




;op= 1 ; rcvGradNeumann Computes the discrete gradient 
;by forward finite differences and Neumann boundary conditions. 
;op = 2 Computes the divergence by backward finite differences. 

; exported as functions in /libs/imgproc/rcvImgProc.red
_rcvNeumann: routine [
    src  	[image!]
    dst1  	[image!]
    dst2  	[image!]
    op      [integer!]
    /local
    	stride1 
		bmp1 
		data1 
		pos
        pixD1 	[int-ptr!]
        pixD2 	[int-ptr!]
        handleD1 handleD2 
        h w x y 
        v1 v2 v3
] [
	
	stride1: 0
    ;bmp1: OS-image/lock-bitmap as-integer src/node no
    bmp1: OS-image/lock-bitmap src no
    data1: OS-image/get-data bmp1 :stride1   
	handleD1: 0
    handleD2: 0
    pixD1: image/acquire-buffer dst1 :handleD1
    pixD2: image/acquire-buffer dst2 :handleD2
	w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size) 
    y: 0 
    x: 0
    
    ;im_out(i,j) = (im_in1(i,j)-im_in1(i-1,j)) + (im_in2(i,j)-im2(i,j-1))
    while [y < h] [
		while [x < w][
				pos: stride1 >> 2 * y + x + 1
			    v1: data1/pos
			    v2: data1/pos
			    v3: data1/pos
			    
			    switch op [
			    	1 [ if x < (w - 1) [pos: stride1 >> 2 * y + x + 2 v2: data1/pos]
			   			if y < (h - 1) [pos: stride1 >> 2 * (y + 1) + x + 1 v3: data1/pos]
			    	]
			    	
			    	2 [ if x > 0 [pos: stride1 >> 2 * y + x v2: data1/pos]
			    		if y > 0 [pos: stride1 >> 2 * (y - 1) + x + 1 v3: data1/pos]
			    	]
			    ]
			    pixD1/value: v2 - v1
			    pixD2/value: v3 - v1
				pixD1: pixD1 + 1
				pixD2: pixD2 + 1
				x: x + 1
		]
		x: 0
		y: y + 1
	]
	;OS-image/unlock-bitmap as-integer src/node bmp1;
	OS-image/unlock-bitmap src bmp1; MB
	image/release-buffer dst1 handleD1 yes
	image/release-buffer dst2 handleD2 yes
]



