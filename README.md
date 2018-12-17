# MIST4Matlab
Microscope Image Synthesis Toolbox (MIST) for Matlab.

## Installation

### In the OS:
1. Clone or extract MIST4Matlab to a folder *F* of your choice (e.g. *../MIST4Matlab/*).
2. On Linux: Make the file where Matlab stores its search paths writable for your user. Therefore, run the following command in the terminal (adjust the path to match your Matlab installation):
```
sudo chown $USER /usr/local/MATLAB/R2018b/toolbox/local/pathdef.m
```

### In MATLAB:
1. Start MATLAB (on Windows: run it as administrator, so that Matlab can permanently save the changes to its search paths).
2. Navigate to the folder *F*, where you cloned/extracted MIST4Matlab.
3. Execute the following command in the command window:
```MATLAB
setupMIST4Matlab
```
