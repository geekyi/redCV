Red [	Title:   "Matrix tests "	Author:  "Francois Jouen"	File: 	 %MatrixConvolution.red	Needs:	 'View]#include %../../libs/redcv.red ; for redCV functions; laplacian convolution filtermask: [-1.0 0.0 -1.0		0.0 4.0 0.0 	   -1.0 0.0 -1.0]intSize: 8img1: rcvLoadImage %../../images/lena.jpgimg2: rcvCreateImage img1/sizemat1: rcvCreateMat 'integer! intSize img1/sizemat2: rcvCreateMat 'integer! intSize img1/sizercvImage2Mat img1 mat1									; Converts to  grayscale image and to 1 Channel matrix [0..255]  rcvConvolveMat mat1 mat2 img1/size mask 1.0 0.0			; Mat convolutionrcvMat82Image mat2 img2									; from matrix to red images1: rcvNamedWindow "Source"m1: rcvNamedWindow "Matrix Convolution"rcvMoveWindow s1 100x100rcvMoveWindow m1 400x100rcvShowImage s1 img1rcvShowImage m1 img2rcvResizeWindow m1 512x512do-events