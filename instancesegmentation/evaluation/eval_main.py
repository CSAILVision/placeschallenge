# Evaluation demo for places instance segmentation challenge
# Our evaluation follow the COCO instance segmentation criterion
# Before running this script:
# 1. encode annotations(*.png) into RLE format (.json);
# 2. detections should also be saved as RLE format (.json)

import pdb
import os
import argparse
import sys
from json_dataset import JsonDataset
from evaluator import InstanceEvaluator


def parse_args():
	parser = argparse.ArgumentParser(description='Evaluation demo')
	parser.add_argument('--dataset_json', default='./instance_validation_gts.json')
	parser.add_argument('--preds_json', default='./instance_validation_preds.json')

	args = parser.parse_args()
	return args


def eval(args):
	dataset = JsonDataset(args.dataset_json)
	evaluator = InstanceEvaluator(dataset, args.preds_json)
	evaluator.evaluate()
	evaluator.summarize()


if __name__ == '__main__':
	args = parse_args()
	eval(args)