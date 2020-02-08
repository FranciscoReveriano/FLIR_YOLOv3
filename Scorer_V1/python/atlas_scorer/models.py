from abc import ABC, abstractmethod

from Scorer_V1.python.atlas_scorer.errors import AtlasScorerError

_shape_registry = {}


class Shape(ABC):
    SHAPE_TYPE = None

    def __init_subclass__(cls, **kwargs):
        """Register all derived Shape types."""
        super().__init_subclass__(**kwargs)

        if cls.SHAPE_TYPE is None:
            raise NotImplementedError

        if cls.SHAPE_TYPE not in _shape_registry:
            _shape_registry[cls.SHAPE_TYPE] = cls

    @abstractmethod
    def __init__(self, data):
        self.data = data

    @classmethod
    def factory(cls, shape_type, shape_data):
        if shape_type is None:
            return None

        shape_subcls = _shape_registry.get(shape_type, None)

        if shape_subcls is not None:
            return shape_subcls(shape_data)

        return None

    @abstractmethod
    def center(self):
        raise NotImplementedError

    @abstractmethod
    def inside(self, point):
        raise NotImplementedError


class BBOX(Shape):
    SHAPE_TYPE = 'bbox_xywh'

    def __init__(self, data):
        super().__init__(data)

    def __repr__(self):
        return f'BBOX({str(self.data)})'

    @property
    def x(self):
        return self.data[0]

    @property
    def y(self):
        return self.data[1]

    @property
    def w(self):
        return self.data[2]

    @property
    def h(self):
        return self.data[3]

    def center(self):
        return (
            self.x + self.w / 2.0,
            self.y + self.h / 2.0
        )

    def inside(self, point):
        return (self.x <= point[0] <= (self.x + self.w) and
                self.y <= point[1] <= (self.y + self.h))


class DescriptorCommon(ABC):
    @abstractmethod
    def __init__(self, shape, obj_class, userData=None, tags=None, uid=None,
                 range=None, aspect=None):
        if not isinstance(shape, Shape):
            raise AtlasScorerError('shape must be of type Shape.')

        self.shape = shape
        self.obj_class = obj_class
        self.userData = userData or {}
        self.tags = tags or []
        self.uid = uid
        self.range = range
        self.aspect = aspect


class Annotation(DescriptorCommon):
    def __init__(self, shape, obj_class, userData=None, tags=None, uid=None,
                 range=None, aspect=None, **kwargs):
        super().__init__(shape, obj_class, userData, tags, uid, range, aspect)


class Declaration(DescriptorCommon):
    def __init__(self, shape, obj_class, confidence, userData=None, tags=None,
                 uid=None, range=None, aspect=None, **kwargs):
        super().__init__(shape, obj_class, userData, tags, uid, range, aspect)

        self.confidence = confidence


class Frame(ABC):
    DESCRIPTOR_TYPE = None

    @abstractmethod
    def __init__(self, num=None, tags=None):
        self.num = num
        self.tags = tags or []

    @property
    @abstractmethod
    def _data_vec(self):
        raise NotImplementedError

    def add(self, data):
        if not isinstance(data, self.DESCRIPTOR_TYPE):
            raise AtlasScorerError(f'data must be of type {self.DESCRIPTOR_TYPE}.')

        self._data_vec.append(data)


class FrameAnnotation(Frame):
    DESCRIPTOR_TYPE = Annotation

    def __init__(self, num=None, annotations=None, tags=None, **kwargs):
        super().__init__(num, tags)

        self.annotations = annotations or []

    @property
    def _data_vec(self):
        return self.annotations


class FrameDeclaration(Frame):
    DESCRIPTOR_TYPE = Declaration

    def __init__(self, num=None, declarations=None, tags=None, **kwargs):
        super().__init__(num, tags)

        self.declarations = declarations or []

    @property
    def _data_vec(self):
        return self.declarations


class AtlasCommon:
    REQUIRED_VERSION = None
    FRAME_DESCRIPTOR_TYPE = None

    def __init__(self, uid, userData=None, tags=None):
        self.uid = uid
        self.userData = userData or {}
        self.tags = tags or []

    @property
    @abstractmethod
    def _frame_data(self):
        raise NotImplementedError

    def add_frame(self, data, frame_num=None):
        if not isinstance(data, self.FRAME_DESCRIPTOR_TYPE):
            raise AtlasScorerError(
                f'data must be of type {self.FRAME_DESCRIPTOR_TYPE}.')

        num = frame_num if data.num is None else data.num

        if not isinstance(num, int):
            raise AtlasScorerError('Integer frame number is required to add frame.')

        key = f'f{num}'
        self._frame_data[key] = data


class AtlasTruth(AtlasCommon):
    REQUIRED_VERSION = '0.0.1'
    FRAME_DESCRIPTOR_TYPE = FrameAnnotation

    def __init__(self, uid, collection, startTime, stopTime, nFrames,
                 frameAnnotations=None, userData=None, tags=None,
                 staticFov=None, **kwargs):
        super().__init__(uid, userData, tags)

        self.collection = collection
        self.startTime = startTime
        self.stopTime = stopTime
        self.nFrames = nFrames
        self.frameAnnotations = frameAnnotations or {}
        self.staticFov = staticFov

    @property
    def _frame_data(self):
        return self.frameAnnotations


class AtlasDecl(AtlasCommon):
    REQUIRED_VERSION = '0.0.1'
    FRAME_DESCRIPTOR_TYPE = FrameDeclaration

    def __init__(self, uid, source, frameDeclarations=None, userData=None,
                 tags=None, **kwargs):
        super().__init__(uid, userData, tags)

        self.source = source
        self.frameDeclarations = frameDeclarations or {}

    @property
    def _frame_data(self):
        return self.frameDeclarations
