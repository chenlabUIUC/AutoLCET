# Description  
This code is used to align the tilt series and do the reconstruction.  
# Getting started  
1. Download the "alignment and reconstruction example" folder.  
2. Run "alignment_example.ipynb" for alignment. Please install all imported libiaries.   
3. The input data contains (a) The coarse aligned tilt series. and (b) A csv file recording the tilt angles. Both file can be produced in the last step (tilt series extraction example). But for completion of the example we provide the file examples here. (a) is already provided here. For (b) please download "_20240612_124708_log_norm.tif" from xxxx. Both files should be in the "input" folder.  

4. Run "recon_SVMBIR_example.ipynb" to do reconstruction. Please install all imported libraries. To the best of my knowledge, the svmbir library does not work well on Windows OS.  
5. The input data in from the last alignment step which is in "output/align". The results will be saved in "output/reconstruction".    
