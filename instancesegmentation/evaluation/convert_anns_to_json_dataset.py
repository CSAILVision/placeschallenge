# This script converts image annotations in a val/test into a RLE format json dataset 

import os
import glob
import argparse
import json
import numpy as np
from scipy.misc import imread
from pycocotools import mask as COCOmask


def parse_args():
	parser = argparse.ArgumentParser(description='Evaluation demo')
	parser.add_argument('--ann_dir', default='annotations_instance/validation') # CHANGE ACCORDINGLY
	parser.add_argument('--imgCatIdsFile', default='../imgCatIds.json')
	parser.add_argument('--output_json', default='./instance_validation_gts2.json')
	
	args = parser.parse_args()
	return args


def convert(args):
	data_dict = json.load(open(args.imgCatIdsFile, 'r'))
	img2id = {x['file_name']: x['id'] 
			 for x in data_dict['images']}

	annotations = []
	ann_id = 0
	# loop over annotation files
	files_ann = sorted(glob.glob(os.path.join(args.ann_dir, '*.png')))
	for i, file_ann in enumerate(files_ann):
		if i % 50 == 0:
			print('#files processed: {}'.format(i))

		ann_mask = imread(file_ann)
		img_id = img2id[os.path.basename(file_ann).replace('.png', '.jpg')]
		Om = ann_mask[:, :, 0]
		Oi = ann_mask[:, :, 1]

		# loop over instances
		for instIdx in np.unique(Oi):
			if instIdx == 0:
				continue
			imask = (Oi == instIdx)
			cat_id = Om[imask][0]

			# RLE encoding
			rle = COCOmask.encode(np.asfortranarray(imask.astype(np.uint8)))

			ann = {}
			ann['id'] = ann_id
			ann_id += 1
			ann['image_id'] = img_id
			ann['segmentation'] = rle
			ann['category_id'] = int(cat_id)
			ann['iscrowd'] = 0
			ann['area'] = np.sum(imask)
			annotations.append(ann)

	data_dict['annotations'] = annotations
	print('#files: {}, #instances: {}'.format(len(files_ann), len(annotations)))

	with open(args.output_json, 'w') as f:
		json.dump(data_dict, f)


if __name__ == '__main__':
	args = parse_args()
	convert(args)