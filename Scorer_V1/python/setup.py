from setuptools import find_packages, setup
setup(
    name='atlas_scorer',
    version='0.0.1',
    author='CoVar Applied Technologies',
    author_email='team@covar.com',
    url='http://www.covar.com/',
    description='ATLAS Scorer',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    license='Government Purpose Rights',
    python_requires='>=3.6',
    install_requires=[
        'marshmallow >= 3.0.0rc9',
        'numpy >= 1.17.0',
        'pandas >= 0.25.0',
        'matplotlib >= 3.1.1',
    ],
)
