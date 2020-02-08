"""Module for handling annotation and declaration schemas.
Primarily uses the marshmallow package for validating, reading
and writing atlas objects.
"""

import csv
import os
from collections import OrderedDict, defaultdict

import numpy as np
from marshmallow import Schema, fields, missing, post_dump, post_load, pre_dump
from marshmallow import validate as mm_validate, validates as mm_validates

import Scorer_V1.python.atlas_scorer.models as models
from Scorer_V1.python.atlas_scorer.errors import AtlasScorerError, AtlasScorerDeserializationError


class BaseSchema(Schema):
    """Minor modifications to the schema class for ATLAS."""
    __model__ = None

    def _remove_empty_fields(self, obj, **kwargs):
        """Avoid dumping empty fields."""

        for name, field in self.fields.items():
            if not field.required:
                obj_data = getattr(obj, name, missing)

                if obj_data is None or obj_data == {} or obj_data == []:
                    setattr(obj, name, missing)
                    
        return obj

    def handle_error(self, exc, data, **kwargs):
        raise AtlasScorerError(exc)

    @pre_dump
    def _pre_dump_hook(self, obj, **kwargs):
        return self._remove_empty_fields(obj)

    @post_load
    def make_object(self, data, **kwargs):
        return self.__model__(**data)


class OrderedDictField(fields.Mapping):
    mapping_type = OrderedDict


class ShapeSchema(BaseSchema):
    shapeType = fields.String(required=True, load_only=True, data_key='type',
                              validate=mm_validate.OneOf(
                                  models._shape_registry.keys()))
    data = fields.Raw(required=True)
    
    class Meta:
        fields = ('shapeType', 'data')
        ordered = True
        
    @post_load
    def make_object(self, data, **kwargs):
        obj = models.Shape.factory(data['shapeType'], data['data'])

        if obj is not None:
            return obj
        else:
            # This should never happen due to validation on shapeType, but just
            # in case...
            raise AtlasScorerDeserializationError(
                f'Unsupported shapeType: {data["shapeType"]}.')

    @post_dump(pass_original=True)
    def add_type(self, output, original, **kwargs):
        # Special handling for shapeType.
        output["type"] = original.SHAPE_TYPE
        return output


class DescriptorCommonSchema(BaseSchema):
    obj_class = fields.String(required=True, data_key='class')
    uid = fields.String(allow_none=True)
    range = fields.Float(allow_none=True, allow_nan=True)
    aspect = fields.Float(allow_none=True, allow_nan=True)
    shape = fields.Nested(ShapeSchema, required=True)
    userData = fields.Dict()
    tags = fields.List(fields.String())
    
    class Meta:
        fields = ("obj_class", "uid", "range", "aspect", "shape",
                  "userData", "tags")
        ordered = True


class AnnotationSchema(DescriptorCommonSchema):
    __model__ = models.Annotation


class DeclarationSchema(DescriptorCommonSchema):
    __model__ = models.Declaration

    confidence = fields.Float(required=True, allow_nan=True)

    class Meta:
        fields = ("confidence", *DescriptorCommonSchema().fields.keys())
        ordered = True

class FrameCommonSchema(BaseSchema):
    tags = fields.List(fields.String())


class FrameAnnotationSchema(FrameCommonSchema):
    __model__ = models.FrameAnnotation

    annotations = fields.Nested(AnnotationSchema, required=True, many=True)

    class Meta:
        fields = ("annotations", *FrameCommonSchema().fields.keys())
        ordered = True

class FrameDeclarationSchema(FrameCommonSchema):
    __model__ = models.FrameDeclaration

    declarations = fields.Nested(DeclarationSchema, required=True, many=True)

    class Meta:
        fields = ("declarations", *FrameCommonSchema().fields.keys())
        ordered = True

class AtlasCommonSchema(BaseSchema):
    uid = fields.String(required=True, data_key='fileUID')
    userData = fields.Dict()
    tags = fields.List(fields.String())


class AtlasTruthSchema(AtlasCommonSchema):
    __model__ = models.AtlasTruth

    truthJsonVersion = fields.String(required=True, load_only=True,
                                     validate=mm_validate.Equal(
                                         models.AtlasTruth.REQUIRED_VERSION))
    collection = fields.String(required=True)
    startTime = fields.DateTime(required=True)
    stopTime = fields.DateTime(required=True)
    frameAnnotations = OrderedDictField(
        required=True,
        keys=fields.String(validate=mm_validate.Regexp(r'^f[0-9]+$')),
        values=fields.Nested(FrameAnnotationSchema))
    nFrames = fields.Integer(required=True)
    staticFov = fields.List(fields.Float(), allow_none=True)

    class Meta:
        fields = ("truthJsonVersion", "collection", *AtlasCommonSchema().fields.keys(),
                    "startTime", "stopTime", "nFrames", "staticFov", "frameAnnotations")
        ordered = True

    @mm_validates("staticFov")
    def validate_static_fov(self, value):
        if value is not None:
            if len(value) != 2:
                raise AtlasScorerDeserializationError(
                    'staticFov must contain two elements.')

    @post_dump
    def add_version(self, output, **kwargs):
        output['truthJsonVersion'] = models.AtlasTruth.REQUIRED_VERSION
        return output


class AtlasDeclSchema(AtlasCommonSchema):
    __model__ = models.AtlasDecl

    declJsonVersion = fields.String(required=True, load_only=True,
                                    validate=mm_validate.Equal(
                                        models.AtlasDecl.REQUIRED_VERSION))
    source = fields.String(required=True)
    frameDeclarations = OrderedDictField(
        required=True,
        keys=fields.String(validate=mm_validate.Regexp(r'^f[0-9]+$')),
        values=fields.Nested(FrameDeclarationSchema))
    
    class Meta:
        fields = ("declJsonVersion", "source", *AtlasCommonSchema().fields.keys(),
                  "frameDeclarations")
        ordered = True

    @post_dump
    def add_version(self, output, **kwargs):
        output['declJsonVersion'] = models.AtlasDecl.REQUIRED_VERSION
        return output

    @classmethod
    def load_csv(cls, filename, validate=True, return_dict=False):
        """
        Load declarations from a .csv file

        Args:
            filename (str): CSV filename
            validate (bool, optional): Default is **True**
            return_dict (bool, optional): Whether the returned datastructure is
                a dict or an AtlasScorer model object. If set to ``True``, the
                `validate` flag is forced to True during processing; Defaul **False**

        Returns:
            (AtlasDecl model or dict): Parsed model or dict containing contents
                of CSV decl file
        """
        validate = True if return_dict else validate
        def gen_decl_dict(data):
            bbox_str = data['shape_bbox_xywh']
            if bbox_str[0] != '[' or bbox_str[-1] != ']':
                raise AtlasScorerDeserializationError(
                    'shape_bbox_xywh field in CSV file must be bracketed.')

            try:
                bbox = [float(x) for x in bbox_str[1:-1].split(' ')]
            except ValueError:
                if bbox_str == '[]':
                    # This is the case where we processed a frame, but have no
                    # declarations.  Make a fake bbox to keep things happy.
                    bbox = [np.nan] * 4
                else:
                    raise AtlasScorerDeserializationError(
                        'shape_bbox_xywh field in CSV file can not be parsed.')

            if len(bbox) != 4:
                raise AtlasScorerDeserializationError(
                    'shape_bbox_xywh field in CSV contains incorrect number '
                    'of values.')

            d = dict_func(bbox, data['class'], float(data['confidence']))

            for opt_field in ['range', 'aspect']:
                try:
                    d[opt_field] = float(data[opt_field])
                except KeyError:
                    pass

            return d

        def dict_for_validate(bbox, obj_class, conf):
            return {
                'shape': {
                    'type': 'bbox_xywh',
                    'data': bbox,
                },
                'class': obj_class,
                'confidence': float(conf),
            }

        def dict_for_non_validate(bbox, obj_class, conf):
            return {
                'shape': models.BBOX(bbox),
                'obj_class': obj_class,
                'confidence': float(conf),
            }

        dict_func = dict_for_validate if validate else dict_for_non_validate

        if not os.path.isfile(filename):
            raise AtlasScorerError(f'CSV file {filename} not found.')

        with open(filename, 'r', newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            row = next(reader)

            required_fields = {'fileUID', 'frameIndex', 'source',
                               'shape_bbox_xywh', 'class', 'confidence'}

            missing_fields = required_fields - set(reader.fieldnames)

            if any(missing_fields):
                raise AtlasScorerError(
                    f'CSV file is missing required fields: {missing_fields}.')

            required_uid = row['fileUID']
            required_source = row['source']

            if validate:
                data = defaultdict(lambda: defaultdict(list))
                data[f'f{row["frameIndex"]}']['declarations'].append(
                    gen_decl_dict(row))
            else:
                data = defaultdict(models.FrameDeclaration)
                data[f'f{row["frameIndex"]}'].add(
                    models.Declaration(**gen_decl_dict(row)))

            for row in reader:
                if row['fileUID'] != required_uid:
                    raise AtlasScorerError('CSV file contains multiple fileUID values.')

                if row['source'] != required_source:
                    raise AtlasScorerError('CSV file contains multiple source values.')

                if validate:
                    data[f'f{row["frameIndex"]}']['declarations'].append(
                        gen_decl_dict(row))
                else:
                    data[f'f{row["frameIndex"]}'].add(
                        models.Declaration(**gen_decl_dict(row)))

        if validate:
            d = {
                'declJsonVersion': models.AtlasDecl.REQUIRED_VERSION,
                'fileUID': required_uid,
                'source': required_uid,
                'frameDeclarations': data
            }
            if return_dict:
                return d
            return AtlasDeclSchema().load(d)
        else:
            return models.AtlasDecl(required_uid, required_source, data)

    # TODO Add method to write declarations to CSV
