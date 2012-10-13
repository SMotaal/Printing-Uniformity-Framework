%ddir = fullfile('~','Documents','MATLAB','data');

import Data.*
import Alpha.*

tic

sid = 'ritsm7401';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(FS.dataDir('uniprint',sid),sid);

sid = 'ritsm7402a';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(FS.dataDir('uniprint',sid),sid);

sid = 'ritsm7402b';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(FS.dataDir('uniprint',sid),sid);

sid = 'ritsm7402c';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(FS.dataDir('uniprint',sid),sid);

sid = 'rithp7k01';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(FS.dataDir('uniprint',sid),sid);

sid = 'rithp5501';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(FS.dataDir('uniprint',sid),sid);

toc


