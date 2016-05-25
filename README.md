# Matlab Interface to the Labchart Server

This code was written to control aspects of Labchart from Matlab. Specifically the first goal was to add comments in Labchart from Matlab. It is a (slow) work in progress.

## Example Usage

``` matlab
active = labchart.getActiveDocument();
active.addComment("Testing");
```
