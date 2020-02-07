In order to use this package, one should install it with pip. To do so, first navigate to this directory.

```pip install -r requirements.txt```

The use of a virtual environment is strongly recommended.
https://docs.python-guide.org/dev/virtualenvs/

to begin, use these commands:
```pip install virtualenv
virtualenv my_environment_name```

on windows:
```my_environment_name\Scripts\activate```

on unix:
```source venv\bin\activate```

Once the virtual environment is activated and the atlas_scorer package is installed, you should
have access to the packages listed in requirements.txt, as well as the atlas scorer package. You
can test the install by using
```python examples\test_decl_creation.py```

Examples for how to create .decl files are in ```python examples\test_decl_creation.py```, examples for how to score
are in the documentation for the Scorer() object (score.py), and an example is in

```python examples\test_scoring.py```