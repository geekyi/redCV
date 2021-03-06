Red [
	Title:   "Pyramidal test"
	Author:  "Francois Jouen"
	File: 	 %pyramidal.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for red functions
margins: 10x10
knl: rcvMakeGaussian 5x5
img1: rcvCreateImage 512x512
dst: rcvCreateImage 512x512
iSize: 0x0
knl: rcvMakeGaussian 5x5

loadImage: does [
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		; update faces
		
		iSize: img1/size
		canvas/size: iSize
		canvas/image/size: iSize	
		
		canvas/offset/x: (win/size/x - img1/size/x) / 2
		
		{if img1/size >= 256x256 [
			win/size/x: iSize/x + 20
			win/size/y: iSize/y + 100
		] }
		canvas/image: dst
		f/data: form dst/size
	]
]



	  
; ***************** Test Program ****************************
view win: layout [
		title "Pyramidal Sizing"
		button 80 "Load" 			[loadImage]
		
								    					    								
		button 85 "Pyr Down"	   [
									iSize: iSize / 2
								    	if iSize > 5x5 [
								    		f/data: form rcvResizeImage/gaussian dst canvas iSize
										]
								    ]	
		button 80 "Pyr Up"	   		[
									iSize: iSize * 2
									f/data: form rcvResizeImage/gaussian dst canvas iSize
								    ]				
								    
		f: field 80x29						
		button 80 "Quit" 			[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		
		return
		canvas: base 512x512 dst
		
			
]
