from pprint import pprint

from Scorer_V1.python.atlas_scorer.models import AtlasDecl, BBOX, Declaration, FrameDeclaration
from Scorer_V1.python.atlas_scorer.schemas import AtlasDeclSchema

# Example of creating declarations and serializing.

d = AtlasDecl('some_uid', 'some_source',
              userData={'algo': 'my_cool_algo', 'version': '0.0.1'})

# Add a single declaration for frame #1.
fd = FrameDeclaration(num=1)
fd.add(Declaration(BBOX([1, 2, 3, 4]), 'PICKUP', 0.1, range=25.4))
d.add_frame(fd)

# Add two declarations for frame #2.
fd = FrameDeclaration(num=2)
fd.add(Declaration(BBOX([5, 6, 7, 8]), 'PICKUP', 0.9))
fd.add(Declaration(BBOX([50, 60, 70, 80]), 'CAR', 0.2, tags=['sedan', 'red'],
                   userData={'foo': 'bar'}))
d.add_frame(fd)

# Serialize AtlasDecl object to Python dict and print it.
pprint(AtlasDeclSchema().dump(d))

# Now serialize AtlasDecl object to JSON and confirm that we can successfully
# deserialize back into a AtlasDecl object.
json_data = AtlasDeclSchema().dumps(d)
AtlasDeclSchema().loads(json_data)