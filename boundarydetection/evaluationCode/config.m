SBDopts.datasetpath='~/semantic_contours/benchmark/new_dataset/';
SBDopts.path=fullfile(SBDopts.datasetpath,'cls/%s.mat');
%SBDopts.val_path=fullfile(SBDopts.datasetpath,'%d/val/%s.mat');
SBDopts.train_list=fullfile(SBDopts.datasetpath,'train.txt');
SBDopts.val_list=fullfile(SBDopts.datasetpath,'val.txt');

