%ddir = fullfile('~','Documents','MATLAB','data');

tic

sid = 'ritsm7401';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(datadir('uniprint',sid),sid);

sid = 'ritsm7402a';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(datadir('uniprint',sid),sid);

sid = 'ritsm7402b';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(datadir('uniprint',sid),sid);

sid = 'ritsm7402c';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(datadir('uniprint',sid),sid);

sid = 'rithp7k01';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(datadir('uniprint',sid),sid);

sid = 'rithp5501';
eval([sid ' = supCreateMatrix(''' sid ''');']); save(datadir('uniprint',sid),sid);

toc


