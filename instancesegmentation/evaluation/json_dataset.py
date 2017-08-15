from pycocotools.coco import COCO


class JsonDataset(object):
	def __init__(self, dset_json):
		self.COCO = COCO(dset_json)
		category_ids = self.COCO.getCatIds()
		categories = [x['name'] for x in self.COCO.loadCats(category_ids)]
		self.category_to_id_map = dict(zip(categories, category_ids))
		self.classes = ['__background__'] + categories
		self.num_classes = len(self.classes)