function setup_zoom()
% setup_zoom()
%
% Just call this once when setting up drawing.
%  Every time user zooms in or out, fontsize and arrow
%  widths will scale automatically.
%
% (C) R. Das, Stanford University, 2017

h = zoom;
set(h,'ActionPostCallback',@zoomCallBack);
set(gcf,'ResizeFcn',@zoomCallBack);
set(h,'Enable','on');
zoom off;

% everytime you zoom in, this function is executed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zoomCallBack(~, evd)
%axis equal
%fprintf( 'Updating graphics size... \n');
update_graphics_size();
