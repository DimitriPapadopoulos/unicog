%function [names, values] = specif_contrasts(session,condition)
%Specify contrasts to be estimated
%
% This function is being called by lcogn_single_firstlevel.m during
% 'contrasts specification'.
%
% The outputs that this function must provide are:
%   o names:  cell array of strings, each string being the name of the ith
%             contrast defined.
%   o values: cell array of matrices, each matrix being a contrast. A 1xN vector
%             will create a T-contrast while a MxN matrix will create an F-contrast.
%             In all cases, these inputs will be padded with zeros if they
%             are too short compared to the design matrix.
% Of course, the number of items in 'names' and 'values' must be the same.
% Input parameters are provided by specif_model and might help defining
% the contrasts.

% ADAPTATION SPM5-->SPM8 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We specify the contrasts using data from subject 1 (all subjects are
% supposed to have the same structure and the same data for the same value
% of "option" = the first level model)

s = 1;
rootdir = fullfile(root, subjects{s});
funcdir = spm_select('CPath',fullfile('fMRI',sprintf('acquisition%d',acq(s))),rootdir);
%funcfiles = cellstr(spm_select('List',funcdir, sprintf('^swa%s.*.nii$',option)));
funcfiles = cellstr(spm_select('List',funcdir, sprintf('^sw%s.*.nii$',option)));
nrun = size(funcfiles,1);

% We take only first session (run=1) because the number of conditions is
% supposed to be the same for all sessions (runs).
n = 1;
cfile = funcfiles{n};
basename = cfile(3:length(cfile)-4);
%basename = cfile(4:length(cfile)-4); %% AM - 10/08/2012 - To be coherent with the wiki page: "The name of these onset files must be the same as the corresponding EPI files, with an additional suffix. E.g. if the image files are bloc1.nii, bloc2.nii, ... the mat files can be bloc1_model1.mat, bloc2_model1.nii,... This suffix system allows you to generate different models with different events." 
%matfile = spm_select('FPList', fullfile(root,onsets_dir), sprintf('^%s.*.mat$', basename))
%matfile = spm_select('FPList', fullfile(root), sprintf('^%s.*.mat$', basename))
matfile = spm_select('FPList', fullfile(root),'localizer.mat')
mymatfile = load(matfile);
condition = mymatfile.names;

%- Number of sessions
%nbsess = length(unique(session));
nbsess = nrun; % Simplification for SPM8

%- Number of conditions
%nbcond = length(unique(condition));
nbcond = length(unique(cell2mat(condition))); %% AM 11/09/2012 - It is a cell and "unique" works with arrays

% END OF ADAPTATION SPM5-->SPM8 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


names = { 'Horizontal Checkerboard',...
          'Vertical Checkerboard',...
          'Right Audio Click',...
          'Left Audio Click',...
          'Right Video Click',...
          'Left Video Click',...
          'Audio Computation',...
          'Video Computation',...
          'Video Sentences',...
          'Audio Sentences',...
          'Left Click',...
          'Right Click',...
          'Checkerboard',...
          'Motor',...
          'Computation', ...
          'Sentences',...
          'Audio',...
          'Video',...
          'H Checkerboard - V Checkerboard',...
          'V Checkerboard - H Checkerboard',...
          'Left Click - Right Click',...
          'Right Click - Left Click',...
          'Video - Audio',...
          'Audio - Video',...
          'Motor - Cognitive',...
          'Cognitive - Motor',...
          'Audio Computation - Audio Sentences',...
          'Video Computation - Video Sentences',...
          'Computation - Sentences',...
          'Video - Checkerboard',...
          'Video Sentences - Checkerboard',...
	  'Audio Click - Audio Sentences',...
	  'Video Click - Video Sentences',...
          'Effects of interest without time derivative'};

%nbcond = length(unique(condition));

%nbsess = length(unique(session)); % ADAPTATION SPM5-->SPM8

nbderiv = 1; % 0 | 1 | 2

isrp = 0; % 0 | 1

V = [eye(nbcond); zeros(nbderiv*nbcond,nbcond)];
V = reshape(V,nbcond,[]);
V = repmat([V zeros(nbcond,1+isrp*6)],1,nbsess);

values{1}  = V(1,:); % 'Horizontal Checkerboard'
values{2}  = V(2,:); % 'Vertical Checkerboard'
values{3}  = V(3,:); % 'Right Audio Click'
values{4}  = V(4,:); % 'Left Audio Click'
values{5}  = V(5,:); % 'Right Video Click'
values{6}  = V(6,:); % 'Left Video Click'
values{7}  = V(7,:); % 'Audio Computation'
values{8}  = V(8,:); % 'Video Computation'
values{9}  = V(9,:); % 'Video Sentences'
values{10} = V(10,:); % 'Audio Sentences'
values{11} = V(4,:) + V(6,:); % 'Left Click'
values{12} = V(3,:) + V(5,:); % 'Right Click'
values{13} = V(1,:) + V(2,:); % 'Checkerboard'
values{14} = V(4,:) + V(6,:) + V(3,:) + V(5,:); % 'Motor'
values{15} = V(7,:) + V(8,:); % 'Computation'
values{16} = V(9,:) + V(10,:); % 'Sentences'
values{17} = V(3,:) + V(4,:) + V(7,:) + V(10,:); % 'Audio'
values{18} = V(5,:) + V(6,:) + V(8,:) + V(9,:); % 'Video'
values{19} = V(1,:) - V(2,:); % 'H Checkerboard - V Checkerboard'
values{20} = V(2,:) - V(1,:); % 'V Checkerboard - H Checkerboard'
values{21} = V(4,:) + V(6,:) - V(3,:) - V(5,:); % 'Left Click - Right Click'
values{22} = V(3,:) + V(5,:) - V(4,:) - V(6,:); % 'Right Click - Left Click'
values{23} = V(5,:) + V(6,:) + V(8,:) + V(9,:) - V(3,:) - V(4,:) - V(7,:) - V(10,:); % 'Video - Audio'
values{24} = V(3,:) + V(4,:) + V(7,:) + V(10,:) - V(5,:) - V(6,:) - V(8,:) - V(9,:); % 'Audio - Video'
values{25} = V(3,:) + V(4,:) + V(5,:) + V(6,:) - V(7,:) - V(8,:) - V(9,:) - V(10,:); % 'Motor - Cognitive'
values{26} = V(7,:) + V(8,:) + V(9,:) + V(10,:) - V(3,:) - V(4,:) - V(5,:) - V(6,:); % 'Cognitive - Motor'
values{27} = V(7,:) - V(10,:); % 'Audio Computation - Audio Sentences'
values{28} = V(8,:) - V(9,:); % 'Video Computation - Video Sentences'
values{29} = V(7,:) + V(8,:) - V(9,:) - V(10,:); % 'Computation - Sentences'
values{30} = V(5,:) + V(6,:) + V(8,:) + V(9,:) - 2*( V(1,:) + V(2,:) ); % 'Video - Checkerboard'
values{31} = 2 * V(9,:) - V(1,:) - V(2,:); % 'Video Sentences - Checkerboard'
values{32} = V(3,:) + V(4,:) - 2 * V(10,:); % 'Audio Click - Audio Sentences'
values{33} = V(5,:) + V(6,:) - 2 * V(9,:); % 'Video Click - Video Sentences'
values{34} = V; % 'Effects of interest without time derivative'
