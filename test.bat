@echo off

if exist a.out del a.out
if exist test.txt del test.txt

iverilog fetch.v decode.v execute.v alu.v biu.v hazard_detector.v fastrom.v test.v

if exist a.out vvp a.out >test.txt
