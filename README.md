# Matlab-Whisker-Tracker


Functions & work-flow

* ParameterSetup.m - UI to test & optimize tracker settings. Updated settings are stored in Settings.mat
* BatchTracker.m - UI to select videos for tracking, tracks videos, stores output in a datapath specified in makeSettings.m
* Tracker Analysis - Directory containing miscellaneous functions to further process tracker output:
  * Main.m - Framework to call functions in directory
  * getParams - Extract n parameters for m traces in a frame, returns a [m x n] sized matrix per frame.
   * CleanTraces - Omit traces not meeting requirements (specified in makeAnalyseSettings.m), fit a polynomial trough raw traces
   * DetectTouch - Measure distance between whiskers and objects, returns indices of points on traces touching an object
   * FIG_ - returns a figure on data
   
  
   

