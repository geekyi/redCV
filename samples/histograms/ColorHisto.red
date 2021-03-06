Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %ColorHisto.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
msize: 256x256
img1: make image! reduce [msize black]
histor: make vector! 256
histog: make vector! 256
histob: make vector! 256
historc: make vector! 256
histogc: make vector! 256
histobc: make vector! 256

smooth: false

loadImage: does [
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: black
	tmp: request-file
	if not none? tmp [
		img1:  rcvLoadImage  tmp
		canvas1/image: img1
	]
]


processMat: does [
	histor: rcvHistogram/red img1
	histog: rcvHistogram/green img1
	histob: rcvHistogram/blue img1
	
	tmp: copy histor
	sort tmp
	maxi: last tmp
	rcvConvertMatScale/normal histor historc  maxi 200 ; change scale
	if smooth [tmp: rcvSmoothHistogram historc  historc: copy tmp]
	
	tmp: copy histog
	sort tmp
	maxi: last tmp
	rcvConvertMatScale/normal histog histogc  maxi 200 ; change scale
	
	if smooth [tmp: rcvSmoothHistogram histogc histogc: copy tmp]
	
	tmp: copy histob
	sort tmp
	maxi: last tmp
	rcvConvertMatScale/normal histob histobc  maxi 200 ; change scale
	if smooth [tmp: rcvSmoothHistogram histobc histobc: copy tmp]
]

showPlot: does [
	plotr: copy [line-width 1 pen red line]
	plotg: copy [line-width 1 pen green line]
	plotb: copy [line-width 1 pen blue line]
	
	i: 1 
	while [i <= 256] [  coord: as-pair (i) (250 - historc/(i))
						append plotr coord
						coord: as-pair (i) (250 - histogc/(i))
						append plotg coord
						coord: as-pair (i) (250 - histobc/(i))
						append plotb coord
						i: i + 1]				
	canvas2/draw: reduce [plotr plotg plotb] 
]



; ***************** Test Program ****************************
view win: layout [
		title "Histogram Tests"
		origin margins space margins
		button 100 "Load Image" 		[loadImage processMat showPlot]
		check 150 "Smooth Histogram" 	[smooth: face/data processMat showPlot]
		button 60 "Quit" 				[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base black msize
]
