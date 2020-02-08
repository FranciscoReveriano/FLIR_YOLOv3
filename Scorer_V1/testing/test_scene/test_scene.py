import sys
import os
import matplotlib.pyplot as plt

from Scorer_V1.python.atlas_scorer.score import Scorer

## 1
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'],
                     validate_inputs=True)
scorer.link()
conf_labels = scorer.aggregate()
print("%%%%%%%")
print("scorer.aggregate()")
print("%%%%%%%")
print(f'detection conf_labels: {conf_labels}')

## 2
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()
print("%%%%%%%")
print("scorer.aggregate(alg='identification')")
print("%%%%%%%")
conf_labels = scorer.aggregate(alg='identification')
print(f'identification conf_labels: {conf_labels}')

# 3
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.aggregate(alg='detection')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
conf_labels = scorer.aggregate(alg='detection')
print(f'detection conf_labels: {conf_labels}')

## 4
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.aggregate(alg='identification')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
conf_labels = scorer.aggregate(alg='identification')
print(f'identification conf_labels: {conf_labels}')

## 5
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'")
print("scorer.aggregate(alg='detection')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'
conf_labels = scorer.aggregate(alg='detection')
print(f'detection conf_labels: {conf_labels}')


## 6
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'")
print("scorer.aggregate(alg='identification')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'
conf_labels = scorer.aggregate(alg='identification')
print(f'identification conf_labels: {conf_labels}')

## 7
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'")
print("scorer.aggregate(alg='detection')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'
conf_labels = scorer.aggregate(alg='detection', score_class='tree')
print(f'detection conf_labels: {conf_labels}')

## 8
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'")
print("scorer.aggregate(alg='detection')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'
conf_labels = scorer.aggregate(alg='detection', score_class='sky')
print(f'identification conf_labels: {conf_labels}')

## 9
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'")
print("scorer.aggregate(alg='identification')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'
conf_labels = scorer.aggregate(alg='identification', score_class='tree')
print(f'identification conf_labels: {conf_labels}')

## 10
scorer = Scorer()
scorer = scorer.load([r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json'],
                     [r'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json'])
scorer.link()

print("%%%%%%%")
print("scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'")
print("scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'")
print("scorer.aggregate(alg='detection')")
print("%%%%%%%")
scorer.annotation_binary_label_function = lambda x: x['class'] == 'car'
scorer.annotation_ignorable_function = lambda x: x['class'] == 'tree'
conf_labels = scorer.aggregate(alg='identification', score_class='sky')
print(f'identification conf_labels: {conf_labels}')