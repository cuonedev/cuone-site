require 'rbconfig'

gxx = 'C:/Ruby34-x64/msys64/ucrt64/bin/x86_64-w64-mingw32-g++.exe -std=gnu++11'
RbConfig::CONFIG['CXX'] = gxx
RbConfig::MAKEFILE_CONFIG['CXX'] = gxx
