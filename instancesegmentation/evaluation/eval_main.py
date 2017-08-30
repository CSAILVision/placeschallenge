# Evaluation demo for places instance segmentation challenge
# Our evaluation follow the COCO instance segmentation criterion
# Before running this script:
# 1. encode annotations(*.png) into RLE format (.json) 
# 	 by running convert_anns_to_json_dataset.py;
# 2. detection results should also be saved as RLE format (.json)

import os
import argparse
import sys
from evaluator import InstanceEvaluator


def parse_args():
	parser = argparse.ArgumentParser(description='Evaluation demo')
	parser.add_argument('--dataset_json', default='./instance_validation_gts.json')
	parser.add_argument('--preds_json', default='./instance_validation_preds.json')

	args = parser.parse_args()
	return args


def eval(args):
	evaluator = InstanceEvaluator(args.dataset_json, args.preds_json)
	evaluator.evaluate()
	evaluator.summarize()


if __name__ == '__main__':
	args = parse_args()
	eval(args)