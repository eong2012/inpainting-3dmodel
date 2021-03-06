% *  This code was used in the following articles:
% *  [1] Learning 3-D Scene Structure from a Single Still Image, 
% *      Ashutosh Saxena, Min Sun, Andrew Y. Ng, 
% *      In ICCV workshop on 3D Representation for Recognition (3dRR-07), 2007.
% *      (best paper)
% *  [2] 3-D Reconstruction from Sparse Views using Monocular Vision, 
% *      Ashutosh Saxena, Min Sun, Andrew Y. Ng, 
% *      In ICCV workshop on Virtual Representations and Modeling 
% *      of Large-scale environments (VRML), 2007. 
% *  [3] 3-D Depth Reconstruction from a Single Still Image, 
% *      Ashutosh Saxena, Sung H. Chung, Andrew Y. Ng. 
% *      International Journal of Computer Vision (IJCV), Aug 2007. 
% *  [6] Learning Depth from Single Monocular Images, 
% *      Ashutosh Saxena, Sung H. Chung, Andrew Y. Ng. 
% *      In Neural Information Processing Systems (NIPS) 18, 2005.
% *
% *  These articles are available at:
% *  http://make3d.stanford.edu/publications
% * 
% *  We request that you cite the papers [1], [3] and [6] in any of
% *  your reports that uses this code. 
% *  Further, if you use the code in image3dstiching/ (multiple image version),
% *  then please cite [2].
% *  
% *  If you use the code in third_party/, then PLEASE CITE and follow the
% *  LICENSE OF THE CORRESPONDING THIRD PARTY CODE.
% *
% *  Finally, this code is for non-commercial use only.  For further 
% *  information and to obtain a copy of the license, see 
% *
% *  http://make3d.stanford.edu/publications/code
% *
% *  Also, the software distributed under the License is distributed on an 
% * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
% *  express or implied.   See the License for the specific language governing 
% *  permissions and limitations under the License.
% *
% */
function h = dispMatchSearchRegin(I1,I2,P1,P2,ConS1, ConS2, F, ...
                                    x1_2Max, MaxD1, x1_2Min, MinD1,...
                                    x2_1Max, MaxD2, x2_1Min, MinD2, ...
                                    FlagRotate, varargin)
% PLOTMATCHES  Plot keypoint matches
%   PLOTMATCHES(I1,I2,P1,P2,MATCHES) plots the two images I1 and I2
%   and lines connecting the frames (keypoints) P1 and P2 as specified
%   by MATCHES.
%
%   P1 and P2 specify two sets of frames, one per column. The first
%   two elements of each column specify the X,Y coordinates of the
%   corresponding frame. Any other element is ignored.
%
%   ConS specifies Constrain for each features serach region, 
%   one per column. The 4 elementes of each column are max and min
%   boundary in x y respectively.
%   [xmin; xmax; ymin; ymax]
%
%   The images I1 and I2 might be either both grayscale or both color
%   and must have DOUBLE storage class. If they are color the range
%   must be normalized in [0,1].
%
%   The function accepts the following option-value pairs:
%
%   'Stacking' ['h']
%      Stacking of images: horizontal ['h'], vertical ['v'], diagonal
%      ['h'], overlap ['o']
%
%   'Interactive' [1] (always to 1)
%      In this mode the
%      program lets the user browse the constrain region by moving the mouse:
%      Click to select and highlight feature point; press any key to end.
%
%   See also PLOTSIFTDESCRIPTOR(), PLOTSIFTFRAME(), PLOTSS().

% AUTORIGHTS
% Copyright (c) 2006 The Regents of the University of California.
% All Rights Reserved.
% 
% Created by Andrea Vedaldi
% UCLA Vision Lab - Department of Computer Science
% 
% Permission to use, copy, modify, and distribute this software and its
% documentation for educational, research and non-profit purposes,
% without fee, and without a written agreement is hereby granted,
% provided that the above copyright notice, this paragraph and the
% following three paragraphs appear in all copies.
% 
% This software program and documentation are copyrighted by The Regents
% of the University of California. The software program and
% documentation are supplied "as is", without any accompanying services
% from The Regents. The Regents does not warrant that the operation of
% the program will be uninterrupted or error-free. The end-user
% understands that the program was developed for research purposes and
% is advised not to rely exclusively on the program for any reason.
% 
% This software embodies a method for which the following patent has
% been issued: "Method and apparatus for identifying scale invariant
% features in an image and use of same for locating an object in an
% image," David G. Lowe, US Patent 6,711,293 (March 23,
% 2004). Provisional application filed March 8, 1999. Asignee: The
% University of British Columbia.
% 
% IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
% FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
% INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND
% ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. THE UNIVERSITY OF
% CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
% A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS"
% BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO PROVIDE
% MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

% --------------------------------------------------------------------
% Modified by Min to show interactive between features and constrain region
% April 29th, 2007
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%                                                  Check the arguments
% --------------------------------------------------------------------

stack='h' ;
interactive=0 ;
only_interactive=0 ;
dodist=0;

for k=1:2:length(varargin)
  switch lower(varargin{k})
	 case 'stacking'
		stack=varargin{k+1} ;
	 case 'interactive'
		interactive=varargin{k+1};
      case 'dist'
        dist = varargin{k+1};
        dodist=1;
	 otherwise
		error(['[Unknown option ''', varargin{k}, '''.']) ;             
  end
end
 
% --------------------------------------------------------------------
%                                                           Do the job
% --------------------------------------------------------------------

[M1,N1,K1]=size(I1) ;
[M2,N2,K2]=size(I2) ;

switch stack
  case 'h'
    N3=N1+N2 ;
    M3=max(M1,M2) ;
    oj=N1 ;
    oi=0 ;
  case 'v'
    M3=M1+M2 ;
    N3=max(N1,N2) ;
    oj=0 ;
    oi=M1 ;    
  case 'd'
    M3=M1+M2 ;
    N3=N1+N2 ;
    oj=N1 ;
    oi=M1 ;
  case 'o'
    M3=max(M1,M2) ;
    N3=max(N1,N2) ;
    oj=0;
    oi=0;
  otherwise
    error(['Unkown stacking type '''], stack, ['''.']) ;
end

% Combine the two images. In most cases just place one image next to
% the other. If the stacking is 'o', however, combine the two images
% linearly.
I=zeros(M3,N3,K1) ;
if stack ~= 'o'
	I(1:M1,1:N1,:) = I1 ;
	I(oi+(1:M2),oj+(1:N2),:) = I2 ;
else
	I(oi+(1:M2),oj+(1:N2),:) = I2 ;
	I(1:M1,1:N1,:) = I(1:M1,1:N1,:) + I1 ;
	I(1:min(M1,M2),1:min(N1,N2),:) = 0.5 * I(1:min(M1,M2),1:min(N1,N2),:) ;
end

axes('Position', [0 0 1 1]) ;
imagesc(I) ; colormap gray ; hold on ; axis image ; axis off ;

% K = size(P1, 2) ;
%K = size(matches, 2) ;
% nans = NaN * ones(1,K) ;

x = [ P1(1,:)' ; P2(1,:)'+oj] ;
y = [ P1(2,:)' ; P2(2,:)'+oi] ;
%x = [ P1(1,matches(1,:)) ; P2(1,matches(2,:))+oj ; nans ] ;
%y = [ P1(2,matches(1,:)) ; P2(2,matches(2,:))+oi ; nans ] ;

% if interactive > 1 we do not drive lines, but just points.
%if(interactive > 1)
	h = plot(x(:),y(:),'g.') ;
%else
%	h = line(x(:)', y(:)') ;
%end
set(h,'Marker','.','Color','g') ;

% --------------------------------------------------------------------
%                                                          Interactive
% --------------------------------------------------------------------

%if(~interactive || interactive==3), return ; end

%sel1 = unique(matches(1,:)) ;
%sel2 = unique(matches(2,:)) ;

K1 = size(P1,2) ;
K2 = size(P2,2) ;
%K1 = length(sel1) ; %size(P1,2) ;
%K2 = length(sel2) ; %size(P2,2) ;
X = [ P1(1,:) P2(1,:)+oj ;
			P1(2,:) P2(2,:)+oi ; ] ;
%X = [ P1(1,sel1) P2(1,sel2)+oj ;
%			P1(2,sel1) P2(2,sel2)+oi ; ] ;

fig = gcf ;
is_hold = ishold ;
hold on ;

% save the handlers for later to restore --------| define the interactive function|
dhandler = get(fig,'WindowButtonDownFcn') ;
uhandler = get(fig,'WindowButtonUpFcn') ;
mhandler = get(fig,'WindowButtonMotionFcn') ;
khandler = get(fig,'KeyPressFcn') ;
pointer  = get(fig,'Pointer') ;

set(fig,'KeyPressFcn',        @key_handler) ;
set(fig,'WindowButtonDownFcn',@click_down_handler) ;
set(fig,'WindowButtonUpFcn',  @click_up_handler) ;
set(fig,'Pointer','crosshair') ;
% --------------------------------------------------------------------------------

data.exit        = 0 ;   % signal exit to the interactive mode
data.selected    = [] ;  % currently selected feature
data.X           = X ;   % feature anchors

highlighted = [] ;       % currently highlighted feature
hh = [] ;                % hook of the highlight plot

guidata(fig,data) ;
while ~ data.exit
  uiwait(fig) ;
  data = guidata(fig) ;
	if(any(size(highlighted) ~= size(data.selected)) || ...
		 any(highlighted ~= data.selected) ) 

		highlighted = data.selected ;

		% delete previous highlight
		if( ~isempty(hh) )
			delete(hh) ;
		end

		hh=[] ;
		
		% each selected feature uses its own color
		c=1 ;
		colors=[1.0 0.0 0.0 ;
						0.0 1.0 0.0 ;
						0.0 0.0 1.0 ;
					  1.0 1.0 0.0 ;
					  0.0 1.0 1.0 ;
					  1.0 0.0 1.0 ] ;
		
		% more than one feature might be seleted at one time...
		for this=highlighted
% -------------------------------------------------------------------------------------------			

			% find matches
			if( this <= K1 ) 
				sele = this ;
                % --------Min-------
                disp('Matches selected Index');
			    sele
                % ------------------
				%sel=find(matches(1,:)== sel1(this));
		if FlagRotate
	                ConSSel = ConS1(:,sele)+[oj; oi; oj; oi; oj; oi; oj; oi];
		else
	                ConSSel = ConS1(:,sele)+[oj; oj; oi; oi];
        end
                % --------- Max and Min Point
                disp('MaxD1');
                MaxD1(sele)
                x1_2Max(:,sele)
                disp('MinD1');
                MinD1(sele)
                x1_2Min(:,sele)
                xMaxSel = round(x1_2Max(:,sele))+[oj; oi];
                xMinSel = round(x1_2Min(:,sele))+[oj; oi];
                % ---------------------------
                Point_sel = P1(1:2,sele);
				l1 = F*P1(:,sele);
				% try four combination to find 2 point
				q = 1;
 				% x biggest case
				y_cand(q) = (-l1(3) - l1(1)*N1)/l1(2);
				if (y_cand(q) <= M2) && (y_cand(q) >= 1)
					x_cand(q) = N1;
					q = q+1;
				end
 				% x smallest case
				y_cand(q) = (-l1(3) - l1(1)*1)/l1(2);
				if (y_cand(q) <= M2) && (y_cand(q) >= 1)
					x_cand(q) = 1;
					q = q+1;
				end
 				% y biggest case
				x_cand(q) = (-l1(3) - l1(2)*M1)/l1(1);
				if (x_cand(q) <= N2) && (x_cand(q) >= 1)
					y_cand(q) = M1;
					q = q+1;
				end
 				% y smallest case
				x_cand(q) = (-l1(3) - l1(2)*1)/l1(1);
				if (x_cand(q) <= N2) && (x_cand(q) >= 1)
					y_cand(q) = 1;
					q = q+1;
				end
				if size(x_cand,2) > size(y_cand,2)
                    x_cand(end) = [];
                elseif size(x_cand,2) < size(y_cand,2)
                    y_cand(end) = [];
                end
                x_cand = x_cand+oj;
                y_cand = y_cand+oi;
            else % -------------------( this > K1 ) 
                sele = this - K1;
                % --------Min-------
                disp('Matches selected Index');
			    sele
                % ------------------				
                Point_sel = P2(1:2,sele) + [oj; oi];
		        K=length(sele);
                sele = sele(1);
		        ConSSel = ConS2(:,sele);   
                % --------- Max and Min Point
                disp('MaxD1');
                MaxD2(sele)
                x2_1Max(:,sele)
                disp('MinD1');
                MinD2(sele)
                x2_1Min(:,sele)
                xMaxSel = round(x2_1Max(:,sele));
                xMinSel = round(x2_1Min(:,sele));
                % ---------------------------
				l2 = F'*P2(:,sele);
 				% x biggest case
                q = 1;
				y_cand(q) = (-l2(3) - l2(1)*N2)/l2(2);
				if (y_cand(q) <= M1) && (y_cand(q) >= 1)
					x_cand(q) = N2;
					q = q+1;
				end
 				% x smallest case
				y_cand(q) = (-l2(3) - l2(1)*1)/l2(2);
				if (y_cand(q) <= M1) && (y_cand(q) >= 1)
					x_cand(q) = 1;
					q = q+1;
				end
 				% y biggest case
				x_cand(q) = (-l2(3) - l2(2)*M2)/l2(1);
				if (x_cand(q) <= N1) && (x_cand(q) >= 1)
					y_cand(q) = M2;
					q = q+1;
				end
 				% y smallest case
				x_cand(q) = (-l2(3) - l2(2)*1)/l2(1);
				if (x_cand(q) <= N1) && (x_cand(q) >= 1)
					y_cand(q) = 1;
					q = q+1;
                end
                if size(x_cand,2) > size(y_cand,2)
                    x_cand(end) = [];
                elseif size(x_cand,2) < size(y_cand,2)
                    y_cand(end) = [];
                end
				%sel=find(matches(2,:)== sel2(this-K1)) ;
			end				
			if(dodist)
                        	d=dist(sele)
            end

			% plot matches
		if FlagRotate	
			x = [ ConSSel(1) ConSSel(3) ConSSel(5) ConSSel(7) ConSSel(1)];
   			y = [ ConSSel(2) ConSSel(4) ConSSel(6) ConSSel(8) ConSSel(2)];
		else
			x = [ ConSSel(2) ConSSel(1) ConSSel(1) ConSSel(2) ConSSel(2)];
   			y = [ ConSSel(4) ConSSel(4) ConSSel(3) ConSSel(3) ConSSel(4)];
		end
			%x = [ P1(1,matches(1,sel)) ; P2(1,matches(2,sel))+oj ; nan*ones(1,K) ] ;
			%y = [ P1(2,matches(1,sel)) ; P2(2,matches(2,sel))+oi ; nan*ones(1,K) ] ;
			
            if q >= 3
                % draw epiploar line and selected features
    			hh = [hh line(x(:)', y(:)',...
										'Marker','*',...
										'Color',colors(c,:),...
                    						'LineWidth',3)...
                      line(x_cand(:)', y_cand(:)',...
                                                                                'Marker','*',...
                                                                                'Color',colors(c+5,:),...
                                                                                'LineWidth',1)...
                      scatter(Point_sel(1), Point_sel(2), 4,'r')...                                     
                      scatter(xMinSel(1), xMinSel(2), 50,'y')...% --------plot xMaxSel and xMinSel------   
                      scatter(xMaxSel(1), xMaxSel(2), 50,'b')];
                    % --------------------------------------
            else   
                hh = [hh line(x(:)', y(:)',...
										'Marker','*',...
										'Color',colors(c,:),...
                    						'LineWidth',3)];
            end    
		
			if( size(P1,1) == 4 )
				f1 = unique(P1(:,matches(1,sel))','rows')' ;
				hp=plotsiftframe(f1);
				set(hp,'Color',colors(c,:)) ;
				hh=[hh hp] ; 
			end
			
			if( size(P2,1) == 4 )
				f2 = unique(P2(:,matches(2,sel))','rows')' ;
				f2(1,:)=f2(1,:)+oj ;
				f2(2,:)=f2(2,:)+oi ;
				hp=plotsiftframe(f2);
				set(hp,'Color',colors(c,:)) ;
				hh=[hh hp] ; 
			end
			
			c=c+1;
% -------------------------------------------------------------------------------------------
		end
		
		drawnow ;
	end
end

if( ~isempty(hh) )
	delete(hh) ;
end

if ~is_hold
  hold off ;  
end

set(fig,'WindowButtonDownFcn',  dhandler) ;
set(fig,'WindowButtonUpFcn',    uhandler) ;
set(fig,'WindowButtonMotionFcn',mhandler) ;
set(fig,'KeyPressFcn',          khandler) ;
set(fig,'Pointer',              pointer ) ;

% ====================================================================
function data=selection_helper(data)
% --------------------------------------------------------------------
P = get(gca, 'CurrentPoint') ;
P = [P(1,1); P(1,2)] ;

d = (data.X(1,:) - P(1)).^2 + (data.X(2,:) - P(2)).^2 ;
dmin=min(d) ;
idx=find(d==dmin) ;

data.selected = idx ;

% ====================================================================
function click_down_handler(obj,event)
% --------------------------------------------------------------------
% select a feature and change motion handler for dragging

[obj,fig]=gcbo ;
data = guidata(fig) ;
data.mhandler = get(fig,'WindowButtonMotionFcn') ;
set(fig,'WindowButtonMotionFcn',@motion_handler) ;
data = selection_helper(data) ;
guidata(fig,data) ;
uiresume(obj) ;

% ====================================================================
function click_up_handler(obj,event)
% --------------------------------------------------------------------
% stop dragging

[obj,fig]=gcbo ;
data = guidata(fig) ;
set(fig,'WindowButtonMotionFcn',data.mhandler) ;
guidata(fig,data) ;
uiresume(obj) ;

% ====================================================================
function motion_handler(obj,event)
% --------------------------------------------------------------------
% select features while dragging

data = guidata(obj) ;
data = selection_helper(data); 
guidata(obj,data) ;
uiresume(obj) ;

% ====================================================================
function key_handler(obj,event)
% --------------------------------------------------------------------
% use keypress to exit

data = guidata(gcbo) ;
data.exit = 1 ;
guidata(obj,data) ;
uiresume(gcbo) ;

