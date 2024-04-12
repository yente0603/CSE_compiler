#!/usr/bin/bash

echo '| test1.pas |'
cat testdata/1.pas;echo 
./a.out < testdata/1.pas

echo '------------------------'
echo '| test2.pas |'
cat testdata/2.pas;echo 
./a.out < testdata/2.pas

echo '------------------------'
echo '| test3.pas |'
cat testdata/3.pas;echo 
./a.out < testdata/3.pas

echo '------------------------'
echo '| test4.pas|'
cat testdata/4.pas;echo 
./a.out < testdata/4.pas

echo '------------------------'
echo '| test5.pas |'
cat testdata/5.pas;echo 
./a.out < testdata/5.pas

echo '------------------------'
echo '| test6.pas |'
cat testdata/6.pas;echo 
./a.out < testdata/6.pas

echo '------------------------'
echo '| test7.pas |'
cat testdata/7.pas;echo 
./a.out < testdata/7.pas