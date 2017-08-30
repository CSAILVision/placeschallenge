# This script includes the evaluator for instance segmentation challenge
# it works with COCO evaluator

import numpy as np
from pycocotools.coco import COCO
from pycocotools.cocoeval import COCOeval


class InstanceEvaluator(object):
	def __init__(self, dataset_json, preds_json):
		# load dataset ground truths
		self.dataset = COCO(dataset_json)
		category_ids = self.dataset.getCatIds()
		categories = [x['name'] for x in self.dataset.loadCats(category_ids)]
		self.category_to_id_map = dict(zip(categories, category_ids))
		self.classes = ['__background__'] + categories
		self.num_classes = len(self.classes)

		# load predictions
		self.preds = self.dataset.loadRes(preds_json)
		self.coco_eval = COCOeval(self.dataset, self.preds, 'segm')
		self.coco_eval.params.maxDets = [1, 50, 255]

	def evaluate(self):
		self.coco_eval.evaluate()
		self.coco_eval.accumulate()

	def _summarize(self, ap=1, iouThr=None, areaRng='all', maxDets=255):
		p = self.coco_eval.params
		iStr = ' {:<18} {} @[ IoU={:<9} | area={:>6s} | maxDets={:>3d} ] = {:0.3f}'
		titleStr = 'Average Precision' if ap == 1 else 'Average Recall'
		typeStr = '(AP)' if ap==1 else '(AR)'
		iouStr = '{:0.2f}:{:0.2f}'.format(p.iouThrs[0], p.iouThrs[-1]) \
		if iouThr is None else '{:0.2f}'.format(iouThr)

		aind = [i for i, aRng in enumerate(p.areaRngLbl) if aRng == areaRng]
		mind = [i for i, mDet in enumerate(p.maxDets) if mDet == maxDets]
		if ap == 1:
			# dimension of precision: [TxRxKxAxM]
			s = self.coco_eval.eval['precision']
			# IoU
			if iouThr is not None:
				t = np.where(iouThr == p.iouThrs)[0]
				s = s[t]
			s = s[:,:,:,aind,mind]
		else:
			# dimension of recall: [TxKxAxM]
			s = self.coco_eval.eval['recall']
			if iouThr is not None:
				t = np.where(iouThr == p.iouThrs)[0]
				s = s[t]
			s = s[:,:,aind,mind]
		if len(s[s>-1])==0:
			mean_s = -1
		else:
		    mean_s = np.mean(s[s>-1])
		print(iStr.format(titleStr, typeStr, iouStr, areaRng, maxDets, mean_s))
		return mean_s

	def summarize(self, IoU_lo_thres=0.5, IoU_hi_thres=0.95):
		def _get_thr_ind(thr):
			ind = np.where((self.coco_eval.params.iouThrs > thr - 1e-5) &
						   (self.coco_eval.params.iouThrs < thr + 1e-5))[0][0]
			iou_thr = self.coco_eval.params.iouThrs[ind]
			assert np.isclose(iou_thr, thr)
			return ind

		ind_lo = _get_thr_ind(IoU_lo_thres)
		ind_hi = _get_thr_ind(IoU_hi_thres)

		# (iou, recall, cls, area, max_dets)
		precision = self.coco_eval.eval['precision'][ind_lo:(ind_hi + 1), :, :, 0, 2]
		ap_mean = np.mean(precision[precision > -1])
		print('* MeanAP: {}'.format(ap_mean))

		print('* Performance by class:')
		ap_by_class = []
		for cls_ind, cls_name in enumerate(self.classes):
			if cls_name == '__background__':
				continue
			cls_precision = self.coco_eval.eval['precision'][ind_lo: (ind_hi + 1), :, cls_ind - 1, 0, 2]
			cls_ap = np.mean(cls_precision[cls_precision > -1])
			ap_by_class.append(cls_ap)
			print('{}, AP: {}'.format(cls_name, cls_ap))
		ap_by_class = np.asarray(ap_by_class)

		print('* Performance at different thresholds:')
		ap_by_thres = np.zeros((12,))
		ap_by_thres[0] = self._summarize(1)
		ap_by_thres[1] = self._summarize(1, iouThr=.5, maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[2] = self._summarize(1, iouThr=.75, maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[3] = self._summarize(1, areaRng='small', maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[4] = self._summarize(1, areaRng='medium', maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[5] = self._summarize(1, areaRng='large', maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[6] = self._summarize(0, maxDets=self.coco_eval.params.maxDets[0])
		ap_by_thres[7] = self._summarize(0, maxDets=self.coco_eval.params.maxDets[1])
		ap_by_thres[8] = self._summarize(0, maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[9] = self._summarize(0, areaRng='small', maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[10] = self._summarize(0, areaRng='medium', maxDets=self.coco_eval.params.maxDets[2])
		ap_by_thres[11] = self._summarize(0, areaRng='large', maxDets=self.coco_eval.params.maxDets[2])
		return ap_mean, ap_by_class, ap_by_thres