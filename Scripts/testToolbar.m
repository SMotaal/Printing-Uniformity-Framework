
obj = x.PlotMediator;
parentFigure = x;

cases     = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01', 'rithp5501'};
sets      = int8([100, 75, 50, 25, 0]);

hFigure   = parentFigure.Handle;

caseID = obj.CaseID;
selectedCase = find(strcmpi(caseID, cases));
jCaseMenu = obj.createDropDown(hFigure, cases, selectedCase, ...
  @obj.selectCaseID, 0, [], 150);

setID = obj.SetID;
selectedSet = find(sets==setID);
jSetMenu = obj.createDropDown(hFigure, sets, selectedSet, ...
  @obj.selectSetID, 175, [], 75);

hToolbar = findall(allchild(hFigure),'flat','type','uitoolbar');

if isempty(hToolbar), hToolbar  = uitoolbar(hFigure); end

drawnow;

jContainer = get(hToolbar(1),'JavaContainer');
jToolbar = jContainer.getComponentPeer;

jToolbar.add(jCaseMenu, 1);
jToolbar.add(jSetMenu, 2);
jToolbar.repaint;
jToolbar.revalidate;
