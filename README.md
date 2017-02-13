# Matlab Interface to the LabChart Server

This code controls parts of LabChart, from Matlab.

As an example, one of the first goals was to support adding comments into a LabChart file, via Matlab.

## Example Usage

``` matlab
active = labchart.getActiveDocument();
active.addComment('Testing');
```

## Current Features

* Changing zoom level
* Moving to a comment
* Adding a comment

## Features in progress

* stimulator programming

## Possible future features

* generic examples and support for reading streamed data from LabChart to Matlab

## Requirements

LabChart must be installed on the computer running this code.

## COM Server Background

This section contains information on how to write more code for the repo, particularly more code that interacts with the COM server.

AD Instruments provides a COM server for LabChart that allows sending commands to LabChart. This code wraps calls to that server. Documentation for this server is minimal, and code development so far has relied largely on trial and error with a running LabChart instance. 

"Documentation" of some methods can be found in Excel. This can be done via:

1. Open Excel
2. Press 'alt+F11'
3. Select menu => tools => references
4. Check the box for AD Instruments
5. Select menu => view => object browser
6. Go to the top of the window and select 'ADIChart'

Additional methods can be discovered by recording macros in LabChart. For methods not obviously exposed to Matlab (i.e. seen by calling methods() on the COM instance), the invoke() command can also be used.

Most object retain a 'h' property, which is the handle to the actual COM object. 
