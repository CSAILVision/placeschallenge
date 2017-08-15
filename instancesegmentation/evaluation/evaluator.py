import numpy as np
from pycocotools.cocoeval import COCOeval


class InstanceEvaluator(object):
	def __init__(self, dataset, preds_json):
		self.dataset = dataset
		self.preds = self.dataset.COCO.loadRes(preds_json)
		self.coco_eval = COCOeval(dataset.COCO, self.preds, 'segm')
		self.coco_eval.params.maxDets = [1, 50, 256]

	def evaluate(self):
		self.coco_eval.evaluate()
		self.coco_eval.accumulate()

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
		print('MeanAP: {}'.format(ap_mean))

	def _summarize(self, ap=1, iouThr=None, areaRng='all', maxDets=256):
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