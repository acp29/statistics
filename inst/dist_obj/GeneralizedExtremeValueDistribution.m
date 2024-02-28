## Copyright (C) 2024 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of the statistics package for GNU Octave.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

classdef GeneralizedExtremeValueDistribution
  ## -*- texinfo -*-
  ## @deftypefn {statistics} GeneralizedExtremeValueDistribution
  ##
  ## Generalized extreme value probability distribution object.
  ##
  ## A @code{GeneralizedExtremeValueDistribution} object consists of parameters,
  ## a model description, and sample data for a generalized extreme value
  ## probability distribution.
  ##
  ## The generalized extreme value distribution uses the following parameters.
  ##
  ## @multitable @columnfractions 0.25 0.48 0.27
  ## @headitem @var{Parameter} @tab @var{Description} @tab @var{Support}
  ##
  ## @item @qcode{k} @tab Shape @tab @math{-Inf < k < Inf}
  ## @item @qcode{sigma} @tab Scale @tab @math{sigma > 0}
  ## @item @qcode{mu} @tab Location @tab @math{-Inf < mu < Inf}
  ## @end multitable
  ##
  ## There are several ways to create a @code{GeneralizedExtremeValueDistribution}
  ## object.
  ##
  ## @itemize
  ## @item Fit a distribution to data using the @code{fitdist} function.
  ## @item Create a distribution with specified parameter values using the
  ## @code{makedist} function.
  ## @item Use the constructor @qcode{GeneralizedExtremeValueDistribution
  ## (@var{k}, @var{sigma})} to create a generalized extreme value distribution
  ## with specified parameter values.
  ## @item Use the static method @qcode{GeneralizedExtremeValueDistribution.fit
  ## (@var{x}, @var{k}, @var{freq})} to a distribution to data @var{x}.
  ## @end itemize
  ##
  ## It is highly recommended to use @code{fitdist} and @code{makedist}
  ## functions to create probability distribution objects, instead of the
  ## constructor and the aforementioned static method.
  ##
  ## A @code{GeneralizedExtremeValueDistribution} object contains the following
  ## properties, which can be accessed using dot notation.
  ##
  ## @multitable @columnfractions 0.25 0.25 0.25 0.25
  ## @item @qcode{DistributionName} @tab @qcode{DistributionCode} @tab
  ## @qcode{NumParameters} @tab @qcode{ParameterNames}
  ## @item @qcode{ParameterDescription} @tab @qcode{ParameterValues} @tab
  ## @qcode{ParameterValues} @tab @qcode{ParameterCI}
  ## @item @qcode{ParameterIsFixed} @tab @qcode{Truncation} @tab
  ## @qcode{IsTruncated} @tab @qcode{InputData}
  ## @end multitable
  ##
  ## A @code{GeneralizedExtremeValueDistribution} object contains the following
  ## methods:
  ## @code{cdf}, @code{icdf}, @code{iqr}, @code{mean}, @code{median},
  ## @code{negloglik}, @code{paramci}, @code{pdf}, @code{plot}, @code{proflik},
  ## @code{random}, @code{std}, @code{truncate}, @code{var}.
  ##
  ## Further information about the generalized extreme value distribution can be
  ## found at
  ## @url{https://en.wikipedia.org/wiki/Generalized_extreme_value_distribution}
  ##
  ## @seealso{fitdist, makedist, gevcdf, gevinv, gevpdf, gevrnd, gevfit,
  ## gevlike, gevstat}
  ## @end deftypefn

  properties (Dependent = true)
    k
    sigma
    mu
  endproperties

  properties (GetAccess = public, Constant = true)
    CensoringAllowed = false;
    DistributionName = "GeneralizedExtremeValueDistribution";
    DistributionCode = "gev";
    NumParameters = 3;
    ParameterNames = {"k", "sigma", "mu"};
    ParameterDescription = {"Shape", "Scale", "Location"};
  endproperties

  properties (GetAccess = public, Constant = true)
    ParameterRange = [-Inf, realmin, -Inf; Inf, Inf, Inf];
    ParameterLogCI = [false, true, false];
  endproperties

  properties (GetAccess = public , SetAccess = protected)
    ParameterValues
    ParameterCI
    ParameterCovariance
    ParameterIsFixed
    Truncation
    IsTruncated
    InputData
  endproperties

  methods (Hidden)

    function this = GeneralizedExtremeValueDistribution (k, sigma, mu)
      if (nargin == 0)
        k = 0;
        sigma = 1;
        mu = 0;
      endif
      checkparams (k, sigma, mu);
      this.InputData = [];
      this.IsTruncated = false;
      this.ParameterValues = [k, sigma, mu];
      this.ParameterIsFixed = [true, true, true];
      this.ParameterCovariance = zeros (this.NumParameters);
    endfunction

    function display (this)
      fprintf ("%s =\n", inputname(1));
      __disp__ (this, "normal distribution");
    endfunction

    function disp (this)
      __disp__ (this, "normal distribution");
    endfunction

    function this = set.k (this, k)
      checkparams (k, this.sigma, this.mu);
      this.InputData = [];
      this.ParameterValues(1) = k;
      this.ParameterIsFixed = [true, true, true];
      this.ParameterCovariance = zeros (this.NumParameters);
    endfunction

    function k = get.k (this)
      k = this.ParameterValues(1);
    endfunction

    function this = set.sigma (this, sigma)
      checkparams (this.k, sigma, this.mu);
      this.InputData = [];
      this.ParameterValues(2) = sigma;
      this.ParameterIsFixed = [true, true, true];
      this.ParameterCovariance = zeros (this.NumParameters);
    endfunction

    function sigma = get.sigma (this)
      sigma = this.ParameterValues(2);
    endfunction

    function this = set.mu (this, mu)
      checkparams (this.k, this.sigma, mu);
      this.InputData = [];
      this.ParameterValues(3) = mu;
      this.ParameterIsFixed = [true, true, true];
      this.ParameterCovariance = zeros (this.NumParameters);
    endfunction

    function mu = get.mu (this)
      mu = this.ParameterValues(3);
    endfunction

  endmethods

  methods (Access = public)

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{p} =} cdf (@var{pd}, @var{x})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {@var{p} =} cdf (@var{pd}, @var{x}, @qcode{"upper"})
    ##
    ## Compute the cumulative distribution function (CDF).
    ##
    ## @code{@var{p} = cdf (@var{pd}, @var{x})} computes the CDF of the
    ## probability distribution object, @var{pd}, evaluated at the values in
    ## @var{x}.
    ##
    ## @code{@var{p} = cdf (@dots{}, @qcode{"upper"})} returns the complement of
    ## the CDF of the probability distribution object, @var{pd}, evaluated at
    ## the values in @var{x}.
    ##
    ## @end deftypefn
    function p = cdf (this, x, uflag)
      if (! isscalar (this))
        error ("cdf: requires a scalar probability distribution.");
      endif
      ## Check for "upper" flag
      if (nargin > 2 && strcmpi (uflag, "upper"))
        utail = true;
      elseif (nargin > 2 && ! strcmpi (uflag, "upper"))
        error ("cdf: invalid argument for upper tail.");
      else
        utail = false;
      endif
      ## Do the computations
      p = gevcdf (x, this.k, this.sigma, this.mu);
      if (this.IsTruncated)
        lx = this.Truncation(1);
        lb = x < lx;
        ux = this.Truncation(2);
        ub = x > ux;
        p(lb) = 0;
        p(ub) = 1;
        p(! (lb | ub)) -= gevcdf (lx, this.k, this.sigma, this.mu);
        p(! (lb | ub)) /= diff (gevcdf ([lx, ux], this.k, this.sigma, this.mu));
      endif
      ## Apply uflag
      if (utail)
        p = 1 - p;
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{p} =} icdf (@var{pd}, @var{p})
    ##
    ## Compute the cumulative distribution function (CDF).
    ##
    ## @code{@var{p} = icdf (@var{pd}, @var{x})} computes the quantile (the
    ## inverse of the CDF) of the probability distribution object, @var{pd},
    ## evaluated at the values in @var{x}.
    ##
    ## @end deftypefn
    function x = icdf (this, p)
      if (! isscalar (this))
        error ("icdf: requires a scalar probability distribution.");
      endif
      if (this.IsTruncated)
        lp = gevcdf (this.Truncation(1), this.k, this.sigma, this.mu);
        up = gevcdf (this.Truncation(2), this.k, this.sigma, this.mu);
        ## Adjust p values within range of p @ lower limit and p @ upper limit
        is_nan = p < 0 | p > 1;
        p(is_nan) = NaN;
        np = lp + (up - lp) .* p;
        x = gevinv (np, this.k, this.sigma, this.mu);
        x(x < this.Truncation(1)) = this.Truncation(1);
        x(x > this.Truncation(2)) = this.Truncation(2);
      else
        x = gevinv (p, this.k, this.sigma, this.mu);
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{r} =} iqr (@var{pd})
    ##
    ## Compute the interquartile range of a probability distribution.
    ##
    ## @code{@var{r} = iqr (@var{pd})} computes the interquartile range of the
    ## probability distribution object, @var{pd}.
    ##
    ## @end deftypefn
    function r = iqr (this)
      if (! isscalar (this))
        error ("iqr: requires a scalar probability distribution.");
      endif
        r = diff (icdf (this, [0.25, 0.75]));
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{m} =} mean (@var{pd})
    ##
    ## Compute the mean of a probability distribution.
    ##
    ## @code{@var{m} = mean (@var{pd})} computes the mean of the probability
    ## distribution object, @var{pd}.
    ##
    ## @end deftypefn
    function m = mean (this)
      if (! isscalar (this))
        error ("mean: requires a scalar probability distribution.");
      endif
      if (this.IsTruncated)
        fm = @(x) x .* pdf (this, x);
        m = integral (fm, this.Truncation(1), this.Truncation(2));
      else
        m = gevstat (this.k, this.sigma, this.mu);
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{m} =} median (@var{pd})
    ##
    ## Compute the median of a probability distribution.
    ##
    ## @code{@var{m} = median (@var{pd})} computes the median of the probability
    ## distribution object, @var{pd}.
    ##
    ## @end deftypefn
    function m = median (this)
      if (! isscalar (this))
        error ("median: requires a scalar probability distribution.");
      endif
      if (this.IsTruncated)
        lx = this.Truncation(1);
        ux = this.Truncation(2);
        Fa_b = gevcdf ([lx, ux], this.k, this.sigma, this.mu);
        m = gevinv (sum (Fa_b) / 2, this.k, this.sigma, this.mu);
      else
        m = gevinv (0.5, this.k, this.sigma, this.mu);
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{nlogL} =} negloglik (@var{pd})
    ##
    ## Compute the negative loglikelihood of a probability distribution.
    ##
    ## @code{@var{m} = negloglik (@var{pd})} computes the negative loglikelihood
    ## of the probability distribution object, @var{pd}.
    ##
    ## @end deftypefn
    function nlogL = negloglik (this)
      if (! isscalar (this))
        error ("negloglik: requires a scalar probability distribution.");
      endif
      if (isempty (this.InputData))
        nlogL = [];
        return
      endif
      nlogL = - gevlike ([this.k, this.sigma, this.mu], ...
                         this.InputData.data, this.InputData.freq);
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{ci} =} paramci (@var{pd})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {@var{ci} =} paramci (@var{pd}, @var{Name}, @var{Value})
    ##
    ## Compute the confidence intervals for probability distribution parameters.
    ##
    ## @code{@var{ci} = paramci (@var{pd})} computes the lower and upper
    ## boundaries of the 95% confidence interval for each parameter of the
    ## probability distribution object, @var{pd}.
    ##
    ## @code{@var{ci} = paramci (@var{pd}, @var{Name}, @var{Value})} computes the
    ## confidence intervals with additional options specified specified by
    ## @qcode{Name-Value} pair arguments listed below.
    ##
    ## @multitable @columnfractions 0.18 0.02 0.8
    ## @headitem @var{Name} @tab @tab @var{Value}
    ##
    ## @item @qcode{"Alpha"} @tab @tab A scalar value in the range @math{(0,1)}
    ## specifying the significance level for the confidence interval.  The
    ## default value 0.05 corresponds to a 95% confidence interval.
    ##
    ## @item @qcode{"Parameter"} @tab @tab A character vector or a cell array of
    ## character vectors specifying the parameter names for which to compute
    ## confidence intervals.  By default, @code{paramci} computes confidence
    ## intervals for all distribution parameters.
    ## @end multitable
    ##
    ## @code{paramci} is meaningful only when @var{pd} is fitted to data,
    ## otherwise an empty array, @qcode{[]}, is returned.
    ##
    ## @end deftypefn
    function ci = paramci (this, varargin)
      if (! isscalar (this))
        error ("paramci: requires a scalar probability distribution.");
      endif
      if (isempty (this.InputData))
        ci = [this.ParameterValues; this.ParameterValues];
      else
        ci = __paramci__ (this, varargin{:});
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{y} =} pdf (@var{pd}, @var{x})
    ##
    ## Compute the probability distribution function (PDF).
    ##
    ## @code{@var{y} = pdf (@var{pd}, @var{x})} computes the PDF of the
    ## probability distribution object, @var{pd}, evaluated at the values in
    ## @var{x}.
    ##
    ## @end deftypefn
    function y = pdf (this, x)
      if (! isscalar (this))
        error ("pdf: requires a scalar probability distribution.");
      endif
      y = gevpdf (x, this.k, this.sigma, this.mu);
      if (this.IsTruncated)
        lx = this.Truncation(1);
        lb = x < lx;
        ux = this.Truncation(2);
        ub = x > ux;
        y(lb | ub) = 0;
        y(! (lb | ub)) /= diff (gevcdf ([lx, ux], this.k, this.sigma, this.mu));
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {} plot (@var{pd})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {} plot (@var{pd}, @var{Name}, @var{Value})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {@var{h} =} plot (@dots{})
    ##
    ## Plot a probability distribution object.
    ##
    ## @code{plot (@var{pd}} plots a probability density function (PDF) of the
    ## probability distribution object @var{pd}.  If @var{pd} contains data,
    ## which have been fitted by @code{fitdist}, the PDF is superimposed over a
    ## histogram of the data.
    ##
    ## @code{plot (@var{pd}, @var{Name}, @var{Value})} specifies additional
    ## options with the @qcode{Name-Value} pair arguments listed below.
    ##
    ## @multitable @columnfractions 0.18 0.02 0.8
    ## @headitem @tab @var{Name} @tab @var{Value}
    ##
    ## @item @qcode{"PlotType"} @tab @tab A character vector specifying the plot
    ## type.  @qcode{"pdf"} plots the probability density function (PDF).  When
    ## @var{pd} is fit to data, the PDF is superimposed on a histogram of the
    ## data.  @qcode{"cdf"} plots the cumulative density function (CDF).  When
    ## @var{pd} is fit to data, the CDF is superimposed over an empirical CDF.
    ## @qcode{"probability"} plots a probability plot using a CDF of the data
    ## and a CDF of the fitted probability distribution.  This option is
    ## available only when @var{pd} is fitted to data.
    ##
    ## @item @qcode{"Discrete"} @tab @tab A logical scalar to specify whether to
    ## plot the PDF or CDF of a discrete distribution object as a line plot or a
    ## stem plot, by specifying @qcode{false} or @qcode{true}, respectively.  By
    ## default, it is @qcode{true} for discrete distributions and @qcode{false}
    ## for continuous distributions.  When @var{pd} is a continuous distribution
    ## object, option is ignored.
    ##
    ## @item @qcode{"Parent"} @tab @tab An axes graphics object for plot.  If
    ## not specified, the @code{plot} function plots into the current axes or
    ## creates a new axes object if one does not exist.
    ## @end multitable
    ##
    ## @code{@var{h} = plot (@dots{})} returns a graphics handle to the plotted
    ## objects.
    ##
    ## @end deftypefn
    function [varargout] = plot (this, varargin)
      if (! isscalar (this))
        error ("plot: requires a scalar probability distribution.");
      endif
      h = __plot__ (this, false, varargin{:});
      if (nargout > 0)
        varargout{1} = h;
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {[@var{nlogL}, @var{param}] =} proflik (@var{pd}, @var{pnum})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {[@var{nlogL}, @var{param}] =} proflik (@var{pd}, @var{pnum}, @qcode{"Display"}, @var{display})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {[@var{nlogL}, @var{param}] =} proflik (@var{pd}, @var{pnum}, @var{setparam})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {[@var{nlogL}, @var{param}] =} proflik (@var{pd}, @var{pnum}, @var{setparam}, @qcode{"Display"}, @var{display})
    ##
    ## Profile likelihood function for a probability distribution object.
    ##
    ## @code{[@var{nlogL}, @var{param}] = proflik (@var{pd}, @var{pnum})}
    ## returns a vector @var{nlogL} of negative loglikelihood values and a
    ## vector @var{param} of corresponding parameter values for the parameter in
    ## the position indicated by @var{pnum}.  By default, @code{proflik} uses
    ## the lower and upper bounds of the 95% confidence interval and computes
    ## 100 equispaced values for the selected parameter.  @var{pd} must be
    ## fitted to data.
    ##
    ## @code{[@var{nlogL}, @var{param}] = proflik (@var{pd}, @var{pnum},
    ## @qcode{"Display"}, @qcode{"on"})} also plots the profile likelihood
    ## against the default range of the selected parameter.
    ##
    ## @code{[@var{nlogL}, @var{param}] = proflik (@var{pd}, @var{pnum},
    ## @var{setparam})} defines a user-defined range of the selected parameter.
    ##
    ## @code{[@var{nlogL}, @var{param}] = proflik (@var{pd}, @var{pnum},
    ## @var{setparam}, @qcode{"Display"}, @qcode{"on"})} also plots the profile
    ## likelihood against the user-defined range of the selected parameter.
    ##
    ## For the generalized extreme value distribution, @qcode{@var{pnum} = 1}
    ## selects the parameter @qcode{k}, @qcode{@var{pnum} = 2} selects the
    ## parameter @var{sigma}, and @qcode{@var{pnum} = 3} selects the parameter
    ## @var{mu}.
    ##
    ## When opted to display the profile likelihood plot, @code{proflik} also
    ## plots the baseline loglikelihood computed at the lower bound of the 95%
    ## confidence interval and estimated maximum likelihood.  The latter might
    ## not be observable if it is outside of the used-defined range of parameter
    ## values.
    ##
    ## @end deftypefn
    function [varargout] = proflik (this, pnum, varargin)
      if (! isscalar (this))
        error ("proflik: requires a scalar probability distribution.");
      endif
      if (isempty (this.InputData))
        error ("proflik: no fitted data available.");
      endif
      [varargout{1:nargout}] = __proflik__ (this, pnum, varargin{:});
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{y} =} random (@var{pd})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {@var{y} =} random (@var{pd}, @var{rows})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {@var{y} =} random (@var{pd}, @var{rows}, @var{cols}, @dots{})
    ## @deftypefnx {GeneralizedExtremeValueDistribution} {@var{y} =} random (@var{pd}, [@var{sz}])
    ##
    ## Generate random arrays from the probability distribution object.
    ##
    ## @code{@var{r} = random (@var{pd})} returns a random number from the
    ## distribution object @var{pd}.
    ##
    ## When called with a single size argument, @code{betarnd} returns a square
    ## matrix with the dimension specified.  When called with more than one
    ## scalar argument, the first two arguments are taken as the number of rows
    ## and columns and any further arguments specify additional matrix
    ## dimensions.  The size may also be specified with a row vector of
    ## dimensions, @var{sz}.
    ##
    ## @end deftypefn
    function r = random (this, varargin)
      if (! isscalar (this))
        error ("random: requires a scalar probability distribution.");
      endif
      if (this.IsTruncated)
        sz = [varargin{:}];
        ps = prod (sz);
        ## Get an estimate of how many more random numbers we need to randomly
        ## pick the appropriate size from
        lx = this.Truncation(1);
        ux = this.Truncation(2);
        ratio = 1 / diff (gevcdf ([lx, ux], this.k, this.sigma, this.mu));
        nsize = fix (2 * ratio * ps);       # times 2 to be on the safe side
        ## Generate the numbers and remove out-of-bound random samples
        r = gevrnd (this.k, this.sigma, this.mu, nsize, 1);
        r(r < lx | r > ux) = [];
        ## Randomly select the required size and reshape to requested dimensions
        idx = randperm (numel (r), ps);
        r = reshape (r(idx), sz);
      else
        r = gevrnd (this.k, this.sigma, this.mu, varargin{:});
      endif
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{s} =} std (@var{pd})
    ##
    ## Compute the standard deviation of a probability distribution.
    ##
    ## @code{@var{s} = std (@var{pd})} computes the standard deviation of the
    ## probability distribution object, @var{pd}.
    ##
    ## @end deftypefn
    function s = std (this)
      if (! isscalar (this))
        error ("std: requires a scalar probability distribution.");
      endif
      v = var (this);
      s = sqrt (v);
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{t} =} truncate (@var{pd}, @var{lower}, @var{upper})
    ##
    ## Truncate a probability distribution.
    ##
    ## @code{@var{t} = truncate (@var{pd})} returns a probability distribution
    ## @var{t}, which is the probability distribution @var{pd} truncated to the
    ## specified interval with lower limit, @var{lower}, and upper limit,
    ## @var{upper}.  If @var{pd} is fitted to data with @code{fitdist}, the
    ## returned probability distribution @var{t} is not fitted, does not contain
    ## any data or estimated values, and it is as it has been created with the
    ## @var{makedist} function, but it includes the truncation interval.
    ##
    ## @end deftypefn
    function this = truncate (this, lower, upper)
      if (! isscalar (this))
        error ("truncate: requires a scalar probability distribution.");
      endif
      if (nargin < 3)
        error ("truncate: missing input argument.");
      elseif (lower >= upper)
        error ("truncate: invalid lower upper limits.");
      endif
      this.Truncation = [lower, upper];
      this.IsTruncated = true;
      this.InputData = [];
      this.ParameterIsFixed = [true, true, true];
      this.ParameterCovariance = zeros (this.NumParameters);
    endfunction

    ## -*- texinfo -*-
    ## @deftypefn  {GeneralizedExtremeValueDistribution} {@var{v} =} var (@var{pd})
    ##
    ## Compute the variance of a probability distribution.
    ##
    ## @code{@var{v} = var (@var{pd})} computes the standard deviation of the
    ## probability distribution object, @var{pd}.
    ##
    ## @end deftypefn
    function v = var (this)
      if (! isscalar (this))
        error ("var: requires a scalar probability distribution.");
      endif
      if (this.IsTruncated)
        fm = @(x) x .* pdf (this, x);
        m = integral (fm, this.Truncation(1), this.Truncation(2));
        fv =  @(x) ((x - m) .^ 2) .* pdf (this, x);
        v = integral (fv, this.Truncation(1), this.Truncation(2));
      else
        [~, v] = gevstat (this.k, this.sigma, this.mu);
      endif
    endfunction

  endmethods

  methods (Static, Hidden)

    function pd = fit (x, varargin)
      ## Check input arguments
      if (nargin < 2)
        alpha = 0.05;
      else
        alpha = varargin{1};
      endif
      if (nargin < 3)
        freq = [];
      else
        freq = varargin{2};
      endif
      if (nargin < 4)
        options.Display = "off";
        options.MaxFunEvals = 400;
        options.MaxIter = 200;
        options.TolX = 1e-6;
      else
        options = varargin{3};
      endif
      ## Fit data
      [phat, pci] = gevfit (x, alpha, freq, options);
      [~, acov] = gevlike (phat, x, freq);
      ## Create fitted distribution object
      pd = GeneralizedExtremeValueDistribution.makeFitted ...
           (phat, pci, acov, x, freq);
    endfunction

    function pd = makeFitted (phat, pci, acov, x, freq)
      k = phat(1);
      sigma = phat(2);
      mu = phat(3);
      pd = GeneralizedExtremeValueDistribution (k, sigma, mu);
      pd.ParameterCI = pci;
      pd.ParameterIsFixed = [false, false, false];
      pd.ParameterCovariance = acov;
      pd.InputData = struct ("data", x, "cens", [], "freq", freq);
    endfunction

  endmethods

endclassdef

function checkparams (k, sigma, mu)
  if (! (isscalar (k) && isnumeric (k) && isreal (k) && isfinite (k)))
    error ("GeneralizedExtremeValueDistribution: MU must be a real scalar.")
  endif
  if (! (isscalar (sigma) && isnumeric (sigma) && isreal (sigma)
                          && isfinite (sigma) && sigma > 0))
    error (strcat (["GeneralizedExtremeValueDistribution: SIGMA must be"], ...
                   [" a positive real scalar."]))
  endif
  if (! (isscalar (mu) && isnumeric (mu) && isreal (mu)
                          && isfinite (mu)))
    error ("GeneralizedExtremeValueDistribution: MU must be a real scalar.")
  endif
endfunction

## Test output
%!shared pd, t
%! pd = GeneralizedExtremeValueDistribution;
%! t = truncate (pd, 2, 4);
%!assert (cdf (pd, [0:5]), [0.3679, 0.6922, 0.8734, 0.9514, 0.9819, 0.9933], 1e-4);
%!assert (cdf (t, [0:5]), [0, 0, 0, 0.7195, 1, 1], 1e-4);
%!assert (cdf (pd, [1.5, 2, 3, 4]), [0.8, 0.8734, 0.9514, 0.9819], 1e-4);
%!assert (cdf (t, [1.5, 2, 3, 4]), [0, 0, 0.7195, 1], 1e-4);
%!assert (icdf (pd, [0:0.2:1]), [-Inf, -0.4759, 0.0874, 0.6717, 1.4999, Inf], 1e-4);
%!assert (icdf (t, [0:0.2:1]), [2, 2.1999, 2.4433, 2.7568, 3.2028, 4], 1e-4);
%!assert (icdf (pd, [-1, 0.4:0.2:1, NaN]), [NaN, 0.0874, 0.6717, 1.4999, Inf, NaN], 1e-4);
%!assert (icdf (t, [-1, 0.4:0.2:1, NaN]), [NaN, 2.4433, 2.7568, 3.2028, 4, NaN], 1e-4);
%!assert (iqr (pd), 1.5725, 1e-4);
%!assert (iqr (t), 0.8164, 1e-4);
%!assert (mean (pd), 0.5772, 1e-4);
%!assert (mean (t), 2.7043, 1e-4);
%!assert (median (pd), 0.3665, 1e-4);
%!assert (median (t), 2.5887, 1e-4);
%!assert (pdf (pd, [0:5]), [0.3679, 0.2546, 0.1182, 0.0474, 0.0180, 0.0067], 1e-4);
%!assert (pdf (t, [0:5]), [0, 0, 1.0902, 0.4369, 0.1659, 0], 1e-4);
%!assert (pdf (pd, [-1, 1:4, NaN]), [0.1794, 0.2546, 0.1182, 0.0474, 0.0180, NaN], 1e-4);
%!assert (pdf (t, [-1, 1:4, NaN]), [0, 0, 1.0902, 0.4369, 0.1659, NaN], 1e-4);
%!assert (isequal (size (random (pd, 100, 50)), [100, 50]))
%!assert (any (random (t, 1000, 1) < 2), false);
%!assert (any (random (t, 1000, 1) > 4), false);
%!assert (std (pd), 1.2825, 1e-4);
%!assert (std (t), 0.5289, 1e-4);
%!assert (var (pd), 1.6449, 1e-4);
%!assert (var (t), 0.2798, 1e-4);

## Test input validation
## 'GeneralizedExtremeValueDistribution' constructor
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(Inf, 1, 1)
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(i, 1, 1)
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution("a", 1, 1)
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution([1, 2], 1, 1)
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(NaN, 1, 1)
%!error <GeneralizedExtremeValueDistribution: SIGMA must be a positive real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, 0, 1)
%!error <GeneralizedExtremeValueDistribution: SIGMA must be a positive real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, -1, 1)
%!error <GeneralizedExtremeValueDistribution: SIGMA must be a positive real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, Inf, 1)
%!error <GeneralizedExtremeValueDistribution: SIGMA must be a positive real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, i, 1)
%!error <GeneralizedExtremeValueDistribution: SIGMA must be a positive real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, "a", 1)
%!error <GeneralizedExtremeValueDistribution: SIGMA must be a positive real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, [1, 2], 1)
%!error <GeneralizedExtremeValueDistribution: SIGMA must be a positive real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, NaN, 1)
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, 1, Inf)
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, 1, i)
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, 1, "a")
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, 1, [1, 2])
%!error <GeneralizedExtremeValueDistribution: MU must be a real scalar.> ...
%! GeneralizedExtremeValueDistribution(1, 1, NaN)

## 'cdf' method
%!error <cdf: invalid argument for upper tail.> ...
%! cdf (GeneralizedExtremeValueDistribution, 2, "uper")
%!error <cdf: invalid argument for upper tail.> ...
%! cdf (GeneralizedExtremeValueDistribution, 2, 3)

## 'paramci' method
%!shared x
%! x = gevrnd (1, 1, 1, [1, 100]);
%!error <paramci: optional arguments must be in NAME-VALUE pairs.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha")
%!error <paramci: invalid VALUE for 'Alpha' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", 0)
%!error <paramci: invalid VALUE for 'Alpha' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", 1)
%!error <paramci: invalid VALUE for 'Alpha' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", [0.5 2])
%!error <paramci: invalid VALUE for 'Alpha' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", "")
%!error <paramci: invalid VALUE for 'Alpha' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", {0.05})
%!error <paramci: invalid VALUE for 'Alpha' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), ...
%!          "parameter", "sigma", "alpha", {0.05})
%!error <paramci: invalid VALUE size for 'Parameter' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), ...
%!          "parameter", {"k", "sigma", "mu", "param"})
%!error <paramci: invalid VALUE size for 'Parameter' argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", 0.01, ...
%!          "parameter", {"k", "sigma", "mu", "param"})
%!error <paramci: unknown distribution parameter.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "parameter", "param")
%!error <paramci: unknown distribution parameter.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", 0.01, ...
%!          "parameter", "param")
%!error <paramci: invalid NAME for optional argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "NAME", "value")
%!error <paramci: invalid NAME for optional argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", 0.01, ...
%!          "NAME", "value")
%!error <paramci: invalid NAME for optional argument.> ...
%! paramci (GeneralizedExtremeValueDistribution.fit (x), "alpha", 0.01, ...
%!          "parameter", "sigma", "NAME", "value")

## 'plot' method
%!error <plot: optional arguments must be in NAME-VALUE pairs.> ...
%! plot (GeneralizedExtremeValueDistribution, "Parent")
%!error <plot: invalid VALUE for 'PlotType' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "PlotType", 12)
%!error <plot: invalid VALUE size for 'Parameter' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "PlotType", {"pdf", "cdf"})
%!error <plot: invalid VALUE for 'PlotType' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "PlotType", "pdfcdf")
%!error <plot: invalid VALUE for 'Discrete' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "Discrete", "pdfcdf")
%!error <plot: invalid VALUE for 'Discrete' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "Discrete", [1, 0])
%!error <plot: invalid VALUE for 'Discrete' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "Discrete", {true})
%!error <plot: invalid VALUE for 'Parent' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "Parent", 12)
%!error <plot: invalid VALUE for 'Parent' argument.> ...
%! plot (GeneralizedExtremeValueDistribution, "Parent", "hax")

## 'proflik' method
%!error <proflik: no fitted data available.> ...
%! proflik (GeneralizedExtremeValueDistribution, 2)
%!error <proflik: PNUM must be a scalar number indexing a non-fixed parameter.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 4)
%!error <proflik: PNUM must be a scalar number indexing a non-fixed parameter.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), [1, 2])
%!error <proflik: PNUM must be a scalar number indexing a non-fixed parameter.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), {1})
%!error <proflik: SETPARAM must be a numeric vector.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, ones (2))
%!error <proflik: missing VALUE for 'Display' argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, "Display")
%!error <proflik: invalid VALUE type for 'Display' argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, "Display", 1)
%!error <proflik: invalid VALUE type for 'Display' argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, "Display", {1})
%!error <proflik: invalid VALUE type for 'Display' argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, "Display", {"on"})
%!error <proflik: invalid VALUE size for 'Display' argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, ...
%!          "Display", ["on"; "on"])
%!error <proflik: invalid VALUE for 'Display' argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, "Display", "onnn")
%!error <proflik: invalid NAME for optional arguments.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, "NAME", "on")
%!error <proflik: invalid optional argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, {"NAME"}, "on")
%!error <proflik: invalid optional argument.> ...
%! proflik (GeneralizedExtremeValueDistribution.fit (x), 1, {[1 2 3 4]}, ...
%!          "Display", "on")

## 'truncate' method
%!error <truncate: missing input argument.> ...
%! truncate (GeneralizedExtremeValueDistribution)
%!error <truncate: missing input argument.> ...
%! truncate (GeneralizedExtremeValueDistribution, 2)
%!error <truncate: invalid lower upper limits.> ...
%! truncate (GeneralizedExtremeValueDistribution, 4, 2)

## Catch errors when using array of probability objects with available methods
%!shared pd
%! pd = GeneralizedExtremeValueDistribution(1, 1, 1);
%! pd(2) = GeneralizedExtremeValueDistribution(1, 3, 1);
%!error <cdf: requires a scalar probability distribution.> cdf (pd, 1)
%!error <icdf: requires a scalar probability distribution.> icdf (pd, 0.5)
%!error <iqr: requires a scalar probability distribution.> iqr (pd)
%!error <mean: requires a scalar probability distribution.> mean (pd)
%!error <median: requires a scalar probability distribution.> median (pd)
%!error <negloglik: requires a scalar probability distribution.> negloglik (pd)
%!error <paramci: requires a scalar probability distribution.> paramci (pd)
%!error <pdf: requires a scalar probability distribution.> pdf (pd, 1)
%!error <plot: requires a scalar probability distribution.> plot (pd)
%!error <proflik: requires a scalar probability distribution.> proflik (pd, 2)
%!error <random: requires a scalar probability distribution.> random (pd)
%!error <std: requires a scalar probability distribution.> std (pd)
%!error <truncate: requires a scalar probability distribution.> ...
%! truncate (pd, 2, 4)
%!error <var: requires a scalar probability distribution.> var (pd)
