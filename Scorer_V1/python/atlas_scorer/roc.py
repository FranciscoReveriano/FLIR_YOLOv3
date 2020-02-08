"""This module handles the ROC class used by the scorer."""

import logging

import matplotlib.pyplot as plt
import numpy as np

from Scorer_V1.python.atlas_scorer.errors import AtlasScorerError


def atlas_score_roc(x, y):
    """
    Generate and ROC object from confidence values (x) and binary labels (y).
    
    :param Iterable x: Confidence values.
    :param Iterable y: Labels containing 0 or 1
    :return: An AtlasMetricROC object.
    :rtype: AtlasMetricROC
    """

    x = np.array(x)
    y = np.array(y)

    unique_y = np.unique(y)

    if x.shape[0] == 0 and y.shape[0] == 0:
        return AtlasMetricROC([], [], [], [], 0, 0)

    if len(unique_y) != 2:
        if (len(unique_y) == 1) and (unique_y[0] == 0 or unique_y[0] == 1):
            log = logging.getLogger(__name__)
            log.warning('Only one class of data was provided; this will result '
                        'in NaN PD or PFA values.')
            unique_y = [0, 1]
        else:
            raise AtlasScorerError('Two unique classes required.')

    if len(x) != len(y):
        raise AtlasScorerError('x and y must be equal length.')

    if set(unique_y) != {0, 1}:
        y[y == unique_y[0]] = 0
        y[y == unique_y[1]] = 1

    sort_idx = np.argsort(x)[::-1]
    sorted_ds = x[sort_idx]
    sorted_y = y[sort_idx]

    nan_spots = np.isnan(sorted_ds)

    # Number of detections as a function of threshold.
    prob_det = np.copy(sorted_y)

    # Number of false alarms as a function of threshold.
    prob_fa = 1 - prob_det

    # Detect and handle ties
    if len(sorted_ds) > 1:
        is_tied_with_next = np.concatenate(
            (sorted_ds[0:-1] == sorted_ds[1:], [False]))
    else:
        is_tied_with_next = [False]

    # If there are any ties we need to figure out the tied regions and set each
    # of the ranks to the average of the tied ranks.
    if any(is_tied_with_next):
        diff_is_tied_with_next = np.diff(is_tied_with_next.astype(np.int),
                                         prepend=int(is_tied_with_next[0]))

        # Start and stop regions of the ties.
        idx1 = np.flatnonzero(diff_is_tied_with_next == 1)
        idx2 = np.flatnonzero(diff_is_tied_with_next == -1) + 1

        # For each tied region we set the first value of PD (or PFA) in the tied
        # region equal to the number of hits (or non-hits) in the range and we
        # set the rest to zero.  This makes sure that when we cumsum (integrate)
        # we get all of the tied values at the same time.
        for s, e in zip(idx1, idx2):
            prob_det[s] = np.sum(prob_det[s:e])
            prob_det[s+1:e] = 0

            prob_fa[s] = np.sum(prob_fa[s:e])
            prob_fa[s+1:e] = 0

    nh1 = sorted_y.sum()
    nh0 = len(sorted_y) - nh1

    # NaNs are not counted as detections or false alarms.
    prob_det[nan_spots & (sorted_y == 1)] = 0
    prob_fa[nan_spots & (sorted_y == 0)] = 0

    prob_det = np.cumsum(prob_det) / nh1
    prob_fa = np.cumsum(prob_fa) / nh0

    prob_det = np.concatenate(([0], prob_det))
    prob_fa = np.concatenate(([0], prob_fa))
    num_fa = prob_fa * nh0

    thresholds = np.concatenate(([np.inf], sorted_ds))

    return AtlasMetricROC(prob_fa, prob_det, num_fa, thresholds, nh1, nh0)


class AtlasMetricROC:
    """ROC object for handling metadata associated with an ROC."""
    def __init__(self, pf, pd, nfa, tau, num_targets, num_non_targets):
        self.pf = pf
        self.pd = pd
        self.nfa = nfa
        self.tau = tau
        self.nTargets = num_targets
        self.nNonTargets = num_non_targets

        self.farDenominator = None

    @property
    def far(self):
        """Far is a dependent property which is just nfa/farDenominator."""
        if self.farDenominator is None:
            return None
        else:
            return self.nfa / self.farDenominator

    @property
    def tp(self):
        """True Positives"""
        return self.pd * self.nTargets

    @property
    def fp(self):
        """False Positives"""
        return self.pf * self.nNonTargets

    @property
    def tn(self):
        """True Negatives"""
        return (1 - self.pf) * self.nNonTargets

    @property
    def fn(self):
        """False Negatives"""
        return (1 - self.pd) * self.nTargets

    @property
    def precision(self):
        return self.tp / (self.tp + self.fp)

    @property
    def recall(self):
        return self.pd

    @property
    def accuracy(self):
        return (self.tp + self.tn) / (self.tp + self.tn + self.fp + self.fn)

    @property
    def f1(self):
        return (2 * self.tp) / (2 * self.tp + self.fp + self.fn)

    @property
    def auc(self):
        return np.trapz(self.pd, self.pf)

    def write_csv(self, csv_file):
        """Write ROC object to file."""
        v = np.column_stack((self.nfa, self.far, self.pd, self.tau))
        np.savetxt(csv_file, v, fmt='%.8f',
                   header="nfa, far, pd, tau", delimiter=',', comments='')

    def _plot_xy(self, x, y, ax=None, title=None, xlabel=None, ylabel=None,
                 label=None, xlim_args=None):
        """Common plotting code to make standard plots"""
        if ax is None:
            fig, ax = plt.subplots(figsize=(8, 6))
        if xlim_args is None:
            xlim_args = {}
        ax.plot(x, y, label=label)
        if ylabel is not None:
            ax.set_ylabel(ylabel)
        if xlabel is not None:
            ax.set_xlabel(xlabel)
        ax.grid(which='both', alpha=0.4)
        if label is not None:
            ax.legend(loc='lower right')
        ax.autoscale(True)

        # Add small 0.4% padding on either side for x-axis so lines at x=0 or 1
        # display correctly (typically get occluded if xlim is [0, 1])
        x_lims = (min(x), max(x))
        x_lims_padding = (x_lims[1] - x_lims[0]) * 0.004
        x_lims_left = x_lims[0] - x_lims_padding
        x_lims_right = x_lims[1] + x_lims_padding
        x_lims_dict = {**{'left': x_lims_left, 'right': x_lims_right}, **xlim_args}
        ax.set_xlim(**x_lims_dict)

        ax.set_ylim(bottom=0, top=1.005)
        if title is not None:
            ax.set_title(title)
        return ax

    def plot_roc(self, ax=None, title='', xlabel='$P_{Fa}$', ylabel='$P_D$', label=None):
        return self._plot_xy(self.pf, self.pd, ax=ax, title=title, xlabel=xlabel,
                             ylabel=ylabel, label=label, xlim_args={'right': 1})

    def plot_far(self, ax=None, title='', xlabel='$FAR$', ylabel='$P_D$', label=None):
        if self.far is None:
            raise AttributeError(
                'FAR is `None`. Ensure that `farDenominator` has been set correctly')
        return self._plot_xy(self.far, self.pd, ax=ax, title=title, xlabel=xlabel,
                             ylabel=ylabel, label=label)

    def plot_prec_recall(self, ax=None, title='', xlabel='$Recall$',
                         ylabel='$Precision$', label=None):
        return self._plot_xy(self.recall, self.precision, ax=ax, title=title,
                             xlabel=xlabel, ylabel=ylabel, label=label,
                             xlim_args={'right': 1})
