function ligand = draw_image( ligand, plot_settings )
% ligand = draw_image( ligand, plot_settings )
% 
% Draw the 'silhouette' of a ligand (like a protein) if
%  its image_boundary field has been setup by SETUP_IMAGE_FOR_LIGAND.
%
% Note: this function does not move the image boundary to the back of the
%  drawing -- that needs to be handled by a call to MOVE_STUFF_TO_BACK later.
% 
% (C) Rhiju Das, Stanford University

assert( isfield( ligand, 'image_boundary') );
if ~exist( 'plot_settings', 'var' ) plot_settings = getappdata(gca, 'plot_settings' ); end;
if ~isfield( plot_settings, 'image_representation' ) plot_settings.image_representation = 'image_boundary'; end;
if ( ~isfield( plot_settings, 'show_images') || plot_settings.show_images );
    if ~isfield( ligand, 'image_offset' ) ligand.image_offset = [0,0]; end;
    switch plot_settings.image_representation
        case 'image_boundary'
            % Also reset the image_handle and image_handle2 if either
            % is now a rectangle -- as that will prevent setting of XData
            % and YData later on. (This is, I assume, something that can
            % happen if the image representation gets switched from
            % rectangle to image_boundary.)
            if ( ~isfield( ligand, 'image_handle2' ) | ~isvalid( ligand.image_handle2 ) | isa( ligand.image_handle2, 'matlab.graphics.primitive.Rectangle' ) )
                ligand = rmgraphics( ligand, {'image_handle2'} );
                ligand.image_handle2 = patch(0,0,[0,0,0],'edgecolor','none');
                send_to_top_of_back( ligand.image_handle2 );
            end
            if( ~isfield( ligand, 'image_handle' ) | ~isvalid( ligand.image_handle ) | isa( ligand.image_handle, 'matlab.graphics.primitive.Rectangle' ) )
                ligand = rmgraphics( ligand, {'image_handle'} );
                ligand.image_handle = patch(0,0,[0,0,0],'edgecolor','none');
                send_to_top_of_back( ligand.image_handle );
                setappdata( ligand.image_handle, 'res_tag', ligand.res_tag );
                draggable( ligand.image_handle,'n',[-inf inf -inf inf], @move_snapgrid, 'endfcn', @redraw_res_and_helix );
            end
            image_boundary = ligand.image_boundary;
            if isfield( plot_settings, 'ligand_image_scaling' ) image_boundary = image_boundary * plot_settings.ligand_image_scaling; end;            
            set( ligand.image_handle, ...
                'XData', image_boundary(:,1) + ligand.plot_pos(:,1) + ligand.image_offset(1), ...
                'YData', image_boundary(:,2) + ligand.plot_pos(:,2) + ligand.image_offset(2) );
            set( ligand.image_handle2, ...
                'XData', image_boundary(:,1) + ligand.plot_pos(:,1) + ligand.image_offset(1) + 0.25, ...
                'YData', image_boundary(:,2) + ligand.plot_pos(:,2) + ligand.image_offset(2) - 0.25);
        case 'rounded_rectangle'
            if ( ~isfield( ligand, 'image_handle2' ) | ~isvalid( ligand.image_handle2 ) )
                ligand.image_handle2 = rectangle('position',[0,0,0,0],'curvature',0.5,'edgecolor','none','clipping','off');
                send_to_top_of_back( ligand.image_handle2 );
            end
            if( ~isfield( ligand, 'image_handle' ) | ~isvalid( ligand.image_handle ) )
                ligand.image_handle = rectangle('position',[0,0,0,0],'curvature',0.5,'edgecolor','none','clipping','off');
                send_to_top_of_back( ligand.image_handle );
                setappdata( ligand.image_handle, 'res_tag', ligand.res_tag );
                draggable( ligand.image_handle,'n',[-inf inf -inf inf], @move_snapgrid, 'endfcn', @redraw_res_and_helix );
            end
            
            % should make these user-settable (perhaps by draggable 'image controls')
            if ~isfield( ligand, 'image_radius' ) ligand.image_radius = 2 * std( ligand.image_boundary ); end;
            ligand.image_radius = plot_settings.spacing * ceil( ligand.image_radius/ plot_settings.spacing );
            set( ligand.image_handle,...
                'Position', ...
                [ligand.image_offset(1)+ligand.plot_pos(:,1)-ligand.image_radius(1),...
                 ligand.image_offset(2)+ligand.plot_pos(:,2)-ligand.image_radius(2),...
                 2*ligand.image_radius(1),2*ligand.image_radius(2) ]);
            set( ligand.image_handle2,...
                'Position', ...
                [ligand.image_offset(1)+ligand.plot_pos(:,1)-(ligand.image_radius(1)+0.25), ligand.image_offset(2)+ligand.plot_pos(:,2)-(ligand.image_radius(2)+0.25),...
                 2*(ligand.image_radius(1)+0.25),2*(ligand.image_radius(2)+0.25)]);
    end
    set_ligand_image_color( ligand );
    if ~isfield( ligand, 'label_relpos' ) ligand.label_relpos = ligand.relpos; end;
    if ~isfield( ligand, 'label' ) & isfield( ligand, 'name' )
         h = text( 0, 0, ligand.name, 'fontsize',10, ....
             'fontweight', 'bold', 'verticalalign','middle','horizontalalign','center','clipping','off' );
         ligand.label = h;
         draggable( h, 'n',[-inf inf -inf inf], @move_ligand_label )
         setappdata( h, 'ligand_tag', ligand.res_tag );
    end
    set(ligand.label,'position',get_plot_pos(ligand,ligand.label_relpos),'fontsize',plot_settings.fontsize*14/10,'color',[0,0,0] );
    if isfield( ligand, 'handle' ) set( ligand.handle, 'visible', 'off'  ); end;
    setappdata( gca, ligand.res_tag, ligand );
else
    ligand = rmgraphics( ligand, {'image_handle','image_handle2','label'} );
    if isfield( ligand, 'handle' ) 
        set( ligand.handle, 'fontsize',  plot_settings.fontsize*1.5,'visible','on');
    end;
end
   



